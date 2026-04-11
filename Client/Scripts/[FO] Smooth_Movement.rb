#==============================================================================
# [FO] Smooth_Movement
# Versão  : 1.0.0
# Autor   : Caio Juan De Lima Silva
# Projeto : Fields Online
#------------------------------------------------------------------------------
# Compatibilidade: RPG Maker VX Ace + VXA-OS 2022 (GitHub)
#------------------------------------------------------------------------------
# DESCRIÇÃO:
#   Este script implementa interpolação linear (lerp) nas posições visuais dos
#   personagens, eventos, NPCs e jogadores remotos (Game_NetPlayer), criando
#   um efeito de movimento suave semelhante ao encontrado em MMORPGs clássicos
#   como Tibia Online, Ragnarok Online, MU Online e World of Warcraft.
#
#   O sistema funciona separando a posição lógica (tile) da posição visual
#   (smooth_x / smooth_y), interpolando a posição visual em direção à posição
#   lógica a cada frame, com velocidades configuráveis por tipo de entidade.
#
# FUNCIONAMENTO:
#   - @smooth_x / @smooth_y: posição visual interpolada (em tiles, float)
#   - @real_x   / @real_y  : posição lógica nativa do VX Ace (em tiles, float)
#   - A cada frame, smooth_x/y se aproxima de real_x/y usando lerp
#   - screen_x / screen_y são sobrescritos para usar smooth_x/y
#
# NOTAS:
#   - O jogador local NÃO é suavizado por padrão (VX Ace já faz isso nativamente)
#   - Jogadores remotos (Game_NetPlayer) recebem lerp próprio para esconder lag
#   - Eventos e MOBs recebem lerp suave para movimentos mais naturais
#   - Compatível com o sistema de drop, HUD, Minimap e demais scripts [FO] / [VS]
#==============================================================================

#==============================================================================
# >> MÓDULO DE CONFIGURAÇÕES
#    Ajuste os valores abaixo conforme necessário para o seu projeto.
#==============================================================================
module FO
  module SmoothMovement

    #--------------------------------------------------------------------------
    # Velocidade de interpolação para jogadores remotos (Game_NetPlayer)
    # Valores entre 0.05 (muito lento) e 1.0 (instantâneo)
    # Recomendado: 0.15 ~ 0.25 para esconder lag de rede com suavidade
    #--------------------------------------------------------------------------
    NET_LERP_SPEED = 0.20

    #--------------------------------------------------------------------------
    # Velocidade de interpolação para eventos com movimento (Game_Event)
    # NPCs, objetos animados, personagens do mapa
    # Recomendado: 0.25 ~ 0.35 para movimento natural
    #--------------------------------------------------------------------------
    EVENT_LERP_SPEED = 0.30

    #--------------------------------------------------------------------------
    # Velocidade de interpolação para MOBs / Inimigos
    # Usado quando o evento for identificado como MOB (via tag ou classe futura)
    # Recomendado: 0.20 ~ 0.30
    #--------------------------------------------------------------------------
    MOB_LERP_SPEED = 0.25

    #--------------------------------------------------------------------------
    # Distância mínima (em tiles) para aplicar snap direto na posição final
    # Evita micro-oscilações quando smooth_x/y está muito próximo de real_x/y
    # Recomendado: 0.005 ~ 0.02
    #--------------------------------------------------------------------------
    SNAP_THRESHOLD = 0.01

    #--------------------------------------------------------------------------
    # Suavizar também o jogador local?
    # false = usa o sistema nativo do VX Ace (recomendado)
    # true  = aplica lerp também no jogador controlado pelo usuário
    #--------------------------------------------------------------------------
    SMOOTH_LOCAL_PLAYER = false

  end # SmoothMovement
end # FO

#==============================================================================
# >> Game_CharacterBase
#    Classe base de todos os personagens do mapa.
#    Adicionamos inicialização e atualização das posições suavizadas.
#==============================================================================
class Game_CharacterBase

  # Expõe as posições visuais suavizadas para leitura externa (ex: Minimap, HUD)
  attr_reader :smooth_x
  attr_reader :smooth_y

  #----------------------------------------------------------------------------
  # Alias: init_public_members
  # Inicializa @smooth_x e @smooth_y junto com os membros públicos padrão.
  # Garante que as posições visuais existam desde o início do ciclo de vida.
  #----------------------------------------------------------------------------
  alias fo_smooth_init_public_members init_public_members
  def init_public_members
    fo_smooth_init_public_members
    # Inicializa as posições visuais com os valores lógicos atuais
    @smooth_x = @x.to_f
    @smooth_y = @y.to_f
  end

  #----------------------------------------------------------------------------
  # Alias: update
  # Chama a atualização da posição suavizada a cada frame.
  #----------------------------------------------------------------------------
  alias fo_smooth_update update
  def update
    fo_smooth_update
    fo_update_smooth_position
  end

  #----------------------------------------------------------------------------
  # Método: fo_update_smooth_position
  # Interpola @smooth_x e @smooth_y em direção a @real_x e @real_y usando lerp.
  # Aplica snap quando a diferença for menor que SNAP_THRESHOLD.
  #----------------------------------------------------------------------------
  def fo_update_smooth_position
    speed = fo_lerp_speed

    # Interpolação no eixo X
    dx = @real_x - @smooth_x
    if dx.abs < FO::SmoothMovement::SNAP_THRESHOLD
      @smooth_x = @real_x
    else
      @smooth_x += dx * speed
    end

    # Interpolação no eixo Y
    dy = @real_y - @smooth_y
    if dy.abs < FO::SmoothMovement::SNAP_THRESHOLD
      @smooth_y = @real_y
    else
      @smooth_y += dy * speed
    end
  end

  #----------------------------------------------------------------------------
  # Método: fo_lerp_speed
  # Retorna a velocidade de lerp padrão para esta classe base.
  # Sobrescrito em subclasses para velocidades específicas por tipo.
  #----------------------------------------------------------------------------
  def fo_lerp_speed
    FO::SmoothMovement::EVENT_LERP_SPEED
  end

  #----------------------------------------------------------------------------
  # Override: screen_x
  # Calcula a posição X na tela usando @smooth_x ao invés de @real_x.
  # Mantém a fórmula original do VX Ace, apenas substituindo a base.
  #----------------------------------------------------------------------------
  def screen_x
    $game_map.adjust_x(@smooth_x) * 32 + 16
  end

  #----------------------------------------------------------------------------
  # Override: screen_y
  # Calcula a posição Y na tela usando @smooth_y ao invés de @real_y.
  # Mantém a fórmula original do VX Ace, incluindo shift_y e jump_height.
  #----------------------------------------------------------------------------
  def screen_y
    $game_map.adjust_y(@smooth_y) * 32 + 32 - shift_y - jump_height
  end

