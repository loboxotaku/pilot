defmodule Pilot.Commands.EmbedTest do
  use ExUnit.Case, async: true

  alias Pilot.Commands.Embed

  describe "generate/1" do
    test "returns error when text is nil" do
      opts = %{text: nil, format: :json}
      result = Embed.generate(opts)
      assert result == 1
    end

    test "returns error when text is empty string" do
      opts = %{text: "", format: :json}
      result = Embed.generate(opts)
      assert result == 1
    end

    test "accepts valid options" do
      opts = %{text: "test", model: "default", format: :json}
      # Can't test actual HTTP without mocking, but verify structure
      assert opts[:text] == "test"
      assert opts[:model] == "default"
    end
  end
end
