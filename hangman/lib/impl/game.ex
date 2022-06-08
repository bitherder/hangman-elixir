defmodule Hangman.Impl.Game do
  @moduledoc """
  Game logic for Hangman game
  """

  alias Hangman.Type

  @type t :: %__MODULE__{
    turns_left: integer,
    game_state: Type.state,
    letters: list(String.t),
    used: Mapset.t(String.t)
  }

  defstruct(
   turns_left: 7,
   game_state: :initializing,
   letters: [],
   used: MapSet.new()
  )

  def new_game do
    new_game(Dictionary.random_word)
  end

  def new_game(word) do
    %__MODULE__{
      letters: word |> String.codepoints
    }
  end
end
