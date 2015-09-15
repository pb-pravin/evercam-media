defmodule EvercamMedia.Snapshot do
  alias EvercamMedia.Repo
  alias EvercamMedia.S3
  alias EvercamMedia.HTTPClient
  require Logger

  def fallback do
    path = Application.app_dir(:evercam_media)
    path = Path.join path, "priv/static/images/unavailable.jpg"
    File.read! path
  end

  def check_camera(args, retry \\ true) do
    case fetch_snapshot(args) do
      {:ok, response} ->
        image = response.body
        check_jpg(response)
        broadcast_snapshot(args[:camera_exid], image)
        store(args[:camera_exid], args[:camera_id], image, "Evercam Proxy")
      {:error, error} ->
         deal_with_camera_error(args, error)
    end
  end

  def deal_with_camera_error(args, error) do
    case error do
      %HTTPotion.HTTPError{} ->
        deal_with_camera_error_http(args, error)
      _ ->
        Logger.error "Unhandled error #{inspect error}"
    end
  end

  def deal_with_camera_error_http(args, error) do
    timestamp = Ecto.DateTime.utc
    case error.message do
      "nxdomain" ->
        pid = args[:camera_exid] |> String.to_atom |> Process.whereis
        Logger.info "Shutting down worker for camera #{args[:camera_exid]} - nxdomain"
        Process.exit pid, :shutdown
      "req_timedout" ->
        Logger.error "Request timeout for camera #{args[:camera_exid]}"
      "econnrefused" ->
        Logger.error "Connection refused for camera #{args[:camera_exid]}"
        update_camera_status(args[:camera_exid], timestamp, false)
       _ ->
         update_camera_status(args[:camera_exid], timestamp, false)
         Logger.error "Unhandled HTTPError #{inspect error}"
    end
  end

  def fetch_snapshot(args) do
    [username, password] = String.split(args[:auth], ":")
    try do
      response =
        case args[:vendor_exid] do
          "samsung" -> HTTPClient.get(:digest_auth, args[:url], username, password)
          "ubiquiti" -> HTTPClient.get(:cookie_auth, args[:url], username, password)
          _ -> HTTPClient.get(:basic_auth, args[:url], username, password)
        end
      {:ok, response}
    rescue
      error -> {:error, error}
    end
  end

  def store(camera_exid, camera_id, image, notes \\ "", count \\ 1) do
    snap_timestamp = Ecto.DateTime.utc
    file_timestamp = Timex.Date.now(:secs)
    file_path = "/#{camera_exid}/snapshots/#{file_timestamp}.jpg"
    response =  S3.upload(camera_exid, image, file_path, file_timestamp)
    case response do
      {:error, httpotion_response} ->
        %HTTPoison.Error{reason: reason} = httpotion_response
        Logger.error "Error uploading file to S3:  #{reason}"
      _ ->
        Logger.info "Uploaded file to S3 for camera #{camera_exid}: #{file_path}"
    end

    update_camera_status(camera_exid, snap_timestamp, true)
    save_snapshot_record(camera_exid, camera_id, notes, snap_timestamp, file_timestamp, file_path)
    ConCache.put(:cache, camera_exid, %{image: image, timestamp: file_timestamp, notes: notes})
    %{camera_id: camera_exid, image: image, timestamp: file_timestamp, notes: notes}
  end

  def check_jpg(response) do
    if String.valid?(response) do
      raise SnapshotError
    end
  end

  def error_handler(error) do
    Logger.error inspect(error)
    Logger.error Exception.format_stacktrace System.stacktrace
  end

  def save_snapshot_record(camera_exid, camera_id, notes, snap_timestamp, file_timestamp, file_path, _) do
    Repo.insert %Snapshot{camera_id: camera_id, data: "S3", notes: notes, created_at: snap_timestamp}
    update_thumbnail_url(camera_exid, file_path)
  end

  def update_thumbnail_url(camera_exid, file_path) do
    camera = Repo.one! Camera.by_exid(camera_exid)
    camera = %{camera | thumbnail_url: S3.file_url(file_path)}
    Repo.update camera
  end

  def update_camera_status(camera_exid, timestamp, status) do
    camera = Repo.one! Camera.by_exid(camera_exid)
    camera_is_online = camera.is_online
    camera = construct_camera(camera, timestamp, status, camera_is_online == status)
    Repo.update camera

    unless camera_is_online == status do
      try do
        log_camera_status(camera.id, status, timestamp)
      rescue
        _error ->
          error_handler(_error)
      end
      invalidate_cache(camera_exid)
    end
  end

  def invalidate_cache(camera_exid) do
    Exq.Enqueuer.enqueue(
      :exq_enqueuer,
      "cache",
      "Evercam::CacheInvalidationWorker",
      camera_exid
    )
  end

  def broadcast_snapshot(camera_id, image) do
    EvercamMedia.Endpoint.broadcast(
      "cameras:#{camera_id}",
      "snapshot-taken",
      %{image: Base.encode64(image)}
    )
  end

  def log_camera_status(camera_id, true, timestamp) do
    Repo.insert %CameraActivity{camera_id: camera_id, action: "online", done_at: timestamp}
  end

  def log_camera_status(camera_id, false, timestamp) do
    Repo.insert %CameraActivity{camera_id: camera_id, action: "offline", done_at: timestamp}
  end

  defp construct_camera(camera, timestamp, _, true) do
    %{camera | last_polled_at: timestamp}
  end

  defp construct_camera(camera, timestamp, false, false) do
    %{camera | last_polled_at: timestamp, is_online: false}
  end

  defp construct_camera(camera, timestamp, true, false) do
    %{camera | last_polled_at: timestamp, is_online: true, last_online_at: timestamp}
  end

  def decode_request_token(token) do
    {_, encrypted_message} = Base.url_decode64(token)
    message = :crypto.block_decrypt(
      :aes_cbc256,
      System.get_env["SNAP_KEY"],
      System.get_env["SNAP_IV"],
      encrypted_message
    )
    String.split(message, "|")
  end
end

defmodule SnapshotError do
  defexception message: "Response isn't an image"
end
