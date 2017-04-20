require 'json'

class Hangman
  attr_accessor :input, :text

  @@count = 8
  @@win = false
  @@guess_word = false
  @@give_feedback = false


  def start
    open_dictionary("dictionary.txt")
    selection_of_words
    randomize_word
    create_feedback_arrays
    rules
    until @@count == 0
      guess_whole_word
      user_input
      user_input_valid?
      win?
      feedback
      show_feedback
    end
  end
  
  def open_dictionary(filename)
    @dictionary = File.open(filename, 'r')
  end

  def selection_of_words
    @selected_words = []

    @dictionary.each do |word|
      if (word.strip.length >= 5 && word.strip.length <= 12)
        @selected_words << word
      end
    end
  end

  def randomize_word
    @word = @selected_words.sample.upcase!
    puts @word.strip!
  end

  def rules
    puts %{
      H A N G M A N - word guessing game

      Your task is simple. You have to guess the word before end of the game.
      Word is randomly selected from dictionary.
      It will be between 5 - 12 characters.
      You have #{@@count} turns to guess word. 
      You can guess whole word only at beginning of each turn.
      Otherwise you guess by entering letter from A - Z.
      After each turn You will be given feedback.
      Type 'SAVE' at the beginning of turn to save your game.
      Alternatively type 'LOAD' to load last saved game.
      Have fun!
    }
  end

  def show_user_options
    puts "\n"
    prompt = "> "

    puts %{
      ENTER ONE OF THE FOLLOWING:

         YES - to guess the word.
         NO  - to continue guessing letter.
         SAVE - to save Your game.
         LOAD - to load Your last saved game.
    }

    puts "... waiting for input ..."
  end

  def show_count
    puts "#{@@count} turns left."
  end

  def guess_whole_word
    show_user_options

    while @text = gets.chomp
      case @text.upcase
      when "YES"
        @@guess_word = true
        break
      when "NO"
        @@guess_word = false
        break
      when "SAVE"
        save_game
        puts "\n\n"
      when "LOAD"
        load_game
        puts "\n\n"
      else
        puts "\n"
        puts "INVALID INPUT !!! USE ONLY YES OR NO !!!"
        puts prompt
      end
    end
  end

  def user_input
    if @@guess_word == true
      puts "\n"
      puts "Guess your word now: "
      @text = gets.chomp
    else
      puts "\n"
      puts "Enter your letter: "

      prompt = "> "

      while @text = gets.chomp
        break if @text.length == 1
        puts "\n"
        puts "TOO MANY CHARACTERS! ENTER ONLY 1 CHARACTER FOR LETTER GUESSING!"
        puts prompt
      end
    end
  end

  def user_input_valid?    
    @input = @text.upcase
    
    if @input =~ /^[A-Za-z]*$/ 
      puts "\n"
      puts "Your input: #{@input}"
      @@count -= 1
      @@give_feedback = true
    else
      puts "\n"
      puts "INVALID INPUT! Please use only A-Z characters!"
    end
  end

  def win?
    if @input == @word
      puts "You won!"
      puts "Secret word: #{@word}"
      @@win = true
      exit
    end
  end

  def create_feedback_arrays
    @feedback = Array.new(@word.length, "-")
    @correct_letters = []
    @wrong_letters = []
  end

  def feedback
      word_array = @word.split("")

      word_array.each_with_index do |letter, index|
        if letter == @input
          @feedback[index] = letter
          @correct_letters << letter
        elsif !@word.include?(@input)
          @wrong_letters << @input
        end
      end
  end

  def show_feedback
    print "Word to guess (#{@word.length} characters): #{@feedback.join("")} \n"
    puts "Correct characters: #{@correct_letters.uniq.join("")}\n"
    puts "Wrong characters: #{@wrong_letters.uniq.join("")}\n"
    show_count
  end

  def to_json
    state = JSON.dump ({
       :count => @@count, :word => @word, :feedback => @feedback, :correct_letters => @correct_letters, 
       :wrong_letters => @wrong_letters
      })
    return state
  end

  def from_json(str)
    data = JSON.parse(str)
    @@count = data['count']
    @word = data['word']
    @feedback = data['feedback']
    @correct_letters = data['correct_letters']
    @wrong_letters = data['wrong_letters']
  end

  def save_game
    Dir.mkdir('saves') unless Dir.exist? 'saves'
    
    print "\nGive a name for Your save game: "
    save_name = gets.chomp
    Dir.chdir("saves")
    save_file = File.open(save_name,'w+')
    json_string = to_json

    save_file.write(json_string)
    save_file.close
    puts "\n........ SAVED GAME SUCCESSFULY!\n"
    show_user_options
  end

  def load_game

    if File.exist?('saves')
        puts "\n"
        puts "Enter savename to load: "

        Dir.foreach('saves') { |file| puts file unless file == '..' || file == '.'}

        not_picked = true
        file_input = nil

        while not_picked
            file_input = gets.chomp

            Dir.foreach('saves') { |file| not_picked = false if file == file_input}          
            puts "\n"
            puts "Pick a save game with appropriate name:\n\n" if not_picked == true
        
        end

        Dir.chdir("saves")
        file = File.readlines(file_input)
        from_json(file[0])
        puts "\n....LOADED SUCCESSFULY....\n"
        show_feedback
        show_user_options    
      else
        puts "\n"
        puts "No saved games detected!!\n"
      end
  end


end

game = Hangman.new
game.start
