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
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "new game returns correct word" do
    game = Game.new_game("wombat")
    assert game.turns_left == 7
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

  test "turns left is not decremented for good guess" do
    game = Game.new_game("wombat")
    turns_left = game.turns_left

    assert {%{turns_left: ^turns_left}, %{turns_left: ^turns_left}} =
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

  test "bad_move for upper case letters" do
    game = Game.new_game("Wombat")
    assert {%{game_state: :bad_guess}, %{game_state: :bad_guess}} = Game.make_move(game, "W")
  end

  test "handles a sequence of moves" do
    [
      ["a", :bad_guess, 6, ~w[_ _ _ _ _], ~w[a]],
      ["a", :already_used, 6, ~w[_ _ _ _ _], ~w[a]],
      ["e", :good_guess, 6, ~w[_ e _ _ _], ~w[a e]],
      ["x", :bad_guess, 5, ~w[_ e _ _ _], ~w[a e x]]
    ]
    |>assure_sequence_of_moves()
  end

  test "handles a winning game" do
    [
      ["a", :bad_guess, 6, ~w[_ _ _ _ _], ~w[a]],
      ["a", :already_used, 6, ~w[_ _ _ _ _], ~w[a]],
      ["e", :good_guess, 6, ~w[_ e _ _ _], ~w[a e]],
      ["x", :bad_guess, 5, ~w[_ e _ _ _], ~w[a e x]],
      ["l", :good_guess, 5, ~w[_ e l l _], ~w[a e l x]],
      ["o", :good_guess, 5, ~w[_ e l l o], ~w[a e l o x]],
      ["y", :bad_guess, 4, ~w[_ e l l o], ~w[a e l o x y]],
      ["h", :won, 4, ~w[h e l l o], ~w[a e h l o x y]]
    ]
    |>assure_sequence_of_moves()
  end

  test "handles a loosing game" do
    [
      ["a", :bad_guess, 6, ~w[_ _ _ _ _], ~w[a]],
      ["b", :bad_guess, 5, ~w[_ _ _ _ _], ~w[a b]],
      ["c", :bad_guess, 4, ~w[_ _ _ _ _], ~w[a b c]],
      ["d", :bad_guess, 3, ~w[_ _ _ _ _], ~w[a b c d]],
      ["e", :good_guess, 3, ~w[_ e _ _ _], ~w[a b c d e]],
      ["f", :bad_guess, 2, ~w[_ e _ _ _], ~w[a b c d e f]],
      ["g", :bad_guess, 1, ~w[_ e _ _ _], ~w[a b c d e f g]],
      ["h", :good_guess, 1, ~w[h e _ _ _], ~w[a b c d e f g h]],
      ["i", :lost, 0, ~w[h e _ _ _], ~w[a b c d e f g h i]]
    ]
    |>assure_sequence_of_moves()
  end
  defp assure_sequence_of_moves(script) do
    game = Game.new_game("hello")
    Enum.reduce(script, game, &check_one_move/2)
  end

  def check_one_move([guess, state, turns, letters, used], game) do
    {game, tally} = Game.make_move(game, guess)

    assert tally.turns_left == turns
    assert tally.used == used
    assert tally.letters == letters
    assert tally.game_state == state
    game
  end
end
