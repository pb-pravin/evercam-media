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

  def check_camera(args, retry \\ true) do
    try do
      response = fetch(args[:url], args[:auth])
      check_jpg(response)
      store(args[:camera_id], response)
    rescue
      error in [FunctionClauseError] ->
        error_handler(error)
      error in [HTTPotion.HTTPError] ->
        case error.message do
          "req_timedout" ->
            if retry do
              check_camera(args, false)
            end
          _message ->
            timestamp = Timex.Date.convert(Timex.Date.now, :secs)
            enqueue_status_update(args[:camera_id], false, timestamp)
        end
      _error ->
        error_handler(_error)
    end
  end

  def store(camera_id, image, count \\ 1) do
    try do
      timestamp = Timex.Date.convert Timex.Date.now, :secs
      file_path = "/#{camera_id}/snapshots/#{timestamp}.jpg"

      S3.upload(camera_id, image, file_path, timestamp)
      enqueue_snapshot_update(camera_id, timestamp)
      enqueue_status_update(camera_id, true, timestamp)
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
      raise "Response isn't an image"
    end
  end

  def error_handler(error) do
    Logger.error inspect(error)
    Logger.error Exception.format_stacktrace System.stacktrace
  end

  def enqueue_snapshot_update(camera_id, timestamp) do
    Exq.Enqueuer.enqueue(
      :exq_enqueuer,
      "snapshot",
      "Evercam::RubySnapshotWorker",
      [camera_id, timestamp]
    )
  end

  def enqueue_status_update(camera_id, status, timestamp) do
    Exq.Enqueuer.enqueue(
      :exq_enqueuer,
      "status",
      "Evercam::RubyStatusWorker",
      [camera_id, status, timestamp]
    )
  end
end
