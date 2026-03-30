#==============================================================================
# ** Send_Data
#------------------------------------------------------------------------------
#  Este script envia as mensagens para o cliente.
#------------------------------------------------------------------------------
#  Autor: Valentine
#  Revisado por: Caio Juan De Lima Silva
#  Data de revisão: 2026-03-30
#
#  RESUMO DAS CORREÇÕES APLICADAS:
#
#  [FIX-01] send_data_to_party
#    - Adicionado `return unless @parties[party_id]` para evitar NoMethodError
#      quando a party já foi dissolvida mas o slot ainda não foi limpo.
#
#  [FIX-02] send_player_data / send_map_players / send_remove_player /
#           send_enemy_revive / send_event_movement / send_remove_drop /
#           send_parallel_process_command
#    - Adicionado `return unless @maps[map_id]` (ou `@maps[event.map_id]`)
#      antes de qualquer acesso ao objeto de mapa, evitando NoMethodError
#      quando o mapa ainda não foi carregado ou o ID é inválido.
#
#  [FIX-03] private_chat_message
#    - Adicionado guard `return if name.nil? || name.empty?` para proteger
#      contra pacotes malformados que enviam name vazio ou nil.
#    - String#casecmp(nil) retorna nil em Ruby < 2.4 → nil.zero? → NoMethodError;
#      em Ruby >= 2.4 levanta TypeError. O guard elimina ambos os cenários.
#
#  [FIX-04] send_player_hotbar
#    - `client.hotbar[id]` era acessado duas vezes no código original.
#      Armazenado em variável local `hotbar` para evitar dupla indexação e
#      possível inconsistência se o array mudar entre as duas leituras.
#
#  [FIX-05] send_open_guild / send_guild_leader / send_guild_notice
#    - Adicionado nil check em `@guilds[client.guild_name]` com variável local
#      `guild`. A guild pode ser dissolvida entre a requisição e a execução
#      do método, causando NoMethodError sem o guard.
#==============================================================================

