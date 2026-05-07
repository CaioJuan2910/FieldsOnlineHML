class PlayerService

  def set_hp(client, value)
    client.instance_variable_set(:@hp, [[value, client.mhp].min, 0].max)

    if client.hp <= 0
      handle_death(client)
    else
      $network.send_player_vitals(client)
    end
  end

  def gain_exp(client, amount)
    new_exp = client.exp + amount
    client.change_exp(new_exp)
  end

def gain_gold(client, amount)
  return if amount.nil?

  # ❗ proteção contra valores absurdos
  if amount.abs > 1_000_000_000
    LoggerService.warn("Gold exploit attempt", player: client.name, amount: amount)
    return
  end

  new_gold = [[client.gold + amount, 0].max, Configs::MAX_GOLD].min

  client.instance_variable_set(:@gold, new_gold)

  $network.send_player_gold(client, amount, false, false)

  LoggerService.info("Gold updated", player: client.name, gold: new_gold)
end

  private

  def handle_death(client)
    # por enquanto só mantém o comportamento atual
    client.die if client.respond_to?(:die)
  end

end