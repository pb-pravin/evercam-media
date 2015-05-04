defmodule EvercamMedia.Snapshot do
  alias EvercamMedia.S3
  require Logger

  def fetch(url, ":") do
    HTTPotion.get(url).body
  end

  def fetch(url, auth) do
    [username, password] = String.split(auth, ":")
    request = HTTPotion.get(url, [basic_auth: {username, password}])
    if request.status_code == 401 do
      digest_request = Porcelain.shell("curl --max-time 15 --digest --user '#{auth}' #{url}")
      digest_request.out
    else
      request.body
    end
  end

  def fallback do
    path = Application.app_dir(:evercam_media)
    path = Path.join path, "priv/static/images/unavailable.jpg"
    File.read! path
  end

  def store(camera_id, image, count \\ 1) do
    try do
      timestamp = Timex.Date.convert Timex.Date.now, :secs
      file_path = "/#{camera_id}/snapshots/#{timestamp}.jpg"
      S3.upload(camera_id, image, file_path, timestamp)

      Exq.Enqueuer.enqueue(
        :exq_enqueuer,
        "from_elixir",
        "Evercam::RubyWorker",
        [camera_id, timestamp]
      )
      Logger.info "Uploaded snapshot '#{timestamp}' for camera '#{camera_id}'"
    rescue
      _error ->
        :timer.sleep 1_000
        error_handler(_error)
        Logger.warn "Retrying S3 upload for camera '#{camera_id}', try ##{count}"
        store(camera_id, image, count+1)
    end
  end

  def check_jpg(response) do
    if String.valid?(response) do
      raise HTTPotion.HTTPError, message: "Response isn't an image"
    end
  end

  def error_handler(error) do
    Logger.error inspect(error)
    Logger.error Exception.format_stacktrace System.stacktrace
  end
end
