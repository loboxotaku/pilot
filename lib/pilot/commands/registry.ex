defmodule Pilot.Commands.Registry do
  @moduledoc """
  Registry service commands for service discovery and health checks.
  """

  alias Pilot.Client
  alias Pilot.Output

  @doc """
  List all registered services in the registry.
  """
  @spec list(map()) :: integer()
  def list(opts) do
    Output.with_spinner("Fetching registered services...", fn ->
      case Client.get(:registry, "/api/services") do
        {:ok, services} ->
          formatted =
            Enum.map(services, fn service ->
              %{
                name: service["name"],
                host: service["host"],
                port: service["port"],
                status: service["status"] || "unknown",
                last_seen: service["last_seen"] || "never"
              }
            end)

          Output.print(formatted, format: opts[:format])

        {:error, reason} ->
          Output.error("Failed to fetch services: #{inspect(reason)}")
      end
    end)
  end

  @doc """
  Check health of all registered services.
  """
  @spec health(map()) :: integer()
  def health(opts) do
    case Client.get(:registry, "/api/services") do
      {:ok, services} ->
        results =
          Enum.map(services, fn service ->
            service_atom = String.to_atom(service["name"])
            health = check_service_health(service_atom, service)

            %{
              service: service["name"],
              status: health.status,
              latency: health.latency,
              message: health.message
            }
          end)

        Output.print(results, format: opts[:format])

      {:error, reason} ->
        Output.error("Failed to fetch services: #{inspect(reason)}")
    end
  end

  defp check_service_health(service_atom, _service_info) do
    start_time = System.monotonic_time(:millisecond)

    # Try to check health endpoint
    case Client.get(service_atom, "/health") do
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
  rescue
    _ ->
      %{
        status: :unknown,
        latency: "-",
        message: "Service not configured locally"
      }
  end
end
