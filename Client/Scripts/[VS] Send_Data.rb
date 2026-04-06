#==============================================================================
# ** Send_Data
#------------------------------------------------------------------------------
# Este script envia as mensagens para o servidor.
#------------------------------------------------------------------------------
# Autor: Valentine
#==============================================================================

module Send_Data

  #----------------------------------------------------------------------------
  # * Enviar login
  #----------------------------------------------------------------------------
  def send_login(user, pass)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::LOGIN)
    buffer.write_string(user)
    buffer.write_string(VXAOS::sha256(pass))  # ATUALIZADO: SHA-256 substituiu MD5
    buffer.write_short(Configs::GAME_VERSION)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar criação de conta
  #----------------------------------------------------------------------------
  def send_create_account(user, pass, email)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CREATE_ACCOUNT)
    buffer.write_string(user)
    buffer.write_string(VXAOS::sha256(pass))  # ATUALIZADO: SHA-256 substituiu MD5
    buffer.write_string(email)
    buffer.write_short(Configs::GAME_VERSION)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar criação de personagem
  #----------------------------------------------------------------------------
  def send_create_actor(actor_id, name, character_index, class_id, sex, params)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CREATE_ACTOR)
    buffer.write_byte(actor_id)
    buffer.write_string(name)
    buffer.write_byte(character_index)
    buffer.write_short(class_id)
    buffer.write_byte(sex)
    params.each { |param| buffer.write_byte(param) }
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar uso de personagem
  #----------------------------------------------------------------------------
  def send_use_actor(actor_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::USE_ACTOR)
    buffer.write_byte(actor_id)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar remoção de personagem
  #----------------------------------------------------------------------------
  def send_remove_actor(actor_id, pass)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REMOVE_ACTOR)
    buffer.write_byte(actor_id)
    buffer.write_string(VXAOS::sha256(pass))  # ATUALIZADO: SHA-256 substituiu MD5
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar movimento do jogador
  #----------------------------------------------------------------------------
  def send_player_movement(direction)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_MOVE)
    buffer.write_byte(direction)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar mensagem de chat
  #----------------------------------------------------------------------------
  def send_chat_message(message, talk_type, player_name = '')
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CHAT_MSG)
    buffer.write_string(message)
    buffer.write_byte(talk_type)
    buffer.write_string(player_name)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar ataque do jogador
  #----------------------------------------------------------------------------
  def send_player_attack
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_ATTACK)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar uso de item
  #----------------------------------------------------------------------------
  def send_use_item(item_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::USE_ITEM)
    buffer.write_short(item_id)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar uso de habilidade
  #----------------------------------------------------------------------------
  def send_use_skill(skill_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::USE_SKILL)
    buffer.write_short(skill_id)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar balão
  #----------------------------------------------------------------------------
  def send_balloon(balloon_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::BALLOON)
    buffer.write_byte(balloon_id)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar uso de hotbar
  #----------------------------------------------------------------------------
  def send_use_hotbar(id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::USE_HOTBAR)
    buffer.write_byte(id)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar adição de drop
  #----------------------------------------------------------------------------
  def send_add_drop(item_id, kind, amount)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ADD_DROP)
    buffer.write_short(item_id)
    buffer.write_byte(kind)
    buffer.write_short(amount)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar remoção de drop
  #----------------------------------------------------------------------------
  def send_remove_drop(drop_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REMOVE_DROP)
    buffer.write_byte(drop_id)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar adição de parâmetro
  #----------------------------------------------------------------------------
  def send_add_param(param_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_PARAM)
    buffer.write_byte(param_id)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar equipamento do jogador
  #----------------------------------------------------------------------------
  def send_player_equip(item_id, slot_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_EQUIP)
    buffer.write_byte(slot_id)
    buffer.write_short(item_id)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar hotbar do jogador
  #----------------------------------------------------------------------------
  def send_player_hotbar(id, type, item_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_HOTBAR)
    buffer.write_byte(id)
    buffer.write_byte(type)
    buffer.write_short(item_id)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar alvo
  #----------------------------------------------------------------------------
  def send_target(target_id, type)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::TARGET)
    buffer.write_byte(type)
    buffer.write_short(target_id)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar abertura da janela de amigos
  #----------------------------------------------------------------------------
  def send_open_friend_window
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::OPEN_FRIENDS)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar remoção de amigo
  #----------------------------------------------------------------------------
  def send_remove_friend(index)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REMOVE_FRIEND)
    buffer.write_byte(index)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar criação de guilda
  #----------------------------------------------------------------------------
  def send_create_guild(name, flag)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CREATE_GUILD)
    buffer.write_string(name)
    flag.each { |color_id| buffer.write_byte(color_id) }
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar abertura da janela de guilda
  #----------------------------------------------------------------------------
  def send_open_guild_window
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::OPEN_GUILD)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar líder de guilda
  #----------------------------------------------------------------------------
  def send_guild_leader(name)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::GUILD_LEADER)
    buffer.write_string(name)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar aviso de guilda
  #----------------------------------------------------------------------------
  def send_guild_notice(notice)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::GUILD_NOTICE)
    buffer.write_string(notice)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar remoção de membro de guilda
  #----------------------------------------------------------------------------
  def send_remove_guild_member(name)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REMOVE_GUILD_MEMBER)
    buffer.write_string(name)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar pedido de guilda
  #----------------------------------------------------------------------------
  def send_guild_request(name)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::GUILD_REQUEST)
    buffer.write_string(name)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar saída de guilda
  #----------------------------------------------------------------------------
  def send_leave_guild
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::LEAVE_GUILD)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar saída de grupo
  #----------------------------------------------------------------------------
  def send_leave_party
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::LEAVE_PARTY)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar escolha
  #----------------------------------------------------------------------------
  def send_choice(index)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CHOICE)
    buffer.write_int(index)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar item para o banco
  #----------------------------------------------------------------------------
  def send_bank_item(item_id, kind, amount)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::BANK_ITEM)
    buffer.write_short(item_id)
    buffer.write_byte(kind)
    buffer.write_short(amount)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar ouro para o banco
  #----------------------------------------------------------------------------
  def send_bank_gold(amount)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::BANK_GOLD)
    buffer.write_int(amount)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar fechamento de janela
  #----------------------------------------------------------------------------
  def send_close_window
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CLOSE_WINDOW)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar compra de item
  #----------------------------------------------------------------------------
  def send_buy_item(index, amount)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::BUY_ITEM)
    buffer.write_byte(index)
    buffer.write_short(amount)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar venda de item
  #----------------------------------------------------------------------------
  def send_sell_item(item_id, kind, amount)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::SELL_ITEM)
    buffer.write_short(item_id)
    buffer.write_byte(kind)
    buffer.write_short(amount)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar escolha de teleporte
  #----------------------------------------------------------------------------
  def send_choice_telepot(index)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CHOICE_TELEPORT)
    buffer.write_byte(index)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar próximo comando de evento
  #----------------------------------------------------------------------------
  def send_next_event_command
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::NEXT_COMMAND)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar pedido
  #----------------------------------------------------------------------------
  def send_request(type, player_id = -1)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REQUEST)
    buffer.write_byte(type)
    buffer.write_short(player_id)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar aceitação de pedido
  #----------------------------------------------------------------------------
  def send_accept_request
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ACCEPT_REQUEST)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar recusa de pedido
  #----------------------------------------------------------------------------
  def send_decline_request
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::DECLINE_REQUEST)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar item de troca
  #----------------------------------------------------------------------------
  def send_trade_item(item_id, kind, amount)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::TRADE_ITEM)
    buffer.write_short(item_id)
    buffer.write_byte(kind)
    buffer.write_short(amount)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar ouro de troca
  #----------------------------------------------------------------------------
  def send_trade_gold(amount)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::TRADE_GOLD)
    buffer.write_int(amount)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar logout
  #----------------------------------------------------------------------------
  def send_logout
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::LOGOUT)
    @socket.send(buffer.to_s)
  end

  #----------------------------------------------------------------------------
  # * Enviar comando de administrador
  #----------------------------------------------------------------------------
  def send_admin_command(command, str, int1 = 0, int2 = 0, int3 = 0)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ADMIN_COMMAND)
    buffer.write_byte(command)
    buffer.write_string(str)
    buffer.write_int(int1)
    buffer.write_int(int2)
    buffer.write_short(int3)
    @socket.send(buffer.to_s)
  end

end # module Send_Data