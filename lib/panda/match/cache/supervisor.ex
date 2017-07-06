defmodule Panda.Match.Cache.Supervisor do
  use Supervisor

  def start_link(name) do
    Supervisor.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    children = [
      worker(Panda.Match.Cache, [Panda.Match.Cache])
    ]

    supervise(children, strategy: :one_for_one)
  end
end