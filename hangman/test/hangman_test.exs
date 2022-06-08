defmodule HangmanTest do
  @moduledoc """
  Test hangman interface behavior
  """

  use ExUnit.Case
  use ExUnit.Parameterized

  alias Hangman.Impl.Game

  doctest Hangman

  test "new game returns structure" do
    game = Game.new_game()
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "new game returns correct word" do
    game = Game.new_game("wombat")
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters == ["w", "o", "m", "b", "a", "t"]
  end

  test "all letters are lower case" do
    game = Hangman.new_game()
    assert game.letters |> Enum.map(&lower?/1) |> all_true?
  end

  test_with_params(
    "state doesn't change if a game is won or lost",
    fn state ->
      game = Game.new_game("wombat")
      game = Map.put(game, :game_state, state)
      {new_game, _tally} = Game.make_move(game, "x")
      assert new_game == game
    end
  ) do
    [{:won}, {:lost}]
  end

  defp lower?(string), do: String.match?(string, ~r/^[[:alnum:]]$/)

  defp all_true?(bool_list), do: bool_list |> Enum.reduce(&(&1 and &2))
end
