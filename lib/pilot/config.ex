defmodule Pilot.Config do
  @moduledoc """
  Configuration management for Pilot.

  Loads configuration from:
  1. ~/.pilot/config.yaml (user config)
  2. Environment variables (override)
  3. Command-line options (highest priority)
  """

  use Agent

  @default_config %{
    default_tenant: "cns",
    services: %{
      work: "http://localhost:4000",
      registry: "http://localhost:4001"
    },
    output_format: :table,
    http_timeout: 30_000,
    repl_history_size: 100
  }

  @config_paths [
    "~/.pilot/config.yaml",
    ".pilot/config.yaml"
  ]

  def start_link(_opts \\ []) do
    Agent.start_link(fn -> @default_config end, name: __MODULE__)
  end

  @doc """
  Load configuration from file system and environment.
  """
  @spec load() :: :ok
  def load do
    config =
      @config_paths
      |> Enum.find_value(&load_file/1)
      |> case do
        nil -> @default_config
        loaded -> Map.merge(@default_config, loaded)
      end
      |> merge_env_vars()

    Agent.update(__MODULE__, fn _ -> config end)
    :ok
  end

  @doc """
  Get a configuration value.
  """
  @spec get(atom() | list(atom()), any()) :: any()
  def get(key, default \\ nil) do
    Agent.get(__MODULE__, fn config ->
      get_in(config, List.wrap(key)) || default
    end)
  end

  @doc """
  Set a configuration value.
  """
  @spec put(atom() | list(atom()), any()) :: :ok
  def put(key, value) do
    Agent.update(__MODULE__, fn config ->
      deep_put(config, List.wrap(key), value)
    end)
  end

  @doc """
  Get the entire configuration.
  """
  @spec all() :: map()
  def all do
    Agent.get(__MODULE__, & &1)
  end

  defp load_file(path) do
    expanded_path = Path.expand(path)

    if File.exists?(expanded_path) do
      case YamlElixir.read_from_file(expanded_path) do
        {:ok, config} ->
          atomize_keys(config)

        {:error, _reason} ->
          nil
      end
    else
      nil
    end
  end

  defp merge_env_vars(config) do
    config
    |> maybe_put_env("PILOT_TENANT", [:default_tenant])
    |> maybe_put_env("PILOT_WORK_URL", [:services, :work])
    |> maybe_put_env("PILOT_REGISTRY_URL", [:services, :registry])
    |> maybe_put_env("PILOT_FORMAT", [:output_format], &String.to_atom/1)
  end

  defp maybe_put_env(config, env_var, path, transform \\ & &1) do
    case System.get_env(env_var) do
      nil -> config
      value -> put_in(config, path, transform.(value))
    end
  end

  defp atomize_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} ->
      {String.to_atom(k), atomize_keys(v)}
    end)
  end

  defp atomize_keys(list) when is_list(list) do
    Enum.map(list, &atomize_keys/1)
  end

  defp atomize_keys(value), do: value

  defp deep_put(map, [key], value) do
    Map.put(map, key, value)
  end

  defp deep_put(map, [key | rest], value) do
    nested = Map.get(map, key, %{})
    Map.put(map, key, deep_put(nested, rest, value))
  end
end
