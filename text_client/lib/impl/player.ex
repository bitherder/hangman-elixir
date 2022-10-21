defmodule TextClient.Impl.Player do
  @typep game :: Hangman.game()
  @typep tally :: Hangman.Type.tally()
  @typep state :: {game, tally}

  def start() do
    game = Hangman.new_game()
    tally = Hangman.tally(game)
    interact({game, tally})
  end

  @spec interact(state()) :: :ok

  def interact({_game, %{game_state: :won}}) do
    IO.puts("You've won :-)")
    :ok
  end

  def interact({game, _tally = %{game_state: :lost}}) do
    IO.puts("You've lost :-( ... the word was #{game.letters |> Enum.join}")
    :ok
  end

  def interact({game, tally}) do
    IO.puts feedback_for(tally)
    IO.puts current_word(tally)
    Hangman.make_move(game, get_guess())
    |> interact()
  end

  defp feedback_for(tally = %{game_state: :initializing}) do
    "Welcome! I'm thinking of a #{tally.letters |> length} letter word"
  end

  defp feedback_for(%{game_state: :good_guess}), do: "Good guess!"
  defp feedback_for(%{game_state: :bad_guess}), do: "Sorry, that letter's not in the word"
  defp feedback_for(%{game_state: :already_used}), do: "You already used that letter"

  defp current_word(tally) do
    [
      "Word so far: ", tally.letters |> Enum.join(""),
      IO.ANSI.green(),
      "  (turns left: ",
      IO.ANSI.cyan(),
      tally.turns_left |> to_string,
      IO.ANSI.green(),
      ", used: ",
      IO.ANSI.white(),
      tally.used |> Enum.join(","),
      IO.ANSI.green(),
      ")",
      IO.ANSI.white
    ]
  end

  defp get_guess() do
    IO.gets("Next guess: ")
    |> String.trim()
    |> String.downcase()
  end
end
