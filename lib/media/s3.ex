defmodule EvercamMedia.S3 do
  import EvercamMedia.Snapshot
  require Logger

  defmacrop s3_config(opts) do
    quote do
      {:config,
       'http://s3.amazonaws.com',
       unquote(opts[:access_key_id]),
       unquote(opts[:secret_access_key]),
       :virtual_hosted}
    end
  end

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
    :timer.sleep 1000
  end

  def exists?(file_name) do
    "/" <> name = file_name
    name   = String.to_char_list(name)
    bucket = System.get_env("AWS_BUCKET") |> String.to_char_list
    try do
      :mini_s3.get_object_metadata(bucket, name, [], config())
      true
    rescue
      _error in [ErlangError] ->
        false
      _error ->
        error_handler(_error)
        false
    end
  end

  def file_url(file_name) do
    configure_erlcloud
    "/" <> name = file_name
    name   = String.to_char_list(name)
    bucket = System.get_env("AWS_BUCKET") |> String.to_char_list
    {expires, host, uri} = :erlcloud_s3.make_link(100000000, bucket, name)
    "#{to_string(host)}#{to_string(uri)}"
  end

  defp configure_erlcloud do
    :erlcloud_s3.configure(
      to_char_list(System.get_env["AWS_ACCESS_KEY"]),
      to_char_list(System.get_env["AWS_SECRET_KEY"])
    )
  end

  defp config do
    access_key = System.get_env("AWS_ACCESS_KEY") |> String.to_char_list
    secret_key = System.get_env("AWS_SECRET_KEY") |> String.to_char_list
    s3_config(access_key_id: access_key, secret_access_key: secret_key)
  end
end
