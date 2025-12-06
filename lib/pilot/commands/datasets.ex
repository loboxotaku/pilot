defmodule Pilot.Commands.Datasets do
  @moduledoc """
  Dataset management commands.
  """

  alias Pilot.Output

  @datasets [
    %{
      id: "scifact",
      name: "SciFact",
      description: "Scientific claim verification dataset",
      size: "1.2K claims",
      source: "https://github.com/allenai/scifact"
    },
    %{
      id: "fever",
      name: "FEVER",
      description: "Fact Extraction and VERification dataset",
      size: "185K claims",
      source: "https://fever.ai"
    },
    %{
      id: "gsm8k",
      name: "GSM8K",
      description: "Grade School Math 8K problems",
      size: "8.5K problems",
      source: "https://github.com/openai/grade-school-math"
    },
    %{
      id: "humaneval",
      name: "HumanEval",
      description: "Code generation evaluation dataset",
      size: "164 problems",
      source: "https://github.com/openai/human-eval"
    }
  ]

  @doc """
  List available datasets.
  """
  @spec list(map()) :: integer()
  def list(opts) do
    Output.print(@datasets, format: opts[:format])
  end

  @doc """
  Get dataset info.
  """
  @spec info(map()) :: integer()
  def info(opts) do
    dataset_name = opts[:dataset_name]

    case Enum.find(@datasets, fn d -> d.id == dataset_name end) do
      nil ->
        Output.error("Dataset not found: #{dataset_name}")

        available = Enum.map_join(@datasets, ", ", & &1.id)

        Output.info("Available datasets: #{available}")

      dataset ->
        Output.print(dataset, format: opts[:format])
    end
  end

  @doc """
  Download a dataset.
  """
  @spec download(map()) :: integer()
  def download(opts) do
    dataset_name = opts[:dataset_name]

    case Enum.find(@datasets, fn d -> d.id == dataset_name end) do
      nil ->
        Output.error("Dataset not found: #{dataset_name}")

        available = Enum.map_join(@datasets, ", ", & &1.id)

        Output.info("Available datasets: #{available}")

      dataset ->
        Output.info("Downloading #{dataset.name}...")
        Output.info("Source: #{dataset.source}")
        Output.warning("Dataset download not yet implemented")
        Output.info("Please download manually from the source URL")
        0
    end
  end
end
