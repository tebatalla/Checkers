require_relative 'piece.rb'

class Board
  attr_accessor :grid

  def initialize(fill_grid = true)
    @grid = make_grid
    populate_board if fill_grid
  end

  def inspect
  end

  def [](pos)
    self.grid[pos[0]][pos[1]]
  end

  def []=(pos, piece)
    self.grid[pos[0]][pos[1]] = piece
  end

  def display
    i = 0
    tile = true
    puts "  0  1  2  3  4  5  6  7 "
    self.grid.each do |row|
      print "#{i}"
      row.each do |spot|
        print (spot ? " " + spot.inspect + " " : " \u2003 ").colorize(tile_color(tile))
        tile = !tile
      end
      print " #{i}\n"
      tile = !tile
      i += 1
    end
    puts "  0  1  2  3  4  5  6  7 "
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

  def pieces
    self.grid.flatten.compact
  end
  
  private

  def make_grid
    Array.new(8) { Array.new(8) { nil } }
  end

  def tile_color(toggle)
    return { background: toggle ? :red : :black }
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
    nil
  end
end
