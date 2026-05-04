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
  new_gold = [[client.gold + amount, 0].max, Configs::MAX_GOLD].min
  client.instance_variable_set(:@gold, new_gold)
  $network.send_player_gold(client, amount, false, false)
end

  private

  def handle_death(client)
    # por enquanto só mantém o comportamento atual
    client.die if client.respond_to?(:die)
  end

end