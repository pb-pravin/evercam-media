defmodule EvercamMedia.PageControllerTest do
  use EvercamMedia.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert conn.resp_body =~ "<body>You are being <a href=\"http://www.evercam.io\">redirected</a>.</body>"
  end

end
