class Game
  def initialize
    @board = Board.new
    @player2 = Player.new(team_color = :black, name = "Player 2")
    @player1 = Player.new(team_color = :white), name = "Player 1"
    @current_player = @player1
  end

  def run
    #  until game_finished?
    #    @board.display
    #    check for checkmate
    #    prompt current player to move
    #    make move (validate until move works)
    #    set current player to the other player
    #  end
    #  display_results
  end

  def game_finished?
    #  board.checkmate?
    #
  end

  def switch_players
    @current_player = (@current_player == @player1) ?  @player2 : @player1
  end

  def display_results
    switch_players
    puts "Checkmate. #{current_player.name} wins!"
  end

end


class Board
  def initialize
    setup_board
  end

  def setup_board
  end


end

class Player
  def initialize(team_color, name)
    @team_color = team_color
    @name = name
  end
end


module Slider
end

module Stepper
end

class Piece
end

class Pawn < Piece
end

class Rook < Piece
end

class Bishop < Piece
end

class Knight < Piece
end

class King < Piece
end

class Queen < Piece
end
