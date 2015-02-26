require 'colorize'
require 'byebug'

class Piece
  attr_reader :color, :pos
  attr_accessor :board

  def initialize(color, pos, board)
    @color = color
    @pos = pos
    @board = board
    @king = false
  end

  def inspect
    self.color == :black ? "\u26AB" : "\u26AA"
  end

  def king?
    @king
  end

  def kinged
    @king = true
  end

  def pos=(pos)
    self.board[self.pos] = nil
    @pos = pos
    self.board[self.pos] = self
  end

  def perform_slide(pos)
    if valid_pos?(pos, :slide)
      self.pos = pos
      maybe_promote
      true
    else
      false
    end
  end

  def perform_jump(pos)
    if valid_pos?(pos, :jump)
      remove_piece(jumped_piece(pos))
      self.pos = pos
      maybe_promote
      true
    else
      return false
    end
  end

  private

  def remove_piece(piece)
    self.board[piece.pos] = nil
  end

  def move_diffs
    [[1, -1], [1, 1]] + (king? ? king_diffs : [])
  end

  def king_diffs
    [
      [-1, 1],
      [-1, -1]
    ]
  end

  def valid_pos?(pos, slide)
    if slide == :slide
      pos.all? { |coord| coord.between?(0,7) } && board[pos].nil? &&
      move_diffs.any? do |move|
        slide_diff(move[1]) == pos
      end
    else
      pos.all? { |coord| coord.between?(0,7) } && board[pos].nil? &&
      move_diffs.none? do |move|
        jump_diff(move[1]) == pos && self.board[slide_diff(move[1])].color != color
      end
    end
  end

  def direction
    self.color == :black ? :+ : :-
  end

  def slide_diff(move)
    [self.pos[0].send(direction, 1), self.pos[1] + move[1]]
  end

  def jump_diff(move)
    [self.pos[0].send(direction, 2), self.pos[1] + (move[1] * 2)]
  end

  def jumped_piece(pos)
    horizontal = pos[1] > self.pos[1] ? :+ : :-
    jump_pos = [
      (self.pos[0].send(direction, 1)),
      (self.pos[1].send(horizontal, 1))
    ]
    self.board[jump_pos]
  end

  def maybe_promote
    kinged if (color == :black && pos[0] == 7) || (color == :white && pos[0] == 0)
  end
end
