require_relative 'pieces/bishop'
require_relative 'pieces/king'
require_relative 'pieces/knight'
require_relative 'pieces/pawn'
require_relative 'pieces/queen'
require_relative 'pieces/rook'
require_relative 'empty_square'
require 'colorize'
require 'byebug'

class Board
  attr_accessor :selected_pos, :grid, :current_player, :cursor_pos
  attr_reader :game

  def initialize(game, player = :blue, cursor_pos = [0, 0], selected_pos = nil)
    @cursor_pos = cursor_pos
    @selected_pos = selected_pos
    @current_player = player
    @game = game
  end

  def [](row, col)
    grid[row][col]
  end

  def []=(row, col, value)
    grid[row][col] = value
  end

  def move(start_pos = selected_pos, end_pos = cursor_pos)
    piece = self[*start_pos]

    if piece.valid_move?(end_pos)
      move!(start_pos, end_pos)
    else
      raise_move_error(piece, end_pos)
    end
  end

  def move!(start_pos = selected_pos, end_pos = cursor_pos)
    current_piece = self[*start_pos]
    self[*end_pos] = current_piece
    self[*start_pos] = EmptySquare.new
    current_piece.pos = end_pos
  end

  def switch_players!
    self.current_player = other_player
  end

  def reset_selected_pos
    self.selected_pos = nil
  end

  def set_selected_pos
    if self[*cursor_pos].color == current_player
      self.selected_pos = cursor_pos
    end
  end

  def in_check?(color)
    other_player = color == :blue ? :black : :blue
    king_piece = pieces(color).select { |piece| piece.king? }.first
    king_pos = king_piece.pos
    pieces(other_player).any? { |piece| piece.valid_move?(king_pos) }
  end

  def checkmate?(color)
    in_check?(color) && pieces(color).all? { |piece| piece.valid_moves.empty? }
  end

  def pieces(color)
    grid.flatten.select { |square| square.color == color }
  end

  def positions
    (0..7).map { |row| (0..7).map { |col| [row, col] } }.inject(&:+)
  end

  def populate_grid
    grid = Array.new(8)
    grid[0], grid[7] = other_piece_row(:black), other_piece_row(:blue)
    grid[1], grid[6] = pawn_row(:black), pawn_row(:blue)
    2.upto(5) { |row| grid[row] = empty_row }
    @grid = grid
  end

  def empty_row
    Array.new(8) { EmptySquare.new }
  end

  def pawn_row(color)
    row_idx = color == :blue ? 6 : 1

    (0..7).map { |col| Pawn.new(color, self, [row_idx, col]) }
  end

  def other_piece_row(color)
    row_idx = color == :blue ? 7 : 0

    new_pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]

    new_pieces.map.with_index do |piece, col_idx|
      piece.new(color, self, [row_idx, col_idx])
    end
  end

  def cursor_up
    if cursor_pos.first > 0
      new_pos = [cursor_pos.first - 1, cursor_pos.last]
      self.cursor_pos = new_pos
    end
  end

  def cursor_down
    if cursor_pos.first < 7
      new_pos = [cursor_pos.first + 1, cursor_pos.last]
      self.cursor_pos = new_pos
    end
  end

  def cursor_right
    if cursor_pos.last < 7
      new_pos = [cursor_pos.first, cursor_pos.last + 1]
      self.cursor_pos = new_pos
    end
  end

  def cursor_left
    if cursor_pos.last > 0
      new_pos = [cursor_pos.first, cursor_pos.last - 1]
      self.cursor_pos = new_pos
    end
  end

  def display
    puts render
  end

  def dup
    new_selected_pos = selected_pos ? selected_pos.dup : selected_pos
    new_board = Board.new(current_player, cursor_pos.dup, new_selected_pos)
    new_board.grid = grid.map { |row| row.map { |piece| piece.dup(new_board) } }
    new_board
  end

  def inspect
    nil
  end

  def raise_move_error(piece, end_pos)
    if piece.moves_into_check?(end_pos)
      raise MoveError.new "Can't make a move that leaves you in check."
    else
      raise MoveError.new "Invalid move."
    end
  end

  def other_player
    (current_player == :black) ? :blue : :black
  end

  def is_human?
    self.game.current_player.is_a?(HumanPlayer)
  end

  def render
    grid.map.with_index do |row, r_idx|
      render_row(row, r_idx)
    end.join("\n")
  end

  def render_row(row, r_idx)
    row.map.with_index do |cell, c_idx|
      selected_piece = selected_pos.nil? ? nil : self[*selected_pos]
      cursor_piece = self[*cursor_pos]

      if [r_idx, c_idx] == cursor_pos && is_human?
        cell.to_s.colorize(background: :yellow)
      elsif selected_pos && selected_piece.valid_move?([r_idx, c_idx]) &&
            selected_piece.color == current_player && is_human?
        cell.to_s.colorize(background: :green)
      elsif selected_pos.nil? && cursor_piece.valid_move?([r_idx, c_idx]) &&
            cursor_piece.color == current_player && is_human?
        cell.to_s.colorize(background: :green)
      elsif (r_idx + c_idx) % 2 == 0
        cell.to_s.colorize(background: :light_black)
      else
        cell.to_s.colorize(background: :white)
      end
    end.join('')
  end

end
