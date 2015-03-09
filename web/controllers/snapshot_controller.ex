defmodule Media.SnapshotController do
  use Phoenix.Controller
  use Timex
  import Media.SnapshotFetch
  require Logger
  plug :action

  def show(conn, params) do
    [code, image] = snapshot(params["token"])

    conn
    |> put_status(code)
    |> put_resp_content_type("image/jpeg")
    |> text image
  end

  defp snapshot(token) do
    try do
      [url, auth, credentials, time, _] = decode_request_token(token)
      check_token_expiry(time)
      response = fetch_snapshot(url, auth)
      check_jpg(response)

      [200, response]
    rescue
      error in [FunctionClauseError] ->
        Logger.error "#{inspect(error)}"
        [401, fallback_jpg]
      error in [HTTPotion.HTTPError] ->
        Logger.error "#{inspect(error)}"
        [504, fallback_jpg]
      _error ->
        Logger.error "#{inspect(_error)}"
        [500, fallback_jpg]
    end
  end

  defp decode_request_token(token) do
    {_, encrypted_message} = Base.url_decode64(token)
    message = :crypto.block_decrypt(
      :aes_cbc256,
      System.get_env["SNAP_KEY"],
      System.get_env["SNAP_IV"],
      encrypted_message
    )
    String.split(message, "|")
  end

  defp check_token_expiry(time) do
    token_time = DateFormat.parse! time, "{ISOz}"
    token_time = Date.shift token_time, mins: 5

    if Date.now > token_time do
      raise FunctionClauseError
    end
  end

  defp check_jpg(response) do
    if String.valid?(response) do
      raise "Response isn't an image"
    end
  end
end

