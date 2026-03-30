#==============================================================================
# ** Sprite_Minimap
#------------------------------------------------------------------------------
# Esta classe lida com a exibição do mapa em miniatura no canto da tela.
#
# Versão refatorada:
#   - Minimap QUADRADO (largura = altura = Configs::MINIMAP_SIZE)
#   - Frame desenhado via Bitmap (fill_rect) — sem Windowskin
#   - Todas as dimensões e cores centralizadas em Configs::MINIMAP_*
#   - Otimização: refresh só ocorre quando o mapa muda (@last_map_id)
#   - Ícone PVP/Safe como sprite separado ao lado do minimap
#
# Inspirado em: Tibia Online, MU Online, Ragnarok Online
#------------------------------------------------------------------------------
# Autor: Valentine
# Refatorado: uso de Configs para facilitar ajustes sem editar este script
#==============================================================================
class Sprite_Minimap < Sprite2

  # Struct para armazenar nome e largura do tooltip de cada evento no mapa
  Event_Data = Struct.new(:name, :width)

  #----------------------------------------------------------------------------
  # * Inicialização
  #   Cria o bitmap quadrado (Configs::MINIMAP_SIZE × MINIMAP_SIZE + MINIMAP_NAME_HEIGHT),
  #   posiciona na tela e inicializa sprites filhos.
  #----------------------------------------------------------------------------
  def initialize
    super

    # Bitmap total: quadrado + área extra abaixo para o nome do mapa
    # MINIMAP_SIZE        → tamanho do quadrado do frame
    # MINIMAP_NAME_HEIGHT → altura da linha do nome do mapa abaixo do frame
    self.bitmap = Bitmap.new(
      Configs::MINIMAP_SIZE,
      Configs::MINIMAP_SIZE + Configs::MINIMAP_NAME_HEIGHT
    )

    # Posiciona no canto superior direito da tela
    # MINIMAP_X_MARGIN → margem em relação à borda direita
    self.x = Graphics.width - Configs::MINIMAP_SIZE - Configs::MINIMAP_X_MARGIN
    self.y = Configs::MINIMAP_Y
    self.z = Configs::MINIMAP_Z

    # Configurações de fonte para o nome do mapa e tooltips
    self.bitmap.font.size = Configs::MINIMAP_FONT_SIZE
    self.bitmap.font.bold = Configs::MINIMAP_FONT_BOLD

    # Spritesheet 'Minimap': usada apenas para ícones de player/eventos
    # O frame agora é desenhado via Bitmap (fill_rect), não por este spritesheet
    @bitmap = Cache.system('Minimap')

    @dragable      = true
    @event_sprites = {}
    @event_data    = {}
    @last_tip_name = ''

    # Cache: guarda o ID do mapa atual para evitar refresh desnecessário a cada frame
    # Atualizado em refresh(); comparado em update() para detectar troca de mapa
    @last_map_id = nil

    create_player_point
    create_tool_tip
    create_pvp_icon
    refresh
    update
  end

  #----------------------------------------------------------------------------
  # * Altura de uma linha de texto (usada pelo tooltip)
  #----------------------------------------------------------------------------
  def line_height
    Configs::MINIMAP_FONT_SIZE + 4
  end

  #----------------------------------------------------------------------------
  # * Calcula a posição X do minimap na tela
  #   Centralizado em initialize() usando Graphics.width - SIZE - X_MARGIN
  #----------------------------------------------------------------------------
  def adjust_x
    Graphics.width - Configs::MINIMAP_SIZE - Configs::MINIMAP_X_MARGIN
  end

  #----------------------------------------------------------------------------
  # * Verifica se a posição (x, y) está dentro da área do mapa no minimap
  #   Passa para super() já compensado pelo MINIMAP_PADDING (área interna)
  #----------------------------------------------------------------------------
  def in_area?(x = 0, y = 0, w = Configs::MINIMAP_MAP_AREA, h = Configs::MINIMAP_MAP_AREA)
    super(x + Configs::MINIMAP_PADDING, y + Configs::MINIMAP_PADDING, w, h)
  end

  #----------------------------------------------------------------------------
  # * Atualiza opacidade do minimap e de todos os sprites filhos
  #   Chamado por change_opacity() da Sprite2 pai
  #----------------------------------------------------------------------------
  def change_opacity(x = 0, y = 0)
    super()
    @player_sprite.opacity = self.opacity
    @pvp_sprite.opacity    = self.opacity
    @event_sprites.each_value { |sprite| sprite.opacity = self.opacity }
  end

  #----------------------------------------------------------------------------
  # * Cria o sprite do ponto do jogador sobre o mapa
  #   Usa o ícone da spritesheet 'Minimap' na posição (142, 0)
  #   Z: acima do bitmap principal para sobrepor o mapa
  #----------------------------------------------------------------------------
  def create_player_point
    @player_sprite        = Sprite.new
    @player_sprite.bitmap = Bitmap.new(16, 16)
    @player_sprite.bitmap.blt(0, 0, @bitmap, Rect.new(142, 0, 16, 16))
    @player_sprite.z      = self.z + 1
  end

  #----------------------------------------------------------------------------
  # * Cria o sprite do tooltip (nome do evento ao passar o mouse)
  #   Largura = MINIMAP_SIZE para evitar overflow lateral
  #   Z: acima do sprite do jogador
  #----------------------------------------------------------------------------
  def create_tool_tip
    @tool_tip        = Sprite.new
    @tool_tip.bitmap = Bitmap.new(Configs::MINIMAP_SIZE, line_height)
    @tool_tip.z      = @player_sprite.z + 1
  end

  #----------------------------------------------------------------------------
  # * Cria o sprite do ícone PVP / Safe (sprite separado, fora do bitmap)
  #   Posicionado ao lado esquerdo do minimap via Configs::MINIMAP_PVP_X_OFFSET
  #   e Configs::MINIMAP_PVP_Y_OFFSET.
  #   O ícone é atualizado em refresh_pvp_icon quando o mapa muda.
  #----------------------------------------------------------------------------
  def create_pvp_icon
    @pvp_sprite        = Sprite.new
    @pvp_sprite.bitmap = Bitmap.new(24, 24)
    @pvp_sprite.z      = self.z + 1
    refresh_pvp_icon
  end

  #----------------------------------------------------------------------------
  # * Atualiza o conteúdo do ícone PVP / Safe
  #   Redesenha o ícone de acordo com o estado PVP atual do mapa
  #   Chamado em refresh() sempre que o mapa muda
  #----------------------------------------------------------------------------
  def refresh_pvp_icon
    @pvp_sprite.bitmap.clear
    iconset    = Cache.system('Iconset')
    icon_index = $game_map.pvp? ? Configs::MAP_PVP_ICON : Configs::MAP_NONPVP_ICON
    rect       = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    @pvp_sprite.bitmap.blt(0, 0, iconset, rect)
    update_pvp_position
  end

  #----------------------------------------------------------------------------
  # * Atualiza a posição do sprite de ícone PVP / Safe
  #   Usa os offsets definidos em Configs para posicionar ao lado do minimap.
  #   Chamado em refresh_pvp_icon e update() para acompanhar drag do minimap.
  #----------------------------------------------------------------------------
  def update_pvp_position
    @pvp_sprite.x = self.x + Configs::MINIMAP_PVP_X_OFFSET
    @pvp_sprite.y = self.y + Configs::MINIMAP_PVP_Y_OFFSET
  end

  #----------------------------------------------------------------------------
  # * Cria o sprite de um evento especial no mapa
  #   event_id   : ID do evento ($game_map.events)
  #   event_name : nome exibido no tooltip (Vocab::Quest, Vocab::Shop, etc.)
  #   rect_y     : linha do ícone na spritesheet 'Minimap'
  #                  0  → Jogador
  #                  16 → Loja
  #                  32 → Missão
  #                  48 → Banco
  #                  64 → Teleporte
  #                  80 → CheckPoint
  #                  96 → Boss
  #----------------------------------------------------------------------------
  def create_event(event_id, event_name, rect_y)
    event_sprite        = Sprite.new
    event_sprite.bitmap = Bitmap.new(16, 16)
    event_sprite.bitmap.blt(0, 0, @bitmap, Rect.new(142, rect_y, 16, 16))
    event_sprite.x      = self.x + object_x($game_map.events[event_id])
    event_sprite.y      = self.y + object_y($game_map.events[event_id])
    event_sprite.z      = self.z

    @event_sprites[event_id] = event_sprite
    @event_data[event_id]    = Event_Data.new(event_name, text_width(event_name) + 8)
  end

  #----------------------------------------------------------------------------
  # * Libera todos os bitmaps e sprites da memória
  #----------------------------------------------------------------------------
  def dispose
    super
    @player_sprite.bitmap.dispose
    @player_sprite.dispose
    @pvp_sprite.bitmap.dispose
    @pvp_sprite.dispose
    @tool_tip.bitmap.dispose
    @tool_tip.dispose
    dispose_events
  end

  #----------------------------------------------------------------------------
  # * Libera apenas os sprites de eventos (chamado no refresh)
  #----------------------------------------------------------------------------
  def dispose_events
    @event_sprites.each_value do |event|
      event.bitmap.dispose
      event.dispose
    end
    @event_sprites.clear
    @event_data.clear
  end

  #----------------------------------------------------------------------------
  # * Converte posição X do objeto (tiles) para pixels na tela do minimap
  #   Mapeia de [0, $game_map.width] para [PADDING, PADDING + MAP_AREA - 8]
  #   Clampado para não sair da área visível (o -8 evita que o ícone 16px saia)
  #   MINIMAP_PADDING  → offset do frame
  #   MINIMAP_MAP_AREA → tamanho da área de mapa interna
  #----------------------------------------------------------------------------
  def object_x(object)
    px     = Configs::MINIMAP_PADDING + object.x * Configs::MINIMAP_MAP_AREA / [$game_map.width,  1].max
    min_px = Configs::MINIMAP_PADDING
    max_px = Configs::MINIMAP_PADDING + Configs::MINIMAP_MAP_AREA - 8
    [[px, min_px].max, max_px].min
  end

  #----------------------------------------------------------------------------
  # * Converte posição Y do objeto (tiles) para pixels na tela do minimap
  #   Mapeia de [0, $game_map.height] para [PADDING, PADDING + MAP_AREA - 8]
  #   Mesmo critério de clamping do object_x
  #----------------------------------------------------------------------------
  def object_y(object)
    py     = Configs::MINIMAP_PADDING + object.y * Configs::MINIMAP_MAP_AREA / [$game_map.height, 1].max
    min_py = Configs::MINIMAP_PADDING
    max_py = Configs::MINIMAP_PADDING + Configs::MINIMAP_MAP_AREA - 8
    [[py, min_py].max, max_py].min
  end

  #----------------------------------------------------------------------------
  # * Redesenha o minimap completo
  #   Chamado na inicialização e quando o mapa muda (detectado em update)
  #   Sequência: fundo → frame → nome do mapa → ícone PVP → eventos
  #----------------------------------------------------------------------------
  def refresh
    @tool_tip.visible = false
    draw_background
    draw_frame
    draw_map_name
    refresh_pvp_icon
    dispose_events

    if FileTest.exist?("Graphics/Minimaps/#{$game_map.map_id}.png")
      draw_map
      draw_events
    else
      # Sem imagem de mapa: oculta o sprite do jogador para não flutuar no vazio
      @player_sprite.visible = false
    end

    # Atualiza o cache: próximo refresh só ocorre se o mapa mudar
    @last_map_id = $game_map.map_id
  end

  #----------------------------------------------------------------------------
  # * Desenha o fundo do minimap
  #   Dois retângulos via fill_rect (sem Windowskin):
  #   1. Fundo geral (todo o bitmap): Configs::MINIMAP_BG_COLOR
  #   2. Fundo da área do mapa (área interna): Configs::MINIMAP_MAP_BG
  #----------------------------------------------------------------------------
  def draw_background
    self.bitmap.clear

    # Fundo geral do minimap (quadrado + área do nome)
    bg_rect = Rect.new(
      0, 0,
      Configs::MINIMAP_SIZE,
      Configs::MINIMAP_SIZE + Configs::MINIMAP_NAME_HEIGHT
    )
    self.bitmap.fill_rect(bg_rect, Configs::MINIMAP_BG_COLOR)

    # Fundo específico da área de mapa (tom ligeiramente diferente)
    map_rect = Rect.new(
      Configs::MINIMAP_PADDING,
      Configs::MINIMAP_PADDING,
      Configs::MINIMAP_MAP_AREA,
      Configs::MINIMAP_MAP_AREA
    )
    self.bitmap.fill_rect(map_rect, Configs::MINIMAP_MAP_BG)
  end

  #----------------------------------------------------------------------------
  # * Desenha o frame quadrado do minimap via Bitmap (sem Windowskin)
  #   Estrutura de bordas (de fora para dentro):
  #     1. Borda EXTERNA: ao redor de todo o bitmap quadrado
  #        Cor: Configs::MINIMAP_FRAME_OUTER (dourado, inspirado em Tibia/MU)
  #     2. Borda INTERNA: ao redor da área do mapa
  #        Cor: Configs::MINIMAP_FRAME_INNER (mais escura, efeito 3D)
  #     3. Cantos DECORATIVOS: 4×4 px nos 4 cantos da borda interna
  #        Cor: Configs::MINIMAP_FRAME_CORNER (ouro brilhante)
  #   Espessura: Configs::MINIMAP_BORDER pixels para todas as bordas
  #----------------------------------------------------------------------------
  def draw_frame
    s      = Configs::MINIMAP_SIZE
    p      = Configs::MINIMAP_PADDING
    b      = Configs::MINIMAP_BORDER
    outer  = Configs::MINIMAP_FRAME_OUTER
    inner  = Configs::MINIMAP_FRAME_INNER
    corner = Configs::MINIMAP_FRAME_CORNER

    # ── Borda EXTERNA ─────────────────────────────────────────────────────────
    self.bitmap.fill_rect(0,     0,     s,  b,  outer)  # Topo
    self.bitmap.fill_rect(0,     s - b, s,  b,  outer)  # Base
    self.bitmap.fill_rect(0,     0,     b,  s,  outer)  # Esquerda
    self.bitmap.fill_rect(s - b, 0,     b,  s,  outer)  # Direita

    # ── Borda INTERNA ─────────────────────────────────────────────────────────
    # m  = início da borda interna (p - b pixels antes do padding)
    # ma = largura total da borda interna (MAP_AREA + 2*b)
    m  = p - b
    ma = Configs::MINIMAP_MAP_AREA + b * 2

    self.bitmap.fill_rect(m,          m,          ma, b,  inner)  # Topo interno
    self.bitmap.fill_rect(m,          m + ma - b, ma, b,  inner)  # Base interna
    self.bitmap.fill_rect(m,          m,          b,  ma, inner)  # Esquerda interna
    self.bitmap.fill_rect(m + ma - b, m,          b,  ma, inner)  # Direita interna

    # ── Cantos DECORATIVOS ────────────────────────────────────────────────────
    cs = 4  # tamanho do canto (4×4 pixels)
    self.bitmap.fill_rect(m,           m,           cs, cs, corner)  # Superior esquerdo
    self.bitmap.fill_rect(m + ma - cs, m,           cs, cs, corner)  # Superior direito
    self.bitmap.fill_rect(m,           m + ma - cs, cs, cs, corner)  # Inferior esquerdo
    self.bitmap.fill_rect(m + ma - cs, m + ma - cs, cs, cs, corner)  # Inferior direito
  end

  #----------------------------------------------------------------------------
  # * Desenha o nome do mapa centralizado abaixo do frame quadrado
  #   Área do nome: de y=MINIMAP_SIZE até y=MINIMAP_SIZE+MINIMAP_NAME_HEIGHT
  #   Texto centralizado (align = 1)
  #----------------------------------------------------------------------------
  def draw_map_name
    self.bitmap.draw_text(
      0,
      Configs::MINIMAP_SIZE + 2,
      Configs::MINIMAP_SIZE,
      Configs::MINIMAP_NAME_HEIGHT - 2,
      $game_map.display_name,
      1
    )
  end

  #----------------------------------------------------------------------------
  # * Desenha a imagem PNG do mapa na área interna do frame
  #   A imagem é redimensionada (stretch_blt) para caber exatamente em
  #   MINIMAP_MAP_AREA × MINIMAP_MAP_AREA pixels
  #   Origem: Graphics/Minimaps/{map_id}.png
  #----------------------------------------------------------------------------
  def draw_map
    bitmap = Cache.minimap($game_map.map_id.to_s)
    dest   = Rect.new(
      Configs::MINIMAP_PADDING,
      Configs::MINIMAP_PADDING,
      Configs::MINIMAP_MAP_AREA,
      Configs::MINIMAP_MAP_AREA
    )
    self.bitmap.stretch_blt(dest, bitmap, bitmap.rect)
  end

  #----------------------------------------------------------------------------
  # * Atualiza o conteúdo do tooltip com o nome do evento
  #   Fundo semi-transparente + texto centralizado
  #   Só redesenha se o nome do evento mudou desde o último refresh
  #----------------------------------------------------------------------------
  def refresh_tool_tip(event_name, width)
    @last_tip_name = event_name
    @tool_tip.bitmap.clear

    rect = Rect.new(0, 0, width, @tool_tip.bitmap.height)
    @tool_tip.bitmap.fill_rect(rect, Color.new(0, 0, 0, 160))
    @tool_tip.bitmap.draw_text(rect, event_name, 1)
  end

  #----------------------------------------------------------------------------
  # * Desenha os sprites de eventos especiais no minimap
  #   Cada tipo de evento recebe um ícone diferente (linha da spritesheet)
  #   Tipos detectados: Missão, Boss, Loja, Banco, Teleporte, CheckPoint
  #----------------------------------------------------------------------------
  def draw_events
    @player_sprite.visible = true

    $game_map.events.each do |event_id, event|
      next unless event.list

      # Missão disponível (não iniciada)
      if event.quest_not_started?
        create_event(event_id, Vocab::Quest, 32)
        next
      # Boss
      elsif event.boss?
        create_event(event_id, Vocab::Boss, 96)
        next
      end

      event.list.each do |item|
        # Loja (comando 302 = Show Shop Processing)
        if item.code == 302
          create_event(event_id, Vocab::Shop, 16)
          break
        elsif item.code == 355
          param = item.parameters[0]

          # Banco
          if param.include?('open_bank')
            create_event(event_id, Vocab::Bank, 48)
            break
          # Teleporte
          elsif param.include?('open_teleport')
            create_event(event_id, Vocab::Teleport, 64)
            break
          # Ponto de respawn / checkpoint
          elsif param.include?('check_point')
            create_event(event_id, Vocab::CheckPoint, 80)
            break
          end
        end
      end
    end
  end

  #----------------------------------------------------------------------------
  # * Update: atualiza posição do jogador, eventos e tooltip a cada frame
  #   Otimização: refresh() só é chamado quando o mapa muda (@last_map_id)
  #   Evita redesenhar o frame e o mapa desnecessariamente a cada frame
  #----------------------------------------------------------------------------
  def update
    super

    # Redesenha apenas se o jogador trocou de mapa desde o último refresh
    refresh if $game_map.map_id != @last_map_id

    # Atualiza opacidade (drag/hover)
    change_opacity(Configs::MINIMAP_PADDING)

    # Mantém o ícone PVP/Safe sincronizado com a posição atual do minimap
    # (necessário quando o minimap é arrastado pelo jogador)
    update_pvp_position

    # Atualiza posição do sprite do jogador no minimap
    @player_sprite.x = self.x + object_x($game_player)
    @player_sprite.y = self.y + object_y($game_player)

    # Atualiza posição e tooltip de cada evento
    @event_sprites.each do |event_id, event_sprite|
      event_sprite.x = self.x + object_x($game_map.events[event_id])
      event_sprite.y = self.y + object_y($game_map.events[event_id])
      update_tool_tip(event_id)
    end
  end

  #----------------------------------------------------------------------------
  # * Atualiza o tooltip do evento sob o cursor do mouse
  #   Exibe apenas quando o mouse está sobre o ícone do evento
  #   Posiciona o tooltip seguindo o mouse sem sair da tela
  #----------------------------------------------------------------------------
  def update_tool_tip(event_id)
    return if @tool_tip.visible && @last_tip_name != @event_data[event_id].name

    # Verifica se o mouse está sobre o ícone do evento na área do minimap
    @tool_tip.visible = in_area?(
      object_x($game_map.events[event_id]) - Configs::MINIMAP_PADDING,
      object_y($game_map.events[event_id]),
      40, 16
    )

    if @tool_tip.visible
      tip_w = @event_data[event_id].width
      tip_h = @tool_tip.bitmap.height

      # Posiciona o tooltip seguindo o mouse, ajustando para não sair da tela
      @tool_tip.x = Mouse.x + 18 + tip_w > Graphics.width  ?
                    Graphics.width  - tip_w : Mouse.x + 18
      @tool_tip.y = Mouse.y + 18 + tip_h > Graphics.height ?
                    Graphics.height - tip_h : Mouse.y + 18

      # Redesenha o conteúdo do tooltip apenas se o evento mudou
      unless @last_tip_name == @event_data[event_id].name
        refresh_tool_tip(@event_data[event_id].name, tip_w)
      end
    end
  end

end