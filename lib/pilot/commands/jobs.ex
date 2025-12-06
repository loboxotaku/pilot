defmodule Pilot.Commands.Jobs do
  @moduledoc """
  Job management commands.
  """

  alias Pilot.Client
  alias Pilot.Output

  @doc """
  List jobs.
  """
  @spec list(map()) :: integer()
  def list(opts) do
    Output.with_spinner("Fetching jobs...", fn ->
      query_params =
        case opts[:status] do
          nil -> []
          status -> [status: status]
        end

      case Client.get(:work, "/api/jobs", query: query_params) do
        {:ok, jobs} ->
          Output.print(jobs, format: opts[:format])

        {:error, reason} ->
          Output.error("Failed to fetch jobs: #{inspect(reason)}")
      end
    end)
  end

  @doc """
  Submit a job.
  """
  @spec submit(map()) :: integer()
  def submit(opts) do
    with {:ok, config} <- read_config(opts[:config]),
         {:ok, job} <- submit_job(opts[:type], config) do
      Output.success("Job submitted: #{job["id"]}")
      Output.print(job, format: opts[:format])
    else
      {:error, reason} ->
        Output.error("Failed to submit job: #{inspect(reason)}")
    end
  end

  @doc """
  Get job status.
  """
  @spec status(map()) :: integer()
  def status(opts) do
    job_id = opts[:job_id]

    case Client.get(:work, "/api/jobs/#{job_id}") do
      {:ok, job} ->
        Output.print(job, format: opts[:format])

      {:error, {404, _}} ->
        Output.error("Job not found: #{job_id}")

      {:error, reason} ->
        Output.error("Failed to fetch job status: #{inspect(reason)}")
    end
  end

  @doc """
  Cancel a job.
  """
  @spec cancel(map()) :: integer()
  def cancel(opts) do
    job_id = opts[:job_id]

    case Client.post(:work, "/api/jobs/#{job_id}/cancel", %{}) do
      {:ok, _} ->
        Output.success("Job cancelled: #{job_id}")

      {:error, {404, _}} ->
        Output.error("Job not found: #{job_id}")

      {:error, reason} ->
        Output.error("Failed to cancel job: #{inspect(reason)}")
    end
  end

  defp read_config(path) do
    expanded_path = Path.expand(path)

    if File.exists?(expanded_path) do
      case File.read(expanded_path) do
        {:ok, content} ->
          Jason.decode(content)

        error ->
          error
      end
    else
      {:error, :not_found}
    end
  end

  defp submit_job(type, config) do
    payload = %{
      kind: type,
      payload: config,
      tenant: Pilot.Config.get(:default_tenant)
    }

    Client.post(:work, "/api/jobs", payload)
  end
end
