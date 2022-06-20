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
    |> accept_guess(guess)
    |> return_with_tally()
  end

  defp accept_guess(game, guess) do
    %{game | used: MapSet.put(game.used, guess)}
    |> score_game(guess in game.used, guess in game.letters)
  end

  defp score_game(game, _guessed = true, _in_word) do
    %{game | game_state: :already_used}
  end

  defp score_game(game, _guessed, _in_word = true) do
    state = good_state(MapSet.subset?(MapSet.new(game.letters), game.used))
    %{game | game_state: state}
  end

  defp score_game(game, _guessed, _in_word) do
    state = bad_state(game.turns_left)
    %{game | game_state: state, turns_left: game.turns_left - 1}
  end

  defp good_state(_won = true), do: :won
  defp good_state(_won), do: :good_guess

  defp bad_state(_turns_left = 1), do: :lost
  defp bad_state(_turns_left), do: :bad_guess

  defp return_with_tally(game) do
    {game, tally(game)}
  end

  defp tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: letters_found(game.letters, game.used),
      used: game.used |> MapSet.to_list() |> Enum.sort()
    }
  end

  @spec letters_found([String.t()], MapSet.t(String.t())) :: [String.t()]
  defp letters_found(letters, used) do
    letters
    |> Enum.map(fn letter -> reveal_used(letter, MapSet.member?(used, letter)) end)
  end

  defp reveal_used(letter, _used? = true), do: letter
  defp reveal_used(_letter, _used?), do: "_"
end
