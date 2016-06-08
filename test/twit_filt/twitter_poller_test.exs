defmodule TwitFilt.TwitterPollerTest do
  use ExUnit.Case, async: false
  alias TwitFilt.TwitterPoller, as: Poller

  setup do
    :ok = Application.stop :twit_filt
    :ok = Application.start :twit_filt
    :timer.sleep 2_000
    :ok
  end

  test "last tweet id should not appear in consequent responses" do
    # lol bug with assert (macro) case x do y -> z....
    x = case Poller.latest_tweets do
	  [latest_tweet | _] -> Poller.latest_tweets |> Enum.any?(&(&1.id == latest_tweet.id))
	  _ -> false
	end
    refute x
  end
end
