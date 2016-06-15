defmodule Collector.TwitterSupervisor do
  use Supervisor
  require Logger

  def start_link do
    Logger.debug "linking application supervisor"
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    Logger.debug "initing application supervisor"
    supervise([worker(Collector.TwitterPoller, [{Collector.Persister, :get_last_id, []}]),
               worker(Collector.DuplicatesFilter, [fn -> Collector.Persister.get_stored_urls end]),
               worker(Collector.Pipeline, [fn -> Collector.Persister.read_tweets(200) end]),
	      ],
      strategy: :one_for_one)
  end
end
