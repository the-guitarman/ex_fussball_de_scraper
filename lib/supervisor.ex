defmodule ExFussballDeScraper.Supervisor do
  use Supervisor

  def start_link(args, opts) do
    Supervisor.start_link(__MODULE__, args, opts)
  end

  def init(args) do
    children = [
      {ExFussballDeScraper.GenServer, Keyword.put(args, :name, ExFussballDeScraper.GenServer)}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
