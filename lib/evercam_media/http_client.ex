defmodule EvercamMedia.HTTPClient do
  alias EvercamMedia.HTTPClient.DigestAuth

  def get(url) do
    HTTPotion.get url
  end

  def get(url, ":") do
    get(url)
  end

  def get(url, auth) do
    [username, password] = String.split(auth, ":")
    response = get(:basic_auth, url, username, password)
    case response.status_code do
      200 ->  response
      401 ->  get(:digest_auth, response, url, username, password)
      _ -> raise "Oops! Error getting response from camera."
    end
  end

  def get(:basic_auth, url, username, password) do
    HTTPotion.get url, [:basic_auth, {username, password}]
  end

  def get(:digest_auth, url, username, password) do
    response = get(url)
    digest  = get_digest(url, username, password) # Need to implement it.
    HTTPotion.get url, headers: ["Authorization": digest]
  end

  def get(:digest_auth, response, url, username, password) do
    digest_token =  DigestAuth.get_digest_token(response, url, user, password)
    HTTPotion.get url, headers: ["Authorization": "Digest #{digest_token}"]
  end

  def get(:token_auth, url, username, password) do
    # To be implemented
    #  HTTPotion.get url, headers: ["Cookie": cookie]
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
                cnonce)
    digest =
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
      parsed = Regex.scan(~r/(\w+\s*)=\"([\w=\s\\]+)/, auth_head) ->
        parsed
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
