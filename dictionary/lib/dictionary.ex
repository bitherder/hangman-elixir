defmodule Dictionary do
  @word_list "assets/words.txt"
    |> File.read!
    |> String.trim
    |> String.split(~r/\n/)

  def random_word do
    @word_list
    |> Enum.random
  end
end
