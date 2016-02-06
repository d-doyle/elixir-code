defmodule Dictionary do
  @moduledoc """
  A dictionary module to support anagrams
  """
  @name DictionaryAgent

  #API

  @doc """
  Starts a new agent to hold the dictionary information, and gives the agent a name
  """
  def start_link do
    Agent.start_link(&Map.new/0, name: @name)
  end

  @doc """
  Takes any word as a parameter
  Returns the anagrams of that word using the Agent to call the get anagrams function
  and pass it the current state of the dictionary (map)
  """
  def anagram_of(word) do
    Agent.get(@name, &do_anagram_of(&1, word))
  end

  @doc """
  Takes a list of words
  Adds the words to the dictionary (map) using the Agent to call the add words function
  and pass in the current state
  """
  def add_words(words) do
    Agent.update(@name, &do_add_words(&1, words))
  end

  #IMPL
  def do_anagram_of(dict, word),
    # Get all values from the dictionary for the given key
    do: Dict.get(dict, signature(word))

  def do_add_words(dict \\ Map.new, words),
    # For each word in words, add it to dict using the supplied function
    do: Enum.reduce(words, dict, &add_one_word(&1, &2))

  defp add_one_word(word, dict),
    # Add a word to the dictionary passing in the dictionary, key,
    # intial value for emtpy dictionaries, and function to add the new word to the value
    do: Dict.update(dict, signature(word), [word], &[word|&1])

  defp signature(word),
    # Sort the letters of the word to create a key
    do: word |> to_char_list |> Enum.sort |> to_string
end

Dictionary.start_link
Dictionary.add_words ~w{ cat dog act god }
Dictionary.add_words ~w{ bat tab }

IO.inspect Dictionary.anagram_of("cat") |> Enum.sort
IO.inspect Dictionary.anagram_of("bat") |> Enum.sort
IO.inspect Dictionary.anagram_of("dog") |> Enum.sort
