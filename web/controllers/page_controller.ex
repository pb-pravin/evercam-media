defmodule Media.PageController do
  use Media.Web, :controller

  plug :action

  def index(conn, _params) do
    redirect conn, external: "http://www.evercam.io"
  end
end