end # Game_CharacterBase

#==============================================================================
# >> Game_Player
#    Jogador local controlado pelo usuário.
#    Quando SMOOTH_LOCAL_PLAYER = false, espelha smooth_x/y diretamente em
#    real_x/y, pois o VX Ace já realiza suavização nativa no jogador local.
#==============================================================================
class Game_Player < Game_Character

  #----------------------------------------------------------------------------
  # Override: fo_update_smooth_position
  # Comportamento depende da configuração SMOOTH_LOCAL_PLAYER:
  #   false → smooth_x/y espelha real_x/y (sem lerp adicional)
  #   true  → aplica lerp normalmente via método da classe base
  #----------------------------------------------------------------------------
  def fo_update_smooth_position
    if FO::SmoothMovement::SMOOTH_LOCAL_PLAYER
      # Aplica lerp também no jogador local (opcional)
      super
    else
      # Espelha diretamente: o VX Ace já suaviza o jogador local nativamente
      @smooth_x = @real_x
      @smooth_y = @real_y
    end
  end

  #----------------------------------------------------------------------------
  # Override: fo_lerp_speed
  # Retorna velocidade de lerp para o jogador local (usado apenas se
  # SMOOTH_LOCAL_PLAYER = true).
  #----------------------------------------------------------------------------
  def fo_lerp_speed
    FO::SmoothMovement::NET_LERP_SPEED
  end

end # Game_Player

#==============================================================================
# >> Game_Event
#    Eventos do mapa: NPCs, objetos animados, personagens de cenário.
#    Usa EVENT_LERP_SPEED para movimento suave e natural.
#==============================================================================
class Game_Event < Game_Character

  #----------------------------------------------------------------------------
  # Override: fo_lerp_speed
  # Retorna a velocidade de lerp específica para eventos do mapa.
  # Pode ser expandido futuramente para detectar MOBs via nota/tag do evento.
  #----------------------------------------------------------------------------
  def fo_lerp_speed
    FO::SmoothMovement::EVENT_LERP_SPEED
  end

end # Game_Event

#==============================================================================
# >> Game_NetPlayer (condicional)
#    Jogadores remotos conectados via VXA-OS.
#    Só é carregado se a classe Game_NetPlayer estiver definida no projeto,
#    garantindo compatibilidade com projetos sem o módulo de rede.
#==============================================================================
if defined?(Game_NetPlayer)

  class Game_NetPlayer < Game_Character

    #--------------------------------------------------------------------------
    # Alias: moveto
    # Preserva @smooth_x/@smooth_y na posição visual atual ANTES de atualizar
    # a posição lógica. Isso permite que a interpolação ocorra a partir do
    # ponto visual onde o personagem estava, evitando "teleporte" visual.
    #--------------------------------------------------------------------------
    alias fo_smooth_net_moveto moveto
    def moveto(x, y)
      # Garante que smooth_x/y existam antes de preservar (segurança)
      @smooth_x ||= @x.to_f
      @smooth_y ||= @y.to_f

      # Preserva a posição visual atual antes de atualizar a lógica
      prev_smooth_x = @smooth_x
      prev_smooth_y = @smooth_y

      # Executa o moveto original (atualiza @x, @y, @real_x, @real_y)
      fo_smooth_net_moveto(x, y)

      # Restaura a posição visual para que o lerp parta do ponto anterior
      # Isso cria a transição suave entre a posição antiga e a nova
      @smooth_x = prev_smooth_x
      @smooth_y = prev_smooth_y
    end

    #--------------------------------------------------------------------------
    # Override: fo_lerp_speed
    # Retorna a velocidade de lerp específica para jogadores remotos.
    # Valor menor = transição mais lenta e suave (melhor para esconder lag).
    #--------------------------------------------------------------------------
    def fo_lerp_speed
      FO::SmoothMovement::NET_LERP_SPEED
    end

  end # Game_NetPlayer

end # defined?(Game_NetPlayer)

#==============================================================================
# FIM DO SCRIPT [FO] Smooth_Movement v1.0.0
#==============================================================================