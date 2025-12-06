defmodule Pilot.Commands do
  @moduledoc """
  Command modules for Pilot CLI.
  """

  alias Pilot.Commands.{
    Datasets,
    Embed,
    Experiments,
    Jobs,
    Metrics,
    Registry,
    Services
  }

  defdelegate list_jobs(opts), to: Jobs, as: :list
  defdelegate submit_job(opts), to: Jobs, as: :submit
  defdelegate job_status(opts), to: Jobs, as: :status
  defdelegate cancel_job(opts), to: Jobs, as: :cancel

  defdelegate run_experiment(opts), to: Experiments, as: :run
  defdelegate experiment_status(opts), to: Experiments, as: :status
  defdelegate compare_experiments(opts), to: Experiments, as: :compare

  defdelegate list_services(opts), to: Services, as: :list
  defdelegate service_health(opts), to: Services, as: :health
  defdelegate service_logs(opts), to: Services, as: :logs

  defdelegate list_datasets(opts), to: Datasets, as: :list
  defdelegate dataset_info(opts), to: Datasets, as: :info
  defdelegate download_dataset(opts), to: Datasets, as: :download

  defdelegate query_metrics(opts), to: Metrics, as: :query
  defdelegate metrics_dashboard(opts), to: Metrics, as: :dashboard

  defdelegate list_registry(opts), to: Registry, as: :list
  defdelegate registry_health(opts), to: Registry, as: :health

  defdelegate generate_embedding(opts), to: Embed, as: :generate
end
