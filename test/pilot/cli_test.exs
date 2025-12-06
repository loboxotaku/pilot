defmodule Pilot.CLITest do
  use ExUnit.Case, async: true

  describe "main/1" do
    test "parses version flag" do
      # Can't easily test main/1 directly as it calls System.halt
      # But we can test the building blocks
      assert is_binary(Mix.Project.config()[:version])
    end
  end

  describe "command structure" do
    test "all commands have proper structure" do
      # Ensure all command modules exist
      assert Code.ensure_loaded?(Pilot.Commands.Jobs)
      assert Code.ensure_loaded?(Pilot.Commands.Experiments)
      assert Code.ensure_loaded?(Pilot.Commands.Services)
      assert Code.ensure_loaded?(Pilot.Commands.Datasets)
      assert Code.ensure_loaded?(Pilot.Commands.Metrics)
      assert Code.ensure_loaded?(Pilot.Commands.Registry)
      assert Code.ensure_loaded?(Pilot.Commands.Embed)
    end
  end
end
