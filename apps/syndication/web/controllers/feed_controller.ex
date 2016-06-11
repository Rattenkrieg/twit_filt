defmodule Syndication.FeedController do
  use Syndication.Web, :controller
  alias Collector.Persister
  alias Collector.Pipeline

  def index(conn, _params) do
    tweets = Pipeline.latest_tweets
    conn
     |> put_layout(:none)
     |> put_resp_content_type("application/xml")
     |> render "index.xml", items: tweets
  end
end
