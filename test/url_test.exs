defmodule ExFussballDeScraper.UrlTest do
  use ExUnit.Case
  doctest ExFussballDeScraper.Url

  test "grabbing of the next team matches" do
    assert ExFussballDeScraper.Url.build("club-name-team-rewrite", "the-team-id") == "https://www.fussball.de/mannschaft/club-name-team-rewrite/-/saison/#{get_current_saison()}/team-id/the-team-id"
  end

  defp get_current_saison do
    year = get_current_year()
    case Enum.member?(1..7, get_current_month()) do
      true ->
        last_year = year - 1
        Integer.to_string(last_year) <> Integer.to_string(year)
      _ ->
        next_year = year + 1
        Integer.to_string(year) <> Integer.to_string(next_year)
    end
  end

  defp get_current_month do
    {:ok, month} = Timex.format(Timex.local, "%m", :strftime)
    String.to_integer(month)
  end

  defp get_current_year do
    {:ok, year} = Timex.format(Timex.local, "%g", :strftime)
    String.to_integer(year)
  end
end
