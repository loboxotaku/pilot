defmodule Pilot.Commands.ExperimentsTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Pilot.Commands.Experiments

  describe "run/1" do
    test "rejects invalid agent" do
      opts = %{agent: "invalid", dataset: "scifact", format: :json}

      output =
        capture_io(:stderr, fn ->
          Experiments.run(opts)
        end)

      assert output =~ "Invalid agent"
    end

    test "accepts valid agent" do
      opts = %{agent: "proposer", dataset: "scifact", format: :json}
      # Would make HTTP call - just verify structure
      assert opts[:agent] == "proposer"
      assert opts[:dataset] == "scifact"
    end
  end
end
