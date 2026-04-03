#==============================================================================
# ** Game_MoveEvent
#------------------------------------------------------------------------------
# Esta classe lida com o movimento do evento.
#------------------------------------------------------------------------------
# Autor: Valentine
#==============================================================================
module Game_MoveEvent

  #----------------------------------------------------------------------------
  # * Movimento aleatório (inclui direções diagonais)
  #----------------------------------------------------------------------------
  def move_random
    # Inclui direções diagonais (1, 3, 7, 9) além das cardeais (2, 4, 6, 8)
    dirs = [1, 2, 3, 4, 6, 7, 8, 9]
    d = dirs.sample
    if [1, 3, 7, 9].include?(d)
      move_diagonal(d)
    else
      move_straight(d, false)
    end
  end

  #----------------------------------------------------------------------------
  # * Movimento em direção a um personagem (com suporte diagonal)
  #----------------------------------------------------------------------------
  def move_toward_character(character)
    return if in_front?(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    # Tenta movimento diagonal quando há deslocamento em ambos os eixos
    if sx != 0 && sy != 0
      # sy < 0 = precisamos descer (DOWN), sy > 0 = precisamos subir (UP)
      # sx > 0 = precisamos ir para esquerda (LEFT), sx < 0 = direita (RIGHT)
      if sy < 0 && sx > 0
        diag = 1  # DOWN-LEFT
      elsif sy < 0 && sx < 0
        diag = 3  # DOWN-RIGHT
      elsif sy > 0 && sx > 0
        diag = 7  # UP-LEFT
      else
        diag = 9  # UP-RIGHT
      end
      move_diagonal(diag)
      return if @move_succeed
    end
    # Fallback: movimento reto se a diagonal falhar ou só um eixo tiver distância
    if sx.abs > sy.abs
      move_straight(sx > 0 ? Enums::Dir::LEFT : Enums::Dir::RIGHT)
      move_straight(sy > 0 ? Enums::Dir::UP : Enums::Dir::DOWN) if !@move_succeed && sy != 0
    else
      move_straight(sy > 0 ? Enums::Dir::UP : Enums::Dir::DOWN)
      move_straight(sx > 0 ? Enums::Dir::LEFT : Enums::Dir::RIGHT) if !@move_succeed && sx != 0
    end
  end

  #----------------------------------------------------------------------------
  # * Movimento para longe de um personagem (com suporte diagonal)
  #----------------------------------------------------------------------------
  def move_away_from_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    # Tenta movimento diagonal ao fugir quando há deslocamento em ambos os eixos
    if sx != 0 && sy != 0
      # Direção de fuga = oposta ao alvo
      # sx > 0 = estamos à direita, fugimos para RIGHT; sy > 0 = estamos abaixo, fugimos para DOWN
      if sx > 0 && sy > 0
        diag = 3  # DOWN-RIGHT
      elsif sx > 0 && sy < 0
        diag = 9  # UP-RIGHT
      elsif sx < 0 && sy > 0
        diag = 1  # DOWN-LEFT
      else
        diag = 7  # UP-LEFT
      end
      move_diagonal(diag)
      return if @move_succeed
    end
    # Fallback: movimento reto se a diagonal falhar ou só um eixo tiver distância
    if sx.abs > sy.abs
      move_straight(sx > 0 ? Enums::Dir::RIGHT : Enums::Dir::LEFT)
      move_straight(sy > 0 ? Enums::Dir::DOWN : Enums::Dir::UP) if !@move_succeed && sy != 0
    else
      move_straight(sy > 0 ? Enums::Dir::DOWN : Enums::Dir::UP)
      move_straight(sx > 0 ? Enums::Dir::RIGHT : Enums::Dir::LEFT) if !@move_succeed && sx != 0
    end
  end

  #----------------------------------------------------------------------------
  # * Virar em direção a um personagem (sem alteração)
  #----------------------------------------------------------------------------
  def turn_toward_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if sx.abs > sy.abs
      @direction = sx > 0 ? Enums::Dir::LEFT : Enums::Dir::RIGHT
      send_movement
    elsif sy != 0
      @direction = sy > 0 ? Enums::Dir::UP : Enums::Dir::DOWN
      send_movement
    end
  end

end