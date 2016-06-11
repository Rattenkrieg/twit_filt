defmodule Collector.Pipeline do
  use GenServer
  require Logger
  alias Collector.TwitterPoller, as: Poller
  alias Collector.DuplicatesFilter, as: Filter
  alias Collector.Persister

  @served_tweets_cnt Application.get_env(:collector, :served_tweets_cnt)

  def start_link do
    Logger.debug "linking pipeline"
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def fetch_tweets do
    GenServer.cast(__MODULE__, {:fetch_tweets})
  end

  def latest_tweets do
    GenServer.call(__MODULE__, {:latest_tweets})
  end

  def init(tweets) do
    Logger.debug "initing pipeline"
    {:ok, {tweets, 0, 0}}
  end

  def handle_call({:latest_tweets}, _, {tweets, flush_skipped, append_skipped}) do
    {:reply, tweets, {tweets, flush_skipped, append_skipped}}
  end

  def handle_cast({:fetch_tweets}, {tweets, flush_skipped, append_skipped}) do
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

    sieved_cnt = sieved_tweets |> Enum.count
    in_mem_cnt = tweets |> Enum.count
    tweets = tweets ++ Enum.take(tweets, @served_tweets_cnt - sieved_cnt)
                    ++ read_tweets(@served_tweets_cnt - sieved_cnt - in_mem_cnt)
    {:noreply, {tweets, flush_skipped, append_skipped}}
  end

  def poll, do: Poller.latest_tweets

  def sieve(tweets), do: Filter.sieve_urls(tweets)

  def read_tweets(cnt), do: Persister.read_tweets(cnt)

  def update_id(id), do: Persister.update_id(id)

  def backup_tweets(tweets), do: Persister.store_tweets(tweets)

  def append_urls(urls), do: Persister.append_urls(urls)

  def flush_urls, do: Persister.flush_urls
end
