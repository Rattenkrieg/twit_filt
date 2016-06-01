defmodule TwitFilt.TwitterPoller do
  use GenServer
  require Logger
  
  def start_link do
    Logger.debug "linking twitter poller"
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def latest_tweets do
    GenServer.call __MODULE__, {:fetch_home_timeline}
  end
  
  def init(_) do
    Logger.debug "initing twitter poller"
    {:ok, {nil}}
  end

  def handle_call({:fetch_home_timeline}, _, {latest_tweet_id}) do
    IO.puts latest_tweet_id
    ops = if latest_tweet_id == nil, do: [], else: [since_id: latest_tweet_id]
    latest_tweet_id = case home_timeline = ExTwitter.home_timeline ops do
			[latest_tweet | tweets] -> latest_tweet.id
			[] -> latest_tweet_id
		      end
    {:reply, home_timeline, {latest_tweet_id}}
  end
end
