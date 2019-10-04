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
  @spec current_table(String.t, String.t) :: {:ok, Map.t, Integer.t} | {:error, Atom.t, Integer.t}
  def current_table(team_rewrite, team_id) do
    ExFussballDeScraper.GenServer.get(team_rewrite, team_id)
    |> grab_current_table()
  end

  @doc """
  Grabs the table html from the given page html.
  """
  @spec grab_table(String.t) :: String.t
  def grab_table(page_html) do
    page_html
    |> find_and_edit_table_html()
  end

  defp grab_current_table({:error, reason, created_at}), do: {:error, reason, created_at}
  defp grab_current_table({:ok, page_html, created_at}) do
    map =
      %{html: page_html, result: %{}}
      |> find_team_name()
      |> find_season()
      |> find_table()
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
      |> to_string()
      |> String.split(get_css_path(:season_split_at))
      |> Enum.join(get_css_path(:season_join_with))
    %{html: html, result: Map.put(result, :season, season)}
  end

  defp find_matches(%{html: html, result: result}) do
    matches =
      html
      |> Floki.find(get_css_path(:matches))
      |> Enum.chunk_every(3)
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

  defp find_table(%{html: page_html, result: result}) do
    table_html = find_and_edit_table_html(page_html)
    %{html: page_html, result: Map.put(result, :current_table, table_html)}
  end

  defp find_and_edit_table_html(page_html) do
    page_html
    |> Floki.find(get_css_path(:current_table))
    |> Floki.raw_html()
    |> String.replace("\n", "")
    |> String.replace("\t", "")
    |> remove_images()
    |> remove_links()
    |> replace_bootstrap_3_classes()
    |> replace_bootstrap_3_glyphicons()
  end

  defp remove_images(table_html) do
    table_html = Regex.replace(~r/<img .+?>/, table_html, "")
    Regex.replace(~r/<div class="club-logo table-image"><\/div>/, table_html, "")
  end

  defp remove_links(table_html) do
    table_html = Regex.replace(~r/<a .+?>/, table_html, "")
    Regex.replace(~r/<\/a>/, table_html, "")
  end

  defp replace_bootstrap_3_classes(table_html) do
    table_html = Regex.replace(~r/hidden-small/, table_html, "hidden-xs hidden-sm visible-md-* visible-lg-*")
    table_html = Regex.replace(~r/visible-small/, table_html, "visible-xs-* visible-sm-* hidden-md hidden-lg")
    table_html = Regex.replace(~r/table-full-width/, table_html, "table-bordered")
    table_html = Regex.replace(~r/club-[a-z]+/, table_html, "")
    table_html = Regex.replace(~r/column-[a-z]+/, table_html, "")
    Regex.replace(~r/class="\s*?"/, table_html, "")
  end

  defp replace_bootstrap_3_glyphicons(table_html) do
    table_html = Regex.replace(~r/"icon-arrow-up"/, table_html, "\"glyphicon glyphicon-arrow-up\"")
    table_html = Regex.replace(~r/"icon-arrow-right"/, table_html, "\"glyphicon glyphicon-arrow-right\"")
    table_html = Regex.replace(~r/"icon-arrow-down"/, table_html, "\"glyphicon glyphicon-arrow-down\"")
    table_html = Regex.replace(~r/"icon-arrow-left"/, table_html, "\"glyphicon glyphicon-arrow-left\"")
    table_html = Regex.replace(~r/"icon-arrow-up-right"/, table_html, "\"glyphicon glyphicon-arrow-up\"")
    Regex.replace(~r/"icon-arrow-down-right"/, table_html, "\"glyphicon glyphicon-arrow-down\"")
  end

  defp datetime_text_to_iso(text) do
    datetime =
      text
      |> String.split(",")
      |> List.last()
      |> to_string()
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
