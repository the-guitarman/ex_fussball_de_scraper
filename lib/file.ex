defmodule ExFussballDeScraper.File do
  @moduledoc """
  Creates a local file url for test purposes.
  """
  
  @doc """
  Returns a local file url for test purposes.

  ## Example usage
  iex> ExFussballDeScraper.File.build("club-name-team-rewrite", "the-team-id")
  "file://" <> Path.join([File.cwd!, "test", "files", "test.html"])
  """
  @spec build(String, String) :: String
  def build(_team_rewrite, _team_id) do
    "file://" <> Path.join([File.cwd!, "test", "files", "test.html"])
  end
end
