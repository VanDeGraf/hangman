require "json"

class Hangman
  $words_file_name = "5desk.txt"
  $default_max_mistakes = 6

  def initialize(word = get_random_word, mistakes = $default_max_mistakes)
    @true_chars = []
    @false_chars = []
    @word = word
    @max_mistakes = mistakes
    @victory = nil
  end

  public

  def game
    puts "Note: You can save and load your progress with the appropriate commands + save file name."
    until game_end?
      print_status
      user_char = user_input
      while @false_chars.include?(user_char) || @true_chars.include?(user_char)
        puts "You alrady type this char before! Try another!"
        user_char = user_input
      end
      if @word.chars.include?(user_char)
        @true_chars << user_char
        puts "Lucky! This char is in word!"
      else
        @false_chars << user_char
        puts "Unlucky! This char isn't in word!"
      end
    end
    print_status
    if @victory
      puts "You Win! Word is #{@word}!"
    else
      puts "You Lose, because you make too many mistakes! Word is #{@word}!"
    end
  end

  private

  def user_input
    print "Type your char or command: "
    wrong_input_flag = true
    input = gets.chomp
    loop do
      return input.downcase if input.length == 1 && input.downcase.ord.between?(97, 122)
      if input.match?(/save .+/) || input.match?(/load .+/)
        command, filename = input.split(" ", 2)
        unless filename == filename.match(/[a-zA-Z0-9_\-]+/)[0]
          print "Wrong filename, it may contain [a-zA-Z0-9_-]! Type 1 latin alphabetic char or command: "
          input = gets.chomp
          next
        end
        if command == "save"
          game_save(filename)
          puts "Game saved!"
        elsif command == "load"
          game_load!(filename)
          puts "Game loaded!"
          print_status
        end
        print "Type your char or command: "
        input = gets.chomp
        next
      end
      print "Wrong input! Type 1 latin alphabetic char or command: "
      input = gets.chomp
    end
  end

  def get_random_word
    Exception.new("Not found file with word!") unless File.exists?($words_file_name)
    words = File.new($words_file_name, File::RDONLY).readlines.map do |word|
      word.chomp!
      if word.length.between?(5, 12)
        word
      else
        nil
      end
    end
    words.compact.sample.downcase
  end

  def print_status
    chars = @word.chars.map do |char|
      @true_chars.include?(char) ? char : "_"
    end
    output = "Word: [ #{chars.join(" ")} ] "
    output << "Mistakes: #{@false_chars.length}/#{@max_mistakes} "
    output << "Wrong chars: #{@false_chars.join(",")} "
    puts output
  end

  def game_end?
    if @false_chars.length == @max_mistakes
      @victory = false
      return true
    end
    @word.chars.uniq.each { |char| return false unless @true_chars.include?(char) }
    @victory = true
    true
  end

  def game_save(save_name)
    Dir.mkdir("saves") unless Dir.exists?("saves")
    file = File.open("saves/#{save_name}.json", File::CREAT | File::TRUNC | File::WRONLY)
    file.write JSON.dump({
      :true_chars => @true_chars,
      :false_chars => @false_chars,
      :word => @word,
      :max_mistakes => @max_mistakes,
    })
    file.close
  end

  def self.game_load(save_name)
    game = self.new
    game.game_load!(save_name)
    game
  end

  def game_load!(save_name)
    Exception.new("Save file not found!") unless File.exists?("saves/#{save_name}.json")
    file = File.open("saves/#{save_name}.json", File::RDONLY)
    dump = JSON.load(file.read, :symbolize_names => true)
    @true_chars = dump["true_chars"]
    @false_chars = dump["false_chars"]
    @word = dump["word"]
    @max_mistakes = dump["max_mistakes"]
    file.close
  end
end

hangman = Hangman.new
hangman.game
