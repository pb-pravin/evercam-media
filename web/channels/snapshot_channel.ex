defmodule EvercamMedia.SnapshotChannel do
  use Phoenix.Channel

  def join("cameras:" <> camera_id, _auth_msg, socket) do
    {:ok, socket}
  end
end
