defmodule TwitFilt.Persister do
  use GenServer
  require Logger

  @urls_file Application.get_env(:twit_filt, :storage_urls_file)
  @id_file Application.get_env(:twit_filt, :storage_id_file)
  
  def start_link(data_dir) do
    Logger.debug "linking persister"
    GenServer.start_link(__MODULE__, data_dir, name: __MODULE__)
  end

  def append_urls(urls) do
    GenServer.cast(__MODULE__, {:append, urls})
  end

  def update_id(id) do
    GenServer.cast(__MODULE__, {:update, id})
  end

  def flush_urls do
    GenServer.cast(__MODULE__, {:flush})
  end

  def get_stored_urls do
    GenServer.call(__MODULE__, {:contents_urls})
  end

  def get_last_id do
    GenServer.call(__MODULE__, {:contents_id})
  end

  def init(data_dir) do
    Logger.debug "initing persister"
    unless File.exists?(data_dir), do: File.mkdir_p! data_dir
    {:ok, {data_dir}}
  end

  def handle_cast({:append, urls}, {data_dir}) do
    File.write!("#{data_dir}/#{@urls_file}", urls |>
      Enum.map(fn {url, cnt} -> ~s(#{url} #{cnt}\r\n) end), [:append])
    {:noreply, {data_dir}}
  end

  def handle_cast({:update, id}, {data_dir}) do
    File.write!("#{data_dir}/#{@id_file}", ~s(#{id}\r\n))
    {:noreply, {data_dir}}
  end

  def handle_cast({:flush}, {data_dir}) do
    "#{data_dir}/#{@urls_file}" |> File.rm!
    {:noreply, {data_dir}}
  end

  def handle_call({:contents_urls}, _, {data_dir}) do
    urls = "#{data_dir}/#{@urls_file}"
    |> read_file
    |> extract_contents
    |> Enum.into(%{}, fn s ->
      [url, cnt] = String.split(s, " ")
      {url, String.to_integer(cnt)}
    end)
    {:reply, urls, {data_dir}}
  end

  def handle_call({:contents_id}, _, {data_dir}) do
    id = "#{data_dir}/#{@id_file}" |> read_file |> extract_contents
    [id | _] = id ++ [nil]
    {:reply, id, {data_dir}}
  end

  def read_file(file) do
    with {:ok, file} <- File.open(file, [:read]),
         contents <- file
	   |> IO.stream(:line)
	   |> Stream.map(&String.rstrip/1)
	   |> Enum.to_list,
         :ok <- File.close(file),
	 do: {:ok, contents}
  end

  def extract_contents({:ok, contents}), do: contents
  def extract_contents(_), do: []
end
