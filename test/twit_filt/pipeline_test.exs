defmodule TwitFilt.PipelineTest do
  use ExUnit.Case, async: false
  alias TwitFilt.Pipeline
  require Logger
  
  setup do
    :ok = Application.stop :twit_filt
    :ok = Application.start :twit_filt
    :timer.sleep 2_000
    :ok
  end

  test "crap test" do
    Pipeline.work_once
    Logger.debug "sleeping"
    :timer.sleep 5_000
    Logger.debug "awakening"
    assert true
  end
end
