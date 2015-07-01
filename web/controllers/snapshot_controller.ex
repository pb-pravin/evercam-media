defmodule EvercamMedia.SnapshotController do
  use Phoenix.Controller
  use Timex
  import EvercamMedia.Snapshot
  alias EvercamMedia.HTTPClient
  require Logger
  plug :action

  def show(conn, params) do
    [code, response] = [200, ConCache.get(:cache, params["id"])]
    unless response do
      [code, response] = snapshot(params["id"], params["token"])
    end
    show_respond(conn, code, response, params["id"])
  end

  def create(conn, params) do
    [code, response] = [200, ConCache.get(:cache, params["id"])]
    unless response do
      [code, response] = snapshot(params["id"], params["token"], params["notes"])
    end
    create_respond(conn, code, response, params, params["with_data"])
  end

  defp show_respond(conn, 200, response, _camera_id) do
    conn
    |> put_status(200)
    |> put_resp_header("content-type", "image/jpg")
    |> put_resp_header("access-control-allow-origin", "*")
    |> text response[:image]
  end

  defp show_respond(conn, code, response, _) do
    conn
    |> put_status(code)
    |> put_resp_header("access-control-allow-origin", "*")
    |> json response
  end

  defp create_respond(conn, 200, response, params, "true") do
    data = "data:image/jpeg;base64,#{Base.encode64(response[:image])}"

    conn
    |> put_status(200)
    |> put_resp_header("access-control-allow-origin", "*")
    |> json %{created_at: response[:timestamp], notes: response[:notes], data: data}
  end

  defp create_respond(conn, 200, response, params, _) do
    conn
    |> put_status(200)
    |> put_resp_header("access-control-allow-origin", "*")
    |> json %{created_at: response[:timestamp], notes: response[:notes]}
  end

  defp create_respond(conn, code, response, _, _) do
    conn
    |> put_status(code)
    |> put_resp_header("access-control-allow-origin", "*")
    |> json response
  end

  defp snapshot(camera_id, token, notes \\ "Evercam Proxy") do
    try do
      [url, auth, credentials, time, _] = decode_request_token(token)
      # check_token_expiry(time)
      response = case auth do
        ":" -> HTTPClient.get(url)
        _ -> [username, password] = String.split(auth, ":")
             response = HTTPClient.get(:basic_auth, url, username, password)
       end

      data = case response.status_code do
        200 ->  response.body
        401 ->  HTTPClient.get(:digest_auth, response, url, username, password).body
        # How to call/identify if the camera needs Cookie auth?
        _ -> raise "Oops! Error getting response from camera."
      end

      check_jpg(data)
      broadcast_snapshot(camera_id, data)
      response = store(camera_id, data, notes)

      [200, response]
    rescue
      error in [FunctionClauseError] ->
        error_handler(error)
        [401, %{message: "Unauthorized."}]
      _error in [SnapshotError] ->
        [504, %{message: "Camera didn't respond with an image."}]
      _error in [HTTPotion.HTTPError] ->
        timestamp = Ecto.DateTime.utc
        update_camera_status(camera_id, timestamp, false)
        [504, %{message: "Camera seems to be offline."}]
      _error ->
        error_handler(_error)
        [500, %{message: "Sorry, we dropped the ball."}]
    end
  end

  defp check_token_expiry(time) do
    token_time = DateFormat.parse! time, "{ISOz}"
    token_time = Date.shift token_time, mins: 5

    if Date.now > token_time do
      raise FunctionClauseError
    end
  end
end
