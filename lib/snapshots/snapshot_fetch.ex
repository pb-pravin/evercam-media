defmodule Media.SnapshotFetch do
  require Logger

  def fetch_snapshot(url, ":") do
    HTTPotion.get(url).body
  end

  def fetch_snapshot(url, auth) do
    [username, password] = String.split(auth, ":")
    request = HTTPotion.get(url, [basic_auth: {username, password}])
    if request.status_code == 401 do
      digest_request = Porcelain.shell("curl --max-time 15 --digest --user '#{auth}' #{url}")
      digest_request.out
    else
      request.body
    end
  end

  def fallback_jpg do
    path = Application.app_dir(:media)
    path = Path.join path, "priv/static/images/unavailable.jpg"
    File.read! path
  end

  def store_image(image, camera_id, count \\ 1) do
    try do
      timestamp = Timex.Date.convert Timex.Date.now, :secs
      file_path = "#{camera_id}/snapshots/#{timestamp}.jpg"

      :erlcloud_s3.configure(
        to_char_list(System.get_env["AWS_ACCESS_KEY"]),
        to_char_list(System.get_env["AWS_SECRET_KEY"])
      )
      :erlcloud_s3.put_object(
        to_char_list(System.get_env["AWS_BUCKET"]),
        to_char_list(file_path),
        image,
        [],
        []
      )

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
        Logger.warn "Retrying S3 upload for camera '#{camera_id}', try ##{count}"
        store_image(image, camera_id, count+1)
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