module Send_Data

  # ---------------------------------------------------------------------------
  # Métodos auxiliares de envio em grupo
  # ---------------------------------------------------------------------------

  # Envia `data` para todos os clientes em jogo no mapa `map_id`.
  def send_data_to_map(map_id, data)
    @clients.each { |client| client.send_data(data) if client&.in_game? && client.map_id == map_id }
  end

  # Envia `data` para todos os clientes em jogo no servidor.
  def send_data_to_all(data)
    @clients.each { |client| client.send_data(data) if client&.in_game? }
  end

  # Envia `data` para todos os membros de uma party.
  #
  # [FIX-01] nil check em @parties[party_id]:
  #   Se a party foi dissolvida e o slot ainda não foi limpo no mesmo tick
  #   (ex.: send_leave_party + party_chat_message simultâneos),
  #   @parties[party_id] retorna nil → nil.each → NoMethodError.
  def send_data_to_party(party_id, data)
    return unless @parties[party_id]
    @parties[party_id].each { |member| member.send_data(data) }
  end

  # Envia `data` para todos os clientes em jogo que pertencem à guild `guild_name`.
  def send_data_to_guild(guild_name, data)
    @clients.each { |client| client.send_data(data) if client&.in_game? && client.guild_name == guild_name }
  end

  # ---------------------------------------------------------------------------
  # Login / Autenticação
  # ---------------------------------------------------------------------------

  # Envia os dados de login (lista de personagens) ao cliente.
  def send_login(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::LOGIN)
    buffer.write_byte(client.group)
    buffer.write_time(client.vip_time)
    buffer.write_byte(client.actors.size)
    client.actors.each do |actor_id, actor|
      buffer.write_byte(actor_id)
      buffer.write_string(actor.name)
      buffer.write_string(actor.character_name)
      buffer.write_byte(actor.character_index)
      buffer.write_string(actor.face_name)
      buffer.write_byte(actor.face_index)
      buffer.write_byte(actor.sex)
      actor.equips.each { |equip| buffer.write_short(equip) }
    end
    client.send_data(buffer.to_s)
  end

  # Notifica o cliente sobre falha no login com o tipo de erro `type`.
  def send_failed_login(client, type)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::FAIL_LOGIN)
    buffer.write_byte(type)
    client.send_data(buffer.to_s)
  end

  # Notifica o cliente sobre o resultado da criação de conta.
  def send_create_account(client, type)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CREATE_ACCOUNT)
    buffer.write_byte(type)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Gerenciamento de personagens (actors)
  # ---------------------------------------------------------------------------

  # Envia os dados de um personagem recém-criado ao cliente.
  def send_create_actor(client, actor_id, actor)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ACTOR)
    buffer.write_byte(actor_id)
    buffer.write_string(actor.name)
    buffer.write_string(actor.character_name)
    buffer.write_byte(actor.character_index)
    buffer.write_string(actor.face_name)
    buffer.write_byte(actor.face_index)
    buffer.write_byte(actor.sex)
    actor.equips.each { |equip| buffer.write_short(equip) }
    client.send_data(buffer.to_s)
  end

  # Notifica o cliente que a criação de personagem falhou.
  def send_failed_create_actor(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::FAIL_CREATE_ACTOR)
    client.send_data(buffer.to_s)
  end

  # Notifica o cliente para remover um personagem da lista de seleção.
  def send_remove_actor(client, actor_id)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REMOVE_ACTOR)
    buffer.write_byte(actor_id)
    client.send_data(buffer.to_s)
  end

  # Envia todos os dados do personagem selecionado para entrar no jogo.
  # Inclui: atributos, inventário, habilidades, amigos, quests, hotbar,
  # switches, variáveis, self-switches e posição inicial.
  def send_use_actor(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::USE_ACTOR)
    buffer.write_short(client.id)
    buffer.write_string(client.name)
    buffer.write_string(client.character_name)
    buffer.write_byte(client.character_index)
    buffer.write_string(client.face_name)
    buffer.write_byte(client.face_index)
    buffer.write_short(client.class_id)
    buffer.write_byte(client.sex)
    client.equips.each { |equip| buffer.write_short(equip) }
    client.param_base.each { |param| buffer.write_int(param) }
    buffer.write_int(client.hp)
    buffer.write_int(client.mp)
    buffer.write_int(client.exp)
    buffer.write_short(client.points)
    buffer.write_string(client.guild_name)
    buffer.write_int(client.gold)
    # Inventário: itens
    buffer.write_byte(client.actor.items.size)
    client.actor.items.each do |item_id, amount|
      buffer.write_short(item_id)
      buffer.write_short(amount)
    end
    # Inventário: armas
    buffer.write_byte(client.actor.weapons.size)
    client.actor.weapons.each do |weapon_id, amount|
      buffer.write_short(weapon_id)
      buffer.write_short(amount)
    end
    # Inventário: armaduras
    buffer.write_byte(client.actor.armors.size)
    client.actor.armors.each do |armor_id, amount|
      buffer.write_short(armor_id)
      buffer.write_short(amount)
    end
    # Habilidades aprendidas
    buffer.write_byte(client.skills.size)
    client.skills.each { |skill| buffer.write_short(skill) }
    # Lista de amigos
    buffer.write_byte(client.friends.size)
    client.friends.each { |friend| buffer.write_string(friend) }
    # Quests ativas/concluídas
    buffer.write_byte(client.quests.size)
    client.quests.each do |quest_id, quest|
      buffer.write_byte(quest_id)
      buffer.write_byte(quest.state)
    end
    # Hotbar (atalhos de habilidades/itens)
    client.hotbar.each do |hotbar|
      buffer.write_byte(hotbar.type)
      buffer.write_short(hotbar.item_id)
    end
    # Switches do jogador
    client.switches.data.each { |switch| buffer.write_boolean(switch) }
    # Variáveis do jogador
    client.variables.data.each { |variable| buffer.write_short(variable) }
    # Self-switches (chaves compostas: map_id, event_id, letra)
    buffer.write_short(client.self_switches.data.size)
    client.self_switches.data.each do |key, value|
      buffer.write_short(key[0])
      buffer.write_short(key[1])
      buffer.write_string(key[2])
      buffer.write_boolean(value)
    end
    # Posição inicial no mapa
    buffer.write_short(client.map_id)
    buffer.write_short(client.x)
    buffer.write_short(client.y)
    buffer.write_byte(client.direction)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # MOTD (Mensagem do dia)
  # ---------------------------------------------------------------------------

  # Envia a mensagem do dia (MOTD) ao cliente.
  def send_motd(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::MOTD)
    buffer.write_string(@motd)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Dados de jogadores no mapa
  # ---------------------------------------------------------------------------

  # Envia os dados do `client` para todos os jogadores no mapa `map_id`.
  #
  # [FIX-02] nil check em @maps[map_id]:
  #   Se map_id for inválido ou o mapa ainda não foi instanciado,
  #   @maps[map_id] retorna nil → nil.zero_players? → NoMethodError.
  def send_player_data(client, map_id)
    return unless @maps[map_id]
    return if @maps[map_id].zero_players?
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_DATA)
    buffer.write_short(client.id)
    buffer.write_byte(client.group)
    buffer.write_string(client.name)
    buffer.write_string(client.character_name)
    buffer.write_byte(client.character_index)
    buffer.write_byte(client.sex)
    client.equips.each { |equip| buffer.write_short(equip) }
    buffer.write_int(client.param_base[Enums::Param::MAXHP])
    buffer.write_int(client.hp)
    buffer.write_int(client.exp)
    buffer.write_string(client.guild_name)
    buffer.write_short(client.x)
    buffer.write_short(client.y)
    buffer.write_byte(client.direction)
    send_data_to_map(map_id, buffer.to_s)
  end

  # Envia os dados de todos os jogadores do mapa para o `player` recém-chegado.
  #
  # [FIX-02] nil check em @maps[player.map_id] — mesma razão de send_player_data.
  def send_map_players(player)
    return unless @maps[player.map_id]
    return if @maps[player.map_id].zero_players?
    @clients.each do |client|
      # Ignora clientes fora do jogo, de outro mapa ou o próprio jogador
      next if !client&.in_game? || client.map_id != player.map_id || client == player
      buffer = Buffer_Writer.new
      buffer.write_byte(Enums::Packet::PLAYER_DATA)
      buffer.write_short(client.id)
      buffer.write_byte(client.group)
      buffer.write_string(client.name)
      buffer.write_string(client.character_name)
      buffer.write_byte(client.character_index)
      buffer.write_byte(client.sex)
      client.equips.each { |equip| buffer.write_short(equip) }
      buffer.write_int(client.param_base[Enums::Param::MAXHP])
      buffer.write_int(client.hp)
      buffer.write_int(client.exp)
      buffer.write_string(client.guild_name)
      buffer.write_short(client.x)
      buffer.write_short(client.y)
      buffer.write_byte(client.direction)
      player.send_data(buffer.to_s)
    end
  end

  # Notifica o mapa para remover o sprite do jogador `client_id`.
  #
  # [FIX-02] nil check em @maps[map_id].
  def send_remove_player(client_id, map_id)
    return unless @maps[map_id]
    return if @maps[map_id].zero_players?
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REMOVE_PLAYER)
    buffer.write_short(client_id)
    send_data_to_map(map_id, buffer.to_s)
  end

  # Envia a nova posição/direção do `client` para todos no mesmo mapa.
  def send_player_movement(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_MOVE)
    buffer.write_short(client.id)
    buffer.write_short(client.x)
    buffer.write_short(client.y)
    buffer.write_byte(client.direction)
    send_data_to_map(client.map_id, buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Chat
  # ---------------------------------------------------------------------------

  # Envia uma mensagem de chat diretamente ao `client` (ex.: mensagens do sistema).
  def player_chat_message(client, message, color_id)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CHAT_MSG)
    buffer.write_byte(color_id)
    buffer.write_string(message)
    client.send_data(buffer.to_s)
  end

  # Envia uma mensagem de chat para todos os jogadores no mapa `map_id`.
  def map_chat_message(map_id, message, player_id, color_id = Enums::Chat::MAP)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::MAP_MSG)
    buffer.write_short(player_id)
    buffer.write_byte(color_id)
    buffer.write_string(message)
    send_data_to_map(map_id, buffer.to_s)
  end

  # Envia uma mensagem de chat global para todos os jogadores online.
  def global_chat_message(message, color_id = Enums::Chat::GLOBAL)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CHAT_MSG)
    buffer.write_byte(color_id)
    buffer.write_string(message)
    send_data_to_all(buffer.to_s)
  end

  # Envia uma mensagem de chat para todos os membros da party do `client`.
  # send_data_to_party já possui nil check em @parties[party_id] após [FIX-01].
  def party_chat_message(client, message)
    return unless client.in_party?
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CHAT_MSG)
    buffer.write_byte(Enums::Chat::PARTY)
    buffer.write_string(message)
    send_data_to_party(client.party_id, buffer.to_s)
  end

  # Envia uma mensagem de chat para todos os membros da guild do `client`.
  def guild_chat_message(client, message, color_id = Enums::Chat::GUILD)
    return unless client.in_guild?
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CHAT_MSG)
    buffer.write_byte(color_id)
    buffer.write_string(message)
    send_data_to_guild(client.guild_name, buffer.to_s)
  end

  # Envia uma mensagem privada de `client` para o jogador com nome `name`.
  #
  # [FIX-03] Guard contra name nil ou vazio:
  #   - String#casecmp(nil) retorna nil em Ruby < 2.4 → nil.zero? → NoMethodError.
  #   - Em Ruby >= 2.4 levanta TypeError.
  #   - Um pacote malformado com name vazio causaria crash ou comportamento
  #     indefinido. O guard elimina ambos os cenários antes de qualquer operação.
  def private_chat_message(client, message, name)
    return if name.nil? || name.empty?
    # Impede que o jogador envie mensagem privada para si mesmo
    return if client.name.casecmp(name).zero?
    player = find_player(name)
    unless player
      alert_message(client, Enums::Alert::INVALID_NAME)
      return
    end
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CHAT_MSG)
    buffer.write_byte(Enums::Chat::PRIVATE)
    buffer.write_string(message)
    # Envia para o destinatário e para o remetente (confirmação visual)
    player.send_data(buffer.to_s)
    client.send_data(buffer.to_s)
  end

  # Envia uma mensagem de alerta ao `client` com o tipo `type`.
  def alert_message(client, type)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ALERT_MSG)
    buffer.write_byte(type)
    client.send_data(buffer.to_s)
  end

  # Envia a lista de jogadores online ao `client` via chat global.
  def send_whos_online(client, message)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CHAT_MSG)
    buffer.write_byte(Enums::Chat::GLOBAL)
    buffer.write_string(message)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Combate
  # ---------------------------------------------------------------------------

  # Envia dados de ataque a um jogador para todos no mapa.
  def send_attack_player(map_id, hp_damage, mp_damage, critical, attacker_id, attacker_type, ani_index, player_id, animation_id, not_show_missed)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ATTACK_PLAYER)
    buffer.write_short(attacker_id)
    buffer.write_byte(attacker_type)
    buffer.write_byte(ani_index)
    buffer.write_short(player_id)
    buffer.write_int(hp_damage)
    buffer.write_int(mp_damage)
    buffer.write_boolean(critical)
    buffer.write_short(animation_id)
    buffer.write_boolean(not_show_missed)
    send_data_to_map(map_id, buffer.to_s)
  end

  # Envia dados de ataque a um inimigo (event) para todos no mapa.
  def send_attack_enemy(map_id, hp_damage, mp_damage, critical, attacker_id, attacker_type, ani_index, event_id, animation_id)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ATTACK_ENEMY)
    buffer.write_short(attacker_id)
    buffer.write_byte(attacker_type)
    buffer.write_byte(ani_index)
    buffer.write_short(event_id)
    buffer.write_int(hp_damage)
    buffer.write_int(mp_damage)
    buffer.write_boolean(critical)
    buffer.write_short(animation_id)
    send_data_to_map(map_id, buffer.to_s)
  end

  # Envia um pacote de animação para todos no mapa do `character`.
  def send_animation(character, animation_id, attacker_id, attacker_type, ani_index, character_type)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ANIMATION)
    buffer.write_short(attacker_id)
    buffer.write_byte(attacker_type)
    buffer.write_byte(ani_index)
    buffer.write_short(character.id)
    buffer.write_byte(character_type)
    buffer.write_short(animation_id)
    send_data_to_map(character.map_id, buffer.to_s)
  end

  # Envia um balão de emoção/estado para todos no mapa do `character`.
  def send_balloon(character, character_type, balloon_id)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::BALLOON)
    buffer.write_short(character.id)
    buffer.write_byte(character_type)
    buffer.write_byte(balloon_id)
    send_data_to_map(character.map_id, buffer.to_s)
  end

  # Envia um balão de emoção/estado de um inimigo diretamente ao `client`.
  def send_enemy_balloon(client, event_id, balloon_id)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::BALLOON)
    buffer.write_short(event_id)
    buffer.write_byte(Enums::Target::ENEMY)
    buffer.write_byte(balloon_id)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Eventos / Inimigos
  # ---------------------------------------------------------------------------

  # Notifica o mapa que um inimigo (event) reviveu.
  #
  # [FIX-02] nil check em @maps[event.map_id].
  def send_enemy_revive(event)
    return unless @maps[event.map_id]
    return if @maps[event.map_id].zero_players?
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ENEMY_REVIVE)
    buffer.write_short(event.id)
    send_data_to_map(event.map_id, buffer.to_s)
  end

  # Envia os dados de todos os eventos do mapa ao `client` recém-chegado.
  # Nota: @maps[client.map_id] é garantido válido pelo fluxo de entrada no mapa.
  def send_map_events(client)
    @maps[client.map_id].events.each do |event_id, event|
      buffer = Buffer_Writer.new
      buffer.write_byte(Enums::Packet::EVENT_DATA)
      buffer.write_short(event_id)
      buffer.write_short(event.x)
      buffer.write_short(event.y)
      buffer.write_byte(event.direction)
      buffer.write_int(event.hp)
      client.send_data(buffer.to_s)
    end
  end

  # Envia a nova posição/direção de um evento para todos no mapa.
  #
  # [FIX-02] nil check em @maps[event.map_id].
  def send_event_movement(event)
    return unless @maps[event.map_id]
    return if @maps[event.map_id].zero_players?
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::EVENT_MOVE)
    buffer.write_short(event.id)
    buffer.write_short(event.x)
    buffer.write_short(event.y)
    buffer.write_byte(event.direction)
    send_data_to_map(event.map_id, buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Drops (itens no chão)
  # ---------------------------------------------------------------------------

  # Envia todos os drops do mapa ao `client` recém-chegado.
  # Nota: @maps[client.map_id] é garantido válido pelo fluxo de entrada no mapa.
  def send_map_drops(client)
    @maps[client.map_id].drops.each do |drop|
      buffer = Buffer_Writer.new
      buffer.write_byte(Enums::Packet::ADD_DROP)
      buffer.write_short(drop.item_id)
      buffer.write_byte(drop.kind)
      buffer.write_short(drop.amount)
      buffer.write_short(drop.x)
      buffer.write_short(drop.y)
      client.send_data(buffer.to_s)
    end
  end

  # Notifica todos no mapa sobre um novo drop adicionado ao chão.
  def send_add_drop(map_id, item_id, kind, amount, x, y)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ADD_DROP)
    buffer.write_short(item_id)
    buffer.write_byte(kind)
    buffer.write_short(amount)
    buffer.write_short(x)
    buffer.write_short(y)
    send_data_to_map(map_id, buffer.to_s)
  end

  # Notifica todos no mapa para remover um drop do chão.
  #
  # [FIX-02] nil check em @maps[map_id].
  def send_remove_drop(map_id, drop_id)
    return unless @maps[map_id]
    return if @maps[map_id].zero_players?
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REMOVE_DROP)
    buffer.write_byte(drop_id)
    send_data_to_map(map_id, buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Projéteis
  # ---------------------------------------------------------------------------

  # Envia dados de um projétil disparado pelo `client` para todos no mapa.
  def send_add_projectile(client, finish_x, finish_y, target, projectile_type, projectile_id)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ADD_PROJECTILE)
    buffer.write_short(client.x)
    buffer.write_short(client.y)
    buffer.write_short(finish_x)
    buffer.write_short(finish_y)
    buffer.write_short(target.x)
    buffer.write_short(target.y)
    buffer.write_byte(projectile_type)
    buffer.write_byte(projectile_id)
    send_data_to_map(client.map_id, buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Atributos e status do jogador
  # ---------------------------------------------------------------------------

  # Envia HP e MP atuais do `client` para todos no mapa.
  def send_player_vitals(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_VITALS)
    buffer.write_short(client.id)
    buffer.write_int(client.hp)
    buffer.write_int(client.mp)
    send_data_to_map(client.map_id, buffer.to_s)
  end

  # Envia a experiência ganha pelo `client` para todos no mapa.
  def send_player_exp(client, exp)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_EXP)
    buffer.write_short(client.id)
    buffer.write_int(exp)
    send_data_to_map(client.map_id, buffer.to_s)
  end

  # Envia adição ou remoção de um estado (buff/debuff) ao `client`.
  def send_player_state(client, state_id, add_state = true)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_STATE)
    buffer.write_short(state_id)
    buffer.write_boolean(add_state)
    client.send_data(buffer.to_s)
  end

  # Envia o nível de buff de um parâmetro ao `client`.
  def send_player_buff(client, param_id, buff_level)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_BUFF)
    buffer.write_byte(param_id)
    buffer.write_short(buff_level)
    client.send_data(buffer.to_s)
  end

  # Envia o valor de um switch do jogador ao `client`.
  def send_player_switch(client, switch_id)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::SWITCH)
    buffer.write_short(switch_id)
    buffer.write_boolean(client.switches[switch_id])
    client.send_data(buffer.to_s)
  end

  # Envia o valor de uma variável do jogador ao `client`.
  def send_player_variable(client, variable_id)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::VARIABLE)
    buffer.write_short(variable_id)
    buffer.write_short(client.variables[variable_id])
    client.send_data(buffer.to_s)
  end

  # Envia o valor de um self-switch do jogador ao `client`.
  # A chave `key` é composta por [map_id, event_id, letra].
  def send_player_self_switch(client, key)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::SELF_SWITCH)
    buffer.write_short(key[0])
    buffer.write_short(key[1])
    buffer.write_string(key[2])
    buffer.write_boolean(client.self_switches[key])
    client.send_data(buffer.to_s)
  end

  # Envia atualização de item no inventário do `client`.
  def send_player_item(client, item_id, kind, amount, drop_sound, popup)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_ITEM)
    buffer.write_short(item_id)
    buffer.write_byte(kind)
    buffer.write_short(amount)
    buffer.write_boolean(drop_sound)
    buffer.write_boolean(popup)
    client.send_data(buffer.to_s)
  end

  # Envia atualização do ouro do `client`.
  def send_player_gold(client, amount, shop_sound, popup)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_GOLD)
    buffer.write_int(amount)
    buffer.write_boolean(shop_sound)
    buffer.write_boolean(popup)
    client.send_data(buffer.to_s)
  end

  # Envia atualização de um parâmetro do `client` para todos no mapa.
  def send_player_param(client, param_id, value)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_PARAM)
    buffer.write_short(client.id)
    buffer.write_byte(param_id)
    buffer.write_short(value)
    send_data_to_map(client.map_id, buffer.to_s)
  end

  # Envia atualização de um slot de equipamento do `client` para todos no mapa.
  def send_player_equip(client, slot_id)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_EQUIP)
    buffer.write_short(client.id)
    buffer.write_byte(slot_id)
    buffer.write_short(client.equips[slot_id])
    send_data_to_map(client.map_id, buffer.to_s)
  end

  # Envia aprendizado ou esquecimento de uma habilidade ao `client`.
  def send_player_skill(client, skill_id, learn = true)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_SKILL)
    buffer.write_short(skill_id)
    buffer.write_boolean(learn)
    client.send_data(buffer.to_s)
  end

  # Envia a mudança de classe do `client`.
  def send_player_class(client, class_id)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_CLASS)
    buffer.write_short(class_id)
    client.send_data(buffer.to_s)
  end

  # Envia a mudança de sexo do `client` para todos no mapa.
  def send_player_sex(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_SEX)
    buffer.write_short(client.id)
    buffer.write_byte(client.sex)
    send_data_to_map(client.map_id, buffer.to_s)
  end

  # Envia a mudança de gráfico (sprite/face) do `client` para todos no mapa.
  def send_player_graphic(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_GRAPHIC)
    buffer.write_short(client.id)
    buffer.write_string(client.character_name)
    buffer.write_byte(client.character_index)
    buffer.write_string(client.face_name)
    buffer.write_byte(client.face_index)
    send_data_to_map(client.map_id, buffer.to_s)
  end

  # Envia a quantidade de pontos de atributo disponíveis ao `client`.
  def send_player_points(client, points)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_POINTS)
    buffer.write_short(points)
    client.send_data(buffer.to_s)
  end

  # Envia a atualização de um slot da hotbar ao `client`.
  #
  # [FIX-04] Variável local `hotbar`:
  #   No código original, client.hotbar[id] era acessado duas vezes separadas.
  #   Armazenar em variável local evita dupla indexação e garante consistência
  #   caso o array seja modificado entre as duas leituras (ex.: por outro thread
  #   ou callback assíncrono).
  def send_player_hotbar(client, id)
    hotbar = client.hotbar[id]
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_HOTBAR)
    buffer.write_byte(id)
    buffer.write_byte(hotbar.type)
    buffer.write_short(hotbar.item_id)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Alvo (target)
  # ---------------------------------------------------------------------------

  # Envia o alvo atual do `client` de volta ao próprio cliente.
  def send_target(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::TARGET)
    buffer.write_byte(client.target.type)
    buffer.write_short(client.target.id)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Transferência de mapa
  # ---------------------------------------------------------------------------

  # Envia os dados de transferência de mapa ao `client`.
  def send_transfer_player(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::TRANSFER)
    buffer.write_short(client.map_id)
    buffer.write_short(client.x)
    buffer.write_short(client.y)
    buffer.write_byte(client.direction)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Sistema de amigos
  # ---------------------------------------------------------------------------

  # Envia a janela de amigos com a lista de amigos online ao `client`.
  def send_open_friends(client, online_friends)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::OPEN_FRIENDS)
    buffer.write_byte(online_friends.size)
    online_friends.each { |name| buffer.write_string(name) }
    client.send_data(buffer.to_s)
  end

  # Notifica o `client` que um amigo foi adicionado à lista.
  def send_add_friend(client, friend_name)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ADD_FRIEND)
    buffer.write_string(friend_name)
    client.send_data(buffer.to_s)
  end

  # Notifica o `client` que um amigo foi removido da lista pelo índice.
  def send_remove_friend(client, index)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REMOVE_FRIEND)
    buffer.write_byte(index)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Sistema de guild
  # ---------------------------------------------------------------------------

  # Abre a janela de criação de guild para o `client`.
  def send_open_create_guild(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::OPEN_CREATE_GUILD)
    client.send_data(buffer.to_s)
  end

  # Envia os dados da guild ao `client` para exibição na janela de guild.
  #
  # [FIX-05] nil check em @guilds[client.guild_name]:
  #   A guild pode ser dissolvida entre o momento em que a requisição chegou
  #   e a execução deste método. Sem o guard, @guilds[...] retorna nil e
  #   nil.leader → NoMethodError. Variável local `guild` evita múltiplos
  #   acessos ao hash e garante consistência durante toda a serialização.
  def send_open_guild(client, online_members_size)
    guild = @guilds[client.guild_name]
    return unless guild
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::OPEN_GUILD)
    buffer.write_string(guild.leader)
    buffer.write_string(guild.notice)
    guild.flag.each { |color_id| buffer.write_byte(color_id) }
    buffer.write_byte(guild.members.size)
    buffer.write_byte(online_members_size)
    guild.members.each { |name| buffer.write_string(name) }
    client.send_data(buffer.to_s)
  end

  # Envia o nome do líder da guild ao `client`.
  #
  # [FIX-05] nil check em @guilds[client.guild_name].
  def send_guild_leader(client)
    guild = @guilds[client.guild_name]
    return unless guild
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::GUILD_LEADER)
    buffer.write_string(guild.leader)
    client.send_data(buffer.to_s)
  end

  # Envia o aviso (notice) da guild ao `client`.
  #
  # [FIX-05] nil check em @guilds[client.guild_name].
  def send_guild_notice(client)
    guild = @guilds[client.guild_name]
    return unless guild
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::GUILD_NOTICE)
    buffer.write_string(guild.notice)
    client.send_data(buffer.to_s)
  end

  # Envia o nome da guild do `client` para todos no mapa (exibição no sprite).
  def send_guild_name(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::GUILD_NAME)
    buffer.write_string(client.guild_name)
    buffer.write_short(client.id)
    send_data_to_map(client.map_id, buffer.to_s)
  end

  # Notifica o `client` que um membro foi removido da guild.
  def send_remove_guild_member(client, name)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REMOVE_GUILD_MEMBER)
    buffer.write_string(name)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Sistema de party
  # ---------------------------------------------------------------------------

  # Envia os dados de um membro que entrou na party ao `client`.
  def send_join_party(client, player)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::JOIN_PARTY)
    buffer.write_short(player.id)
    buffer.write_string(player.name)
    buffer.write_string(player.character_name)
    buffer.write_byte(player.character_index)
    buffer.write_byte(player.sex)
    player.equips.each { |equip| buffer.write_short(equip) }
    buffer.write_int(player.param_base[Enums::Param::MAXHP])
    buffer.write_int(player.hp)
    buffer.write_int(player.exp)
    client.send_data(buffer.to_s)
  end

  # Notifica todos na party que o `client` saiu.
  # send_data_to_party já possui nil check após [FIX-01].
  def send_leave_party(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::LEAVE_PARTY)
    buffer.write_short(client.id)
    send_data_to_party(client.party_id, buffer.to_s)
  end

  # Notifica o `client` que a party foi dissolvida.
  def send_dissolve_party(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::DISSOLVE_PARTY)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Banco
  # ---------------------------------------------------------------------------

  # Envia os dados do banco (ouro + itens) ao `client` para abrir a janela.
  def send_open_bank(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::OPEN_BANK)
    buffer.write_int(client.bank_gold)
    # Itens no banco
    buffer.write_byte(client.bank_items.size)
    client.bank_items.each do |item_id, amount|
      buffer.write_short(item_id)
      buffer.write_short(amount)
    end
    # Armas no banco
    buffer.write_byte(client.bank_weapons.size)
    client.bank_weapons.each do |weapon_id, amount|
      buffer.write_short(weapon_id)
      buffer.write_short(amount)
    end
    # Armaduras no banco
    buffer.write_byte(client.bank_armors.size)
    client.bank_armors.each do |armor_id, amount|
      buffer.write_short(armor_id)
      buffer.write_short(amount)
    end
    client.send_data(buffer.to_s)
  end

  # Envia atualização de um item no banco ao `client`.
  def send_bank_item(client, item_id, kind, amount)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::BANK_ITEM)
    buffer.write_short(item_id)
    buffer.write_byte(kind)
    buffer.write_short(amount)
    client.send_data(buffer.to_s)
  end

  # Envia atualização do ouro no banco ao `client`.
  def send_bank_gold(client, amount)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::BANK_GOLD)
    buffer.write_int(amount)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Janelas / UI
  # ---------------------------------------------------------------------------

  # Envia sinal para fechar a janela atual do `client`.
  def send_close_window(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CLOSE_WINDOW)
    client.send_data(buffer.to_s)
  end

  # Envia sinal para abrir a loja de um evento ao `client`.
  def send_open_shop(client, event_id, index)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::OPEN_SHOP)
    buffer.write_short(event_id)
    buffer.write_short(index)
    client.send_data(buffer.to_s)
  end

  # Envia sinal para abrir a janela de teleporte ao `client`.
  def send_open_teleport(client, teleport_id)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::OPEN_TELEPORT)
    buffer.write_byte(teleport_id)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Comandos de evento
  # ---------------------------------------------------------------------------

  # Envia um comando de evento ao `client` (ex.: abrir diálogo, executar ação).
  def send_event_command(client, event_id, initial_index, final_index)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::EVENT_COMMAND)
    buffer.write_short(event_id)
    buffer.write_short(initial_index)
    buffer.write_short(final_index)
    client.send_data(buffer.to_s)
  end

  # Envia um comando de processo paralelo para todos no mapa do evento.
  #
  # [FIX-02] nil check em @maps[event.map_id].
  def send_parallel_process_command(event, initial_index, final_index)
    return unless @maps[event.map_id]
    return if @maps[event.map_id].zero_players?
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::EVENT_COMMAND)
    buffer.write_short(event.id)
    buffer.write_short(initial_index)
    buffer.write_short(final_index)
    send_data_to_map(event.map_id, buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Requisições (convites)
  # ---------------------------------------------------------------------------

  # Envia uma requisição (convite de party, guild, trade etc.) ao `client`.
  def send_request(client, type, player)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REQUEST)
    buffer.write_byte(type)
    buffer.write_string(player.name)
    buffer.write_string(player.guild_name)
    client.send_data(buffer.to_s)
  end

  # Notifica o `client` que uma requisição foi aceita.
  def send_accept_request(client, type)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ACCEPT_REQUEST)
    buffer.write_byte(type)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Sistema de troca (trade)
  # ---------------------------------------------------------------------------

  # Envia atualização de item na janela de troca ao `client`.
  def send_trade_item(client, player_id, item_id, kind, amount)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::TRADE_ITEM)
    buffer.write_short(player_id)
    buffer.write_short(item_id)
    buffer.write_byte(kind)
    buffer.write_short(amount)
    client.send_data(buffer.to_s)
  end

  # Envia atualização de ouro na janela de troca ao `client`.
  def send_trade_gold(client, player_id, amount)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::TRADE_GOLD)
    buffer.write_short(player_id)
    buffer.write_int(amount)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Sistema de quests
  # ---------------------------------------------------------------------------

  # Notifica o `client` que uma nova quest foi adicionada.
  def send_add_quest(client, quest_id)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ADD_QUEST)
    buffer.write_byte(quest_id)
    client.send_data(buffer.to_s)
  end

  # Notifica o `client` que uma quest foi concluída.
  def send_finish_quest(client, quest_id)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::FINISH_QUEST)
    buffer.write_byte(quest_id)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # VIP
  # ---------------------------------------------------------------------------

  # Envia o tempo VIP atualizado ao `client`.
  def send_vip_days(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::VIP_DAYS)
    buffer.write_time(client.vip_time + client.added_vip_time)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Logout
  # ---------------------------------------------------------------------------

  # Envia os dados de logout ao `client` para retornar à tela de seleção.
  def send_logout(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::LOGOUT)
    buffer.write_byte(client.actor_id)
    buffer.write_string(client.name)
    buffer.write_string(client.character_name)
    buffer.write_byte(client.character_index)
    buffer.write_string(client.face_name)
    buffer.write_byte(client.face_index)
    buffer.write_byte(client.sex)
    client.equips.each { |equip| buffer.write_short(equip) }
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Administração
  # ---------------------------------------------------------------------------

  # Envia um comando administrativo ao `client` com mensagem de alerta opcional.
  def send_admin_command(client, command, alert_msg = '')
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ADMIN_COMMAND)
    buffer.write_byte(command)
    buffer.write_string(alert_msg)
    client.send_data(buffer.to_s)
  end

  # ---------------------------------------------------------------------------
  # Switches globais (rede)
  # ---------------------------------------------------------------------------

  # Envia a atualização de um switch global para todos os jogadores online.
  def send_global_switch(switch_id, value)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::SWITCH)
    buffer.write_short(switch_id)
    buffer.write_boolean(value)
    send_data_to_all(buffer.to_s)
  end

  # Envia todos os switches globais de rede ao `client` recém-conectado.
  # Os 100 switches globais começam após os switches de jogador
  # (offset: Configs::MAX_PLAYER_SWITCHES + 1).
  def send_global_switches(client)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::NET_SWITCHES)
    100.times { |switch_id| buffer.write_boolean(@switches[switch_id + Configs::MAX_PLAYER_SWITCHES + 1]) }
    client.send_data(buffer.to_s)
  end

end