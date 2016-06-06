defmodule TwitFilt.DuplicatesFilterTest do
  use ExUnit.Case, async: false
  alias TwitFilt.DuplicatesFilter, as: Deduper
  alias TwitFilt.TwitterPoller, as: Poller

  setup_all do
    :ok
  end

  test "fresh sieve should not miss no url" do
    new_tweets = Poller.latest_tweets
    sieved = Deduper.sieve_urls new_tweets
    seen_urls = Deduper.seen_urls

    assert new_tweets |> Enum.all?(fn tweet ->
      tweet.entities.urls |> Enum.empty? ||
      tweet.entities.urls |> Enum.all?(&(Map.has_key?(seen_urls, &1.expanded_url |> Deduper.valuable_part)))
    end)
  end

  test "all sieved tweets must have urls" do

    sieved |> Enum.all?(&(&1.entities.urls |> Enum.count > 0))
  end

  test "tweets count should not increase after sieving" do
    sieved |> Enum.count <= new_tweets |> Enum.count
  end
end
