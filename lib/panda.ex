defmodule Panda do
  def start(_type, _args) do
    { :ok, _ } = Panda.WebServer.start()
    { :ok, supervisor } = Panda.Supervisor.start_link()
    { :ok, supervisor }
  end

  def upcoming_matches do
    Panda.HTTP.get!(:lol, :games, sort: "-begin_at", "page[size]": 5)
  end
end
