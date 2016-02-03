defmodule Dictionary do

  @name DictionaryAgent

  #API
  def start_link do
    Agent.start_link(&HashDict.new/0, name: @name)
  end

  def anagram_of(word) do
    Agent.get(@name, &do_anagram_of(&1, word))
  end

  def add_words(words) do
    Agent.update(@name, &do_add_words(&1, words))
  end

  #IMPL
  def do_anagram_of(dict, word),
  do: Dict.get(dict, signature(word))

  def do_add_words(dict \\ HashDict.new, words),
  do: Enum.reduce(words, dict, &add_one_word(&1, &2))

  defp add_one_word(word, dict),
  do: Dict.update(dict, signature(word), [word], &[word|&1])

  defp signature(word),
  do: word |> to_char_list |> Enum.sort |> to_string
end

Dictionary.start_link
Dictionary.add_words ~w{ cat dog act god }
Dictionary.add_words ~w{ bat tab }

IO.inspect Dictionary.anagram_of "cat"
