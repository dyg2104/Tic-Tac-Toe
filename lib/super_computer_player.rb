require_relative 'tic_tac_toe_node'

class SuperComputerPlayer < ComputerPlayer
  def move(game, mark)
    ttt_node = TicTacToeNode.new(game.board, mark)

    descendants = ttt_node.children

    descendants.each do |child|
      return child.prev_move_pos if child.winning_node?(mark)
    end

    descendants.each do |child|
      return child.prev_move_pos if !child.losing_node?(mark)
    end

    raise "Error: No non-losing nodes."
  end

end

if __FILE__ == $PROGRAM_NAME
  hp = HumanPlayer.new("Human")
  cp = SuperComputerPlayer.new

  TicTacToe.new(cp, hp).run
end