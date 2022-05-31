defmodule Hangman do
  @moduledoc """
  Game logic for hangman
  """
  alias Hangman.Impl.Game

  @opaque game :: Game.t
  @type state :: :intiaizing | :won | :lost | :good_guess | :bad_guess | :already_used
  @type tally :: %{
          turns_left: integer,
          game_state: state,
          letters: list(String.t),
          used: list(String.t)
        }

  @spec new_game :: game
  defdelegate new_game, to: Game

  @spec make_move(game, String.t()) :: {game, tally}
  def make_move(_game, _guess) do
  end
end
