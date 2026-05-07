class EquipmentService

def change_equip(client, slot_id, item_id)
  return if item_id.nil?
  return if item_id < 0

  new_item = equip_object(slot_id, item_id)
  old_item = equip_object(slot_id, client.equips[slot_id])

  return unless can_trade_item(client, new_item, old_item, slot_id)

  client.equips[slot_id] = item_id

  $network.send_player_equip(client, slot_id)

  LoggerService.info("Equip changed", player: client.name, slot: slot_id, item: item_id)

  client.refresh
end

  private

  def can_trade_item(client, new_item, old_item, slot_id)
    return false if !new_item && client.full_inventory?(old_item)
    return false if new_item && !client.equippable?(new_item, slot_id)

    client.gain_item(old_item, 1)
    client.lose_item(new_item, 1)

    client.lose_trade_item(new_item, 1) if new_item && client.in_trade?

    true
  end

  def equip_object(slot_id, item_id)
    slot_id == Enums::Equip::WEAPON ? $data_weapons[item_id] : $data_armors[item_id]
  end

end