# DON'T EDIT ME!

class Board
  attr_reader :rows

  def self.blank_grid
    Array.new(3) { Array.new(3) }
  end

  def initialize(rows = self.class.blank_grid)
    @rows = rows
  end

  def [](pos)
    x, y = pos[0], pos[1]
    @rows[x][y]
  end

  def []=(pos, mark)
    raise "mark already placed there!" unless empty?(pos)

    x, y = pos[0], pos[1]
    @rows[x][y] = mark
  end

  def cols
    cols = [[], [], []]
    @rows.each do |row|
      row.each_with_index do |mark, col_idx|
        cols[col_idx] << mark
      end
    end

    cols
  end

  def diagonals
    down_diag = [[0, 0], [1, 1], [2, 2]]
    up_diag = [[0, 2], [1, 1], [2, 0]]

    [down_diag, up_diag].map do |diag|
      # Note the `x, y` inside the block; this unpacks, or
      # "destructures" the argument. Read more here:
      # http://tony.pitluga.com/2011/08/08/destructuring-with-ruby.html
      diag.map { |x, y| @rows[x][y] }
    end
  end

  def dup
    duped_rows = rows.map(&:dup)
    self.class.new(duped_rows)
  end

  def empty?(pos)
    self[pos].nil?
  end

  def tied?
    return false if won?

    # no empty space?
    @rows.all? { |row| row.none? { |el| el.nil? }}
  end

  def over?
    # style guide says to use `or`, but I (and most others) prefer to
    # use `||` all the time. We don't like two ways to do something
    # this simple.
    won? || tied?
  end

  def winner
    (rows + cols + diagonals).each do |triple|
      return :x if triple == [:x, :x, :x]
      return :o if triple == [:o, :o, :o]
    end

    nil
  end

  def won?
    !winner.nil?
  end
end

# Notice how the Board has the basic rules of the game, but no logic
# for actually prompting the user for moves. This is a rigorous
# decomposition of the "game state" into its own pure object
# unconcerned with how moves are processed.

class TicTacToe
  class IllegalMoveError < RuntimeError
  end

  attr_reader :board, :players, :turn

  def initialize(player1, player2, board = Board.new)
    #@board = Board.new
    @players = { :x => player1, :o => player2 }
    @turn = :x
    @board = board
  end

  def run
    until self.board.over?
      play_turn
    end

    if self.board.won?
      winning_player = self.players[self.board.winner]
      self.show
      puts "#{winning_player.name} won the game!"
    else
      self.show
      puts "No one wins!"
    end
  end

  def show
    puts ""
    self.board.rows.each { |row| p row }
    puts ""
  end

  private
  def place_mark(pos, mark)
    if self.board.empty?(pos)
      self.board[pos] = mark
      true
    else
      false
    end
  end

  def play_turn
    while true
      current_player = self.players[self.turn]
      pos = current_player.move(self, self.turn)

      break if place_mark(pos, self.turn)
    end

    # swap next whose turn it will be next
    @turn = ((self.turn == :x) ? :o : :x)
  end
end

class HumanPlayer
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def move(game, mark)
    game.show
    while true
      puts "#{@name}: please select your space"
      x, y = gets.chomp.split(",").map(&:to_i)
      if HumanPlayer.valid_coord?(x, y)
        return [x, y]
      else
        puts "Invalid coordinate!"
      end
    end
  end

  private
  def self.valid_coord?(x, y)
    [x, y].all? { |coord| (0..2).include?(coord) }
  end
end

class ComputerPlayer
  attr_reader :name

  def initialize
    @name = "HAL"
  end

  def move(game, mark)
    winner_move(game, mark) || random_move(game)
  end

  private
  def winner_move(game, mark)
    (0..2).each do |x|
      (0..2).each do |y|
        board = game.board.dup
        pos = [x, y]

        next unless board.empty?(pos)
        board[pos] = mark

        return pos if board.winner == mark
      end
    end

    # no winning move
    nil
  end

  def random_move(game)
    board = game.board
    while true
      range = (0..2).to_a
      pos = [range.sample, range.sample]

      return pos if board.empty?(pos)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  hp = HumanPlayer.new("Human")
  cp = ComputerPlayer.new

  TicTacToe.new(hp, cp).run
end
