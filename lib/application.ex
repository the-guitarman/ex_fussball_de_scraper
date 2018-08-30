defmodule ExFussballDeScraper.Application do
  use Application

  def start(_type, args) do
    ExFussballDeScraper.Downloader.start()
    ExFussballDeScraper.Supervisor.start_link(args, name: ExFussballDeScraper.Supervisor)
  end
end
