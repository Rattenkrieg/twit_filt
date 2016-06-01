defmodule TwitFilt.DuplicatesFilter do
  use GenServer
  require Logger

  def start_link do
    Logger.debug "linking duplicates filter"
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def sieve_urls(urls) do
    GenServer.call(__MODULE__, {:sieve, urls})
  end
  
  def init(_) do
    Logger.debug "initing duplicates filter"
    {:ok, {MapSet.new}}
  end
  
  def handle_call({:sieve, urls}, _, {seen_urls}) do
    urls = MapSet.new urls
    new_urls = MapSet.difference urls, seen_urls
    {:reply, new_urls, {MapSet.union(urls, seen_urls)}}
  end
end
