defmodule Syndication.FeedView do
  use Syndication.Web, :view
  use Timex

  def date_from_twitter_to_rss(raw_date) do
    raw_date
    |> Timex.parse!("{WDshort} {Mshort} {D} {ISOtime} {Z} {YYYY}")
    |> Timex.format!("%a, %d %b %Y %H:%M:%S %z", :strftime)
  end

  def htmlize_entities(tweet) do
    (tweet.entities.urls ++ (tweet.entities[:media] || []))
    |> Enum.sort(&(List.first(&1.indices) >= List.first(&2.indices)))
    |> Enum.reduce(tweet.text, fn url, text ->
      [begin, behind] = url.indices
      {head, rest} = String.split_at(text, begin)
      {_, rest} = String.split_at(rest, behind - begin)
      expanded_url =
        unless url[:media_url] do
          ~s(<a href="#{url.expanded_url}">#{url.display_url}</a>)
        else
          ~s(<img src="#{url.media_url}" alt="#{url.display_url}" />)
        end
      head <> expanded_url <> rest
    end)
  end

  def htmlize_entities2(tweet) do
    with_expanded_urls = tweet.entities.urls
    |> Enum.sort(&(List.first(&1.indices) >= List.first(&2.indices)))
    |> Enum.reduce(tweet.text, fn url, text ->
      [begin, behind] = url.indices
      {head, rest} = String.split_at(text, begin)
      {_, rest} = String.split_at(rest, behind - 2)
      head <> ~s(<a href="#{url.expanded_url}">#{url.display_url}</a>) <> rest
    end)
    (tweet.entities[:media] || [])
    |> Enum.sort(&(List.first(&1.indices) >= List.first(&2.indices)))
    |> Enum.reduce(with_expanded_urls, fn media, text ->
      [begin, behind] = media.indices
      {head, rest} = String.split_at(text, begin)
      {_, rest} = String.split_at(rest, behind - 2)
      head <> ~s(<img src="#{media.media_url}" alt="#{media.display_url}" />) <> rest
    end)
    with_expanded_urls
  end

  def htmlize_entities1(tweet) do
    expanded_urls = tweet.entities.urls
    |> Enum.reduce(tweet.text, fn url, text ->
      String.replace(text, url.url, ~s(<a href="#{url.expanded_url}">#{url.display_url}</a>))
    end)
    (tweet.entities[:media] || [])
    |> Enum.reduce(expanded_urls, fn media, text ->
      String.replace(text, media.url, ~s(<img src="#{media.media_url}" alt="#{media.display_url}" />))
    end)
  end
end
