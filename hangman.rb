# frozen_string_literal: true

# Importing the unit test library
require 'test/unit/assertions'
include Test::Unit::Assertions

# class representing a game of hangman
class HangmanGame
  # initialize with input to allow adjustng the game difficulty easily
  def initialize(min_word_length, max_word_length, game_turns)
    @min_word_length = min_word_length
    @max_word_length = max_word_length
    @game_turns = game_turns
    @source_dictionary = File.open('5desk.txt').readlines
    @secret_word_array = select_secret_word(@min_word_length, @max_word_length, @source_dictionary)
    @secret_word_shielded_array = shield_word(@secret_word_array)
  end

  # Number Number [Array-of Strings] -> String
  # Consumes a minimum word length, a maximum word length and a dictionary
  # Returns a randomly selected word in the dictonary matching the parameters
  # selected.
  def select_secret_word(min_word_length, max_word_length, source_dictionary)
    input_dictionary = source_dictionary.map(&:chomp)
    input_dictionary = input_dictionary.select { |word| word.length.between?(min_word_length, max_word_length) }
    input_dictionary.sample.downcase.split('')
  end

  # [Array-of 1Strings] -> [Array-of 1Strings]
  # Consumes an input word in the form of an array of letters and returns
  # an array of underscore of the same length.
  def shield_word(input_word)
    Array.new(input_word.length, '_')
  end

  # 1String [Array-of 1Strings] [Array-of 1Strings] -> [Array-of 1Strings]
  # Consumes an input letter, an input word in the form of an array of letters
  # and the same shielded input word in the form of an array of letters with
  # some letters hidden. Returns a shielded input word in the form of an array
  # of letters with the letters matching the input letter revealed.
  def guess(input_letter, input_secret_word_array, input_secret_word_shielded_array)
    (0..input_secret_word_array.length - 1).map do |index|
      if input_secret_word_array[index] == input_letter
        input_letter
      else
        input_secret_word_shielded_array[index]
      end
    end
  end

  # Nil -> 1String
  # Consumes nothing and returns a 1String that is checked as a downcase letter.
  def player_choice_acquisition
    user_input = nil
    until ('a'..'z').include?(user_input)
      puts 'Input your choosen downcase letter:'
      user_input = gets.chomp
    end
    user_input
  end

  # Number Number -> Boolean
  # Check if the iterations are equal to the eallowed turns.
  def no_more_iteration?(iteration, game_turns)
    if iteration >= game_turns
      puts 'YOU LOSE!'
      puts "The word was : #{@secret_word_array.join(' ')}"
      true
    else
      false
    end
  end

  # [Array-of 1Strings] [Array-of 1Strings] -> Boolean
  # Check if the iterations are equal to the eallowed turns.
  def game_won?(secret_word_shielded_array, secret_word_array)
    if secret_word_shielded_array == secret_word_array
      puts 'YOU WIN!'
      puts "The word was : #{@secret_word_array.join(' ')}"
      true
    else
      false
    end
  end

  # Main game loop
  def game_loop
    iteration = 0

    while iteration <= @game_turns

      puts "You have #{@game_turns - iteration} remaining guesses."

      break if no_more_iteration?(iteration, @game_turns)

      saved_secret_word_shielded_array = @secret_word_shielded_array.dup
      puts @secret_word_shielded_array.join(' ')
      @secret_word_shielded_array = guess(player_choice_acquisition, @secret_word_array, @secret_word_shielded_array)

      break if game_won?(@secret_word_shielded_array, @secret_word_array)

      iteration += 1 if saved_secret_word_shielded_array == @secret_word_shielded_array
    end
  end
end

new_game = HangmanGame.new(5, 12, 6)
new_game.game_loop

# Unit tests
assert_equal new_game.no_more_iteration?(3, 3), true
assert_equal new_game.no_more_iteration?(2, 3), false

assert_equal new_game.game_won?(%w[r a i n], %w[r a i n]), true
assert_equal new_game.game_won?(%w[r a i n], %w[r _ i _]), false

assert_equal new_game.select_secret_word(3, 5, %w[abracadabra raining dreaming life]), %w[l i f e]

assert_equal new_game.shield_word(%w[a b r a c a d a b r a]), %w[_ _ _ _ _ _ _ _ _ _ _]
assert_equal new_game.shield_word(%w[r a i n]), %w[_ _ _ _]

assert_equal new_game.guess('a', %w[a b r a c a d a b r a], %w[_ b _ _ c _ d _ b _ _]), %w[a b _ a c a d a b _ a]
assert_equal new_game.guess('n', %w[r a i n], %w[r _ _ _]), %w[r _ _ n]
