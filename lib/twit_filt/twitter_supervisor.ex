defmodule TwitFilt.TwitterSupervisor do
  use Supervisor
  require Logger

  def start_link do
    Logger.debug "linking application supervisor"
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    Logger.debug "initing application supervisor"
    supervise([worker(TwitFilt.TwitterPoller, [{TwitFilt.Persister, :get_last_id, []}]),
               worker(TwitFilt.DuplicatesFilter, [fn -> TwitFilt.Persister.get_stored_urls end]),
               worker(TwitFilt.Pipeline, []),
	      ],
      strategy: :one_for_one)
  end
end
