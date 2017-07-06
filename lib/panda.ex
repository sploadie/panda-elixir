defmodule Panda do
  def start(_type, _args) do
    { :ok, _ } = Panda.WebServer.start()
    { :ok, supervisor } = Panda.Supervisor.start_link()
    { :ok, supervisor }
  end
end
