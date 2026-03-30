#==============================================================================
# ** Game_Battler (Battle)
#------------------------------------------------------------------------------
# Este script lida com a base da batalha em tempo real.
#------------------------------------------------------------------------------
# Autor: Valentine
# Refatorado: uso de Configs::CRITICAL_MULTIPLIER e MAX_PROJECTILE_STEPS
#==============================================================================
module Game_Battler

  # Tabela de efeitos de item: mapeia código do efeito para o método handler
  ITEM_EFFECT_TABLE = {
    11 => :item_effect_recover_hp,
    12 => :item_effect_recover_mp,
    21 => :item_effect_add_state,
    22 => :item_effect_remove_state,
    31 => :item_effect_add_buff,
    32 => :item_effect_add_debuff,
    33 => :item_effect_remove_buff,
    34 => :item_effect_remove_debuff,
    42 => :item_effect_grow,
    43 => :item_effect_learn_skill
  }

  #----------------------------------------------------------------------------
  # * Verifica se o alvo está na frente do atacante (tile adjacente à direção)
  #----------------------------------------------------------------------------
  def in_front?(target)
    x = $network.maps[@map_id].round_x_with_direction(@x, @direction)
    y = $network.maps[@map_id].round_y_with_direction(@y, @direction)
    target.pos?(x, y)
  end

  #----------------------------------------------------------------------------
  # * Verifica se o alvo está dentro do alcance (em tiles)
  #----------------------------------------------------------------------------
  def in_range?(target, range)
    distance_x_from(target.x).abs <= range &&
    distance_y_from(target.y).abs <= range
  end

  #----------------------------------------------------------------------------
  # * Limpa o alvo atual do personagem
  #----------------------------------------------------------------------------
  def clear_target
    @target.id   = -1
    @target.type = Enums::Target::NONE
  end

  #----------------------------------------------------------------------------
  # * Retorna o objeto do alvo atual (inimigo ou jogador)
  #   Verifica ID >= 0 para evitar retornar o último elemento do array
  #----------------------------------------------------------------------------
  def get_target
    @target.type == Enums::Target::ENEMY ?
      $network.maps[@map_id].events[@target.id] :
      @target.id >= 0 ? $network.clients[@target.id] : nil
  end

  #----------------------------------------------------------------------------
  # * Valida se o alvo ainda está disponível no mesmo mapa
  #   Limpa o alvo automaticamente se inválido
  #----------------------------------------------------------------------------
  def valid_target?(target)
    result = target.in_game? && target.map_id == @map_id
    clear_target unless result
    result
  end

  #----------------------------------------------------------------------------
  # * Aplica variação aleatória ao dano (evita valores previsíveis)
  #----------------------------------------------------------------------------
  def apply_variance(damage, variance)
    amp = [damage.abs * variance / 100, 0].max.to_i
    var = rand(amp + 1) + rand(amp + 1) - amp
    damage >= 0 ? damage + var : damage - var
  end

  #----------------------------------------------------------------------------
  # * Calcula o valor final do dano antes de aplicá-lo
  #   CRITICAL_MULTIPLIER: Configs::CRITICAL_MULTIPLIER (padrão 3.0)
  #   Define o quanto o crítico multiplica o dano base – ajuste no Configs
  #----------------------------------------------------------------------------
  def make_damage_value(user, item, critical, animation_id, ani_index)
    value  = item.damage.eval(user, self, user.variables)
    value *= item_element_rate(user, item)
    value *= pdr if item.physical?
    value *= mdr if item.magical?
    value *= rec if item.damage.recover?

    # Aplica multiplicador de crítico definido em Configs::CRITICAL_MULTIPLIER
    # Padrão: 3.0 (dano crítico = 3x o dano normal), inspirado em Tibia/Diablo
    value *= Configs::CRITICAL_MULTIPLIER if critical

    value = apply_variance(value, item.damage.variance)
    value = apply_guard(value)
    # Converte para inteiro caso haja decimais no cálculo
    make_damage(value.to_i, item, user, critical, animation_id, ani_index)
  end

  #----------------------------------------------------------------------------
  # * Distribui o dano calculado para HP e/ou MP do alvo
  #   Suporta dano direto, cura e drain (absorção de vida/mana)
  #----------------------------------------------------------------------------
  def make_damage(value, item, user, critical, animation_id, ani_index)
    execute_hp_damage(-value, critical, user, animation_id, ani_index, item.damage.recover?) if item.damage.to_hp?
    execute_mp_damage(-value, false,    user, item.animation_id, ani_index, item.damage.recover?) if item.damage.to_mp?
    user.execute_hp_damage(value, critical, user, animation_id, ani_index, true) if item.damage.drain? && item.damage.to_hp?
    user.execute_mp_damage(value, false,    user, item.animation_id, ani_index, true) if item.damage.drain? && item.damage.to_mp?
  end

  #----------------------------------------------------------------------------
  # * Aplica redução de dano caso o alvo esteja em guarda
  #----------------------------------------------------------------------------
  def apply_guard(damage)
    damage / (damage > 0 && guard? ? 2 * grd : 1)
  end

  #----------------------------------------------------------------------------
  # * Executa o dano/cura no HP e trata morte se necessário
  #----------------------------------------------------------------------------
  def execute_hp_damage(damage, critical, attacker, animation_id, ani_index, not_show_missed)
    # Limita o dano ao HP atual (não pode matar abaixo de 0)
    damage = -@hp      if damage < 0 && damage.abs > @hp
    # Limita a cura ao HP máximo (não pode ultrapassar mhp)
    damage = mhp - @hp if damage > 0 && @hp + damage > mhp
    send_attack(damage, 0, critical,
                attacker.id, attacker.is_a?(Game_Client) ? 0 : 1,
                ani_index, animation_id, not_show_missed)
    @hp += damage
    refresh
    remove_states_by_damage
    die if dead?
  end

  #----------------------------------------------------------------------------
  # * Executa o dano/cura no MP
  #----------------------------------------------------------------------------
  def execute_mp_damage(damage, critical, attacker, animation_id, ani_index, not_show_missed)
    damage = -@mp      if damage < 0 && damage.abs > @mp
    damage = mmp - @mp if damage > 0 && @mp + damage > mmp
    send_attack(0, damage, critical,
                attacker.id, attacker.is_a?(Game_Client) ? 0 : 1,
                ani_index, animation_id, not_show_missed)
    @mp += damage
    refresh
  end

  #----------------------------------------------------------------------------
  # * Taxa de acerto do item/habilidade
  #----------------------------------------------------------------------------
  def item_hit(user, item)
    rate  = item.success_rate * 0.01
    rate *= user.hit if item.physical?
    rate
  end

  #----------------------------------------------------------------------------
  # * Taxa de evasão do alvo
  #----------------------------------------------------------------------------
  def item_eva(user, item)
    return eva if item.physical?
    return mev if item.magical?
    0
  end

  #----------------------------------------------------------------------------
  # * Taxa de crítico do ataque
  #----------------------------------------------------------------------------
  def item_cri(user, item)
    item.damage.critical ? user.cri * (1 - cev) : 0
  end

  #----------------------------------------------------------------------------
  # * Taxa de elemento aplicada ao dano
  #----------------------------------------------------------------------------
  def item_element_rate(user, item)
    if item.damage.element_id < 0
      user.atk_elements.empty? ? 1.0 : elements_max_rate(user.atk_elements)
    else
      element_rate(item.damage.element_id)
    end
  end

  #----------------------------------------------------------------------------
  # * Retorna a maior taxa de elemento entre os elementos de ataque
  #----------------------------------------------------------------------------
  def elements_max_rate(elements)
    elements.inject([0.0]) { |r, i| r << element_rate(i) }.max
  end

  #----------------------------------------------------------------------------
  # * Aplica o item/habilidade ao alvo (miss, evasão, dano e efeitos)
  #----------------------------------------------------------------------------
  def item_apply(user, item, animation_id, ani_index)
    missed = (rand >= item_hit(user, item))
    evaded = (!missed && rand < item_eva(user, item))
    unless missed || evaded
      if !item.damage.none?
        critical = (rand < item_cri(user, item))
        make_damage_value(user, item, critical, animation_id, ani_index)
      elsif item.animation_id > 0
        attacker_type  = user.is_a?(Game_Client) ? 0 : 1
        character_type = is_a?(Game_Client) ? Enums::Target::PLAYER : Enums::Target::ENEMY
        $network.send_animation(self, item.animation_id, user.id, attacker_type, ani_index, character_type)
      end
      # Efeitos secundários não são aplicados se o usuário morreu pelo dano
      item.effects.each { |effect| item_effect_apply(user, item, effect) } unless dead?
    end
  end

  #----------------------------------------------------------------------------
  # * Despacha o efeito do item para o método handler correto via tabela
  #----------------------------------------------------------------------------
  def item_effect_apply(user, item, effect)
    method_name = ITEM_EFFECT_TABLE[effect.code]
    send(method_name, user, item, effect) if method_name
  end

  def item_effect_recover_hp(user, item, effect)
    value  = (mhp * effect.value1 + effect.value2) * rec
    value *= user.pha if item.is_a?(RPG::Item)
    execute_hp_damage(value.to_i, false, user, item.animation_id, item.ani_index, true)
  end

  def item_effect_recover_mp(user, item, effect)
    value  = (mmp * effect.value1 + effect.value2) * rec
    value *= user.pha if item.is_a?(RPG::Item)
    execute_mp_damage(value.to_i, false, user, item.animation_id, item.ani_index, true)
  end

  def item_effect_add_state(user, item, effect)
    effect.data_id == 0 ?
      item_effect_add_state_attack(user, item, effect) :
      item_effect_add_state_normal(user, item, effect)
  end

  def item_effect_add_state_attack(user, item, effect)
    user.atk_states.each do |state_id|
      chance  = effect.value1
      chance *= state_rate(state_id)
      chance *= user.atk_states_rate(state_id)
      chance *= luk_effect_rate(user)
      add_state(state_id) if rand < chance
    end
  end

  def item_effect_add_state_normal(user, item, effect)
    # Verifica se atacante e alvo são de tipos diferentes (jogador vs inimigo)
    pvp_context = is_a?(Game_Client) != user.is_a?(Game_Client)
    chance  = effect.value1
    chance *= state_rate(effect.data_id) if pvp_context
    chance *= luk_effect_rate(user)      if pvp_context
    add_state(effect.data_id) if rand < chance
  end

  def item_effect_remove_state(user, item, effect)
    remove_state(effect.data_id) if rand < effect.value1
  end

  def item_effect_add_buff(user, item, effect)
    add_buff(effect.data_id)
  end

  def item_effect_add_debuff(user, item, effect)
    chance = debuff_rate(effect.data_id) * luk_effect_rate(user)
    add_debuff(effect.data_id) if rand < chance
  end

  def item_effect_remove_buff(user, item, effect)
    remove_buff(effect.data_id) if @buffs[effect.data_id] > 0
  end

  def item_effect_remove_debuff(user, item, effect)
    remove_buff(effect.data_id) if @buffs[effect.data_id] < 0
  end

  def item_effect_grow(user, item, effect)
    add_param(effect.data_id, effect.value1.to_i)
  end

  def item_effect_learn_skill(user, item, effect)
    learn_skill(effect.data_id) if is_a?(Game_Client)
  end

  #----------------------------------------------------------------------------
  # * Taxa de influência do LUK na aplicação de estados
  #----------------------------------------------------------------------------
  def luk_effect_rate(user)
    [1.0 + (user.luk - luk) * 0.001, 0.0].max
  end

  #----------------------------------------------------------------------------
  # * Calcula o tile máximo que o projétil pode alcançar antes de ser bloqueado
  #   CORREÇÃO: substituído `while true` por loop com limite de passos
  #   Configs::MAX_PROJECTILE_STEPS define o número máximo de iterações
  #   (padrão: 50) – evita loop infinito em mapas com geometria irregular
  #----------------------------------------------------------------------------
  def max_passage(target)
    # Se atacante e alvo estão na mesma posição, retorna direto
    return [target.x, target.y] if pos?(target.x, target.y)

    radians = Math.atan2(target.x - @x, target.y - @y)
    speed_x = Math.sin(radians)
    speed_y = Math.cos(radians)
    result  = [target.x, target.y]
    range_x = (target.x - @x).abs
    range_y = (target.y - @y).abs
    # Usa a direção em relação ao alvo (não a direção do sprite do jogador)
    direction = projectile_direction(target)

    x = @x.to_f
    y = @y.to_f
    steps = 0

    # Loop com guard: Configs::MAX_PROJECTILE_STEPS impede loop infinito
    while steps < Configs::MAX_PROJECTILE_STEPS
      steps += 1
      x += speed_x
      y += speed_y
      x2 = x.to_i
      y2 = y.to_i

      # Projétil ultrapassou o alcance – encerra sem bloquear
      if distance_x_from(x2).abs > range_x || distance_y_from(y2).abs > range_y
        break
      # Projétil colidiu com obstáculo – registra posição de impacto
      elsif !map_passable?(x2, y2, direction)
        result = [x2, y2]
        break
      end
    end

    result
  end

  #----------------------------------------------------------------------------
  # * Calcula a direção do projétil em relação ao alvo
  #----------------------------------------------------------------------------
  def projectile_direction(target)
    sx = distance_x_from(target.x)
    sy = distance_y_from(target.y)
    if sx.abs > sy.abs
      sx > 0 ? Enums::Dir::LEFT : Enums::Dir::RIGHT
    elsif sy != 0
      sy > 0 ? Enums::Dir::UP : Enums::Dir::DOWN
    end
  end

  #----------------------------------------------------------------------------
  # * Verifica se o projétil foi bloqueado antes de atingir o alvo
  #----------------------------------------------------------------------------
  def blocked_passage?(target, x, y)
    !target.pos?(x, y)
  end

  #----------------------------------------------------------------------------
  # * Verifica se o tile é válido e transitável na direção dada
  #----------------------------------------------------------------------------
  def map_passable?(x, y, d)
    $network.maps[@map_id].valid?(x, y) &&
    $network.maps[@map_id].passable?(x, y, d)
  end

  #----------------------------------------------------------------------------
  # * Limpa o alvo de todos os jogadores que tinham este personagem como alvo
  #   Usa change_target (em vez de clear_target) para sincronizar com o cliente
  #----------------------------------------------------------------------------
  def clear_target_players(type, map_id = @map_id)
    return if $network.maps[map_id].zero_players?
    $network.clients.each do |client|
      next unless client&.in_game? && client.map_id == map_id
      next unless client.target.id == @id && client.target.type == type
      client.change_target(-1, Enums::Target::NONE)
    end
  end

end