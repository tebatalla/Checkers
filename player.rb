require_relative 'board'

class HumanPlayer
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def play_turn(board, color)
    render_board(board)
    moves = []
    begin
      puts "#{name} (#{color}), make your move. First, pick a piece"
      piece = gets.chomp.gsub(/\s+/, "").split(",").map(&:to_i)
      loop do
        puts "Where would you like to move this piece to?"
        moves << gets.chomp.gsub(/\s+/, "").split(",").map(&:to_i)
        puts "Any more moves for this piece? (y/n)"
        break unless gets.chomp == "y"
      end
      debugger
      board.move([piece], moves)
    rescue InvalidMoveError
      render_board(board)
      puts "That was an invalid move, try again."
      retry
    rescue NotSameColor
      render_board(board)
      puts "That is not your piece, try again."
      retry
    rescue
      render_board(board)
      puts "Something went wrong, try again."
      retry
    end
  end

  def render_board(board)
    system "clear"
    board.display
  end
end

class ComputerPlayer
  attr_reader :name

  def initialize
    @name = "Beep boop beep"
  end

  def play_turn

  end
end
