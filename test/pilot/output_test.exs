defmodule Pilot.OutputTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias Pilot.Output

  describe "print_table/2" do
    test "prints a list of maps as a table" do
      data = [
        %{name: "Alice", age: 30},
        %{name: "Bob", age: 25}
      ]

      output = capture_io(fn -> Output.print_table(data) end)

      assert output =~ "name"
      assert output =~ "age"
      assert output =~ "Alice"
      assert output =~ "Bob"
    end

    test "prints empty message for empty list" do
      output = capture_io(fn -> Output.print_table([]) end)
      assert output =~ "No data"
    end

    test "prints map as key-value pairs" do
      data = %{key1: "value1", key2: "value2"}
      output = capture_io(fn -> Output.print_table(data) end)

      assert output =~ "Key"
      assert output =~ "Value"
      assert output =~ "key1"
      assert output =~ "value1"
    end
  end

  describe "print_json/2" do
    test "prints data as JSON" do
      data = %{name: "Alice", age: 30}
      output = capture_io(fn -> Output.print_json(data) end)

      {:ok, parsed} = Jason.decode(output)
      assert parsed["name"] == "Alice"
      assert parsed["age"] == 30
    end

    test "prints pretty JSON when requested" do
      data = %{name: "Alice", age: 30}
      output = capture_io(fn -> Output.print_json(data, pretty: true) end)

      assert output =~ "\n"
      assert output =~ "  "
    end
  end

  describe "print_yaml/2" do
    test "prints data as YAML (JSON fallback)" do
      data = %{name: "Alice", age: 30}
      output = capture_io(fn -> Output.print_yaml(data) end)

      # Since YAML writing is not supported, it falls back to JSON
      assert output =~ "\"name\":"
      assert output =~ "Alice"
      assert output =~ "\"age\":"
    end
  end

  describe "success/1" do
    test "prints success message" do
      output = capture_io(fn -> Output.success("Operation completed") end)
      assert output =~ "Operation completed"
    end
  end

  describe "error/1" do
    test "prints error message to stderr" do
      output = capture_io(:stderr, fn -> Output.error("Something went wrong") end)
      assert output =~ "Something went wrong"
    end
  end

  describe "warning/1" do
    test "prints warning message" do
      output = capture_io(fn -> Output.warning("Caution advised") end)
      assert output =~ "Caution advised"
    end
  end

  describe "info/1" do
    test "prints info message" do
      output = capture_io(fn -> Output.info("For your information") end)
      assert output =~ "For your information"
    end
  end
end
