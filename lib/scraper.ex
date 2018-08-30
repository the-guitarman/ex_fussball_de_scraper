defmodule ExFussballDeScraper.Scraper do

  @css_defaults %{
    team_name: ".stage-team h2",
    matches: "#id-team-matchplan-table tbody tr",
    match_headline: "td:first-child",
    match_headline_splitter: "|",
    match_club_names: "td.column-club .club-name",
    current_table: "#team-fixture-league-tables > table"
  }

  # {:ok, %{team_name: team_name, matches: matches_map}, created_at}
  # {:error, reason, created_at}
  def next_matches(team_rewrite, team_id) do
    ExFussballDeScraper.GenServer.get(team_rewrite, team_id)
    |> grab_next_matches()
  end

  defp grab_next_matches({:error, reason, created_at}), do: {:error, reason, created_at}
  defp grab_next_matches({:ok, html, created_at}) do
    map =
      html
      |> find_team_name()
      |> find_matches()
      |> get_result()
    {:ok, map, created_at}
  end

  def current_table(team_rewrite, team_id) do
    ExFussballDeScraper.GenServer.get(team_rewrite, team_id)
    |> grab_current_table()
  end

  # {:ok, %{team_name: team_name, current_table: html}, created_at}
  # {:error, reason, created_at}
  defp grab_current_table({:error, reason, created_at}), do: {:error, reason, created_at}
  defp grab_current_table({:ok, html, created_at}) do
    map =
      html
      |> find_team_name()
      |> find_table()
      |> get_result()
    {:ok, map, created_at}
  end


  defp get_result(%{result: result}) do
    result
  end

  defp find_team_name(html) do
    team_name =
      html
      |> Floki.find(get_css_path(:team_name))
      |> Floki.text()
    %{html: html, result: %{team_name: team_name}}
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
    [start_at | [competition]] =
      Floki.find(markup, get_css_path(:match_headline))
      |> List.first()
      |> Floki.text()
      |> String.split(get_css_path(:match_headline_splitter))
      |> Enum.map(&String.trim/1)
    club_names = Floki.find(markup, get_css_path(:match_club_names))
    %{
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
