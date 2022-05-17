defmodule Dictionary do
  def word_list() do
    "assets/words.txt" |> File.read! |> String.trim |> String.split(~r/\n/)
  end
end
