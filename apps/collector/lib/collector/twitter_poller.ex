defmodule Collector.TwitterPoller do
  use GenServer
  require Logger

  def start_link({m, f, a}) do
    Logger.debug "linking twitter poller"
    latest_tweet_id = apply(m, f, a)
    GenServer.start_link(__MODULE__, latest_tweet_id, name: __MODULE__)
  end

  def latest_tweets do
    GenServer.call(__MODULE__, {:fetch_home_timeline}, 15_000)
  end

  def init(latest_tweet_id) do
    Logger.debug "initing twitter poller"
    {:ok, {latest_tweet_id}}
  end

  def handle_call({:fetch_home_timeline}, _, {latest_tweet_id}) do
    IO.puts latest_tweet_id
    ops = unless latest_tweet_id, do: [count: 200], else: [since_id: latest_tweet_id]
    latest_tweet_id = case home_timeline = ExTwitter.home_timeline ops do
			[latest_tweet | _] -> latest_tweet.id
			[] -> latest_tweet_id
		      end
    {:reply, home_timeline, {latest_tweet_id}}
  end
end
