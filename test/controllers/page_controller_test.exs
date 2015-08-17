defmodule EvercamMedia.PageControllerTest do
  use EvercamMedia.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert conn.resp_body =~ "<body>You are being <a href=\"http://www.evercam.io\">redirected</a>.</body>"
  end

  # test "GET /messages" do
  #  conn = get conn(), "/messages"
  #  assert html_response(conn, 200) =~ "Messages"
  # end
end
