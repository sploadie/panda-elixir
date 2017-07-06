defmodule Panda.Supervisor do
  use Supervisor

  @name Panda.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      supervisor(Panda.Match.Cache.Supervisor, [Panda.Match.Cache.Supervisor]),
      supervisor(Task.Supervisor, [[name: OddsSupervisor]])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
