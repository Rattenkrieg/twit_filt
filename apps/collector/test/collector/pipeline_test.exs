defmodule Collector.PipelineTest do
  use ExUnit.Case, async: false
  alias Collector.Pipeline
  require Logger

  setup do
    :ok = Application.stop :collector
    :ok = Application.start :collector
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
