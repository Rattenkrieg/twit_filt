defmodule TwitFilt.DuplicatesFilter do
  use GenServer
  require Logger

  def start_link do
    Logger.debug "linking duplicates filter"
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def sieve_urls(tweets) do
    GenServer.call(__MODULE__, {:sieve, tweets})
  end
  
  def init(_) do
    Logger.debug "initing duplicates filter"
    {:ok, {MapSet.new}}
  end
  
  def handle_call({:sieve, tweets}, _, {seen_urls}) do
    {filtered_tweets, seen_urls} =
      tweets
      |> Enum.reverse
      |> Enum.reduce({[], seen_urls},
                     fn(tweet, {filtered_tweets, seen_urls}) ->
                        urls = tweet.entities.urls
                        if Enum.all?(urls, &MapSet.member?(seen_urls, &1))
                     	  do {filtered_tweets, seen_urls}
			  else {[tweet | filtered_tweets], Enum.into(urls, seen_urls)}
                        end
                     end)
    {:reply, filtered_tweets, {seen_urls}}
  end
end
