defmodule Pilot.Commands.DatasetsTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias Pilot.Commands.Datasets

  describe "list/1" do
    test "lists available datasets" do
      output = capture_io(fn -> Datasets.list(format: :table) end)

      assert output =~ "scifact"
      assert output =~ "fever"
      assert output =~ "gsm8k"
      assert output =~ "humaneval"
    end
  end

  describe "info/1" do
    test "shows dataset info for valid dataset" do
      output = capture_io(fn -> Datasets.info(dataset_name: "scifact", format: :table) end)

      assert output =~ "SciFact"
      assert output =~ "Scientific claim verification"
    end

    test "shows error for invalid dataset" do
      output =
        capture_io(:stderr, fn -> Datasets.info(dataset_name: "invalid", format: :table) end)

      assert output =~ "Dataset not found"
    end
  end

  describe "download/1" do
    test "shows download message" do
      output = capture_io(fn -> Datasets.download(dataset_name: "scifact") end)

      assert output =~ "SciFact"
      assert output =~ "not yet implemented"
    end
  end
end
