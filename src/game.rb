# from dataclasses import dataclass
# from typing import Dict, List, Optional, Tuple
# from collections import defaultdict

# from src.board import Board
# from src.player import Player

# INDENT = "       "

# @dataclass(frozen=True)
# class GameConfig:
#     """
#     Configuration for a game simulation.

#     Attributes:
#         player_names: Names of players in turn order.
#         starting_money: Initial cash assigned to each player.
#         pass_go_reward: Amount awarded when passing GO.
#         stop_on_bankruptcy: Whether the game stops when any player goes bankrupt.
#     """
#     player_names: List[str]
#     starting_money: int = 16
#     pass_go_reward: int = 1
#     stop_on_bankruptcy: bool = True
    
# @dataclass(frozen=True)
# class GameResult:
#     """
#     Result of a game simulation.

#     Attributes:
#         ranking: List of (cash, player_names) tuples, sorted by cash in descending order.
#         cash_by_player: Mapping of player names to their final cash amounts.
#         position_by_player: Mapping of player names to their final positions.
#         turns_played: Number of turns played.
#         turn_log: Optional list of strings describing events during the game.
#     """
#     ranking: List[Tuple[int, List[str]]]
#     cash_by_player: Dict[str, int]
#     position_by_player: Dict[str, str]
#     turns_played: int
#     turn_log: Optional[List[str]] = None

# class Game:
#     """
#     Deterministic game engine for a fixed board and roll sequence.

#     The game is fully deterministic given:
#     - initial configuration
#     - board layout
#     - sequence of dice rolls
#     """

#     def __init__(self, board: Board, config: GameConfig):
#         if not config.player_names:
#             raise ValueError("At least one player is required.")
#         if config.starting_money < 0:
#             raise ValueError("Starting money cannot be negative.")
#         if config.pass_go_reward < 0:
#             raise ValueError("Pass GO reward cannot be negative.")

#         self.board = board
#         self.config = config
#         self.players = [Player(name=name, cash=config.starting_money) for name in config.player_names]
#         self.property_indexes_by_colour = board.property_indexes_by_colour()

#     def play(self, rolls: List[int], include_turn_log: bool = False) -> GameResult:
#         """
#         Simulates the game using a fixed sequence of dice rolls.

#         Args:
#             rolls: List of positive integers representing dice rolls.
#             include_turn_log: Whether to record per-turn events.

#         Returns:
#             GameResult containing final state and optional log.

#         Notes:
#             - Game proceeds in round-robin player order.
#             - Simulation stops early if stop_on_bankruptcy is True and any player is bankrupt.
#         """

#         turn_log: List[str] = []

#         if not rolls:
#             raise ValueError("Rolls must not be empty.")

#         if any((not isinstance(roll, int) or roll <= 0) for roll in rolls):
#             raise ValueError("Rolls must be positive integers.")

#         turn_index = 0
#         turns_played = 0
#         while turn_index < len(rolls):
#             turns_played += 1
#             current_player = self.players[turn_index % len(self.players)]
#             roll = rolls[turn_index]
#             start_position = current_player.position
#             start_tile = self.board.tile_at(start_position)

#             go_passes = current_player.move(steps=roll, board_size=len(self.board))
#             landed_index = current_player.position
#             landed_tile = self.board.tile_at(landed_index)

#             if include_turn_log:
#                 turn_log.append(
#                     f"Turn {turns_played}: {current_player.name} moved {roll} spaces from {start_tile.name}."
#                 )

#             if go_passes > 0:
#                 reward = go_passes * self.config.pass_go_reward
#                 current_player.credit(reward)
#                 if include_turn_log:
#                     turn_log.append(
#                         f"{INDENT}{current_player.name} passed GO {go_passes} time(s), receiving ${reward}."
#                     )
            
#             landing_tile_msg = landed_tile.land(current_player, self)
#             if landing_tile_msg and include_turn_log:
#                 turn_log.append(landing_tile_msg)

#             owned_tiles = [
#                 self.board.tile_at(tile).name
#                 for tile in sorted(current_player.owned_property_indexes)
#             ]
#             if include_turn_log:
#                 turn_log.append(
#                     f"{INDENT}{current_player.name} now has ${current_player.cash} and owns {', '.join(owned_tiles) or 'nothing'}"
#                 )

#             if self.config.stop_on_bankruptcy and any(player.is_bankrupt for player in self.players):
#                 break

#             turn_index += 1

#         groups = defaultdict(list)

#         for p in self.players:
#             groups[p.cash].append(p.name)

#         # Group players by cash and sort deterministically.
#         # Names within each group are sorted to ensure stable output for testing.
#         ranking = []
#         for cash, names in groups.items():
#             ranking.append((cash, sorted(names)))

#         ranking.sort(reverse=True)

#         cash_by_player = {player.name: player.cash for player in self.players}
#         position_by_player = {
#             player.name: self.board.tile_at(player.position).name for player in self.players
#         }

