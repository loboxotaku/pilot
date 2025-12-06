defmodule Pilot.Output do
  @moduledoc """
  Output formatting utilities for Pilot.

  Supports multiple output formats:
  - table: Human-readable table format
  - json: Machine-readable JSON
  - yaml: YAML format for configuration
  """

  alias Pilot.Config

  @doc """
  Format and print data according to configured format.
  """
  @spec print(any(), keyword()) :: integer()
  def print(data, opts \\ []) do
    format = Keyword.get(opts, :format) || Config.get(:output_format, :table)

    case format do
      :table -> print_table(data, opts)
      :json -> print_json(data, opts)
      :yaml -> print_yaml(data, opts)
      _ -> print_table(data, opts)
    end
  end

  @doc """
  Print data as a table.
  """
  @spec print_table(list() | map() | any(), keyword()) :: integer()
  def print_table(data, opts \\ [])

  def print_table([], _opts) do
    IO.puts("No data")
    0
  end

  def print_table([first | _rest] = data, opts) when is_map(first) do
    headers = Keyword.get(opts, :headers) || map_headers(first)
    rows = Enum.map(data, &map_to_row(&1, headers))

    header_strings = Enum.map(headers, &to_string/1)

    table_options = Keyword.new(TableRex.Renderer.Text.default_options())

    TableRex.Table.new(rows, header_strings)
    |> TableRex.Table.render!(table_options)
    |> IO.puts()

    0
  end

  def print_table(data, _opts) when is_map(data) do
    table_options = Keyword.new(TableRex.Renderer.Text.default_options())

    data
    |> Enum.map(fn {k, v} -> [to_string(k), inspect(v)] end)
    |> TableRex.Table.new(["Key", "Value"])
    |> TableRex.Table.render!(table_options)
    |> IO.puts()

    0
  end

  def print_table(data, _opts) do
    # For debugging purposes only - consider using proper formatting
    IO.puts(inspect(data, pretty: true))
    0
  end

  @doc """
  Print data as JSON.
  """
  @spec print_json(any(), keyword()) :: integer()
  def print_json(data, opts \\ []) do
    pretty = Keyword.get(opts, :pretty, false)

    json =
      if pretty do
        Jason.encode!(data, pretty: true)
      else
        Jason.encode!(data)
      end

    IO.puts(json)
    0
  end

  @doc """
  Print data as YAML.
  """
  @spec print_yaml(any(), keyword()) :: integer()
  def print_yaml(data, _opts \\ []) do
    # YamlElixir only supports reading, not writing
    # Use JSON pretty print as fallback
    print_json(data, pretty: true)
  end

  @doc """
  Print a success message.
  """
  @spec success(String.t()) :: integer()
  def success(message) do
    IO.puts([IO.ANSI.green(), "✓ ", IO.ANSI.reset(), message])
    0
  end

  @doc """
  Print an error message.
  """
  @spec error(String.t()) :: integer()
  def error(message) do
    IO.puts(:stderr, [IO.ANSI.red(), "✗ ", IO.ANSI.reset(), message])
    1
  end

  @doc """
  Print a warning message.
  """
  @spec warning(String.t()) :: integer()
  def warning(message) do
    IO.puts([IO.ANSI.yellow(), "⚠ ", IO.ANSI.reset(), message])
    0
  end

  @doc """
  Print an info message.
  """
  @spec info(String.t()) :: integer()
  def info(message) do
    IO.puts([IO.ANSI.blue(), "ℹ ", IO.ANSI.reset(), message])
    0
  end

  @doc """
  Show a spinner while executing a function.
  """
  @spec with_spinner(String.t(), (-> any())) :: any()
  def with_spinner(message, fun) do
    task = Task.async(fun)

    spinner_frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    spinner_loop(task, spinner_frames, message, 0)
  end

  defp spinner_loop(task, frames, message, frame_idx) do
    case Task.yield(task, 100) do
      {:ok, result} ->
        IO.write("\r#{String.duplicate(" ", String.length(message) + 3)}\r")
        result

      nil ->
        frame = Enum.at(frames, rem(frame_idx, length(frames)))
        IO.write("\r#{frame} #{message}")
        spinner_loop(task, frames, message, frame_idx + 1)
    end
  end

  defp map_headers(map) do
    map
    |> Map.keys()
    |> Enum.sort()
  end

  defp map_to_row(map, headers) do
    Enum.map(headers, fn header ->
      map
      |> Map.get(header)
      |> format_value()
    end)
  end

  defp format_value(nil), do: ""
  defp format_value(val) when is_binary(val), do: val
  defp format_value(val) when is_number(val), do: to_string(val)
  defp format_value(val) when is_atom(val), do: to_string(val)
  defp format_value(val) when is_list(val), do: inspect(val)
  defp format_value(val) when is_map(val), do: inspect(val)
  defp format_value(val), do: inspect(val)
end
