defmodule TwitFilt.TwitterSupervisor do
  use Supervisor
  require Logger

  def start_link do
    Logger.debug "linking application supervisor"
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    Logger.debug "initing application supervisor"
    supervise([worker(TwitFilt.TwitterPoller, [])], strategy: :one_for_one)
  end
end
