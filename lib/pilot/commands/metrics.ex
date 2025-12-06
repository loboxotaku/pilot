defmodule Pilot.Commands.Metrics do
  @moduledoc """
  Metrics querying commands.
  """

  alias Pilot.Client
  alias Pilot.Output

  @doc """
  Query metrics.
  """
  @spec query(map()) :: integer()
  def query(opts) do
    metric = opts[:metric]
    model = opts[:model]

    query_params =
      []
      |> maybe_add_param(:metric, metric)
      |> maybe_add_param(:model, model)

    Output.with_spinner("Querying metrics...", fn ->
      case Client.get(:work, "/api/metrics", query: query_params) do
        {:ok, metrics} ->
          Output.print(metrics, format: opts[:format])

        {:error, reason} ->
          Output.error("Failed to query metrics: #{inspect(reason)}")
      end
    end)
  end

  @doc """
  Launch metrics dashboard.
  """
  @spec dashboard(map()) :: integer()
  def dashboard(_opts) do
    Output.info("Opening metrics dashboard...")

    case Client.get(:work, "/api/metrics/dashboard") do
      {:ok, %{"url" => url}} ->
        Output.success("Dashboard available at: #{url}")
        open_browser(url)
        0

      {:ok, _} ->
        # Fallback if no URL provided
        url = Pilot.Config.get([:services, :work])
        dashboard_url = "#{url}/dashboard"
        Output.info("Dashboard URL: #{dashboard_url}")
        open_browser(dashboard_url)
        0

      {:error, reason} ->
        Output.error("Failed to launch dashboard: #{inspect(reason)}")
    end
  end

  defp maybe_add_param(params, _key, nil), do: params
  defp maybe_add_param(params, key, value), do: [{key, value} | params]

  defp open_browser(url) do
    case :os.type() do
      {:unix, :darwin} ->
        System.cmd("open", [url])

      {:unix, _} ->
        System.cmd("xdg-open", [url])

      {:win32, _} ->
        System.cmd("cmd", ["/c", "start", url])

      _ ->
        Output.info("Please open the URL manually: #{url}")
    end
  end
end
