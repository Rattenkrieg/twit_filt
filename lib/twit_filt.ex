defmodule TwitFilt do
  use Application
  require Logger

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Logger.debug "starting application"
    
    import Supervisor.Spec, warn: false

    children = [
      supervisor(TwitFilt.TwitterSupervisor, [])
      # Define workers and child supervisors to be supervised
      # worker(TwitFilt.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TwitFilt.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
