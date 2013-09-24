class Game

  attr_accessor :board

  def initialize
    @player2 = Player.new(team_color = :black, name = "Player 2")
    @player1 = Player.new(team_color = :white, name = "Player 1")
    @current_player = @player1
    @board = Board.new
  end

  def run
    welcome
    until game_finished?
      @board.display

      successful_move = false
      until successful_move
        start_pos, end_pos = @current_player.move_prompt
        successful_move = @board.move(start_pos, end_pos)
        break if @board.checkmate?
      end
      switch_players
    end
    display_results
  end

  private

    def game_finished?
      #  board.checkmate?
      false
    end

    def switch_players
      @current_player = (@current_player == @player1) ?  @player2 : @player1
    end

    def display_results
      switch_players
      puts "Checkmate. #{current_player.name} wins!"
    end

    def welcome
      puts "welcome to chess"
    end

    def move_prompt
      # prompt player to suppy start and end coordinates
      puts "#{@current_player.name}'s turn. Please move. (e.g. 1,2 2,2)"
      start_position, end_position = gets.chomp.split
      #  add error checking
      start_position = start_position.split(",").map(&:to_i)
      end_position = end_position.split(",").map(&:to_i)
      return [start_position, end_position]
    end

end


class Board

  SYMBOLS = {
    "BLACK" => {
      "KING" => "\u265A",
      "QUEEN" => "\u265B",
      "ROOK" => "\u265C",
      "BISHOP" => "\u265D",
      "KNIGHT" => "\u265E",
      "PAWN" => "\u265F"
    },

    "WHITE" => {
      "KING" => "\u2654",
      "QUEEN" => "\u2655",
      "ROOK" => "\u2656",
      "BISHOP" => "\u2657",
      "KNIGHT" => "\u2658",
      "PAWN" => "\u2659"
    }
  }

  attr_accessor :squares

  def initialize
    @squares = []

    setup_board
  end

  def setup_board
     @squares = Array.new(8) { Array.new(8) }

     team_color = :black
     @squares[0][0], @squares[0][7] = Rook.new(team_color), Rook.new(team_color)
     @squares[0][1], @squares[0][6] = Knight.new(team_color), Knight.new(team_color)
     @squares[0][2], @squares[0][5] = Bishop.new(team_color), Bishop.new(team_color)
     @squares[0][3] =                 Queen.new(team_color)
     @squares[0][4] =                 King.new(team_color)
     (0..7).each { |col| @squares[1][col] = Pawn.new(team_color) }

     team_color = :white
     @squares[7][0], @squares[7][7] = Rook.new(team_color), Rook.new(team_color)
     @squares[7][1], @squares[7][6] = Knight.new(team_color), Knight.new(team_color)
     @squares[7][2], @squares[7][5] = Bishop.new(team_color), Bishop.new(team_color)
     @squares[7][3] =                 Queen.new(team_color)
     @squares[7][4] =                 King.new(team_color)
     (0..7).each { |col| @squares[6][col] = Pawn.new(team_color) }

  end

  def move(pos1, pos2)
    #  raise error and return false if...
    #     if attempted move will place you in check
    #     if your pos1 has no pieces
    #     if you try to move the wrong piece
    #
    @squares[pos2[0]][pos2[1]] = @squares[pos1[0]][pos1[1]]
    #
    #  raise error and return false if...
    #     if it's not a valid move (check if pos2 is in valid moves array)
    #     if you are still in check after the move

    #  update board with the piece in its new location

    return true
  end

  def checkmate?(player)
    return false # placeholder
  end

  def check?(player)
  end

  def display
    @squares.each_with_index do |row, row_index|
      row.each_index do |col_index|
        square_contents = @squares[row_index][col_index]
        if square_contents.nil?
          print " "
        else
          color = square_contents.color.to_s.upcase
          type = square_contents.class.to_s.upcase
          print SYMBOLS[color][type]
        end
      end
      puts
    end
  end

end

class Player
  def initialize(team_color, name)
    @team_color = team_color
    @name = name
  end
end


module Slider
  def valid_moves
    # recursively build move branch

  end

  def moves

  end
end

module Stepper
  def valid_moves

  end

  def moves

  end
end

class Piece
  attr_accessor :color

  def initialize(team_color)
    @color = team_color
  end


  def valid_move?(pos1, pos2)

  end

end

class Pawn < Piece

  def initialize(color)
    super(color)
  end

  def move_dir

  end

end

class Rook < Piece
  include Slider

  def initialize(color)
    super(color)
  end

  def move_dir

  end

end

class Bishop < Piece
  include Slider

  def initialize(color)
    super(color)
  end

  def move_dir

  end

end

class Knight < Piece
  include Stepper

  def initialize(color)
    super(color)
  end

  def move_dir

  end

end

class King < Piece
  include Stepper

  def initialize(color)
    super(color)
  end

  def move_dir

  end

end

class Queen < Piece
  include Slider

  def initialize(color)
    super(color)
  end

  def move_dir

  end

end
