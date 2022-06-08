defmodule Hangman.Type do
  @moduledoc """
  Common types for hangman game
  """

  @type state :: :initiaizing | :won | :lost | :good_guess | :bad_guess | :already_used

  @type tally :: %{
          turns_left: integer,
          game_state: state,
          letters: list(String.t()),
          used: list(String.t())
        }
end
