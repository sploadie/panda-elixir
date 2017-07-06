defmodule Panda.Match.Cache do
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def lookup(server, id) do
    GenServer.call(server, {:lookup, id})
  end

  def add(server, id, odds) do
    GenServer.call(server, {:add, id, odds})
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:lookup, id}, _from, cache) do
    {:reply, Map.fetch(cache, id), cache}
  end

  def handle_call({:add, id, odds}, _from, cache) do
    {:reply, :ok, Map.put(cache, id, odds)}
  end
end