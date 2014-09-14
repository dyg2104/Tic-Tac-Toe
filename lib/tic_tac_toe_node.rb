require_relative 'tic_tac_toe'

class TicTacToeNode
  attr_reader :board
  attr_reader :next_mover_mark
  attr_reader :prev_move_pos

  def initialize(board, next_mover_mark, prev_move_pos = nil)
    @board = board
    @next_mover_mark = next_mover_mark
    @prev_move_pos = prev_move_pos
  end

  # This method generates an array of all moves that can be made after
  # the current move.
  def children
    next_states = []

    rows = @board.rows
    rows.each_with_index do |row, i|
      row.each_with_index do |column, j|

        if @board.empty?([i,j])
          pos = [i,j]
          holder = @board.dup
          holder[pos] = next_mover_mark

          if next_mover_mark == :x
            next_states << TicTacToeNode.new(holder, :o, pos)
          else
            next_states << TicTacToeNode.new(holder, :x, pos)
          end
        end

      end
    end

    next_states
  end

  def losing_node?(evaluator)

    if self.board.over?
      return false if (self.board.winner == nil || self.board.winner == evaluator)
      return true if self.board.winner != evaluator
    end

    if self.next_mover_mark != evaluator
      return self.children.any? { |child| child.losing_node?(evaluator) }
    end

    if self.next_mover_mark == evaluator
      return self.children.all? { |child| child.losing_node?(evaluator) }
    end

  end

  def winning_node?(evaluator)

    if self.board.over?
      return false if (self.board.winner == nil || self.board.winner != evaluator)
      return true if (self.board.over? && self.board.winner == evaluator)
    end

    if self.next_mover_mark != evaluator
      return self.children.any? { |child| child.winning_node?(evaluator) }
    end

    if self.next_mover_mark == evaluator
      return self.children.all? { |child| child.winning_node?(evaluator) }
    end

  end

end


