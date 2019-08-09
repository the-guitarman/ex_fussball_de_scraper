defmodule ExFussballDeScraper.Scraper do
  @moduledoc """
  Grabs some content from a fussball.de team website.
  """

  @css_defaults %{
    team_name: ".stage-team h2",
    matches: "#id-team-matchplan-table tbody tr",
    matches_match_id: "td:last-child a",
    matches_match_headline: "td:first-child",
    matches_match_headline_splitter: "|",
    matches_match_club_names: "td.column-club .club-name",
    current_table: "#team-fixture-league-tables > table",
    season: "select[name=\"saison\"] option:first-child",
    season_split_at: "/",
    season_join_with: "-"

  }

  @doc """
  Returns the next matches from a fussball.de team website. 
  """
  @spec next_matches(String, String) :: {:ok, Map, Integer} | {:error, Atom, Integer}
  def next_matches(team_rewrite, team_id) do
    ExFussballDeScraper.GenServer.get(team_rewrite, team_id)
    |> grab_next_matches()
  end

  defp grab_next_matches({:error, reason, created_at}), do: {:error, reason, created_at}
  defp grab_next_matches({:ok, html, created_at}) do
    map =
      %{html: html, result: %{}}
      |> find_team_name()
      |> find_season()
      |> find_matches()
      |> get_result()
    {:ok, map, created_at}
  end

  @doc """
  Returns the current table from a fussball.de team website. 
  """
  def current_table(team_rewrite, team_id) do
    ExFussballDeScraper.GenServer.get(team_rewrite, team_id)
    |> grab_current_table()
  end

  defp grab_current_table({:error, reason, created_at}), do: {:error, reason, created_at}
  defp grab_current_table({:ok, html, created_at}) do
    map =
      %{html: html, result: %{}}
      |> find_team_name()
      |> find_table()
      |> remove_images()
      |> remove_links()
      |> replace_bootstrap_3_classes()
      |> replace_bootstrap_3_glyphicons()
      |> get_result()
    {:ok, map, created_at}
  end


  defp get_result(%{result: result}) do
    result
  end

  defp find_team_name(%{html: html, result: result}) do
    team_name =
      html
      |> Floki.find(get_css_path(:team_name))
      |> Floki.text()
    %{html: html, result: Map.put(result, :team_name, team_name)}
  end

  defp find_season(%{html: html, result: result}) do
    season =
      html
      |> Floki.find(get_css_path(:season))
      |> Enum.map(&Floki.text/1)
      |> Enum.sort(&(&1 >= &2))
      |> List.first()
      |> String.split(get_css_path(:season_split_at))
      |> Enum.join(get_css_path(:season_join_with))
    %{html: html, result: Map.put(result, :season, season)}
  end

  defp find_matches(%{html: html, result: result}) do
    matches =
      html
      |> Floki.find(get_css_path(:matches))
      |> Enum.chunk(3)
      |> Enum.map(&extract_match/1)
    %{html: html, result: Map.put(result, :matches, matches)}
  end

  defp extract_match(markup) do
    id =
      Floki.find(markup, get_css_path(:matches_match_id))
      |> Enum.filter(fn({_, _, [first | _rest]}) -> is_binary(first) end)
      |> Floki.text()
      |> String.trim()
    [start_at | [competition]] =
      Floki.find(markup, get_css_path(:matches_match_headline))
      |> List.first()
      |> Floki.text()
      |> String.split(get_css_path(:matches_match_headline_splitter))
      |> Enum.map(&String.trim/1)
    club_names = Floki.find(markup, get_css_path(:matches_match_club_names))
    %{
      id: id,
      start_at: start_at |> datetime_text_to_iso(),
	    competition: competition,
	    home: club_names |> List.first() |> Floki.text() |> String.trim(),
	    guest: club_names |> List.last() |> Floki.text() |> String.trim()
    }
  end

  defp find_table(%{html: html, result: result}) do
    table =
      html
      |> Floki.find(get_css_path(:current_table))
      |> Floki.raw_html()
      |> String.replace("\n", "")
      |> String.replace("\t", "")
    %{html: html, result: Map.put(result, :current_table, table)}
  end

  defp remove_images(%{html: html, result: %{current_table: current_table} = result}) do
    current_table = Regex.replace(~r/<img .+?>/, current_table, "")
    current_table = Regex.replace(~r/<div class="club-logo table-image"><\/div>/, current_table, "")
    %{html: html, result: Map.put(result, :current_table, current_table)}
  end

  defp remove_links(%{html: html, result: %{current_table: current_table} = result}) do
    current_table = Regex.replace(~r/<a .+?>/, current_table, "")
    current_table = Regex.replace(~r/<\/a>/, current_table, "")
    %{html: html, result: Map.put(result, :current_table, current_table)}
  end

  defp replace_bootstrap_3_classes(%{html: html, result: %{current_table: current_table} = result}) do
    current_table = Regex.replace(~r/hidden-small/, current_table, "hidden-xs hidden-sm visible-md-* visible-lg-*")
    current_table = Regex.replace(~r/visible-small/, current_table, "visible-xs-* visible-sm-* hidden-md hidden-lg")
    current_table = Regex.replace(~r/table-full-width/, current_table, "table-bordered")
    current_table = Regex.replace(~r/club-[a-z]+/, current_table, "")
    current_table = Regex.replace(~r/column-[a-z]+/, current_table, "")
    current_table = Regex.replace(~r/class="\s*?"/, current_table, "")
    %{html: html, result: Map.put(result, :current_table, current_table)}
  end

  defp replace_bootstrap_3_glyphicons(%{html: html, result: %{current_table: current_table} = result}) do
    current_table = Regex.replace(~r/"icon-arrow-up"/, current_table, "\"glyphicon glyphicon-arrow-up\"")
    current_table = Regex.replace(~r/"icon-arrow-right"/, current_table, "\"glyphicon glyphicon-arrow-right\"")
    current_table = Regex.replace(~r/"icon-arrow-down"/, current_table, "\"glyphicon glyphicon-arrow-down\"")
    current_table = Regex.replace(~r/"icon-arrow-left"/, current_table, "\"glyphicon glyphicon-arrow-left\"")

    current_table = Regex.replace(~r/"icon-arrow-up-right"/, current_table, "\"glyphicon glyphicon-arrow-up\"")
    current_table = Regex.replace(~r/"icon-arrow-down-right"/, current_table, "\"glyphicon glyphicon-arrow-down\"")
    %{html: html, result: Map.put(result, :current_table, current_table)}
  end

  defp datetime_text_to_iso(text) do
    datetime =
      text
      |> String.split(",")
      |> List.last()
      |> String.trim()
      |> Timex.parse!("%d.%m.%Y - %H:%M Uhr", :strftime)

    timezone_name = Timex.Timezone.Local.lookup()

    offset =
      timezone_name
      |> Timex.Timezone.get(datetime)
      |> Timex.Timezone.total_offset()

    timezone = Timex.Timezone.get(timezone_name, Timex.local())

    {:ok, result} =
      datetime
      |> Timex.shift(seconds: -1 * offset)
      |> Timex.Timezone.convert(timezone)
      |> Timex.format("{ISO:Extended}")

    result
  end

  defp get_css_path(key) do
    keys = Application.get_env(:ex_fussball_de_scraper, :css, @css_defaults)
    keys[key]
  end
end
