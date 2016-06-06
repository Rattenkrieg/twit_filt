defmodule TwitFilt.Pipeline do
  use GenServer
  require Logger
  alias TwitFilt

  def start_link do
    Logger.debug "linking pipeline"
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def work_once do
    GenServer.cast(__MODULE__, {:work_once})
  end
  
  def init(_) do
    Logger.debug "initing pipeline"
    {:ok, {0, 0}}
  end

  def handle_cast({:work_once}, {flush_skipped, append_skipped}) do
    {latest_tweet_id, latest_tweets} = poll
    sieved_tweets = latest_tweets |> sieve

    unless Enum.empty?(latest_tweets), do: update_id latest_tweet_id
    unless Enum.empty?(sieved_tweets) do
      backup_tweets sieved_tweets

      sieved_urls = for tweet <- sieved_tweets,
	url_struct <- tweet.entities.urls,
	url <- url_struct.expanded_url |> DuplicatesFilter.valuable_part,
	into: MapSet.new,
        do: url
  # TODO: ^ duplicates_filter sieve_urls logic duplication
      append_urls sieved_urls
    end
    {:noreply, {}}
  end
  
  def poll, do: TwitterPoller.latest_tweets

  def sieve(tweets), do: TwitterPoller.sieve_urls(tweets)

  def update_id(id), do: Persister.update_id(id)

  def backup_tweets(tweets), do: nil

  def append_urls(urls), do: Persister.append_urls(urls)

  def flush_urls, do: Persister.flush_urls
end
