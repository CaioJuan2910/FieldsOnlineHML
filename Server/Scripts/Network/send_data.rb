#==============================================================================
# ** Send_Data
#------------------------------------------------------------------------------
#  Este script envia as mensagens para o cliente.
#------------------------------------------------------------------------------
#  Autor: Valentine
#  Melhorias: Fields Online Dev Team
#==============================================================================

module Send_Data

  def send_data_to_map(map_id, data)
    $clients.each do |client|
      next unless client && client.map_id == map_id
      client.send_data(data)
    end
  end

  def send_data_to_all(data)
    $clients.each do |client|
      next unless client
      client.send_data(data)
    end
  end

  def send_data_to_party(party_id, data)
    $clients.each do |client|
      next unless client && client.party_id == party_id
      client.send_data(data)
    end
  end

  def send_data_to_guild(guild_name, data)
    $clients.each do |client|
      next unless client && client.guild_name == guild_name
      client.send_data(data)
    end
  end

  def send_login(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::LOGIN)
    client.send_data(packet)
  end

  def send_failed_login(client, type)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::FAILED_LOGIN)
    packet.write_byte(type)
    client.send_data(packet)
  end

  def send_create_account(client, type)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::CREATE_ACCOUNT)
    packet.write_byte(type)
    client.send_data(packet)
  end

  def send_create_actor(client, actor_id, actor)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::CREATE_ACTOR)
    packet.write_byte(actor_id)
    packet.write_string(actor[:name])
    packet.write_byte(actor[:sex])
    packet.write_short(actor[:class_id])
    packet.write_short(actor[:char_index])
    packet.write_short(actor[:face_index])
    client.send_data(packet)
  end

  def send_failed_create_actor(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::FAILED_CREATE_ACTOR)
    client.send_data(packet)
  end

  def send_remove_actor(client, actor_id)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::REMOVE_ACTOR)
    packet.write_byte(actor_id)
    client.send_data(packet)
  end

  def send_use_actor(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::USE_ACTOR)
    packet.write_short(client.id)
    packet.write_string(client.name)
    packet.write_byte(client.sex)
    packet.write_short(client.class_id)
    packet.write_short(client.level)
    packet.write_string(client.title)
    packet.write_short(client.char_index)
    packet.write_string(client.char_name)
    packet.write_short(client.face_index)
    packet.write_string(client.face_name)
    packet.write_byte(client.admin)
    client.send_data(packet)
  end

  def send_motd(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::MOTD)
    packet.write_string(Configs::MOTD)
    client.send_data(packet)
  end

  def send_player_data(client, map_id)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_DATA)
    packet.write_short(client.id)
    packet.write_short(map_id)
    packet.write_short(client.x)
    packet.write_short(client.y)
    packet.write_byte(client.direction)
    packet.write_short(client.level)
    packet.write_string(client.name)
    packet.write_string(client.title)
    packet.write_byte(client.sex)
    packet.write_short(client.class_id)
    packet.write_short(client.char_index)
    packet.write_string(client.char_name)
    packet.write_short(client.face_index)
    packet.write_string(client.face_name)
    packet.write_byte(client.admin)
    packet.write_byte(client.opacity)
    packet.write_byte(client.move_speed)
    packet.write_bool(client.in_party?)
    packet.write_bool(client.in_guild?)
    packet.write_string(client.guild_name)
    Configs::EQUIP_SLOTS.size.times do |i|
      packet.write_short(client.equips[i] ? client.equips[i] : 0)
    end
    send_data_to_map(map_id, packet)
  end

  def send_map_players(player)
    $clients.each do |client|
      next unless client && client.map_id == player.map_id && client.id != player.id
      send_player_data(client, client.map_id)
    end
  end

  def send_remove_player(client_id, map_id)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::REMOVE_PLAYER)
    packet.write_short(client_id)
    send_data_to_map(map_id, packet)
  end

  def send_player_movement(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_MOVEMENT)
    packet.write_short(client.id)
    packet.write_short(client.x)
    packet.write_short(client.y)
    packet.write_byte(client.direction)
    packet.write_byte(client.move_speed)
    packet.write_bool(client.moving)
    send_data_to_map(client.map_id, packet)
  end

  # === CHAT ===

  # Helper privado — centraliza a criação do pacote CHAT_MSG
  def build_chat_packet(color_id, message)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::CHAT_MSG)
    packet.write_byte(color_id)
    packet.write_string(message)
    packet
  end

  def player_chat_message(client, message, color_id)
    client.send_data(build_chat_packet(color_id, message))
  end

  def map_chat_message(map_id, message, player_id, color_id = Enums::Chat::MAP)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::MAP_MSG)
    packet.write_byte(color_id)
    packet.write_short(player_id)
    packet.write_string(message)
    send_data_to_map(map_id, packet)
  end

  def global_chat_message(message, color_id = Enums::Chat::GLOBAL)
    send_data_to_all(build_chat_packet(color_id, message))
  end

  def party_chat_message(client, message)
    return unless client.in_party?
    send_data_to_party(client.party_id, build_chat_packet(Enums::Chat::PARTY, message))
  end

  def guild_chat_message(client, message, color_id = Enums::Chat::GUILD)
    return unless client.in_guild?
    send_data_to_guild(client.guild_name, build_chat_packet(color_id, message))
  end

  def private_chat_message(client, message, name)
    return if client.name.casecmp(name).zero?
    player = find_player(name)
    unless player
      alert_message(client, Enums::Alert::PLAYER_NOT_FOUND)
      return
    end
    packet = build_chat_packet(Enums::Chat::PRIVATE, message)
    player.send_data(packet)
    client.send_data(packet)
  end

  def send_whos_online(client, message)
    client.send_data(build_chat_packet(Enums::Chat::GLOBAL, message))
  end

  def send_server_message(client, message, color_id = Enums::Chat::GLOBAL)
    client.send_data(build_chat_packet(color_id, message))
  end

  def broadcast_server_message(message, color_id = Enums::Chat::GLOBAL)
    send_data_to_all(build_chat_packet(color_id, message))
  end

  # === FIM DA SEÇÃO DE CHAT ===

  def alert_message(client, type)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::ALERT)
    packet.write_byte(type)
    client.send_data(packet)
  end

  def send_attack_player(client, target_id, damage, type, element_id, critical)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::ATTACK_PLAYER)
    packet.write_short(client.id)
    packet.write_short(target_id)
    packet.write_short(damage)
    packet.write_byte(type)
    packet.write_byte(element_id)
    packet.write_bool(critical)
    send_data_to_map(client.map_id, packet)
  end

  def send_attack_enemy(client, event_id, damage, type, element_id, critical)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::ATTACK_ENEMY)
    packet.write_short(client.id)
    packet.write_short(event_id)
    packet.write_short(damage)
    packet.write_byte(type)
    packet.write_byte(element_id)
    packet.write_bool(critical)
    send_data_to_map(client.map_id, packet)
  end

  def send_animation(map_id, animation_id, target_id, target_type)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::ANIMATION)
    packet.write_short(animation_id)
    packet.write_short(target_id)
    packet.write_byte(target_type)
    send_data_to_map(map_id, packet)
  end

  def send_balloon(character, character_type, balloon_id)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::BALLOON)
    packet.write_short(character.id)
    packet.write_byte(character_type)
    packet.write_byte(balloon_id)
    send_data_to_map(character.map_id, packet)
  end

  def send_enemy_balloon(client, event_id, balloon_id)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::BALLOON)
    packet.write_short(event_id)
    packet.write_byte(Enums::CharacterType::ENEMY)
    packet.write_byte(balloon_id)
    send_data_to_map(client.map_id, packet)
  end

  def send_enemy_revive(event)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::ENEMY_REVIVE)
    packet.write_short(event.id)
    packet.write_short(event.x)
    packet.write_short(event.y)
    send_data_to_map(event.map_id, packet)
  end

  def send_map_events(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::MAP_EVENTS)
    events = $game_map[client.map_id] ? $game_map[client.map_id].events : {}
    packet.write_short(events.size)
    events.each do |event_id, event|
      packet.write_short(event_id)
      packet.write_short(event.x)
      packet.write_short(event.y)
      packet.write_byte(event.direction)
      packet.write_byte(event.move_speed)
      packet.write_bool(event.moving)
      packet.write_bool(event.dead?)
      packet.write_short(event.hp)
      packet.write_short(event.max_hp)
      packet.write_byte(event.opacity)
    end
    client.send_data(packet)
  end

  def send_event_movement(event)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::EVENT_MOVEMENT)
    packet.write_short(event.id)
    packet.write_short(event.x)
    packet.write_short(event.y)
    packet.write_byte(event.direction)
    packet.write_byte(event.move_speed)
    packet.write_bool(event.moving)
    send_data_to_map(event.map_id, packet)
  end

  def send_map_drops(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::MAP_DROPS)
    drops = $drops[client.map_id] ? $drops[client.map_id] : []
    packet.write_short(drops.size)
    drops.each do |drop|
      packet.write_short(drop[:id])
      packet.write_short(drop[:item_id])
      packet.write_byte(drop[:kind])
      packet.write_short(drop[:amount])
      packet.write_short(drop[:x])
      packet.write_short(drop[:y])
    end
    client.send_data(packet)
  end

  def send_add_drop(map_id, item_id, kind, amount, x, y)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::ADD_DROP)
    drop_id = $drops[map_id] ? $drops[map_id].size : 0
    packet.write_short(drop_id)
    packet.write_short(item_id)
    packet.write_byte(kind)
    packet.write_short(amount)
    packet.write_short(x)
    packet.write_short(y)
    send_data_to_map(map_id, packet)
  end

  def send_remove_drop(map_id, drop_id)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::REMOVE_DROP)
    packet.write_short(drop_id)
    send_data_to_map(map_id, packet)
  end

  def send_add_projectile(map_id, projectile_id, user_id, user_type, target_id, target_type, x, y, direction)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::ADD_PROJECTILE)
    packet.write_short(projectile_id)
    packet.write_short(user_id)
    packet.write_byte(user_type)
    packet.write_short(target_id)
    packet.write_byte(target_type)
    packet.write_short(x)
    packet.write_short(y)
    packet.write_byte(direction)
    send_data_to_map(map_id, packet)
  end

  def send_player_vitals(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_VITALS)
    packet.write_short(client.id)
    packet.write_short(client.hp)
    packet.write_short(client.max_hp)
    packet.write_short(client.mp)
    packet.write_short(client.max_mp)
    send_data_to_map(client.map_id, packet)
  end

  def send_player_exp(client, exp)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_EXP)
    packet.write_int(client.exp)
    packet.write_int(client.next_level_exp)
    packet.write_short(client.level)
    packet.write_short(exp)
    client.send_data(packet)
  end

  def send_player_state(client, state_id, add_state = true)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_STATE)
    packet.write_short(client.id)
    packet.write_short(state_id)
    packet.write_bool(add_state)
    send_data_to_map(client.map_id, packet)
  end

  def send_player_buff(client, param_id, buff_level)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_BUFF)
    packet.write_short(client.id)
    packet.write_byte(param_id)
    packet.write_byte(buff_level)
    send_data_to_map(client.map_id, packet)
  end

  def send_player_switch(client, switch_id)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_SWITCH)
    packet.write_short(switch_id)
    packet.write_bool(client.switches[switch_id])
    client.send_data(packet)
  end

  def send_player_variable(client, variable_id)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_VARIABLE)
    packet.write_short(variable_id)
    packet.write_int(client.variables[variable_id])
    client.send_data(packet)
  end

  def send_player_self_switch(client, key)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_SELF_SWITCH)
    packet.write_string(key)
    packet.write_bool(client.self_switches[key])
    client.send_data(packet)
  end

  def send_player_item(client, item_id, kind, amount, drop_sound, popup)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_ITEM)
    packet.write_short(item_id)
    packet.write_byte(kind)
    packet.write_short(amount)
    packet.write_bool(drop_sound)
    packet.write_bool(popup)
    client.send_data(packet)
  end

  def send_player_gold(client, amount, shop_sound, popup)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_GOLD)
    packet.write_int(client.gold)
    packet.write_int(amount)
    packet.write_bool(shop_sound)
    packet.write_bool(popup)
    client.send_data(packet)
  end

  def send_player_param(client, param_id, value)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_PARAM)
    packet.write_short(client.id)
    packet.write_byte(param_id)
    packet.write_short(value)
    send_data_to_map(client.map_id, packet)
  end

  def send_player_equip(client, slot_id)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_EQUIP)
    packet.write_short(client.id)
    packet.write_byte(slot_id)
    packet.write_short(client.equips[slot_id] ? client.equips[slot_id] : 0)
    send_data_to_map(client.map_id, packet)
  end

  def send_player_skill(client, skill_id, learn = true)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_SKILL)
    packet.write_short(skill_id)
    packet.write_bool(learn)
    client.send_data(packet)
  end

  def send_player_class(client, class_id)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_CLASS)
    packet.write_short(client.id)
    packet.write_short(class_id)
    send_data_to_map(client.map_id, packet)
  end

  def send_player_sex(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_SEX)
    packet.write_short(client.id)
    packet.write_byte(client.sex)
    send_data_to_map(client.map_id, packet)
  end

  def send_player_graphic(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_GRAPHIC)
    packet.write_short(client.id)
    packet.write_short(client.char_index)
    packet.write_string(client.char_name)
    packet.write_short(client.face_index)
    packet.write_string(client.face_name)
    send_data_to_map(client.map_id, packet)
  end

  def send_player_points(client, points)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_POINTS)
    packet.write_short(points)
    client.send_data(packet)
  end

  def send_player_hotbar(client, id)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PLAYER_HOTBAR)
    packet.write_byte(id)
    packet.write_byte(client.hotbar[id][:type])
    packet.write_short(client.hotbar[id][:id])
    client.send_data(packet)
  end

  def send_target(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::TARGET)
    packet.write_short(client.target_id)
    packet.write_byte(client.target_type)
    client.send_data(packet)
  end

  def send_transfer_player(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::TRANSFER_PLAYER)
    packet.write_short(client.map_id)
    packet.write_short(client.x)
    packet.write_short(client.y)
    packet.write_byte(client.direction)
    client.send_data(packet)
  end

  def send_open_friends(client, online_friends)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::OPEN_FRIENDS)
    packet.write_byte(client.friends.size)
    client.friends.each do |friend|
      packet.write_string(friend[:name])
      packet.write_bool(online_friends.include?(friend[:name]))
    end
    client.send_data(packet)
  end

  def send_add_friend(client, friend_name)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::ADD_FRIEND)
    packet.write_string(friend_name)
    packet.write_bool(find_player(friend_name) != nil)
    client.send_data(packet)
  end

  def send_remove_friend(client, index)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::REMOVE_FRIEND)
    packet.write_byte(index)
    client.send_data(packet)
  end

  def send_open_create_guild(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::OPEN_CREATE_GUILD)
    client.send_data(packet)
  end

  def send_open_guild(client, online_members_size)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::OPEN_GUILD)
    guild = $guilds[client.guild_name]
    packet.write_string(guild[:name])
    packet.write_string(guild[:notice])
    packet.write_string(guild[:leader])
    packet.write_short(online_members_size)
    packet.write_short(guild[:members].size)
    guild[:members].each do |member|
      packet.write_string(member[:name])
      packet.write_bool(find_player(member[:name]) != nil)
    end
    client.send_data(packet)
  end

  def send_guild_leader(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::GUILD_LEADER)
    packet.write_string($guilds[client.guild_name][:leader])
    client.send_data(packet)
  end

  def send_guild_notice(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::GUILD_NOTICE)
    packet.write_string($guilds[client.guild_name][:notice])
    client.send_data(packet)
  end

  def send_guild_name(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::GUILD_NAME)
    packet.write_short(client.id)
    packet.write_string(client.guild_name)
    send_data_to_map(client.map_id, packet)
  end

  def send_remove_guild_member(client, name)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::REMOVE_GUILD_MEMBER)
    packet.write_string(name)
    client.send_data(packet)
  end

  def send_join_party(client, player)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::JOIN_PARTY)
    packet.write_short(player.id)
    packet.write_string(player.name)
    packet.write_short(player.level)
    packet.write_short(player.hp)
    packet.write_short(player.max_hp)
    packet.write_short(player.mp)
    packet.write_short(player.max_mp)
    client.send_data(packet)
  end

  def send_leave_party(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::LEAVE_PARTY)
    packet.write_short(client.id)
    send_data_to_party(client.party_id, packet)
  end

  def send_dissolve_party(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::DISSOLVE_PARTY)
    client.send_data(packet)
  end

  def send_open_bank(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::OPEN_BANK)
    packet.write_short(client.bank_items.size)
    client.bank_items.each do |item|
      packet.write_short(item[:item_id])
      packet.write_byte(item[:kind])
      packet.write_short(item[:amount])
    end
    packet.write_int(client.bank_gold)
    client.send_data(packet)
  end

  def send_bank_item(client, item_id, kind, amount)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::BANK_ITEM)
    packet.write_short(item_id)
    packet.write_byte(kind)
    packet.write_short(amount)
    client.send_data(packet)
  end

  def send_bank_gold(client, amount)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::BANK_GOLD)
    packet.write_int(amount)
    client.send_data(packet)
  end

  def send_close_window(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::CLOSE_WINDOW)
    client.send_data(packet)
  end

  def send_open_shop(client, event_id, index)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::OPEN_SHOP)
    shop = $game_map[client.map_id].events[event_id].shop(index)
    packet.write_short(shop.size)
    shop.each do |item|
      packet.write_short(item[:item_id])
      packet.write_byte(item[:kind])
      packet.write_int(item[:price])
    end
    client.send_data(packet)
  end

  def send_open_teleport(client, teleport_id)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::OPEN_TELEPORT)
    packet.write_short(teleport_id)
    client.send_data(packet)
  end

  def send_event_command(client, event_id, initial_index, final_index)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::EVENT_COMMAND)
    packet.write_short(event_id)
    packet.write_short(initial_index)
    packet.write_short(final_index)
    client.send_data(packet)
  end

  def send_parallel_process_command(event, initial_index, final_index)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::PARALLEL_PROCESS_COMMAND)
    packet.write_short(event.id)
    packet.write_short(initial_index)
    packet.write_short(final_index)
    send_data_to_map(event.map_id, packet)
  end

  def send_request(client, type, player)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::REQUEST)
    packet.write_byte(type)
    packet.write_short(player.id)
    packet.write_string(player.name)
    client.send_data(packet)
  end

  def send_accept_request(client, type)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::ACCEPT_REQUEST)
    packet.write_byte(type)
    client.send_data(packet)
  end

  def send_trade_item(client, player_id, item_id, kind, amount)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::TRADE_ITEM)
    packet.write_short(player_id)
    packet.write_short(item_id)
    packet.write_byte(kind)
    packet.write_short(amount)
    client.send_data(packet)
  end

  def send_trade_gold(client, player_id, amount)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::TRADE_GOLD)
    packet.write_short(player_id)
    packet.write_int(amount)
    client.send_data(packet)
  end

  def send_add_quest(client, quest_id)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::ADD_QUEST)
    packet.write_short(quest_id)
    quest = $quests[quest_id]
    packet.write_string(quest[:name])
    packet.write_string(quest[:description])
    packet.write_short(quest[:objectives].size)
    quest[:objectives].each do |objective|
      packet.write_byte(objective[:type])
      packet.write_short(objective[:id])
      packet.write_short(objective[:amount])
      packet.write_short(client.quest_objectives(quest_id, objective[:id]))
    end
    client.send_data(packet)
  end

  def send_finish_quest(client, quest_id)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::FINISH_QUEST)
    packet.write_short(quest_id)
    client.send_data(packet)
  end

  def send_vip_days(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::VIP_DAYS)
    packet.write_short(client.vip_days)
    client.send_data(packet)
  end

  def send_logout(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::LOGOUT)
    client.send_data(packet)
  end

  def send_admin_command(client, command, alert_msg = '')
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::ADMIN_COMMAND)
    packet.write_byte(command)
    packet.write_string(alert_msg)
    client.send_data(packet)
  end

  def send_global_switch(switch_id, value)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::GLOBAL_SWITCH)
    packet.write_short(switch_id)
    packet.write_bool(value)
    send_data_to_all(packet)
  end

  def send_global_switches(client)
    packet = Buffer::Writer.new
    packet.write_byte(Enums::Packet::GLOBAL_SWITCHES)
    packet.write_short($global_switches.size)
    $global_switches.each do |switch_id, value|
      packet.write_short(switch_id)
      packet.write_bool(value)
    end
    client.send_data(packet)
  end

  private :build_chat_packet

end