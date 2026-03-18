class Tile
    INDENT = "       "

    attr_reader :name

    def initialize(name)
        @name = name
    end

    def land(player, game)
        raise NotImplementedError, "Subclasses must implement land"
    end
end

class GoTile < Tile

    def land(player, game)
        "#{Tile::INDENT}#{player.name} landed on GO."
    end
end