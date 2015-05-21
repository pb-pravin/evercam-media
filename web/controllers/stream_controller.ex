defmodule EvercamMedia.StreamController do
  use Phoenix.Controller
  use Timex
  alias EvercamMedia.Repo
  import EvercamMedia.Snapshot
  require Logger
  plug :action

  def rtmp(conn, params) do
    conn
    |> put_status(request_stream(params["name"], params["token"], :kill))
    |> text ""
  end

  def hls(conn, params) do
    request_stream(params["camera_id"], params["token"], :check)
    |> hls_response conn, params
  end

  defp hls_response(200, conn, params) do
    conn
    |> put_resp_header("access-control-allow-origin", "*")
    |> redirect external: "#{Application.get_env(:nginx_rtmp, :hls_url)}/hls/#{params["camera_id"]}/index.m3u8"
  end

  defp hls_response(status, conn, params) do
    conn
    |> put_status status
    |> text ""
  end

  def ts(conn, params) do
    conn
    |> put_resp_header("access-control-allow-origin", "*")
    |> redirect external: "#{Application.get_env(:nginx_rtmp, :hls_url)}/hls/#{params["camera_id"]}/#{params["filename"]}"
  end

  defp request_stream(camera_id, token, command) do
    try do
      [username, password, rtsp_url, _] = decode_request_token(token)
      camera = Repo.one! Camera.by_exid(camera_id)
      check_auth(camera, username, password)
      stream(camera_id, rtsp_url, token, command)
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

  defp stream(camera_id, rtsp_url, token, :check) do
    cmd = Porcelain.shell("ps -ef | grep ffmpeg | grep #{rtsp_url} | grep -v grep | awk '{print $2}'")
    pids = String.split cmd.out
    if length(pids) == 0 do
      Porcelain.spawn_shell("ffmpeg -rtsp_transport tcp -i #{rtsp_url} -c copy -f flv rtmp://localhost:1935/live/#{camera_id}?token=#{token} &")
    end
  end

  defp stream(camera_id, rtsp_url, token, :kill) do
    cmd = Porcelain.shell("ps -ef | grep ffmpeg | grep #{rtsp_url} | grep -v grep | awk '{print $2}'")
    pids = String.split cmd.out
    Enum.each pids, &Porcelain.shell("kill -9 #{&1}")
    Porcelain.spawn_shell("ffmpeg -rtsp_transport tcp -i #{rtsp_url} -c copy -f flv rtmp://localhost:1935/live/#{camera_id}?token=#{token} &")
  end
end
