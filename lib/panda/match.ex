defmodule Panda.Match do
  @doc """
  Get match information with id
  """
  @spec get!(integer) :: Map
  def get!(id) do
    Panda.HTTP.get!("matches/#{id}")
  end

  @doc """
  Works for matches with more than two teams for possible future application
  Saves result in cache regardless of prior value

  TODO:
  * Separate some of the functionality to increase modularity and legibility
  * Review and optimize, possibly using Streams if `.map`s can be sufficiently chained
  """
  @spec get_odds!(integer) :: List
  def get_odds!(id) do
    # Get teams
    teams = get!(id)["opponents"]
    # Get team matches in parallel
    |> Enum.map(fn team -> Task.async(fn -> Map.put(team, "matches", Panda.HTTP.get!("/teams/#{team["id"]}/matches", %{"sort" => "-begin_at", "page[size]" => 100, "filter[future]" => "false"})) end) end)
    |> Enum.map(&Task.await/1)
    # Move team name and get wins
    |> Enum.map(fn team -> Map.put(team, "name", team["opponent"]["name"]) |> Map.put("wins", wins(team["matches"], team["id"])) end)

    team_ids = Enum.map(teams, &(&1["id"]))

    # Get wins over opponents (for this match)
    teams = Enum.map(teams, fn team ->
      other_team_ids = List.delete(team_ids, team["id"])
      Map.put(team, "wins_over_opponents", Enum.filter(team["wins"], fn match -> Enum.any?(match["opponents"], &(Enum.member?(other_team_ids, &1["id"]))) end))
    end)

    total_wins_over_opponents = Enum.reduce(teams, 0, fn team, acc -> acc + length(team["wins_over_opponents"]) end)

    # Get odds, with a one to one ratio of matchup winrates and overall winrates
    odds = Enum.reduce(teams, %{}, fn team, acc -> Map.put(acc, team["name"], ((length(team["wins"]) / length(team["matches"])) + (length(team["wins_over_opponents"]) / total_wins_over_opponents)) / 2 * 100) end)
    total = Enum.reduce(odds, 0, fn {_name, value}, acc -> acc + value end)
    odds = Enum.reduce(odds, %{}, fn {name, value}, acc -> Map.put(acc, name, value / total * 100) end)

    Panda.Match.Cache.add(Panda.Match.Cache, id, odds)
    odds
  end

  def get_odds_from_cache(id) do
    case Panda.Match.Cache.lookup(Panda.Match.Cache, id) do
      {:ok, odds} -> odds
      :error -> nil
    end
  end

  @spec wins(List, integer) :: List
  def wins(matches, id) do
    Enum.filter(matches, fn match -> match["winner"] && match["winner"]["id"] == id end)
  end
end