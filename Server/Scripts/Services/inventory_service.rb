class InventoryService

def gain_item(client, item, amount)
  return if item.nil?
  return if amount == 0

  # ❗ proteção contra exploit
  if amount.abs > 1000
    LoggerService.warn("Item exploit attempt", player: client.name, item: item.id, amount: amount)
    return
  end

  container = item_container(client, item)
  return unless container

  new_value = [[item_number(client, item) + amount].max, Configs::MAX_ITEMS].min
  container[item.id] = new_value

  container.delete(item.id) if container[item.id] == 0

  kind = kind_item(item)

  $network.send_player_item(client, item.id, kind, amount, false, false)

  LoggerService.info("Item updated", player: client.name, item: item.id, amount: amount)
end

  def lose_item(client, item, amount)
    gain_item(client, item, -amount)
  end

  private

  def item_container(client, item)
    return client.items if item.is_a?(RPG::Item)
    return client.weapons if item.is_a?(RPG::Weapon)
    return client.armors if item.is_a?(RPG::Armor)
    nil
  end

  def item_number(client, item)
    container = item_container(client, item)
    container ? container[item.id] || 0 : 0
  end

  def kind_item(item)
    return 1 if item.is_a?(RPG::Item)
    return 2 if item.is_a?(RPG::Weapon)
    return 3 if item.is_a?(RPG::Armor)
  end

  def update_quest_item(client, item)
    client.add_itens_count(item)
  end

end