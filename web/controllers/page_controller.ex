defmodule EvercamMedia.PageController do
  use EvercamMedia.Web, :controller

  plug :action

  def index(conn, _params) do
    redirect conn, external: "http://www.evercam.io"
  end
end