#         return GameResult(
#             ranking=ranking,
#             cash_by_player=cash_by_player,
#             position_by_player=position_by_player,
#             turns_played=turns_played,
#             turn_log=turn_log if include_turn_log else None,
#         )
    
#     def owns_full_colour_set(self, owner: Player, colour: str) -> bool:
#         """
#         Checks whether a player owns all properties of a given colour.

#         Args:
#             owner: The player to check.
#             colour: The property colour group.

#         Returns:
#             True if the player owns all properties of that colour, False otherwise.
#         """
#         colour_indexes = self.property_indexes_by_colour.get(colour, [])
#         return bool(colour_indexes) and all(
#             index in owner.owned_property_indexes
#             for index in colour_indexes
#         )

require_relative 'player'
require_relative 'board'

# Configuration for a game simulation.
class GameConfig
  attr_reader :player_names, :starting_money, :pass_go_reward, :stop_on_bankruptcy

  def initialize(player_names:, starting_money: 16, pass_go_reward: 1, stop_on_bankruptcy: true)
    @player_names = player_names
    @starting_money = starting_money
    @pass_go_reward = pass_go_reward
    @stop_on_bankruptcy = stop_on_bankruptcy
  end
end

# Result of a game simulation.
class GameResult
  attr_reader :ranking, :cash_by_player, :position_by_player, :turns_played, :turn_log

  def initialize(ranking:, cash_by_player:, position_by_player:, turns_played:, turn_log: nil)
    @ranking = ranking
    @cash_by_player = cash_by_player
    @position_by_player = position_by_player
    @turns_played = turns_played
    @turn_log = turn_log
  end
end

# Deterministic game engine for a fixed board and roll sequence.
class Game
  INDENT = "       "

  attr_reader :board, :config, :players, :property_indexes_by_colour

  def initialize(board, config)
    if config.player_names.empty?
      raise ArgumentError, "At least one player is required."
    end
    if config.starting_money < 0
      raise ArgumentError, "Starting money cannot be negative."
    end
    if config.pass_go_reward < 0
      raise ArgumentError, "Pass GO reward cannot be negative."
    end

    @board = board
    @config = config
    @players = config.player_names.map do |name|
      Player.new(name, config.starting_money)
    end
    @property_indexes_by_colour = board.property_indexes_by_colour
  end

  # Simulates the game using a fixed sequence of dice rolls.
  def play(rolls, include_turn_log = false)
    turn_log = []

    if rolls.empty?
      raise ArgumentError, "Rolls must not be empty."
    end

    unless rolls.all? { |roll| roll.is_a?(Integer) && roll > 0 }
      raise ArgumentError, "Rolls must be positive integers."
    end

    turn_index = 0
    turns_played = 0
    while turn_index < rolls.length
      turns_played += 1
      current_player = players[turn_index % players.length]
      roll = rolls[turn_index]
      start_position = current_player.position
      start_tile = board.tile_at(start_position)

      go_passes = current_player.move(roll, board.length)
      landed_index = current_player.position
      landed_tile = board.tile_at(landed_index)

      if include_turn_log
        turn_log << "Turn #{turns_played}: #{current_player.name} moved #{roll} spaces from #{start_tile.name}."
      end

      if go_passes > 0
        reward = go_passes * config.pass_go_reward
        current_player.credit(reward)
        if include_turn_log
          turn_log << "#{INDENT}#{current_player.name} passed GO #{go_passes} time(s), receiving $#{reward}."
        end
      end

      landing_tile_msg = landed_tile.land(current_player, self)
      if landing_tile_msg && include_turn_log
        turn_log << landing_tile_msg
      end

      owned_tiles = current_player.owned_property_indexes.sort.map do |tile|
        board.tile_at(tile).name
      end

      if include_turn_log
        turn_log << "#{INDENT}#{current_player.name} now has $#{current_player.cash} and owns #{owned_tiles.empty? ? 'nothing' : owned_tiles.join(', ')}"
      end

      if config.stop_on_bankruptcy && players.any?(&:bankrupt?)
        break
      end

      turn_index += 1
    end

    groups = Hash.new { |h, k| h[k] = [] }

    players.each do |p|
      groups[p.cash] << p.name
    end

    # Group players by cash and sort deterministically.
    # Names within each group are sorted to ensure stable output for testing.
    ranking = groups.map do |cash, names|
      [cash, names.sort]
    end

    ranking.sort_by! { |cash, _| -cash }

    cash_by_player = players.map { |player| [player.name, player.cash] }.to_h
    position_by_player = players.map do |player|
      [player.name, board.tile_at(player.position).name]
    end.to_h

    GameResult.new(
      ranking: ranking,
      cash_by_player: cash_by_player,
      position_by_player: position_by_player,
      turns_played: turns_played,
      turn_log: include_turn_log ? turn_log : nil
    )
  end

  # Checks whether a player owns all properties of a given colour.
  def owns_full_colour_set(owner, colour)
    colour_indexes = property_indexes_by_colour[colour] || []
    return false if colour_indexes.empty?

    colour_indexes.all? do |index|
      owner.owned_property_indexes.include?(index)
    end
  end