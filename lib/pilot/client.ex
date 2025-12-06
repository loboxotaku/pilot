defmodule Pilot.Client do
  @moduledoc """
  HTTP client for communicating with NSAI services.

  Provides a unified interface for making requests to:
  - Work service (job management)
  - Registry service (service discovery)
  - Other NSAI ecosystem services
  """

  alias Pilot.Config

  @doc """
  Make a GET request to a service.
  """
  @spec get(atom(), String.t(), keyword()) :: {:ok, any()} | {:error, any()}
  def get(service, path, opts \\ []) do
    request(:get, service, path, opts)
  end

  @doc """
  Make a POST request to a service.
  """
  @spec post(atom(), String.t(), any(), keyword()) :: {:ok, any()} | {:error, any()}
  def post(service, path, body, opts \\ []) do
    opts = Keyword.put(opts, :json, body)
    request(:post, service, path, opts)
  end

  @doc """
  Make a PUT request to a service.
  """
  @spec put(atom(), String.t(), any(), keyword()) :: {:ok, any()} | {:error, any()}
  def put(service, path, body, opts \\ []) do
    opts = Keyword.put(opts, :json, body)
    request(:put, service, path, opts)
  end

  @doc """
  Make a DELETE request to a service.
  """
  @spec delete(atom(), String.t(), keyword()) :: {:ok, any()} | {:error, any()}
  def delete(service, path, opts \\ []) do
    request(:delete, service, path, opts)
  end

  @doc """
  Make a request to a service.
  """
  def request(method, service, path, opts \\ []) do
    url = build_url(service, path)
    timeout = Keyword.get(opts, :timeout, Config.get(:http_timeout, 30_000))

    req_opts = [
      method: method,
      url: url,
      receive_timeout: timeout,
      retry: :transient,
      retry_delay: fn attempt -> attempt * 1000 end,
      max_retries: 3
    ]

    req_opts =
      if body = Keyword.get(opts, :json) do
        Keyword.merge(req_opts, json: body)
      else
        req_opts
      end

    case Req.request(req_opts) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        {:error, {status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Get the URL for a service.
  """
  @spec service_url(atom()) :: String.t()
  def service_url(service) do
    Config.get([:services, service]) ||
      raise "Service #{service} not configured"
  end

  defp build_url(service, path) do
    base_url = service_url(service)
    path = String.trim_leading(path, "/")
    "#{base_url}/#{path}"
  end
end
