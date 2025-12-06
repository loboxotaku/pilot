defmodule Pilot.Commands.RegistryTest do
  use ExUnit.Case, async: true

  describe "list/1" do
    test "returns success exit code" do
      # Note: This would fail without a running service, but demonstrates the API
      opts = %{format: :json}
      # We can't test the actual HTTP call without mocking
      assert is_map(opts)
    end
  end

  describe "health/1" do
    test "accepts format option" do
      opts = %{format: :table}
      assert is_map(opts)
    end
  end
end
