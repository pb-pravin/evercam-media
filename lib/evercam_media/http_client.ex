defmodule EvercamMedia.HTTPClient do
  alias EvercamMedia.HTTPClient.DigestAuth

  def get(url) do
    HTTPotion.get url
  end

  def get(url, ":") do
    get(url)
  end

  def get(:basic_auth, url, username, password) do
    HTTPotion.get url, [basic_auth: {username, password}]
  end

  def get(:digest_auth, url, username, password) do
    response = get(url)
    get(:digest_auth, response, url, username, password)
  end

  def get(:cookie_auth, snapshot_url, username, password) do
    u = URI.parse(snapshot_url)
    login_url = u.scheme <> "://" <> u.authority <> "/login.cgi"
    cookie = get_cookie(login_url, username, password)
    HTTPotion.get snapshot_url, [headers: ["Cookie": cookie]]
  end

  def get(:digest_auth, response, url, username, password) do
    digest_token =  DigestAuth.get_digest_token(response, url, username, password)
    HTTPotion.get url, headers: ["Authorization": "Digest #{digest_token}"]
  end

  defp get_cookie(url, username, password) do
    request = HTTPotion.get url
    cookie = parse_cookie_header(request)
    HTTPotion.post url, [body: multipart_text(username, password), headers: ["Content-Type": "multipart/form-data; boundary=----WebKitFormBoundaryEq1VsbBovj79sSoL", "Cookie": cookie]]
    cookie
  end

  defp parse_cookie_header(request) do
    session_header = Dict.get(request.headers, :"Set-Cookie")
    session_string =
      case session_header do
        [hd|tl] -> session_header |> Enum.join(",")
        _ ->  session_header
      end

    cookie = Regex.run(~r/(AIROS_SESSIONID=[a-z0-9]+)/, session_string) |> hd
  end

  defp multipart_text(username, password) do
    "------WebKitFormBoundaryEq1VsbBovj79sSoL\r\nContent-Disposition: form-data;name=\"uri\"\r\n\r\n\r\n------WebKitFormBoundaryEq1VsbBovj79sSoL\r\nContent-Disposition:form-data; name=\"username\"\r\n\r\n#{username}\r\n------WebKitFormBoundaryEq1VsbBovj79sSoL\r\nContent-Disposition: form-data; name=\"password\"\r\n\r\n#{password}\r\n------WebKitFormBoundaryEq1VsbBovj79sSoL\r\nContent-Disposition: form-data; name=\"Submit\"\r\n\r\nLogin\r\n------WebKitFormBoundaryEq1VsbBovj79sSoL\r\n"
  end
end


defmodule EvercamMedia.HTTPClient.DigestAuth do
  def get_digest_token(response, url, username, password) do
    digest_head = parse_digest_header(response.headers |> Dict.get(:"WWW-Authenticate"))
    %{"realm" => realm, "nonce"  => nonce} = digest_head
    cnonce = :crypto.strong_rand_bytes(16) |> md5
    url = URI.parse(url)
    response = create_digest_response(
      username,
      password,
      realm,
      digest_head |> Map.get("qop"),
      url.path,
      nonce,
      cnonce
    )
    [{"username", username},
     {"realm", realm},
     {"nonce", nonce},
     {"uri", url.path},
     {"cnonce", cnonce},
     {"response", response}]
    |> add_opaque(digest_head |> Map.get("opaque"))
    |> Enum.map(fn {key, val} -> {key, "\"#{val}\""} end)
    |> add_nonce_counter
    |> add_auth(digest_head |> Map.get("qop"))
    |> Enum.map(fn {key, val} -> "#{key}=#{val}" end)
    |> Enum.join(", ")
  end

  defp parse_digest_header(auth_head) do
    cond do
      parsed = Regex.scan(~r/(\w+\s*)=\"([\w=\s\\]+)/, auth_head) -> parsed
      |> Enum.map(fn [_, key, val] -> {key, val} end)
      |> Enum.into(%{})
      true -> raise "Error in digest authentication header: #{auth_head}"
    end
  end

  defp create_digest_response(username, password, realm, qop, uri, nonce, cnonce) do
    ha1 = [username, realm, password] |> Enum.join(":") |> md5
    ha2 = ["GET", uri] |> Enum.join(":") |> md5
    create_digest_response(ha1, ha2, qop, nonce, cnonce)
  end

  defp create_digest_response(ha1, ha2, nil, nonce, _cnonce),
  do: [ha1, nonce, ha2] |> Enum.join(":") |> md5

  defp create_digest_response(ha1, ha2, _qop, nonce, cnonce) do
    [ha1, nonce, "00000001", cnonce, "auth", ha2] |> Enum.join(":") |> md5
  end

  defp add_opaque(digest, nil), do: digest
  defp add_opaque(digest, opaque), do: [{"opaque", opaque} | digest]

  defp add_nonce_counter(digest), do: [{"nc", "00000001"} | digest]

  defp add_auth(digest, nil) do
    digest
  end

  defp add_auth(digest, cop) do
    cond do
      cop |> String.contains?("auth") -> [{"qop", "\"auth\""} | digest]
      true -> digest
    end
  end

  defp md5(data) do
    Base.encode16(:erlang.md5(data), case: :lower)
  end
end
