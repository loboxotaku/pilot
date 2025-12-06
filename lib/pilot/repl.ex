defmodule Pilot.REPL do
  @moduledoc """
  Interactive REPL for Pilot.

  Provides an Elixir-like shell for interacting with the NSAI ecosystem.
  """

  alias Pilot.{Client, Config, Output}

  @history_file "~/.pilot/history"
  @max_history 100

  def start do
    IO.puts("""
    #{IO.ANSI.cyan()}
    ╔═══════════════════════════════════════╗
    ║         Pilot REPL v#{version()}         ║
    ║   NSAI Ecosystem Interactive Shell   ║
    ╚═══════════════════════════════════════╝
    #{IO.ANSI.reset()}

    Type 'help' for available commands, 'exit' to quit.
    """)

    load_history()
    loop(%{history: [], history_index: 0})
  end

  defp loop(state) do
    prompt = "#{IO.ANSI.green()}pilot>#{IO.ANSI.reset()} "
    input = IO.gets(prompt) |> String.trim()

    case handle_input(input, state) do
      {:exit, _state} ->
        save_history(state.history)
        IO.puts("Goodbye!")
        :ok

      {:continue, new_state} ->
        loop(new_state)
    end
  end

  defp handle_input("", state), do: {:continue, state}
  defp handle_input("exit", state), do: {:exit, state}
  defp handle_input("quit", state), do: {:exit, state}

  defp handle_input("help", state) do
    print_help()
    {:continue, state}
  end

  defp handle_input("history", state) do
    state.history
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.each(fn {cmd, idx} ->
      IO.puts("  #{idx}. #{cmd}")
    end)

    {:continue, state}
  end

  defp handle_input("clear", state) do
    IO.write(IO.ANSI.clear())
    {:continue, state}
  end

  defp handle_input("config", state) do
    Config.all()
    |> Output.print(format: :yaml)

    {:continue, state}
  end

  defp handle_input(input, state) do
    new_state = update_in(state.history, &[input | &1])

    case eval_input(input) do
      {:ok, result} ->
        IO.puts(inspect(result, pretty: true, syntax_colors: IO.ANSI.syntax_colors()))
        {:continue, new_state}

      {:error, reason} ->
        Output.error("Error: #{inspect(reason)}")
        {:continue, new_state}
    end
  end

  defp eval_input(input) do
    # Try to evaluate as Elixir code
    {result, _binding} = Code.eval_string(input, [], __ENV__)
    {:ok, result}
  rescue
    _e ->
      # If evaluation fails, try as a command
      eval_command(input)
  end

  defp eval_command(input) do
    case String.split(input, " ", parts: 2) do
      ["jobs.list"] ->
        Client.get(:work, "/api/jobs")

      ["jobs.submit", args] ->
        with {:ok, config} <- Jason.decode(args) do
          Client.post(:work, "/api/jobs", config)
        end

      ["services.list"] ->
        Client.get(:registry, "/api/services")

      ["services.health"] ->
        services = [:work, :registry]

        results =
          Enum.map(services, fn service ->
            case Client.get(service, "/health") do
              {:ok, response} ->
                {service, :healthy, response}

              {:error, reason} ->
                {service, :unhealthy, reason}
            end
          end)

        {:ok, results}

      ["datasets.list"] ->
        {:ok,
         [
           %{id: "scifact", name: "SciFact"},
           %{id: "fever", name: "FEVER"},
           %{id: "gsm8k", name: "GSM8K"},
           %{id: "humaneval", name: "HumanEval"}
         ]}

      ["metrics.query", metric] ->
        Client.get(:work, "/api/metrics", query: [metric: metric])

      _ ->
        {:error, "Unknown command: #{input}"}
    end
  end

  defp print_help do
    IO.puts("""
    #{IO.ANSI.cyan()}Available Commands:#{IO.ANSI.reset()}

    #{IO.ANSI.yellow()}REPL Commands:#{IO.ANSI.reset()}
      help                 Show this help
      history              Show command history
      clear                Clear screen
      config               Show current configuration
      exit, quit           Exit REPL

    #{IO.ANSI.yellow()}Job Management:#{IO.ANSI.reset()}
      jobs.list
      jobs.submit <json>

    #{IO.ANSI.yellow()}Services:#{IO.ANSI.reset()}
      services.list
      services.health

    #{IO.ANSI.yellow()}Datasets:#{IO.ANSI.reset()}
      datasets.list

    #{IO.ANSI.yellow()}Metrics:#{IO.ANSI.reset()}
      metrics.query <metric_name>

    #{IO.ANSI.yellow()}Elixir Expressions:#{IO.ANSI.reset()}
      You can also evaluate Elixir code directly:
        1 + 1
        Enum.map([1, 2, 3], &(&1 * 2))
        Client.get(:work, "/api/jobs")
    """)
  end

  defp load_history do
    history_path = Path.expand(@history_file)

    if File.exists?(history_path) do
      File.read!(history_path)
      |> String.split("\n", trim: true)
      |> Enum.take(-@max_history)
    else
      []
    end
  end

  defp save_history(history) do
    history_path = Path.expand(@history_file)
    history_dir = Path.dirname(history_path)

    File.mkdir_p!(history_dir)

    history
    |> Enum.reverse()
    |> Enum.take(@max_history)
    |> Enum.join("\n")
    |> then(&File.write!(history_path, &1))
  end

  defp version do
    Mix.Project.config()[:version]
  end
end
