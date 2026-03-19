require 'set'

# Mutable game state for one participant.
class Player
  attr_accessor :name, :cash, :position, :owned_property_indexes

  def initialize(name, cash)
    @name = name
    @cash = cash
    @position = 0
    @owned_property_indexes = Set.new
  end

  # Moves the player and returns the number of times GO is passed.
  def move(steps, board_size)
    if board_size <= 0
      raise ArgumentError, "Board size must be greater than zero."
    end

    destination = position + steps
    self.position = destination % board_size

    destination.div(board_size)
  end

  def credit(amount)
    self.cash += amount
  end

  def debit(amount)
    self.cash -= amount
  end

  def bankrupt?
    return cash < 0
  end
end