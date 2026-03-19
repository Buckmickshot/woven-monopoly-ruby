# Represents a purchasable board property.
class Property < Tile
  attr_accessor :price, :colour, :owner

  def initialize(name:, price:, colour:, owner: nil)
    super(name)
    @price = price
    @colour = colour
    @owner = owner
  end

  def is_owned?
    !owner.nil?
  end

  def base_rent
    price
  end

  # Handle logic when a player lands on this property.
  def land(player, game)
    # Case 1 — unowned → must buy
    if !is_owned?
      player.debit(price)
      self.owner = player
      player.owned_property_indexes.add(player.position)

      "#{Tile::INDENT}#{player.name} landed on #{name} which has no owner and bought it for $#{price}"
    
    # Case 2 — owned by someone else → pay rent
    elsif owner != player
      rent = base_rent

      rent *= 2 if game.owns_full_colour_set(owner, colour)

      player.debit(rent)
      owner.credit(rent)

      "#{Tile::INDENT}#{player.name} landed on #{name}, which is owned by #{owner.name}. #{player.name} paid $#{rent} in rent to #{owner.name}."
    
    # Case 3 — owned by self → do nothing
    else
      "#{Tile::INDENT}#{player.name} landed on #{name}, which they own."
    end
  end
end