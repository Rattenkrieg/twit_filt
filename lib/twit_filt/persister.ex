defmodule TwitFilt.Persister do
  use GenServer
  require Logger

  @file_name Application.get_env(:twit_filt, :storage_file)
  
  def start_link(data_dir) do
    Logger.debug "linking persister"
    GenServer.start_link(__MODULE__, data_dir, name: __MODULE__)
  end

  def append_urls(urls) do
    GenServer.cast __MODULE__, {:append, urls}
  end

  def init(data_dir) do
    Logger.debug "initing persister"
    File.mkdir_p! data_dir
    {:ok, {data_dir}}
  end

  def handle_cast({:append, urls}, {data_dir}) do
    File.write!("#{data_dir}/#{@file_name}", Enum.map(urls, &(~s(#{&1}\r\n))), [:append])
    {:noreply, {data_dir}}
  end
end
