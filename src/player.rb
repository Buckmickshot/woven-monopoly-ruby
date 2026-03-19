# from dataclasses import dataclass, field
# from typing import Set


# @dataclass
# class Player:
# 	"""Mutable game state for one participant."""

# 	name: str
# 	cash: int
# 	position: int = 0
# 	owned_property_indexes: Set[int] = field(default_factory=set)

# 	def move(self, steps: int, board_size: int) -> int:
# 		"""Moves the player and returns the number of times GO is passed."""
# 		if board_size <= 0:
# 			raise ValueError("Board size must be greater than zero.")

# 		start_position = self.position
# 		destination = start_position + steps
# 		self.position = destination % board_size

# 		passes = destination // board_size
# 		return passes

# 	def credit(self, amount: int) -> None:
# 		self.cash += amount

# 	def debit(self, amount: int) -> None:
# 		self.cash -= amount

# 	@property
# 	def is_bankrupt(self) -> bool:
# 		return self.cash < 0

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