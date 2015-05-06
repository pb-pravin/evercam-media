defmodule EvercamMedia.S3 do
  require Logger

  def upload(camera_id, image, file_path, timestamp) do
    # TODO: replace this with a proper uploading method
    # using http requests from elixir (hackney?)

    tmp_path = "/tmp/#{camera_id}-#{timestamp}.jpg"
    File.write! tmp_path, image
    command = "
      s3_put.sh \
      #{System.get_env("AWS_ACCESS_KEY")} \
      #{System.get_env("AWS_SECRET_KEY")} \
      #{System.get_env("AWS_BUCKET")} \
      #{tmp_path} \
      #{file_path}
    "
    output = Porcelain.shell(command)

    if output.err || output.status != 0 do
      raise HTTPotion.HTTPError, message: inspect(output.err)
    end

    File.rm tmp_path
  end
end
