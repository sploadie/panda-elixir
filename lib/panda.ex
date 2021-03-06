defmodule Panda do
  def start(_type, _args) do
    { :ok, _ } = Panda.WebServer.start()
    { :ok, supervisor } = Panda.Supervisor.start_link()
    { :ok, supervisor }
  end

  @doc """
  I know this was supposed to be 5 matches, but the top five matches almost never have their opponents announced.
  """
  @spec upcoming_matches() :: List
  def upcoming_matches do
    Panda.HTTP.get!("matches", %{"sort" => "-begin_at", "filter[future]" => "true", "page[size]" => 20})
    |> Enum.map(fn match -> Map.take(match, ["begin_at", "id", "name"]) end)
  end

  @spec odds_for_match(integer) :: Map
  def odds_for_match(id) do
    odds = Panda.Match.get_odds_from_cache(id)
    if (odds), do: odds, else: Panda.Match.get_odds!(id)
  end
end
