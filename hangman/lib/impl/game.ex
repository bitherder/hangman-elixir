defmodule Hangman.Impl.Game do
  @moduledoc """
  Game logic for Hangman game
  """

  alias Hangman.Types

  @type t :: %__MODULE__{
    turns_left: integer,
    game_state: Types.state,
    letters: list(String.t),
    used: Mapset.t(String.t)
  }

  defstruct(
   turns_left: 7,
   game_state: :initalizing,
   letters: [],
   used: MapSet.new()
  )

  def new_game do
    %__MODULE__{
      letters: Dictionary.random_word |> String.codepoints
    }
  end
end
