defmodule Pilot.CLI do
  @moduledoc """
  Main CLI entry point for Pilot.

  Pilot is an interactive CLI/REPL for the NSAI ecosystem, providing:
  - Job management
  - Experiment running and monitoring
  - Service health checks
  - Dataset operations
  - Metrics querying
  - Interactive REPL
  """

  alias Pilot.Commands
  alias Pilot.Config

  @version Mix.Project.config()[:version]

  def main(args) do
    # Start the application
    {:ok, _} = Application.ensure_all_started(:pilot)

    # Load configuration
    Config.load()

    # Parse and execute
    args
    |> parse_args()
    |> execute()
  end

  defp parse_args(args) do
    optimus = build_optimus()

    case Optimus.parse!(optimus, args) do
      {[:help], _} ->
        {:help, optimus}

      {[:version], _} ->
        {:version}

      {[:repl], _opts} ->
        {:repl}

      {[:jobs, :list], opts} ->
        {:jobs, :list, opts}

      {[:jobs, :submit], opts} ->
        {:jobs, :submit, opts}

      {[:jobs, :status], opts} ->
        {:jobs, :status, opts}

      {[:jobs, :cancel], opts} ->
        {:jobs, :cancel, opts}

      {[:experiments, :run], opts} ->
        {:experiments, :run, opts}

      {[:experiments, :status], opts} ->
        {:experiments, :status, opts}

      {[:experiments, :compare], opts} ->
        {:experiments, :compare, opts}

      {[:services, :list], opts} ->
        {:services, :list, opts}

      {[:services, :health], opts} ->
        {:services, :health, opts}

      {[:services, :logs], opts} ->
        {:services, :logs, opts}

      {[:datasets, :list], opts} ->
        {:datasets, :list, opts}

      {[:datasets, :info], opts} ->
        {:datasets, :info, opts}

      {[:datasets, :download], opts} ->
        {:datasets, :download, opts}

      {[:metrics, :query], opts} ->
        {:metrics, :query, opts}

      {[:metrics, :dashboard], opts} ->
        {:metrics, :dashboard, opts}

      {[:registry, :list], opts} ->
        {:registry, :list, opts}

      {[:registry, :health], opts} ->
        {:registry, :health, opts}

      {[:embed], opts} ->
        {:embed, :generate, opts}

      _other ->
        {:help, optimus}
    end
  rescue
    e ->
      IO.puts(:stderr, "Error: #{Exception.message(e)}\n")
      {:error, 1}
  end

  defp execute({:help, _optimus}) do
    # Optimus handles help display internally
    0
  end

  defp execute({:version}) do
    IO.puts("Pilot v#{@version}")
    0
  end

  defp execute({:repl}) do
    Pilot.REPL.start()
    0
  end

  defp execute({:jobs, :list, opts}) do
    Commands.Jobs.list(parse_result_to_map(opts))
  end

  defp execute({:jobs, :submit, opts}) do
    Commands.Jobs.submit(parse_result_to_map(opts))
  end

  defp execute({:jobs, :status, opts}) do
    Commands.Jobs.status(parse_result_to_map(opts))
  end

  defp execute({:jobs, :cancel, opts}) do
    Commands.Jobs.cancel(parse_result_to_map(opts))
  end

  defp execute({:experiments, :run, opts}) do
    Commands.Experiments.run(parse_result_to_map(opts))
  end

  defp execute({:experiments, :status, opts}) do
    Commands.Experiments.status(parse_result_to_map(opts))
  end

  defp execute({:experiments, :compare, opts}) do
    Commands.Experiments.compare(parse_result_to_map(opts))
  end

  defp execute({:services, :list, opts}) do
    Commands.Services.list(parse_result_to_map(opts))
  end

  defp execute({:services, :health, opts}) do
    Commands.Services.health(parse_result_to_map(opts))
  end

  defp execute({:services, :logs, opts}) do
    Commands.Services.logs(parse_result_to_map(opts))
  end

  defp execute({:datasets, :list, opts}) do
    Commands.Datasets.list(parse_result_to_map(opts))
  end

  defp execute({:datasets, :info, opts}) do
    Commands.Datasets.info(parse_result_to_map(opts))
  end

  defp execute({:datasets, :download, opts}) do
    Commands.Datasets.download(parse_result_to_map(opts))
  end

  defp execute({:metrics, :query, opts}) do
    Commands.Metrics.query(parse_result_to_map(opts))
  end

  defp execute({:metrics, :dashboard, opts}) do
    Commands.Metrics.dashboard(parse_result_to_map(opts))
  end

  defp execute({:registry, :list, opts}) do
    Commands.Registry.list(parse_result_to_map(opts))
  end

  defp execute({:registry, :health, opts}) do
    Commands.Registry.health(parse_result_to_map(opts))
  end

  defp execute({:embed, :generate, opts}) do
    Commands.Embed.generate(parse_result_to_map(opts))
  end

  defp execute({:error, code}) do
    code
  end

  defp build_optimus do
    Optimus.new!(
      name: "pilot",
      description: "Interactive CLI/REPL for the NSAI ecosystem",
      version: @version,
      author: "North Shore AI",
      about: """
      Pilot provides a unified interface for:
      - Managing jobs and experiments
      - Monitoring services
      - Querying datasets and metrics
      - Interactive REPL for advanced usage
      """,
      allow_unknown_args: false,
      parse_double_dash: true,
      flags: [
        help: [
          short: "-h",
          long: "--help",
          help: "Show help"
        ],
        version: [
          short: "-v",
          long: "--version",
          help: "Show version"
        ],
        repl: [
          long: "--repl",
          help: "Start interactive REPL"
        ]
      ],
      options: [
        format: [
          short: "-f",
          long: "--format",
          help: "Output format: table, json, yaml",
          default: "table",
          parser: fn s -> {:ok, String.to_atom(s)} end
        ],
        config: [
          short: "-c",
          long: "--config",
          help: "Path to config file",
          default: "~/.pilot/config.yaml"
        ]
      ],
      subcommands: [
        jobs: jobs_subcommand(),
        experiments: experiments_subcommand(),
        services: services_subcommand(),
        datasets: datasets_subcommand(),
        metrics: metrics_subcommand(),
        registry: registry_subcommand(),
        embed: embed_command()
      ]
    )
  end

  defp jobs_subcommand do
    [
      name: "jobs",
      about: "Manage jobs",
      subcommands: [
        list: [
          name: "list",
          about: "List jobs",
          options: [
            status: [
              long: "--status",
              help: "Filter by status"
            ]
          ]
        ],
        submit: [
          name: "submit",
          about: "Submit a job",
          options: [
            type: [
              long: "--type",
              help: "Job type",
              required: true
            ],
            config: [
              long: "--config",
              help: "Config file path",
              required: true
            ]
          ]
        ],
        status: [
          name: "status",
          about: "Get job status",
          args: [
            job_id: [
              value_name: "JOB_ID",
              help: "Job ID",
              required: true
            ]
          ]
        ],
        cancel: [
          name: "cancel",
          about: "Cancel a job",
          args: [
            job_id: [
              value_name: "JOB_ID",
              help: "Job ID",
              required: true
            ]
          ]
        ]
      ]
    ]
  end

  defp experiments_subcommand do
    [
      name: "experiments",
      about: "Run and manage experiments",
      subcommands: [
        run: [
          name: "run",
          about: "Run an experiment",
          args: [
            agent: [
              value_name: "AGENT",
              help: "Agent to run (proposer, antagonist, synthesizer)",
              required: true
            ]
          ],
          options: [
            dataset: [
              long: "--dataset",
              help: "Dataset to use",
              required: true
            ]
          ]
        ],
        status: [
          name: "status",
          about: "Get experiment status",
          args: [
            exp_id: [
              value_name: "EXP_ID",
              help: "Experiment ID",
              required: true
            ]
          ]
        ],
        compare: [
          name: "compare",
          about: "Compare two experiments",
          args: [
            exp_id1: [
              value_name: "EXP_ID1",
              help: "First experiment ID",
              required: true
            ],
            exp_id2: [
              value_name: "EXP_ID2",
              help: "Second experiment ID",
              required: true
            ]
          ]
        ]
      ]
    ]
  end

  defp services_subcommand do
    [
      name: "services",
      about: "Manage services",
      subcommands: [
        list: [
          name: "list",
          about: "List services"
        ],
        health: [
          name: "health",
          about: "Check service health"
        ],
        logs: [
          name: "logs",
          about: "View service logs",
          args: [
            service_name: [
              value_name: "SERVICE_NAME",
              help: "Service name",
              required: true
            ]
          ],
          options: [
            tail: [
              short: "-n",
              long: "--tail",
              help: "Number of lines to show",
              default: "100",
              parser: :integer
            ],
            follow: [
              short: "-f",
              long: "--follow",
              help: "Follow log output"
            ]
          ]
        ]
      ]
    ]
  end

  defp datasets_subcommand do
    [
      name: "datasets",
      about: "Manage datasets",
      subcommands: [
        list: [
          name: "list",
          about: "List available datasets"
        ],
        info: [
          name: "info",
          about: "Get dataset info",
          args: [
            dataset_name: [
              value_name: "DATASET_NAME",
              help: "Dataset name",
              required: true
            ]
          ]
        ],
        download: [
          name: "download",
          about: "Download a dataset",
          args: [
            dataset_name: [
              value_name: "DATASET_NAME",
              help: "Dataset name",
              required: true
            ]
          ]
        ]
      ]
    ]
  end

  defp metrics_subcommand do
    [
      name: "metrics",
      about: "Query metrics",
      subcommands: [
        query: [
          name: "query",
          about: "Query metrics",
          options: [
            metric: [
              long: "--metric",
              help: "Metric name",
              required: true
            ],
            model: [
              long: "--model",
              help: "Model name"
            ]
          ]
        ],
        dashboard: [
          name: "dashboard",
          about: "Launch metrics dashboard"
        ]
      ]
    ]
  end

  defp registry_subcommand do
    [
      name: "registry",
      about: "Service registry operations",
      subcommands: [
        list: [
          name: "list",
          about: "List all registered services"
        ],
        health: [
          name: "health",
          about: "Check health of all registered services"
        ]
      ]
    ]
  end

  defp embed_command do
    [
      name: "embed",
      about: "Generate text embeddings",
      args: [
        text: [
          value_name: "TEXT",
          help: "Text to embed",
          required: true
        ]
      ],
      options: [
        model: [
          long: "--model",
          help: "Embedding model to use",
          default: "default"
        ],
        show_full: [
          long: "--show-full",
          help: "Show full embedding vector"
        ]
      ]
    ]
  end

  defp parse_result_to_map(%Optimus.ParseResult{} = result) do
    result.options
    |> Map.merge(result.args)
    |> Map.merge(result.flags)
  end

  defp parse_result_to_map(opts), do: opts
end
