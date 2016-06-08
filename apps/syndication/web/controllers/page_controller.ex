defmodule Syndication.PageController do
  use Syndication.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
