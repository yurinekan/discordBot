defmodule JacquinTest do
  use ExUnit.Case
  doctest Jacquin

  test "greets the world" do
    assert Jacquin.hello() == :world
  end
end
