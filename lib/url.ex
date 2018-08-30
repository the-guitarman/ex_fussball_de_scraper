defmodule ExFussballDeScraper.Url do

  @error {:error, nil, nil}
  @default_scheme "https"
  @default_host "www.fussball.de"
  @default_path_regex ~r/\/mannschaft\/(?<team_rewrite>[^\/]+)\/-\/saison\/(?<saison>\d\d\d\d)\/team-id\/(?<team_id>[^\/]+)(#!(?<fragment>[^\/]+))*/

  def parse(url) do
    url
    |> URI.parse()
    |> get_path_from_uri()
    |> get_parameters_from_path()
  end

  defp get_path_from_uri(%{host: host, path: path}) when host == @host do
    {:ok, path}
  end
  defp get_path_from_uri(_), do: @error

  defp get_parameters_from_path(@error), do: @error
  defp get_parameters_from_path({:ok, path}) do
    case Regex.named_captures(get_path_regex(), path) do
      nil -> @error
      parameters -> {:ok, Map.get(parameters, "team_rewrite"), Map.get(parameters, "team_id")}
    end
  end

  defp get_path_regex do
    Application.get_env(:ex_fussball_de_scraper, :url)[:url_path_regex] || @default_path_regex
  end




  def build(team_rewrite, team_id) do
    get_scheme() <> "://" <> get_host() <> "/mannschaft/" <> team_rewrite <> "/-/saison/" <> get_current_saison() <> "/team-id/" <> team_id
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




  defp get_scheme() do
    Application.get_env(:ex_fussball_de_scraper, :url)[:scheme] || @default_scheme
  end

  defp get_host() do
    Application.get_env(:ex_fussball_de_scraper, :url)[:host] || @default_host
  end
end
