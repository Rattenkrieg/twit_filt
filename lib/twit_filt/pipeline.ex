defmodule TwitFilt.Pipeline do
  use GenServer
  require Logger
  alias TwitFilt.TwitterPoller, as: Poller
  alias TwitFilt.DuplicatesFilter, as: Filter
  alias TwitFilt.Persister

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
    latest_tweets = poll
    sieved_tweets = latest_tweets |> sieve

    case latest_tweets do
      [latest_tweet | _] ->
        update_id latest_tweet.id

        urls = for tweet <- latest_tweets,
                   url_struct <- tweet.entities.urls,
                   do: url_struct.expanded_url |> Filter.valuable_part

        append_urls urls
      _ -> nil
    end
    unless Enum.empty?(sieved_tweets), do: backup_tweets sieved_tweets

    {:noreply, {flush_skipped, append_skipped}}
  end

  def poll, do: Poller.latest_tweets

  def sieve(tweets), do: Filter.sieve_urls(tweets)

  def update_id(id), do: Persister.update_id(id)

  def backup_tweets(tweets), do: Persister.store_tweets(tweets)

  def append_urls(urls), do: Persister.append_urls(urls)

  def flush_urls, do: Persister.flush_urls
end
