defmodule Pilot.ClientTest do
  use ExUnit.Case, async: true

  alias Pilot.Client

  describe "service_url/1" do
    test "raises when service is not configured" do
      assert_raise RuntimeError, ~r/not configured/, fn ->
        Client.service_url(:nonexistent_service)
      end
    end

    test "returns URL for configured service" do
      # work and registry are configured by default
      url = Client.service_url(:work)
      assert is_binary(url)
      assert String.starts_with?(url, "http")
    end
  end
end
