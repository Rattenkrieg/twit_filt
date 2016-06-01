defmodule TwitFilt.TwitterPoller do
  use GenServer
  require Logger
  
  def start_link do
    Logger.debug "linking twitter poller"
    GenServer.start_link(__MODULE__, nil, name: :twitter_poller)
  end

  def latest_tweets(twitter_poller) do
    GenServer.call(twitter_poller, {:fetch_home_timeline})
  end
  
  def init(_) do
    Logger.debug "initing twitter poller"
    {:ok, {-1}}
  end

  def handle_call({:fetch_home_timeline}, _, {latest_tweet_id}) do
    IO.puts latest_tweet_id
    home_timeline = [latest_tweet | tweets] = ExTwitter.home_timeline()
    {:reply, home_timeline, {latest_tweet.id}}
  end
end
