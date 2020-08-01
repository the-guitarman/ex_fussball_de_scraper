defmodule ExFussballDeScraper.GenServer do
  use GenServer

  @default_call_timeout 2000

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Returns the current state:
  * `{:ok, html}`
  * `{:error, error_reason_string}`
  """
  def get(team_rewrite, team_id) do
    try do
      GenServer.call __MODULE__, {:get, team_rewrite, team_id}, get_timeout_config()
    catch
      _error, _params -> {:error, :gen_server_error, timestamp_now()}
    end
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  # %{team_rewrite_team_id: data = {:ok, %{created_at: nil, html: nil}}}
  # %{team_rewrite_team_id: data = {:error, %{created_at: nil, reason: _reason}}}
  # {:reply, {:ok, html, created_at}, new_state}
  # {:reply, {:error, reason, created_at}, new_state}
  def handle_call({:get, team_rewrite, team_id}, _from, data) do
    main_key = main_key(team_rewrite, team_id)
    team_data = Map.get(data, main_key)

    new_data =
      case download?(team_data) do
        true ->
          new_team_data =
            ExFussballDeScraper.Downloader.get(team_rewrite, team_id)
            |> new_data()
          Map.put(data, main_key, new_team_data)
        _ -> data
      end

    reply =
      Map.get(new_data, main_key)
      |> get_reply()


    IO.puts("ExFussballDeScraper.GenServer.get(#{team_rewrite}, #{team_id})")
    IO.inspect(reply)

    {:reply, reply, new_data, get_timeout_config()}
  end

  def handle_info(:timeout, state), do: {:noreply, state}

  defp get_reply({:ok, %{created_at: created_at, html: html}}), do: {:ok, html, created_at}
  defp get_reply({:error, %{created_at: created_at, reason: reason}}), do: {:error, reason, created_at}

  defp download?(nil), do: true
  defp download?({_, %{created_at: created_at}}) do
    cached_data_should_be_updated?(created_at)
  end

  defp new_data({:ok, html}) do
    {:ok, %{created_at: timestamp_now(), html: html}}
  end
  defp new_data({:error, reason}) do
    {:error, %{created_at: timestamp_now(), reason: reason}}
  end

  defp cached_data_should_be_updated?(created_at) do
    one_hour_in_seconds = 60*60
    created_at < (timestamp_now() - one_hour_in_seconds)
  end

  defp timestamp_now do
    Timex.local
    |> Timex.to_unix()
  end

  defp main_key(team_rewrite, team_id) do
    team_rewrite <> "_" <> team_id
    |> String.to_atom()
  end

  defp get_timeout_config() do
    Application.get_env(:ex_fussball_de_scraper, :gen_server)[:call_timeout] || @default_call_timeout
  end
end
