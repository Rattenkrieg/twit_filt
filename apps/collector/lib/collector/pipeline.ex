defmodule Collector.Pipeline do
  use GenServer
  require Logger
  alias Collector.TwitterPoller, as: Poller
  alias Collector.DuplicatesFilter, as: Filter
  alias Collector.Persister

  def start_link do
    Logger.debug "linking pipeline"
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def work_once do
    GenServer.call(__MODULE__, {:work_once})
  end

  def init(_) do
    Logger.debug "initing pipeline"
    {:ok, {0, 0}}
  end

  def handle_call({:work_once}, _, {flush_skipped, append_skipped}) do
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

    resp_tweets = sieved_tweets ++ read_tweets(200 - Enum.count(sieved_tweets))
    {:reply, resp_tweets, {flush_skipped, append_skipped}}
  end

  def poll, do: Poller.latest_tweets

  def sieve(tweets), do: Filter.sieve_urls(tweets)

  def read_tweets(cnt), do: Persister.read_tweets(cnt)

  def update_id(id), do: Persister.update_id(id)

  def backup_tweets(tweets), do: Persister.store_tweets(tweets)

  def append_urls(urls), do: Persister.append_urls(urls)

  def flush_urls, do: Persister.flush_urls
end
