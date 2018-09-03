defmodule ExFussballDeScraper.GenServerTest do
  use ExUnit.Case, async: true
  doctest ExFussballDeScraper.GenServer

  setup do
    pid = start_supervised!(ExFussballDeScraper.GenServer)
    %{gen_server_pid: pid}
  end

  test "spawns buckets", %{gen_server_pid: _pid} do
    {:ok, html, created_at} = ExFussballDeScraper.GenServer.get("club-name-team-rewrite", "team-id")

    assert String.contains?(html, "<!doctype html>")

    created_at =
      created_at
      |> Timex.from_unix()
      |> Timex.Timezone.convert(Timex.Timezone.Local.lookup())

    assert created_at.year == Timex.local().year
    assert created_at.minute == Timex.local().minute
    assert created_at.second == Timex.local().second
  end
end
