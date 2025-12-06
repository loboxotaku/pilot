defmodule Pilot.ConfigTest do
  use ExUnit.Case, async: false

  alias Pilot.Config

  setup do
    # Config is already started by the application
    # Just reset it for each test
    :ok
  end

  describe "default configuration" do
    test "loads default values" do
      Config.load()

      assert Config.get(:default_tenant) == "cns"
      assert Config.get([:services, :work]) == "http://localhost:4000"
      assert Config.get(:output_format) == :table
    end
  end

  describe "get/2" do
    test "retrieves values with atom keys" do
      Config.load()
      assert Config.get(:default_tenant) == "cns"
    end

    test "retrieves nested values with path" do
      Config.load()
      assert Config.get([:services, :work]) == "http://localhost:4000"
    end

    test "returns default for missing keys" do
      Config.load()
      assert Config.get(:nonexistent, "default") == "default"
    end
  end

  describe "put/2" do
    test "sets values" do
      Config.load()
      Config.put(:custom_key, "value")
      assert Config.get(:custom_key) == "value"
    end

    test "sets nested values" do
      Config.load()
      Config.put([:nested, :key], "value")
      assert Config.get([:nested, :key]) == "value"
    end
  end

  describe "all/0" do
    test "returns entire config" do
      Config.load()
      config = Config.all()
      assert is_map(config)
      assert config[:default_tenant] == "cns"
    end
  end
end
