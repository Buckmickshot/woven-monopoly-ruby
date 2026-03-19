# import json
# from dataclasses import dataclass
# from typing import Any, Dict, List
# from src.property import Property
# from src.tiles import GoTile, Tile

# @dataclass(frozen=True)
# class Board:
#     """Immutable representation of the game board."""
#     tiles: List[Tile]

#     def __post_init__(self) -> None:
#         if not self.tiles:
#             raise ValueError("Board must contain at least one tile.")

#     def __len__(self) -> int:
#         return len(self.tiles)

#     def tile_at(self, index: int) -> Tile:
#         """Returns the tile at a given index, wrapping around the board."""
#         return self.tiles[index % len(self.tiles)]

#     def property_indexes_by_colour(self) -> Dict[str, List[int]]:
#         """Groups property indexes by colour."""
#         result: Dict[str, List[int]] = {}

#         for index, tile in enumerate(self.tiles):
#             if not isinstance(tile, Property):
#                 continue

#             result.setdefault(tile.colour, []).append(index)
#         return result
    
# def _require_tile_field(raw_tile: Dict[str, Any], field_name: str, index: int) -> Any:
#     """Ensures a required field exists in the raw JSON tile."""

#     if field_name not in raw_tile:
#         raise ValueError(f"Tile at index {index} is missing required field '{field_name}'.")
#     return raw_tile[field_name]
    
# def _validate_tile(raw_tile: Dict[str, Any], index: int) -> Tile:
#     """Validates and converts a raw JSON tile into a Tile object."""

#     if not isinstance(raw_tile, dict):
#         raise ValueError(f"Tile at index {index} must be an object.")

#     name = _require_tile_field(raw_tile, "name", index)
#     tile_type = _require_tile_field(raw_tile, "type", index)

#     if not isinstance(name, str) or not name.strip():
#         raise ValueError(f"Tile at index {index} has invalid 'name'.")
#     if not isinstance(tile_type, str) or not tile_type.strip():
#         raise ValueError(f"Tile at index {index} has invalid 'type'.")

#     if tile_type == "property":
#         price = _require_tile_field(raw_tile, "price", index)
#         colour = _require_tile_field(raw_tile, "colour", index)
#         if not isinstance(price, int) or price <= 0:
#             raise ValueError(f"Property '{name}' must have a positive integer price.")
#         if not isinstance(colour, str) or not colour.strip():
#             raise ValueError(f"Property '{name}' must have a non-empty colour.")

#         return Property(name=name, price=price, colour=colour)

#     elif tile_type == "go":
#         return GoTile(name=name)

#     else:
#         return Tile(name=name)

# def load_board(board_path: str) -> Board:
#     """Loads and validates a board configuration from JSON."""

#     with open(board_path) as f:
#         raw_content = json.load(f)

#     if not isinstance(raw_content, list):
#         raise ValueError("Board JSON must be an array of tiles.")

#     tiles = [
#         _validate_tile(raw_tile, index)
#         for index, raw_tile in enumerate(raw_content)
#     ]

#     if not tiles:
#         raise ValueError("Board must not be empty.")

#     if not isinstance(tiles[0], GoTile):
#         raise ValueError("First board tile must be GO.")

#     return Board(tiles=tiles)

require_relative 'property'
require_relative 'tiles'
require 'json'

# Immutable representation of the game board.
class Board
  attr_reader :tiles

  def initialize(tiles)
    if tiles.empty?
      raise ArgumentError, "Board must contain at least one tile."
    end

    @tiles = tiles
  end

  def length
    tiles.length
  end

  # Returns the tile at a given index, wrapping around the board.
  def tile_at(index)
    tiles[index % length]
  end

  # Groups property indexes by colour.
  def property_indexes_by_colour
    result = Hash.new { |h, k| h[k] = [] }

    tiles.each_with_index do |tile, index|
      next unless tile.is_a?(Property)

      result[tile.colour] << index
    end

    result
  end
end

# Ensures a required field exists in the raw JSON tile.
def _require_tile_field(raw_tile, field_name, index)
  unless raw_tile.key?(field_name)
    raise ArgumentError, "Tile at index #{index} is missing required field '#{field_name}'."
  end
  raw_tile[field_name]
end

# Validates and converts a raw JSON tile into a Tile object.
def _validate_tile(raw_tile, index)
  unless raw_tile.is_a?(Hash)
    raise ArgumentError, "Tile at index #{index} must be an object."
  end

  name = _require_tile_field(raw_tile, "name", index)
  tile_type = _require_tile_field(raw_tile, "type", index)

  if !name.is_a?(String) || name.strip.empty?
    raise ArgumentError, "Tile at index #{index} has invalid 'name'."
  end
  if !tile_type.is_a?(String) || tile_type.strip.empty?
    raise ArgumentError, "Tile at index #{index} has invalid 'type'."
  end

  case tile_type
    when "property"
      price = _require_tile_field(raw_tile, "price", index)
      colour = _require_tile_field(raw_tile, "colour", index)

      if !price.is_a?(Integer) || price <= 0
        raise ArgumentError, "Property '#{name}' must have a positive integer price."
      end
      if !colour.is_a?(String) || colour.strip.empty?
        raise ArgumentError, "Property '#{name}' must have a non-empty colour."
      end

      Property.new(name, price, colour)

    when "go"
      GoTile.new(name)

    else
      Tile.new(name)
  end
end

def load_board(board_path)
  raw_content = JSON.parse(File.read(board_path))

  unless raw_content.is_a?(Array)
    raise ArgumentError, "Board JSON must be an array of tiles."
  end

  tiles = raw_content.each_with_index.map do |raw_tile, index|
    _validate_tile(raw_tile, index)
  end

  if tiles.empty?
    raise ArgumentError, "Board must not be empty."
  end

  unless tiles[0].is_a?(GoTile)
    raise ArgumentError, "First board tile must be GO."
  end

  Board.new(tiles)
end