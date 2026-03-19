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

      Property.new(name: name, price: price, colour: colour)

    when "go"
      GoTile.new(name)

    else
      raise ArgumentError, "Tile '#{name}' has unsupported type '#{tile_type}'."
  end
end

# Loads and validates a board configuration from JSON.
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