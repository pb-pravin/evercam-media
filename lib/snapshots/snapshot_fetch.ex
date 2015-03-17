defmodule Media.SnapshotFetch do
  def fetch_snapshot(url, ":") do
    HTTPotion.get(url).body
  end

  def fetch_snapshot(url, auth) do
    [username, password] = String.split(auth, ":")
    ibrowse = [basic_auth: {String.to_char_list(username), String.to_char_list(password)}]
    HTTPotion.get(url, [], [ibrowse: ibrowse, timeout: 15000]).body
  end

  def fallback_jpg do
    path = Application.app_dir(:media)
    path = Path.join path, "priv/static/images/unavailable.jpg"
    File.read! path
  end
end