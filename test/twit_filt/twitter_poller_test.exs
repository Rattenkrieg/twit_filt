defmodule TwitFilt.TwitterPollerTest do
  use ExUnit.Case, async: false
  alias TwitFilt.TwitterPoller, as: Poller

  setup_all do
    :ok
  end

  test "last tweet id should not appear in consequent responses" do
    new_tweets = Poller.latest_tweets
    refute case new_tweets do
	     [last_tweet | _] -> Poller.latest_tweets |> Enum.any?(&(&1.id == latest_tweet.id))
	     _ -> false
	   end
  end
end
