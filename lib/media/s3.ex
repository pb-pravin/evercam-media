defmodule Media.S3 do
  require Logger

  def upload(camera_id, image, file_path, timestamp) do
    tmp_path = "tmp/#{camera_id}-#{timestamp}.jpg"

    File.write! tmp_path, image

    output = Porcelain.shell("
      s3_put.sh \
      #{System.get_env("AWS_ACCESS_KEY")} \
      #{System.get_env("AWS_SECRET_KEY")} \
      #{System.get_env("AWS_BUCKET")} \
      #{tmp_path} \
      #{file_path}
    ")

    if output.err do raise HTTPotion.HTTPError, message: inspect(output.err) end
    File.rm tmp_path
  end
end
