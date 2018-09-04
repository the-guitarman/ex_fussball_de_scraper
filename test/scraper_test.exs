defmodule ExFussballDeScraper.ScraperTest do
  use ExUnit.Case
  doctest ExFussballDeScraper.Scraper

  test "grabbing of the next team matches" do
    {:ok, map, _created_at} = ExFussballDeScraper.Scraper.next_matches("club-name-team-rewrite", "team-id")
    assert map.team_name == "Spvgg. Blau-Weiß Chemnitz 02"

    [first_match | _other_matches] = map.matches
    assert first_match.competition == "Landesklasse"
    assert first_match.guest == "Spvgg. Blau-Weiß Chemnitz 02"
    assert first_match.home == "ESV Lok Zwickau"

    assert Enum.count(map.matches) == 10
  end

  test "grabbing of the current team table" do
    {:ok, map, _created_at} = ExFussballDeScraper.Scraper.current_table("club-name-team-rewrite", "team-id")
    assert map.team_name == "Spvgg. Blau-Weiß Chemnitz 02"
    assert String.contains?(map.current_table, map.team_name)
  end
end
