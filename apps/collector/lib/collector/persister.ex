defmodule Collector.Persister do
  require Logger

  @data_dir Application.get_env(:collector, :data_dir)
  @urls_file Application.get_env(:collector, :storage_urls_file)
  @id_file Application.get_env(:collector, :storage_id_file)

  @on_load :init
  def init do
    unless File.exists?(@data_dir), do: File.mkdir_p! @data_dir
    :ok
  end

  def append_urls(urls) do
    spawn fn ->
      File.write!("#{@data_dir}/#{@urls_file}", urls
      |> Enum.map(&(~s(#{&1}\r\n))), [:append])
    end
  end

  def update_id(id) do
    spawn fn ->
      File.write!("#{@data_dir}/#{@id_file}", ~s(#{id}\r\n))
    end
  end

  def flush_urls do
    "#{@data_dir}/#{@urls_file}" |> File.rm!
  end

  def get_stored_urls do
    "#{@data_dir}/#{@urls_file}"
    |> read_strings
    |> extract_contents
    |> Enum.reduce(%{},
      fn url, acc -> Map.update(acc, url, 1, &(&1 + 1))
    end)
  end

  def get_last_id do
    id = "#{@data_dir}/#{@id_file}" |> read_strings |> extract_contents
    [id | _] = id ++ [nil]
    id
  end

  def store_tweets(tweets) do
    spawn fn ->
      tweets
      |> Enum.each(&File.write!("#{@data_dir}/#{&1.id}.dat", :erlang.term_to_binary(&1)))
    end
  end

  def read_tweets(cnt) do
    "#{@data_dir}/*.dat"
    |> Path.wildcard
    |> Enum.sort(&(&1 > &2))
    |> Enum.take(cnt)
    |> Enum.map(&(File.read!(&1) |> :erlang.binary_to_term))
  end

  def read_strings(file) do
    with {:ok, file} <- File.open(file, [:read]),
         contents = file
	   |> IO.stream(:line)
	   |> Stream.map(&String.rstrip/1)
	   |> Enum.to_list,
         :ok <- File.close(file),
	 do: {:ok, contents}
  end

  def extract_contents({:ok, contents}), do: contents
  def extract_contents(_), do: []
end
