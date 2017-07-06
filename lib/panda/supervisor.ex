defmodule Panda.Supervisor do
  use Supervisor

  @name Panda.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = []
    supervise(children, strategy: :one_for_one)
  end
end
