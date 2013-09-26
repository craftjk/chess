require "debugger"

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
      puts "#{@board.object_id}"
      @board.display
      puts "You are in check!" if @board.check?(@current_player.team_color)
      begin
        start_pos, end_pos = @current_player.move_prompt
        @board.move(start_pos, end_pos, @current_player.team_color)
        break if @board.checkmate?(@current_player.team_color)
      rescue ArgumentError => e #end
        p "#{e}"
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
      puts "Checkmate. #{@current_player.name} wins!"
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
    pre_move_validation(pos1, pos2, team_color)

    # store what's in the square we want to move into, into a variable
    pos2_obj = self[pos2]

    # make the move and check that it's valid
    self[pos2], self[pos1] = self[pos1], nil


    # if invalid, return piece to pos1 and have pos2 = variable
    # raise error

    if check?(team_color)
      self[pos1], self[pos2] = self[pos2], pos2_obj
      raise ArgumentError.new "You are still in check, try again."
    end

  end

  def avoid_checkmate?(pos1, pos2, team_color)
    # store what's in the square we want to move into, into a variable
    pos2_obj = self[pos2]

    # make the move and check that it's valid
    self[pos2], self[pos1] = self[pos1], nil


    # if invalid, return piece to pos1 and have pos2 = variable
    # raise error

    if !check?(team_color)
      self[pos1], self[pos2] = self[pos2], pos2_obj
      return true
    else
      self[pos1], self[pos2] = self[pos2], pos2_obj
    end

    return false
  end

  def pre_move_validation(pos1, pos2, team_color)

    if self[pos1].nil?
      raise ArgumentError.new "No piece at this location, pick again."
    elsif self[pos1].color != team_color
      raise ArgumentError.new "Wrong team, pick again."
    elsif !self[pos2].nil? && self[pos2].color == team_color
      raise ArgumentError.new "Can't move onto your own piece, pick again."
    elsif !valid_move?(pos1, pos2, team_color)
      raise ArgumentError.new "Invalid move."
    end
    true
  end
  #
  # def validate_move(pos1, pos2, team_color)
  #   test_board = deep_dup(@squares)
  #   test_board[pos2[0]][pos2[1]] = test_board[pos1[0]][pos1[1]]
  #   test_board[pos1[0]][pos1[1]] = nil
  #
  #   if test_board.check?(team_color)
  #     raise ArgumentError.new "You are still in check, try again."
  #   end
  #   true
  # end

  def valid_moves(pos1, team_color)

    piece = self[pos1]
    test_moves = piece.potential_moves(pos1, team_color)
    # pawn goes first because it is exceptional
    if piece.is_a?(Pawn)
      invalid_moves = []

      invalid_moves << test_moves[0] if !self[test_moves[0]].nil?

      if !self[test_moves[1]].nil? || !path_is_clear?(pos1, test_moves[1])
        invalid_moves << test_moves[1]
      end

      if piece.color == :black
        invalid_moves << test_moves[1] if pos1[0] != 1
      end

      if piece.color == :white
        invalid_moves << test_moves[1] if pos1[0] != 6
      end

      if self[test_moves[2]].nil? || self[test_moves[2]].color == team_color
        invalid_moves << test_moves[2]
      end

      unless test_moves[3].nil?
        if self[test_moves[3]].nil? || self[test_moves[3]].color == team_color
          invalid_moves << test_moves[3]
        end
      end

      test_moves.delete_if{ |move| invalid_moves.include?(move) }

    end

    # delete if moving onto your own piece
    test_moves.delete_if do |test_pos|
      self[test_pos].is_a?(Piece) && self[test_pos].color == team_color
    end

    if piece.is_a?(Slider)
      test_moves.keep_if { |test_pos| path_is_clear?(pos1, test_pos) }
    end

    #test_moves.delete_if(#move doesn't skip over a piece)

    # test_moves.delete_if(#king is in check after move)
    test_moves
  end

  def path_is_clear?(pos1, pos2)
    # pos2 == your piece vs pos2 == opponent's piece
    drow = pos2[0] <=> pos1[0]
    dcol = pos2[1] <=> pos1[1]

    new_pos_row = pos1[0] + drow
    new_pos_col = pos1[1] + dcol

    # new_pos = new_pos_row, new_pos_col
    until [new_pos_row, new_pos_col] == pos2
      return false if @squares[new_pos_row][new_pos_col].is_a?(Piece)
      new_pos_row += drow
      new_pos_col += dcol
    end
    true
  end

  def valid_move?(pos1, pos2, team_color)
    valid_moves = valid_moves(pos1, team_color)
    valid_moves.include?(pos2)
  end



  def checkmate?(team_color)
    king_pos = find_king(team_color)
    attacking_team_color = (team_color == :black) ? :white : :black

    checkmate_avoided = false
    @squares.each_with_index do |row, row_index|
      row.each_with_index do |square_contents, col_index|
        next if square_contents.nil?
        piece = square_contents
        if piece.color == team_color
          valid_moves([row_index, col_index], team_color).each do |move|
            checkmate_avoided = avoid_checkmate?([row_index, col_index], move, team_color)
            return true if checkmate_avoided == true
          end
        end
      end
    end

    #  1) king is in check
    #  3) none of his pieces can move between him and the attacker so that he's no longer in check'
    # => loop through every other piece and see if a valid move from them puts them in between
    #     the attacker so that the king is no longer in check
    false
  end

  def check?(team_color)
    king_pos = find_king(team_color)
    attacking_team_color = (team_color == :black) ? :white : :black

    @squares.each_with_index do |row, row_index|
      row.each_with_index do |square_contents, col_index|
        next if square_contents.nil?
        piece = square_contents
        if piece.color != team_color
          return true if valid_moves([row_index, col_index], attacking_team_color).include?(king_pos)
        end
      end
    end
    false
  end

  def deep_dup(array)
    deep_copy = []
    array.each do |check_case|
      if check_case.is_a?(Array)
        deep_copy << deep_dup(check_case)
      else
        deep_copy << check_case.dup unless check_case.nil?
      end
    end
    deep_copy
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

  def [](pos)
    row = pos[0]
    col = pos[1]
    @squares[row][col]
  end

  def []=(pos, value)
    row = pos[0]
    col = pos[1]
    @squares[row][col] = value
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
  def potential_moves(pos, color)
    potential_moves = []
    posx, posy = pos
    move_dir.each do |dx,dy|
      newy = posy
      newx = posx
      7.times do
        newx += dx
        newy += dy
        potential_moves << [newx, newy]
      end
    end
    potential_moves.select { |x, y| x.between?(0,7) && y.between?(0,7) }
  end
