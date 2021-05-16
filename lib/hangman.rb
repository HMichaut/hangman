# frozen_string_literal: true

require 'yaml'

# class representing a game of hangman
class HangmanGame
  # initialize with input to allow adjustng the game difficulty easily
  def initialize(min_word_length, max_word_length, game_turns)
    @min_word_length = min_word_length
    @max_word_length = max_word_length
    @game_turns = game_turns
    @iteration = 0
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
      puts 'Input your choosen downcase letter or save:'
      user_input = gets.chomp
      open('hangman.yaml', 'w') { |f| YAML.dump(self, f) } if user_input == 'save'
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
    while @iteration <= @game_turns

      puts "You have #{@game_turns - @iteration} remaining guesses."

      break if no_more_iteration?(@iteration, @game_turns)

      saved_secret_word_shielded_array = @secret_word_shielded_array.dup
      puts @secret_word_shielded_array.join(' ')
      @secret_word_shielded_array = guess(player_choice_acquisition, @secret_word_array, @secret_word_shielded_array)

      break if game_won?(@secret_word_shielded_array, @secret_word_array)

      @iteration += 1 if saved_secret_word_shielded_array == @secret_word_shielded_array
    end
  end
end

# Select new game or load previous game
def new_game_or_load
  user_input = nil
  until %w[y n].include?(user_input)
    puts 'Load saved game? y / n'
    user_input = gets.chomp
    if user_input == 'y'
      loaded_game = open('hangman.yaml', 'r') { |f| YAML.safe_load(f, [HangmanGame]) }
      loaded_game.game_loop
    else
      new_game = HangmanGame.new(5, 12, 6)
      new_game.game_loop
    end
  end
end

new_game_or_load
