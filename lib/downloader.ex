defmodule ExFussballDeScraper.Downloader do
  @moduledoc """
  Downloads and returns a websites html.
  """

  use HTTPoison.Base

  def get(team_rewrite, team_id) do
    get_body(team_rewrite, team_id)
    |> get_result()
  end

  def process_url(url) do
    url
  end

  defp get_body(team_rewrite, team_id) do
    url = get_module(Mix.env()).build(team_rewrite, team_id)
    case url do
      "file://" <> file ->
        case File.read(file) do
          {:ok, body} -> {:ok, %{body: body}}
          {:error, :enoent} -> {:ok, %{body: ""}}
        end
      _ ->
        __MODULE__.get(url, get_headers(), get_hackney_parameters())
    end
  end

  defp get_result({:error, %HTTPoison.Error{reason: error_reason}}), do: {:error, error_reason}
  defp get_result({:error, error_reason}), do: {:error, error_reason}
  defp get_result({:ok, result}), do: {:ok, result.body}

  defp get_headers do
    [
      {"User-Agent", get_user_agent()}
    ]
  end

  defp get_user_agent do
    ExFussballDeScraper.Downloader.UserAgent.get(:random)
  end

  defp get_hackney_parameters do
    [
      ssl: [
        {:verify, :verify_none},
        {:versions, [:"tlsv1.2", :"tlsv1.1", :tlsv1]}
      ],
      follow_redirect: true
    ]
  end

  defp get_module(:test), do: ExFussballDeScraper.File
  defp get_module(_), do: ExFussballDeScraper.Url
end
