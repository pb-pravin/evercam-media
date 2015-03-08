defmodule Media.PageController do
  use Media.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end
end
