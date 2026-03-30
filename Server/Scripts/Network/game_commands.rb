#==============================================================================
# ** Game_Commands
#------------------------------------------------------------------------------
#  Este script lida com os comandos do painel de administração.
#------------------------------------------------------------------------------
#  Autor: Valentine
#  Revisado: guards de nil, precisão de logs, robustez de amount e days
#==============================================================================

module Game_Commands

  #----------------------------------------------------------------------------
  # * Despacha comandos recebidos do painel de administração
  #   - client : conexão do administrador que enviou o comando
  #   - command: constante Enums::Command identificando a ação
  #   - str    : argumento textual (nome do jogador, mensagem, etc.)
  #   - int1/2/3: argumentos inteiros (id de item, quantidade, coordenadas…)
  #----------------------------------------------------------------------------
  def admin_commands(client, command, str, int1, int2, int3)
    case command
    when Enums::Command::KICK
      kick_player(client, str)

    when Enums::Command::TELEPORT
      teleport_player(client, str, int1, int2, int3)

    when Enums::Command::GO
      go_to_player(client, str)

    when Enums::Command::PULL
      pull_player(client, str)

    when Enums::Command::ITEM
      # CORREÇÃO: $data_items[int1] retorna nil para índice 0 ou fora do range.
      # Chamar give_item com item=nil causnil causaria NoMethodError em item.name.
      # O guard "if item" garante que só prosseguimos com um item válido.
      item = $data_items[int1]
      give_item(client, item, str, int2) if item

    when Enums::Command::WEAPON
      # Mesmo guard aplicado para armas
      item = $data_weapons[int1]
      give_item(client, item, str, int2) if item

    when Enums::Command::ARMOR
      # Mesmo guard aplicado para armaduras
      item = $data_armors[int1]
      give_item(client, item, str, int2) if item

    when Enums::Command::GOLD
      give_gold(client, str, int2)

    when Enums::Command::BAN_IP, Enums::Command::BAN_ACC
      ban(client, command, str, int1)

    when Enums::Command::UNBAN
      Database.unban(client, str)

    when Enums::Command::SWITCH
      # Converte str para inteiro pois o painel envia o ID como string
      change_global_switch(str.to_i, int1 == 1)

    when Enums::Command::MOTD
      change_motd(client, str)

    when Enums::Command::MUTE
      mute_player(client, str)

    when Enums::Command::MSG
      admin_message(client, str)
    end
  end

  #----------------------------------------------------------------------------
  # * Despacha comandos recebidos do painel de monitoramento (permissões
  #   reduzidas em relação ao painel de administração completo)
  #----------------------------------------------------------------------------
  def monitor_commands(client, command, name)
    case command
    when Enums::Command::GO
      go_to_player(client, name)
    when Enums::Command::PULL
      pull_player(client, name)
    when Enums::Command::MUTE
      mute_player(client, name)
    end
  end

  #----------------------------------------------------------------------------
  # * Expulsa um jogador do servidor
  #   - Protege administradores de serem expulsos por outros admins
  #----------------------------------------------------------------------------
  def kick_player(client, name)
    player = find_player(name)

    # Rejeita se o jogador não foi encontrado ou se é administrador
    if !player || player.admin?
      alert_message(client, Enums::Alert::INVALID_NAME)
      return
    end

    global_chat_message("#{player.name} #{Kicked}")
    send_admin_command(player, Enums::Command::KICK)
    player.close_connection_after_writing
    @log.add(client.group, :blue, "#{client.user} expulsou #{player.name}.")
  end

  #----------------------------------------------------------------------------
  # * Teletransporta um jogador (ou todos) para um mapa/coordenada específica
  #   - player: admin que executou o comando
  #   - name  : nome do alvo ou 'all' para todos os jogadores em jogo
  #   - map_id, x, y: destino do teletransporte
  #
  #   CORREÇÃO: flag `teleported` garante que o log só é registrado quando ao
  #   menos um jogador foi de fato teletransportado. Sem ela, o log dispararia
  #   mesmo quando nenhum jogador com o nome informado estava online.
  #----------------------------------------------------------------------------
  def teleport_player(player, name, map_id, x, y)
    teleported = false

    @clients.each do |client|
      next unless client

      if name == 'all' && client.in_game?
        client.transfer(map_id, x, y, client.direction)
        alert_message(client, Enums::Alert::TELEPORTED)
        teleported = true

      elsif client.name.casecmp(name).zero?
        client.transfer(map_id, x, y, client.direction)
        alert_message(client, Enums::Alert::TELEPORTED)
        # Notifica o admin no chat apenas quando o alvo é outro jogador
        player_chat_message(
          player,
          "#{sprintf(Teleported, client.name, x, y)} #{map_id}.",
          Configs::SUCCESS_COLOR
        ) if client != player
        teleported = true
        break
      end
    end

    # Log registrado somente se ao menos um jogador foi teletransportado
    @log.add(
      player.group, :blue,
      "#{player.user} teletransportou #{name} para as coordenadas #{x} e #{y} do mapa #{map_id}."
    ) if teleported
  end

  #----------------------------------------------------------------------------
  # * Teletransporta o admin até a posição de outro jogador
  #
  #   CORREÇÃO: o log agora usa as coordenadas do jogador de destino (player.x,
  #   player.y) em vez de client.x/client.y, que podem ainda não refletir a
  #   nova posição dependendo da implementação interna de #transfer.
  #----------------------------------------------------------------------------
  def go_to_player(client, name)
    player = find_player(name)

    unless player
      alert_message(client, Enums::Alert::INVALID_NAME)
      return
    end

    client.transfer(player.map_id, player.x, player.y, client.direction)

    # Usa coordenadas do destino (player) para precisão no log
    @log.add(
      client.group, :blue,
      "#{client.user} foi até #{name}, nas coordenadas #{player.x} e #{player.y} do mapa #{player.map_id}."
    )
  end

  #----------------------------------------------------------------------------
  # * Puxa um jogador (ou todos) até a posição atual do admin
  #
  #   CORREÇÃO: mesma flag de log preciso aplicada ao pull — o log só é
  #   registrado quando ao menos um jogador foi efetivamente puxado.
  #----------------------------------------------------------------------------
  def pull_player(player, name)
    pulled = false

    @clients.each do |client|
      next unless client

      if name == 'all' && client.in_game? && client != player
        client.transfer(player.map_id, player.x, player.y, client.direction)
        alert_message(client, Enums::Alert::PULLED)
        pulled = true

      elsif client.name.casecmp(name).zero?
        client.transfer(player.map_id, player.x, player.y, client.direction)
        alert_message(client, Enums::Alert::PULLED)
        pulled = true
        break
      end
    end

    # Log registrado somente se ao menos um jogador foi puxado
    @log.add(
      player.group, :blue,
      "#{player.user} puxou #{name} para as coordenadas #{player.x} e #{player.y} do mapa #{player.map_id}."
    ) if pulled
  end

  #----------------------------------------------------------------------------
  # * Entrega um item (item/arma/armadura) a um jogador ou a todos
  #   - item  : objeto RPG::Item/Weapon/Armor — NUNCA deve ser nil aqui
  #   - amount: quantidade a entregar
  #
  #   CORREÇÃO (guard duplo):
  #     1. item nil   → índice inválido passado pelo painel; encerramos cedo
  #        para evitar NoMethodError em item.name dentro do loop.
  #     2. amount <= 0 → quantidade sem sentido; evita log falso e gain_item
  #        com valor negativo/zero que poderia corromper o inventário.
  #----------------------------------------------------------------------------
  def give_item(player, item, name, amount)
    return unless item && amount > 0

    given = false

    @clients.each do |client|
      next unless client

      if name == 'all' && client.in_game?
        # Mantém a condição original: só entrega se o inventário não estiver cheio
        client.gain_item(item, amount, false, true) unless client.full_inventory?(item)
        given = true

      elsif client.name.casecmp(name).zero?
        if client.full_inventory?(item)
          player_chat_message(player, sprintf(FullInventory, client.name), Configs::ERROR_COLOR)
          # Log específico para tentativa frustrada por inventário cheio
          @log.add(
            player.group, :blue,
            "#{player.user} tentou dar #{amount} #{item.name} para #{name}, mas o inventário deste estava cheio."
          )
          return
        end

        client.gain_item(item, amount, false, true)
        player_chat_message(
          player,
          "#{sprintf(GaveItem, amount, item.name)} #{client.name}.",
          Configs::SUCCESS_COLOR
        )
        given = true
        break
      end
    end

    # CORREÇÃO: log só dispara quando o item foi entregue de fato
    @log.add(
      player.group, :blue,
      "#{player.user} deu #{amount} #{item.name} para #{name}."
    ) if given
  end

  #----------------------------------------------------------------------------
  # * Entrega ouro a um jogador ou a todos
  #
  #   CORREÇÃO: guard — amount zero ou negativo não faz sentido operacional e
  #   evitaria um log falso de "deu 0 moedas", além de possível corrupção de
  #   saldo caso gain_gold não trate valores não-positivos internamente.
  #----------------------------------------------------------------------------
  def give_gold(player, name, amount)
    return unless amount > 0

    given = false

    @clients.each do |client|
      next unless client

      if name == 'all' && client.in_game?
        client.gain_gold(amount, false, true)
        given = true

      elsif client.name.casecmp(name).zero?
        client.gain_gold(amount, false, true)
        player_chat_message(
          player,
          "#{sprintf(GaveGold, amount)} #{client.name}.",
          Configs::SUCCESS_COLOR
        )
        given = true
        break
      end
    end

    # CORREÇÃO: log só dispara quando o ouro foi entregue de fato
    @log.add(
      player.group, :blue,
      "#{player.user} deu #{amount} moeda(s) de ouro para #{name}."
    ) if given
  end

  #----------------------------------------------------------------------------
  # * Bane um jogador por IP ou por conta, por N dias
  #   - type: Enums::Command::BAN_IP ou Enums::Command::BAN_ACC
  #   - days: duração do banimento em dias
  #
  #   CORREÇÃO: banimento com 0 ou menos dias expiraria imediatamente (ou no
  #   passado), tornando o ban ineficaz. Rejeitamos antes de qualquer operação.
  #----------------------------------------------------------------------------
  def ban(client, type, name, days)
    if days <= 0
      alert_message(client, Enums::Alert::INVALID_NAME)
      return
    end

    player = find_player(name)

    # Separador de milhar para legibilidade: 86_400 segundos = 1 dia
    time = days * 86_400 + Time.now.to_i

    if !player && type == Enums::Command::BAN_ACC && Database.player_exist?(name)
      # Jogador não está online mas existe no banco — carrega ID da conta e
      # nome com capitalização original para exibição no chat global.
      account_id_db, name = Database.load_some_player_data(name)
      @ban_list[account_id_db] = time
      global_chat_message("#{name} #{Banned}")
      @log.add(client.group, :blue, "#{client.user} baniu #{name} por #{days} dia(s).")
      return

    elsif !player || player.admin?
      # Jogador não encontrado ou é administrador — operação negada
      alert_message(client, Enums::Alert::INVALID_NAME)
      return

    elsif type == Enums::Command::BAN_ACC
      # Ban por conta: registra pelo account_id_db e desconecta o jogador
      @ban_list[player.account_id_db] = time
      send_admin_command(player, type)
      player.close_connection_after_writing

    else
      # Ban por IP: registra o IP e desconecta todos os clientes com esse IP
      @ban_list[player.ip] = time
      kick_banned_ip(player.ip)
    end

    global_chat_message("#{player.name} #{Banned}")
    @log.add(client.group, :blue, "#{client.user} baniu #{player.name} por #{days} dia(s).")
  end

  #----------------------------------------------------------------------------
  # * Desconecta todos os clientes conectados com o IP banido
  #   - Usa &. (safe navigation) para evitar NoMethodError em entradas nil
  #   - Protege administradores de serem desconectados por ban de IP
  #----------------------------------------------------------------------------
  def kick_banned_ip(banned_ip)
    @clients.each do |client|
      # Pula entradas nil ou clientes com IP diferente do banido ou admins
      next if client&.ip != banned_ip || client.admin?
      send_admin_command(client, Enums::Command::BAN_IP)
      client.close_connection_after_writing
    end
  end

  #----------------------------------------------------------------------------
  # * Altera o valor de uma switch global do servidor
  #   - switch_id: deve ser maior que o limite de switches de jogador para
  #     evitar sobrescrever dados individuais de personagens
  #----------------------------------------------------------------------------
  def change_global_switch(switch_id, value)
    return unless switch_id > Configs::MAX_PLAYER_SWITCHES
    @switches[switch_id] = value
  end

  #----------------------------------------------------------------------------
  # * Altera a mensagem do dia (MOTD) e a transmite a todos os jogadores
  #----------------------------------------------------------------------------
  def change_motd(client, motd)
    @motd = motd
    global_chat_message(motd)
    @log.add(client.group, :blue, "#{client.user} mudou a mensagem do dia para: #{motd}.")
  end

  #----------------------------------------------------------------------------
  # * Silencia um jogador por 30 segundos
  #   - Protege administradores de serem silenciados
  #
  #   NOTA: duração de 30 segundos está hardcoded aqui.
  #   Considere mover para Configs::MUTE_DURATION para facilitar ajustes futuros.
  #----------------------------------------------------------------------------
  def mute_player(client, name)
    player = find_player(name)

    if !player || player.admin?
      alert_message(client, Enums::Alert::INVALID_NAME)
      return
    end

    player.muted_time = Time.now + 30
    alert_message(player, Enums::Alert::MUTED)
    @log.add(client.group, :blue, "#{client.user} silenciou #{name} por 30 segundos.")
  end

  #----------------------------------------------------------------------------
  # * Envia uma mensagem de administrador a todos os jogadores em jogo
  #   - Usa &. (safe navigation) para ignorar entradas nil em @clients
  #   - A mensagem também é registrada no chat global com cor de admin
  #----------------------------------------------------------------------------
  def admin_message(player, message)
    @clients.each do |client|
      send_admin_command(client, Enums::Command::MSG, message) if client&.in_game?
    end
    global_chat_message(message, Configs::ADM_MSG_COLOR)
    @log.add(player.group, :blue, "#{player.user} enviou a mensagem: #{message}.")
  end

end