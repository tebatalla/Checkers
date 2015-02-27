require_relative 'board'
require_relative 'player'

class Game
  attr_accessor :board, :current_player
  attr_reader :players

  def initialize(player1, player2)
    @players = {
      black: player1,
      white: player2
    }
    @current_player = :black
    @board = Board.new
  end

  def inspect
    "Game created with #{players[:black].name} and #{players[:white].name}." +
    " To start the game, call play on the game object!"
  end

  def play
    until over?
      players[current_player].play_turn(self.board, current_player)
      toggle_current_player
    end
    toggle_current_player
    over_message
  end

  private

  def toggle_current_player
    self.current_player = current_player == :black ? :white : :black
  end

  def over_message
    puts "Game is over, #{players[current_player].name} wins!"
  end

  def over?
    board.pieces.none? { |piece| piece != @current_player }
  end
end
