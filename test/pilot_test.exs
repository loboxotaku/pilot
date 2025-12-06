defmodule PilotTest do
  use ExUnit.Case
  doctest Pilot

  test "greets the world" do
    assert Pilot.hello() == :world
  end
end
