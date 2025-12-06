defmodule Pilot do
  @moduledoc """
  Pilot - Interactive CLI/REPL for the NSAI Ecosystem.

  Pilot provides a unified command-line interface for interacting with
  North Shore AI's ecosystem of services, including job management,
  experiment running, service monitoring, and dataset operations.

  ## Features

  - Job management (submit, list, monitor, cancel)
  - Experiment orchestration (CNS agents)
  - Service health monitoring
  - Dataset operations
  - Metrics querying
  - Interactive REPL
  - Multiple output formats (table, JSON, YAML)

  ## Usage

      # Command-line mode
      pilot jobs list
      pilot experiments run proposer --dataset scifact
      pilot services health

      # REPL mode
      pilot --repl

  See the CLI module for full command documentation.
  """

  @doc """
  Hello world example function.

  ## Examples

      iex> Pilot.hello()
      :world

  """
  @spec hello() :: :world
  def hello do
    :world
  end
end
