require_relative 'board'
require_relative 'players/human_player'
require_relative 'players/computer_player'
require 'io/console'

class Game
  attr_reader :board
  attr_accessor :players

  def initialize(player1, player2)
    @board = Board.new(self)
    board.populate_grid
    @players = [player1, player2]
    @players.each { |player| player.board = board}
  end

  def self.setup_players
    puts "Player 1 has piece color blue. Human or computer?('h' for human, 'c' for computer)"
    player1 = setup_player(:blue)
    puts "Player 2 has piece color black. Human or computer?('h' for human, 'c' for computer)"
    player2 = setup_player(:black)

    [player1, player2]
  end

  def self.setup_player(color)
    input = gets.chomp.downcase
    until ["h", "c"].include?(input)
      puts "Invalid input. 'h' for human, 'c' for computer."
      input = gets.chomp.downcase
    end

    input == "h" ? HumanPlayer.new(color) : ComputerPlayer.new(color)
  end

  def play
    until checkmate?
      get_move
      switch_players!
    end
    render_board
  end

  def current_player
    players.first
  end

  private

  def get_move
    moved = false
    until moved
      render_board
      moved = current_player.make_move
    end
  end

  def checkmate?
    board.checkmate?(current_player.color)
  end

  def switch_players!
    players.reverse!
    board.switch_players!
  end

  def render_board
    system('clear')
    board.display

    if checkmate?
      puts "Checkmate! #{current_player.color.to_s.capitalize} player loses."
    else
      puts "#{current_player.color.to_s.capitalize}'s turn"
      puts "Check" if board.in_check?(current_player.color)
    end

    sleep(1) if players.all? { |player| player.is_a?(ComputerPlayer) }
  end

end

if __FILE__ == $PROGRAM_NAME
  player1, player2 = Game.setup_players
  g = Game.new(player1, player2)
  g.play
end
