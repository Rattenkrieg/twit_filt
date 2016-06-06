defmodule TwitFilt.DuplicatesFilter do
  use GenServer
  require Logger

  def start_link(seen_urls) do
    Logger.debug "linking duplicates filter"
    GenServer.start_link(__MODULE__, seen_urls.(), name: __MODULE__)
  end

  def sieve_urls(tweets) do
    GenServer.call(__MODULE__, {:sieve, tweets})
  end

  def seen_urls do
    GenServer.call(__MODULE__, {:seen})
  end
  
  def init(seen_urls) do
    Logger.debug "initing duplicates filter"
    {:ok, {seen_urls}}
  end

  def handle_call({:sieve, tweets}, _, {seen_urls}) do
    seen_urls = tweets
    |> Enum.reduce(seen_urls, fn tweet, acc ->
      tweet.entities.urls
      |> Enum.reduce(acc, fn url, acc ->
	Map.update(acc, url.expanded_url |> valuable_part, 1, &(&1 + 1))
      end)
    end)
    {filtered_tweets, seen_urls} = tweets
    |> Enum.sort(&(Enum.count(&1.entities.urls) <= Enum.count(&2.entities.urls)))
    |> Enum.reduce({[], seen_urls}, fn tweet, {filtered, seen} ->
      tweet.entities.urls
      |> Enum.reduce_while({filtered, seen},
      fn url, {filtered, advanced} ->
	url = url.expanded_url |> valuable_part
	case advanced do
	  %{^url => n} when n > 1 -> {:cont, {filtered, Map.update!(advanced, url, &(&1 - 1))}}
	  _ -> {:halt, {[tweet | filtered], seen}}
	end
      end)
    end)
    {:reply, filtered_tweets |> Enum.sort(&(&1.id > &2.id)) , {seen_urls}}
  end

  def handle_call({:sieve_old, tweets}, _, {seen_urls}) do
    {filtered_tweets, seen_urls} =
      tweets
      |> Enum.reverse
      |> Enum.reduce({[], seen_urls},
                     fn(tweet, {filtered_tweets, seen_urls}) ->
                        urls = tweet.entities.urls |> Enum.map(&(&1.expanded_url |> valuable_part))
                        if Enum.all?(urls, &MapSet.member?(seen_urls, &1))
                     	  do {filtered_tweets, seen_urls}
			  else {[tweet | filtered_tweets], Enum.into(urls, seen_urls)}
                        end
                     end)
    {:reply, filtered_tweets, {seen_urls}}
  end

  def handle_call({:seen}, _, {seen_urls}) do
    {:reply, seen_urls, {seen_urls}}
  end

  def valuable_part(url) do
    uri = url |> String.downcase |> URI.parse
    %URI{host: uri.host, path: uri.path, query: uri.query} |> URI.to_string
  end
end
