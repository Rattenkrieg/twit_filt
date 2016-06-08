defmodule Collector.DuplicatesFilterTest do
  use ExUnit.Case, async: false
  alias Collector.DuplicatesFilter, as: Deduper
  alias Collector.TwitterPoller, as: Poller

  setup do
    :ok = Application.stop :collector
    :ok = Application.start :collector
    :timer.sleep 2_000
    :ok
  end

  test "fresh sieve should not miss no url" do
    new_tweets = Poller.latest_tweets
    _ = Deduper.sieve_urls new_tweets
    seen_urls = Deduper.seen_urls

    assert new_tweets |> Enum.all?(fn tweet ->
      tweet.entities.urls |> Enum.empty? ||
      tweet.entities.urls |> Enum.all?(&(Map.has_key?(seen_urls, &1.expanded_url |> Deduper.valuable_part)))
    end)
  end

  test "all sieved tweets must have urls" do
    new_tweets = Poller.latest_tweets
    sieved = Deduper.sieve_urls new_tweets

    sieved |> Enum.all?(&(&1.entities.urls |> Enum.count > 0))
  end

  test "tweets count should not increase after sieving" do
    new_tweets = Poller.latest_tweets
    sieved = Deduper.sieve_urls new_tweets

    assert sieved |> Enum.count <= new_tweets |> Enum.count
  end

  test "sieving same tweets should not decrease urls count" do
    new_tweets = Poller.latest_tweets
    _ = Deduper.sieve_urls new_tweets
    seen_urls_1 = Deduper.seen_urls
    _ = Deduper.sieve_urls new_tweets
    seen_urls_2 = Deduper.seen_urls

    assert seen_urls_1 |> Enum.all?(fn {k, v} -> seen_urls_2[k] >= v end)
  end

  test "sieving same tweets should return []" do
    new_tweets = Poller.latest_tweets
    _ = Deduper.sieve_urls new_tweets
    sieved_2 = Deduper.sieve_urls new_tweets

    assert sieved_2 == []
  end
end
