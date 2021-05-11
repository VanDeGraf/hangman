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
    print "Type your char: "
    input = gets.chomp
    until input.length == 1 && input.downcase.ord.between?(97, 122)
      print "Wrong input! Type 1 latin alphabetic char: "
      input = gets.chomp
    end
    input.downcase
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
end

hangman = Hangman.new
hangman.game
