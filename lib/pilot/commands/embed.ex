defmodule Pilot.Commands.Embed do
  @moduledoc """
  Embedding generation commands for quick text-to-vector conversion.
  """

  alias Pilot.Client
  alias Pilot.Output

  @doc """
  Generate embeddings for the given text.
  """
  @spec generate(map()) :: integer()
  def generate(opts) do
    text = opts[:text]
    model = opts[:model] || "default"

    if is_nil(text) || String.trim(text) == "" do
      Output.error("Text is required for embedding generation")
    else
      Output.with_spinner("Generating embedding...", fn ->
        payload = %{
          text: text,
          model: model
        }

        case Client.post(:work, "/api/embeddings", payload) do
          {:ok, response} ->
            case opts[:format] do
              :json ->
                Output.print(response, format: :json)

              _ ->
                embedding = response["embedding"]
                metadata = response["metadata"] || %{}

                Output.success("Embedding generated")
                Output.info("Model: #{metadata["model"] || model}")
                Output.info("Dimensions: #{length(embedding)}")
                Output.info("First 5 values: #{inspect(Enum.take(embedding, 5))}")

                if opts[:show_full] do
                  Output.print(%{embedding: embedding}, format: :json)
                end

                0
            end

          {:error, reason} ->
            Output.error("Failed to generate embedding: #{inspect(reason)}")
        end
      end)
    end
  end
end
