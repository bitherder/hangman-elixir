defmodule Hangman do
  @moduledoc """
  Game logic for hangman
  """
  alias Hangman.Impl.Game
  alias Hangman.Type

  @opaque game :: Game.t

  @spec new_game :: game
  defdelegate new_game, to: Game

  @spec make_move(game, String.t()) :: {game, Type.tally}
  defdelegate make_move(game, guess), to: Game
end
