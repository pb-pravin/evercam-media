defmodule EvercamMedia.Cache do
  alias EvercamMedia.Repo

  def invalidate_for_user(username) do
    list = ["true", "false", ""]
    permute(username, list, "", 1)
  end

  def invalidate_for_camera(camera_exid) do
    camera = Repo.one! Camera.by_exid_with_owner(camera_exid)
    invalidate_for_user(camera.owner.username)
  end

  defp permute(username, list, _, 1) do
    Enum.each list, &permute(username, list, &1, 0)
  end

  defp permute(username, list, key, 0) do
    Enum.each list, &delete_cache("cameras|#{username}|#{&1}|#{key}")
  end

  defp delete_cache(key) do
    IO.inspect key
    :mcd.delete(:memcached, key)
  end
end
