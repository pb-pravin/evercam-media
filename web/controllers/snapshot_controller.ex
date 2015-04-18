defmodule EvercamMedia.SnapshotController do
  use Phoenix.Controller
  use Timex
  import EvercamMedia.SnapshotFetch
  require Logger
  plug :action

  def show(conn, params) do
    [code, image] = snapshot(params["token"])
    response(conn, code, image, params["id"])
  end

  defp response(conn, 200, image, camera_id) do
    Task.async(fn -> store_image(camera_id, image) end)

    conn
    |> put_status(200)
    |> put_resp_header("Content-Type", "image/jpg")
    |> put_resp_header("access-control-allow-origin", "*")
    |> text image
  end

  defp response(conn, code, _, _) do
    conn
    |> put_status(code)
    |> put_resp_header("access-control-allow-origin", "*")
    |> text "We failed to retrieve a snapshot from the camera"
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
        error_handler(error)
        [401, fallback_jpg]
      error in [HTTPotion.HTTPError] ->
        error_handler(error)
        [504, fallback_jpg]
      _error ->
        error_handler(_error)
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
end
