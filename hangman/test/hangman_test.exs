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

  defp lower?(string), do: String.match?(string, ~r/^[[:alnum:]]$/)

  defp all_true?(bool_list), do: bool_list |> Enum.reduce(&(&1 and &2))

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

  test "a duplicate letter is reported" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state != :already_used
    {game, _tally} = Game.make_move(game, "y")
    assert game.game_state != :already_used
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "letters used are recorded" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    {game, _tally} = Game.make_move(game, "y")
    {game, _tally} = Game.make_move(game, "x")
    assert MapSet.equal?(game.used, MapSet.new(["x", "y"]))
  end

  test "reports good guess" do
    game = Game.new_game("wombat")
    assert {%{game_state: :good_guess}, %{game_state: :good_guess}} = Game.make_move(game, "o")
  end

  test "reports bad guess" do
    game = Game.new_game("wombat")
    assert {%{game_state: :bad_guess}, %{game_state: :bad_guess}} = Game.make_move(game, "x")
  end

  test "turns left is decremented for good guess" do
    game = Game.new_game("wombat")
    new_turns_left = game.turns_left - 1

    assert {%{turns_left: ^new_turns_left}, %{turns_left: ^new_turns_left}} =
             Game.make_move(game, "w")
  end

  test "turns left is decremented for bad guess" do
    game = Game.new_game("wombat")
    new_turns_left = game.turns_left - 1

    assert {%{turns_left: ^new_turns_left}, %{turns_left: ^new_turns_left}} =
             Game.make_move(game, "x")
  end

  test "game lost when last guess is bad" do
    game = Game.new_game("wombat")

    almost_lost =
      Enum.reduce(["p", "d", "q", "x", "y", "z"], game, &elem(Game.make_move(&2, &1), 0))

    assert {%{game_state: :lost}, %{game_state: :lost}} = Game.make_move(almost_lost, "c")
  end

  test "game lost when last guess completes word" do
    game = Game.new_game("wombat")
    almost_lost = Enum.reduce(["w", "o", "m", "b", "a"], game, &elem(Game.make_move(&2, &1), 0))
    assert {%{game_state: :won}, %{game_state: :won}} = Game.make_move(almost_lost, "t")
  end
end
