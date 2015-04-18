defmodule EvercamMedia.SnapshotFetch do
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
    path = Application.app_dir(:evercam_media)
    path = Path.join path, "priv/static/images/unavailable.jpg"
    File.read! path
  end

  def store_image(image, camera_id) do
    timestamp = Timex.Date.convert Timex.Date.now, :secs
    file_path = "#{camera_id}/snapshots/#{timestamp}.jpg"

    :erlcloud_s3.configure(
      to_char_list(System.get_env["AWS_ACCESS_KEY"]),
      to_char_list(System.get_env["AWS_SECRET_KEY"])
    )
    :erlcloud_s3.put_object('evercam-camera-assets', to_char_list(file_path), image, [], [])

    api_url = "#{System.get_env["EVERCAM_API"]}/v1/admin/cameras/#{camera_id}/recordings/snapshot/#{timestamp}"
    HTTPotion.post api_url
  end
end
