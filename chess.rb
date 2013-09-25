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

      begin
        start_pos, end_pos = @current_player.move_prompt
        @board.move(start_pos, end_pos, @current_player.team_color)
        break if @board.checkmate?
      rescue ArgumentError => e #end
        puts "Invalid move. #{e.message}"
        retry
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

  def move(pos1, pos2, team_color)

    squares_dup = @squares.dup

    origin_contents = squares_dup[pos1[0]][pos1[1]]
    target_contents = squares_dup[pos2[0]][pos2[1]]

    if origin_contents.nil?
      raise ArgumentError.new "No piece at this location, pick again."
      return false
    elsif origin_contents.color != team_color
      raise ArgumentError.new "Wrong team, pick again."
      return false
    end

    # try the move to test for check and checkmate
    target_contents = origin_contents
    squares_dup[pos1[0]][pos1[1]] = nil

    if check?(squares_dup)
      raise ArgumentError.new "You are still in check, try again."
      return false
    elsif !target_contents.valid_move?(pos1, pos2)
      raise ArgumentError.new "Invalid move."
      return false
    else
      # perform the move
      @squares[pos2[0]][pos2[1]] = @squares[pos1[0]][pos1[1]]
      true
    end
  end

  def checkmate?(team_color)
    king = find_king(team_color)

    false
  end

  def check?(team_color)
    king_pos = find_king(team_color)

    @squares.each_with_index do |row, row_index|
      row.each_with_index do |square_contents, col_index|
        next if square_contents.nil?
        piece = square_contents
        if piece.color != team_color
          return true if piece.valid_moves.include?(king_pos)
        end
      end
    end
    false
  end


  def display
    puts
    @squares.each_with_index do |row, row_index|
      row.each_index do |col_index|
        square_contents = @squares[row_index][col_index]
        if square_contents.nil?
          print " __ "
        else
          color = square_contents.color.to_s.upcase
          type = square_contents.class.to_s.upcase
          print " #{SYMBOLS[color][type]}  "
        end
      end
      puts
    end
    puts
  end

  def find_king(team_color)
    @squares.each_with_index do |row, row_index|
      row.each_with_index do |square_contents, col_index|
        next if square_contents.nil?
        if square_contents.color == team_color && square_contents.is_a?(King)
          return [row_index, col_index]
        end
      end
    end
  end

end

class Player

  attr_reader :name, :team_color

  def initialize(team_color, name)
    @team_color = team_color
    @name = name
  end

  def move_prompt
    # prompt player to suppy start and end coordinates
    puts "#{self.team_color.capitalize}'s turn. Please move. (e.g. 1,2 2,2)"
    start_position, end_position = gets.chomp.split
    #  add error checking
    start_position = start_position.split(",").map(&:to_i)
    end_position = end_position.split(",").map(&:to_i)
    return [start_position, end_position]
  end

end


module Slider
  def valid_moves
    # recursively build move branch
    []
  end

  def moves

  end
end

module Stepper
  def valid_moves
    []
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

  def valid_moves
    []
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
