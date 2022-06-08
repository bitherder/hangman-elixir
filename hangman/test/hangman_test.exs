defmodule HangmanTest do
  @moduledoc """
  Test hangman interface behavior
  """

  use ExUnit.Case
  doctest Hangman

  test "all letters are lower case" do
    game = Hangman.new_game()
    assert game.letters |> Enum.map(&lower?/1) |> all_true?
  end

  defp lower?(string), do: String.match?(string, ~r/^[[:alnum:]]$/)

  defp all_true?(bool_list), do: bool_list |> Enum.reduce(&(&1 and &2))
end
