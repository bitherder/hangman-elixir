defmodule Hangman.Impl.Game do
  @moduledoc """
  Game logic for Hangman game
  """

  alias Hangman.Type

  @type t :: %__MODULE__{
          turns_left: integer,
          game_state: Type.state(),
          letters: list(String.t()),
          used: Mapset.t(String.t())
        }

  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: [],
    used: MapSet.new()
  )

  @spec new_game() :: t
  def new_game do
    new_game(Dictionary.random_word())
  end

  @spec new_game(String.t()) :: t
  def new_game(word) do
    %__MODULE__{
      letters: word |> String.codepoints()
    }
  end

  @spec make_move(t, String.t()) :: {t, Type.tally()}
  def make_move(game = %{game_state: state}, _guess)
      when state in [:won, :lost] do
        game |> return_with_tally()
  end

  def make_move(game, guess) do
    game
    |> accept_guess(guess, MapSet.member?(game.used, guess))
    |> return_with_tally()
  end

  defp accept_guess(game, _guess, _already_used = true) do
    %{game | game_state: :already_used}
  end

  defp accept_guess(game, guess, _already_used) do
    %{game | used: MapSet.put(game.used, guess)}
    |> score_game(Enum.member?(game.letters, guess))
  end

  defp score_game(game, _in_word = true) do
    state = good_state(MapSet.subset?(MapSet.new(game.letters), game.used))
    %{game | game_state: state, turns_left: game.turns_left - 1}
  end

  defp score_game(game = %{turns_left: 1}, _in_word) do
    %{game | game_state: :lost, turns_left: 0}
  end

  defp score_game(game, _in_word) do
    turns_left = game.turns_left - 1
    %{game | game_state: :bad_guess, turns_left: turns_left}
  end

  defp return_with_tally(game) do
    {game, tally(game)}
  end

  defp tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: [],
      used: game.used |> MapSet.to_list() |> Enum.sort()
    }
  end

  defp good_state(_won = true) do
    :won
  end

  defp good_state(_won) do
    :good_guess
  end
end
