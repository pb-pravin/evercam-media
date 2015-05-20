defmodule EvercamMedia.StreamController do
  use Phoenix.Controller
  use Timex
  alias EvercamMedia.Repo
  import EvercamMedia.Snapshot
  require Logger
  plug :action

  def show(conn, params) do
    conn
    |> put_status(request_stream(params["name"], params["token"]))
    |> text ""
  end

  defp request_stream(camera_id, token) do
    try do
      [username, password, rtsp_url, _] = decode_request_token(token)
      camera = Repo.one! Camera.by_exid(camera_id)
      check_auth(camera, username, password)
      start_stream(camera_id, rtsp_url, token)
      200
    rescue
      _error ->
        error_handler(_error)
        401
    end
  end

  defp check_auth(camera, username, password) do
    if camera.config["auth"]["basic"]["username"] != username ||
      camera.config["auth"]["basic"]["password"] != password do
      raise FunctionClauseError
    end
  end

  defp start_stream(camera_id, rtsp_url, token) do
    cmd = Porcelain.shell("ps -ef | grep ffmpeg | grep #{rtsp_url} | grep -v grep | awk '{print $2}'")
    pids = String.split cmd.out
    Enum.each pids, &Porcelain.shell("kill -9 #{&1}")
    Porcelain.spawn_shell("ffmpeg -rtsp_transport tcp -i #{rtsp_url} -c copy -f flv rtmp://localhost:1935/live/#{camera_id}?token=#{token} &")
  end
end
