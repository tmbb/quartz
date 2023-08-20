defmodule QuartzTest do
  use ExUnit.Case
  doctest Quartz

  test "greets the world" do
    assert Quartz.hello() == :world
  end
end
