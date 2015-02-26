require_relative 'piece.rb'

class Board
  attr_accessor :grid

  def initialize(fill_grid = true)
    @grid = make_grid
    populate_board if fill_grid
  end

  def [](pos)
    self.grid[pos[0]][pos[1]]
  end

  def []=(pos, piece)
    self.grid[pos[0]][pos[1]] = piece
  end

  def display
    i = 8
    tile = true
    self.grid.each do |row|
      row.each do |spot|
        print (spot ? " " + spot.inspect + "  " : " \u2003  ").colorize(tile_color(tile))
        tile = !tile
      end
      tile = !tile
      print "\n"
      i -= 1
    end
    nil
  end

  def dup
    duplicate = Board.new(false)

    pieces.each do |piece|
      piece.dup(duplicate)
    end

    duplicate
  end

  def move(sequence)
    start = sequence.shift
    self[start].perform_moves(sequence)
  end

  private

  def make_grid
    Array.new(8) { Array.new(8) { nil } }
  end

  def tile_color(toggle)
    return { background: toggle ? :white : :black }
  end

  def pieces
    self.grid.flatten.compact
  end

  def populate_board
    playable_tile = true
    self.grid.each_with_index do |row, row_i|
      if row_i < 3
        row.each_index do |tile|
          if playable_tile
            self[[row_i, tile]] = Piece.new(:black, [row_i, tile], self)
          end
          playable_tile = !playable_tile
        end
        playable_tile = !playable_tile
      elsif row_i > 4
        row.each_index do |tile|
          if playable_tile
            self[[row_i, tile]] = Piece.new(:white, [row_i, tile], self)
          end
          playable_tile = !playable_tile
        end
        playable_tile = !playable_tile
      end
    end
    self.display
  end
end
