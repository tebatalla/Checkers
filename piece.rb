require 'colorize'
require 'byebug'

class Piece
  attr_reader :color, :pos
  attr_accessor :board

  def initialize(color, pos, board, king = false)
    @color = color
    @pos = pos
    @board = board
    @king = king

    board[pos] = self
  end

  def inspect
      (king? ? "\u26C3" : "\u26C2").colorize(self.color)
  end

  def king?
    @king
  end

  def make_king
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

  def dup(board)
    Piece.new(self.color, self.pos.dup, board, self.king?)
  end

  def perform_moves!(sequence)
    if sequence.length == 1
      return if perform_slide(sequence.first)
      return if perform_jump(sequence.first)
      raise InvalidMoveError
    else
      sequence.each do |move|
        next if perform_jump(move)
        raise InvalidMoveError
      end
      true
    end
  end

  def valid_move_seq?(sequence)
    dup_board = board.dup
    begin
      dup_board[self.pos].perform_moves!(sequence)
    rescue InvalidMoveError
      false
    else
      true
    end
  end

  def perform_moves(sequence)
    if valid_move_seq?(sequence)
      perform_moves!(sequence)
    else
      raise InvalidMoveError
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
    begin
    if slide == :slide
      pos.all? { |coord| coord.between?(0,7) } && board[pos].nil? &&
      move_diffs.any? do |move|
        slide_diff(move) == pos
      end
    else
      pos.all? { |coord| coord.between?(0,7) } && board[pos].nil? &&
      move_diffs.any? do |move|
        jump_diff(move) == pos &&
          self.board[slide_diff(move[1])].color != color
      end
    end
    rescue NoMethodError
      false
    end
  end

  def direction
    self.color == :black ? :+ : :-
  end

  def slide_diff(move)
    [self.pos[0].send(direction, move[0]), self.pos[1] + move[1]]
  end

  def jump_diff(move)
    [self.pos[0].send(direction, move[0] * 2), self.pos[1] + (move[1] * 2)]
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
    if (color == :black && pos[0] == 7) || (color == :white && pos[0] == 0)
      make_king
    end
  end
end

class InvalidMoveError < RuntimeError
end
