# Base class for all board tiles.
class Tile
  INDENT = "       "

  attr_reader :name

  def initialize(name)
    @name = name
  end

  # Called when a player lands on this tile.
  def land(player, game)
    raise NotImplementedError, "Subclasses must implement #land"
  end
end

# Represents the GO tile.
class GoTile < Tile

  def land(player, game)
    "#{INDENT}#{player.name} landed on GO."
  end
end