defmodule Pilot.Commands.Experiments do
  @moduledoc """
  Experiment management commands.
  """

  alias Pilot.Client
  alias Pilot.Output

  @agents ["proposer", "antagonist", "synthesizer"]

  @doc """
  Run an experiment.
  """
  @spec run(map()) :: integer()
  def run(opts) do
    agent = opts[:agent]
    dataset = opts[:dataset]

    if agent in @agents do
      Output.info("Running #{agent} on #{dataset} dataset...")

      case run_experiment(agent, dataset) do
        {:ok, result} ->
          Output.success("Experiment completed")
          Output.print(result, format: opts[:format])

        {:error, reason} ->
          Output.error("Experiment failed: #{inspect(reason)}")
      end
    else
      Output.error("Invalid agent: #{agent}. Must be one of: #{Enum.join(@agents, ", ")}")
    end
  end

  @doc """
  Get experiment status.
  """
  @spec status(map()) :: integer()
  def status(opts) do
    exp_id = opts[:exp_id]

    case Client.get(:work, "/api/experiments/#{exp_id}") do
      {:ok, experiment} ->
        Output.print(experiment, format: opts[:format])

      {:error, {404, _}} ->
        Output.error("Experiment not found: #{exp_id}")

      {:error, reason} ->
        Output.error("Failed to fetch experiment: #{inspect(reason)}")
    end
  end

  @doc """
  Compare two experiments.
  """
  @spec compare(map()) :: integer()
  def compare(opts) do
    exp_id1 = opts[:exp_id1]
    exp_id2 = opts[:exp_id2]

    with {:ok, exp1} <- fetch_experiment(exp_id1),
         {:ok, exp2} <- fetch_experiment(exp_id2) do
      comparison = compare_experiments(exp1, exp2)
      Output.print(comparison, format: opts[:format])
    else
      {:error, reason} ->
        Output.error("Failed to compare experiments: #{inspect(reason)}")
    end
  end

  defp run_experiment("proposer", dataset) do
    payload = %{
      kind: "cns_proposer",
      payload: %{
        dataset: dataset,
        config: %{
          validation: %{
            schema_compliance: 0.95,
            citation_accuracy: 0.96,
            entailment_threshold: 0.75,
            similarity_threshold: 0.70
          }
        }
      }
    }

    Client.post(:work, "/api/experiments", payload)
  end

  defp run_experiment("antagonist", dataset) do
    payload = %{
      kind: "cns_antagonist",
      payload: %{
        dataset: dataset,
        config: %{
          precision_threshold: 0.8,
          recall_threshold: 0.7,
          beta1_tolerance: 0.1
        }
      }
    }

    Client.post(:work, "/api/experiments", payload)
  end

  defp run_experiment("synthesizer", dataset) do
    payload = %{
      kind: "cns_synthesizer",
      payload: %{
        dataset: dataset,
        config: %{
          max_iterations: 10,
          beta1_reduction_threshold: 0.3,
          critic_weights: %{
            grounding: 0.4,
            logic: 0.3,
            novelty: 0.2,
            bias: 0.1
          }
        }
      }
    }

    Client.post(:work, "/api/experiments", payload)
  end

  defp fetch_experiment(exp_id) do
    case Client.get(:work, "/api/experiments/#{exp_id}") do
      {:ok, experiment} ->
        {:ok, experiment}

      {:error, {404, _}} ->
        {:error, "Experiment not found: #{exp_id}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp compare_experiments(exp1, exp2) do
    metrics1 = exp1["metrics"] || %{}
    metrics2 = exp2["metrics"] || %{}

    metric_keys = (Map.keys(metrics1) ++ Map.keys(metrics2)) |> Enum.uniq()

    comparisons =
      Enum.map(metric_keys, fn key ->
        val1 = metrics1[key]
        val2 = metrics2[key]
        delta = calculate_delta(val1, val2)

        %{
          metric: key,
          exp1: val1,
          exp2: val2,
          delta: delta,
          improvement: improvement_indicator(delta)
        }
      end)

    %{
      exp1_id: exp1["id"],
      exp2_id: exp2["id"],
      comparisons: comparisons
    }
  end

  defp calculate_delta(nil, _), do: nil
  defp calculate_delta(_, nil), do: nil
  defp calculate_delta(val1, val2) when is_number(val1) and is_number(val2), do: val2 - val1
  defp calculate_delta(_, _), do: nil

  defp improvement_indicator(nil), do: "-"
  defp improvement_indicator(delta) when delta > 0, do: "↑"
  defp improvement_indicator(delta) when delta < 0, do: "↓"
  defp improvement_indicator(_), do: "="
end
