defmodule Pilot.Commands.Services do
  @moduledoc """
  Service management commands.
  """

  alias Pilot.Client
  alias Pilot.Output

  @doc """
  List services.
  """
  @spec list(map()) :: integer()
  def list(opts) do
    Output.with_spinner("Fetching services...", fn ->
      case Client.get(:registry, "/api/services") do
        {:ok, services} ->
          formatted =
            Enum.map(services, fn service ->
              %{
                name: service["name"],
                host: service["host"],
                port: service["port"],
                status: service["status"] || "unknown"
              }
            end)

          Output.print(formatted, format: opts[:format])

        {:error, reason} ->
          Output.error("Failed to fetch services: #{inspect(reason)}")
      end
    end)
  end

  @doc """
  Check service health.
  """
  @spec health(map()) :: integer()
  def health(opts) do
    services = [:work, :registry]

    results =
      Enum.map(services, fn service ->
        health = check_health(service)

        %{
          service: service,
          status: health.status,
          latency: health.latency,
          message: health.message
        }
      end)

    Output.print(results, format: opts[:format])
  end

  @doc """
  View service logs.
  """
  @spec logs(map()) :: integer()
  def logs(opts) do
    service_name = opts[:service_name]
    tail = opts[:tail] || 100
    follow = opts[:follow] || false

    if follow do
      follow_logs(service_name)
    else
      fetch_logs(service_name, tail, opts)
    end
  end

  defp check_health(service) do
    start_time = System.monotonic_time(:millisecond)

    case Client.get(service, "/health") do
      {:ok, response} ->
        latency = System.monotonic_time(:millisecond) - start_time

        %{
          status: :healthy,
          latency: "#{latency}ms",
          message: response["message"] || "OK"
        }

      {:error, reason} ->
        %{
          status: :unhealthy,
          latency: "-",
          message: inspect(reason)
        }
    end
  end

  defp fetch_logs(service_name, tail, _opts) do
    case Client.get(:work, "/api/services/#{service_name}/logs", query: [tail: tail]) do
      {:ok, %{"logs" => logs}} ->
        Enum.each(logs, &IO.puts/1)
        0

      {:error, {404, _}} ->
        Output.error("Service not found: #{service_name}")

      {:error, reason} ->
        Output.error("Failed to fetch logs: #{inspect(reason)}")
    end
  end

  defp follow_logs(service_name) do
    Output.info("Following logs for #{service_name}... (Ctrl+C to stop)")

    # This would require WebSocket or SSE support
    # For now, poll every second
    Stream.interval(1000)
    |> Stream.each(fn _ ->
      case Client.get(:work, "/api/services/#{service_name}/logs", query: [tail: 10]) do
        {:ok, %{"logs" => logs}} ->
          Enum.each(logs, &IO.puts/1)

        _ ->
          :ok
      end
    end)
    |> Stream.run()
  end
end
