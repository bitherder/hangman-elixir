defmodule Hangman.Types do
  @type state :: :intiaizing | :won | :lost | :good_guess | :bad_guess | :already_used

  @type tally :: %{
    turns_left: integer,
    game_state: state,
    letters: list(String.t),
    used: list(String.t)
  }
end