end

module Stepper
  def potential_moves(pos, color)
    potential_moves = []
    posx, posy = pos
    move_dir.each do |dx,dy|
      newy = posy
      newx = posx
      newx += dx
      newy += dy
      potential_moves << [newx, newy]
    end
    potential_moves.select { |x, y| x.between?(0,7) && y.between?(0,7) }
  end
end

class Piece
  attr_accessor :color

  def initialize(team_color)
    @color = team_color
  end

end

class Pawn < Piece
  def initialize(color)
    super(color)
  end

  def potential_moves(pos, color)
    #
    potential_moves_arr = []
    posx, posy = pos
    move_dir.each do |dx,dy|
      if color == :white
        dx *= -1
        dy *= -1
      end
      newy = posy
      newx = posx
      newx += dx
      newy += dy
      potential_moves_arr << [newx, newy]
    end
    potential_moves_arr.select { |x, y| x.between?(0,7) && y.between?(0,7) }
  end

  def move_dir
    [[1,0],[2,0],[1,1],[1,-1]]
  end

end

class Rook < Piece
  include Slider

  def initialize(color)
    super(color)

  end

  def move_dir
    [[1,0],[0,-1],[-1,0],[0,1]]
  end

end

class Bishop < Piece
  include Slider

  def initialize(color)
    super(color)
  end

  def move_dir
    [[1,1],[1,-1],[-1,-1],[-1,1]]
  end

end

class Knight < Piece
  include Stepper

  def initialize(color)
    super(color)
  end

  def move_dir
    [[1,2],[2,1],[2,-1],[1,-2],[-1,-2],[-2,-1],[-2,1],[-1,2]]
  end

end

class King < Piece
  include Stepper

  def initialize(color)
    super(color)
  end

  def move_dir
    [[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1]]
  end

end

class Queen < Piece
  include Slider

  def initialize(color)
    super(color)
  end

  def move_dir
    [[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1]]
  end

end




g = Game.new


g.board.move([6,4],[4,4], :white)
g.board.move([1,6],[3,6], :black)
g.board.move([6,0],[5,0], :white)
g.board.move([1,5],[2,5], :black)

g.run



=begin

Refactoring ideas
Implement the [] method in board class to access squares more easily
Refactor setup_board
=end