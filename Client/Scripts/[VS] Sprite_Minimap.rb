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
#   - Coordenadas do jogador (X/Y) exibidas abaixo do nome do mapa
#   - Relógio em tempo real exibido abaixo das coordenadas
#   - Linhas separadoras entre as seções de texto (nome / coords / relógio)
#   - Posição FIXA: drag desabilitado (@dragable = false)
#   - NOVO: Toggle de visibilidade via tecla N ou clique no botão ▼/▲
#            O botão permanece sempre visível no topo-direito do frame
#
# Configs necessários (adicionar em [VS] Configs.rb):
#   MINIMAP_TOGGLE_KEY    = :N                            # Tecla de toggle
#   MINIMAP_BTN_SIZE      = 16                            # Tamanho do botão (px)
#   MINIMAP_BTN_BG        = Color.new(0, 0, 0, 180)       # Fundo do botão
#   MINIMAP_BTN_BORDER    = Color.new(180, 150, 80, 200)  # Borda dourada
#   MINIMAP_BTN_COLOR     = Color.new(255, 255, 200, 255) # Cor do símbolo ▼/▲
#   MINIMAP_BTN_FONT_SIZE = 10                            # Tamanho da fonte
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
  #   Cria o bitmap (MINIMAP_SIZE × total_height), posiciona na tela
  #   e inicializa sprites filhos.
  #
  #   Altura total do bitmap:
  #     MINIMAP_SIZE        → quadrado do frame
  #     MINIMAP_NAME_HEIGHT → nome do mapa
  #     MINIMAP_COORD_HEIGHT→ coordenadas X/Y do jogador
  #     MINIMAP_CLOCK_HEIGHT→ relógio em tempo real
  #----------------------------------------------------------------------------
  def initialize
    super

    self.bitmap = Bitmap.new(
      Configs::MINIMAP_SIZE,
      Configs::MINIMAP_SIZE        +
      Configs::MINIMAP_NAME_HEIGHT  +
      Configs::MINIMAP_COORD_HEIGHT +
      Configs::MINIMAP_CLOCK_HEIGHT
    )

    # Posiciona no canto superior direito da tela
    self.x = Graphics.width - Configs::MINIMAP_SIZE - Configs::MINIMAP_X_MARGIN
    self.y = Configs::MINIMAP_Y
    self.z = Configs::MINIMAP_Z

    # Fonte padrão para todos os textos do minimap
    self.bitmap.font.size = Configs::MINIMAP_FONT_SIZE
    self.bitmap.font.bold = Configs::MINIMAP_FONT_BOLD

    # Spritesheet 'Minimap': usada apenas para ícones de player/eventos
    @bitmap = Cache.system('Minimap')

    # Minimap fixo: jogador não pode arrastar
    @dragable      = false
    @event_sprites = {}
    @event_data    = {}
    @last_tip_name = ''

    # Cache: detecta troca de mapa para disparar refresh completo
    @last_map_id = nil

    # Cache: detecta movimento do jogador para atualizar coordenadas
    @last_player_x = nil
    @last_player_y = nil

    # Cache: detecta mudança de segundo para atualizar o relógio
    @last_time = nil

    # Estado de visibilidade do corpo do minimap (toggle)
    @minimap_visible = true

    create_player_point
    create_tool_tip
    create_pvp_icon
    create_toggle_btn
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
  #----------------------------------------------------------------------------
  def adjust_x
    Graphics.width - Configs::MINIMAP_SIZE - Configs::MINIMAP_X_MARGIN
  end

  #----------------------------------------------------------------------------
  # * Verifica se a posição (x, y) está dentro da área do mapa no minimap
  #----------------------------------------------------------------------------
  def in_area?(x = 0, y = 0, w = Configs::MINIMAP_MAP_AREA, h = Configs::MINIMAP_MAP_AREA)
    super(x + Configs::MINIMAP_PADDING, y + Configs::MINIMAP_PADDING, w, h)
  end

  #----------------------------------------------------------------------------
  # * Atualiza opacidade do minimap e de todos os sprites filhos
  #   O botão de toggle recebe opacity independente (sempre bem visível)
  #----------------------------------------------------------------------------
  def change_opacity(x = 0, y = 0)
    super()
    @player_sprite.opacity = self.opacity
    @pvp_sprite.opacity    = self.opacity
    @toggle_btn.opacity    = [self.opacity, 180].max  # botão nunca fica transparente demais
    @event_sprites.each_value { |sprite| sprite.opacity = self.opacity }
  end

  #----------------------------------------------------------------------------
  # * Cria o sprite do ponto do jogador sobre o mapa
  #----------------------------------------------------------------------------
  def create_player_point
    @player_sprite        = Sprite.new
    @player_sprite.bitmap = Bitmap.new(16, 16)
    @player_sprite.bitmap.blt(0, 0, @bitmap, Rect.new(142, 0, 16, 16))
    @player_sprite.z      = self.z + 1
  end

  #----------------------------------------------------------------------------
  # * Cria o sprite do tooltip (nome do evento ao passar o mouse)
  #----------------------------------------------------------------------------
  def create_tool_tip
    @tool_tip        = Sprite.new
    @tool_tip.bitmap = Bitmap.new(Configs::MINIMAP_SIZE, line_height)
    @tool_tip.z      = @player_sprite.z + 1
  end

  #----------------------------------------------------------------------------
  # * Cria o sprite do ícone PVP / Safe (sprite separado, fora do bitmap)
  #   Como o minimap é fixo, a posição do ícone só precisa ser definida uma vez.
  #----------------------------------------------------------------------------
  def create_pvp_icon
    @pvp_sprite        = Sprite.new
    @pvp_sprite.bitmap = Bitmap.new(24, 24)
    @pvp_sprite.z      = self.z + 1
    refresh_pvp_icon
  end

  #----------------------------------------------------------------------------
  # * Cria o botão de toggle (mostrar/esconder minimap)
  #
  #   Sprite quadrado de Configs::MINIMAP_BTN_SIZE px posicionado no
  #   canto superior direito do frame, com margem interna de 2px.
  #   Permanece SEMPRE visível, mesmo quando o corpo do minimap é ocultado,
  #   permitindo que o jogador reabra o minimap ao clicar nele.
  #
  #   Símbolo exibido:
  #     ▼  → minimap visível   (clicar irá esconder)
  #     ▲  → minimap oculto    (clicar irá mostrar)
  #----------------------------------------------------------------------------
  def create_toggle_btn
    btn_s              = Configs::MINIMAP_BTN_SIZE
    @toggle_btn        = Sprite.new
    @toggle_btn.bitmap = Bitmap.new(btn_s, btn_s)
    @toggle_btn.x      = self.x + Configs::MINIMAP_SIZE - btn_s - 2
    @toggle_btn.y      = self.y + 2
    @toggle_btn.z      = self.z + 2
    refresh_toggle_btn
  end

  #----------------------------------------------------------------------------
  # * Redesenha o botão de toggle
  #   Fundo semi-transparente + borda dourada + símbolo ▼ ou ▲
  #   Chamado em create_toggle_btn e sempre que o estado de visibilidade muda
  #----------------------------------------------------------------------------
  def refresh_toggle_btn
    btn_s  = Configs::MINIMAP_BTN_SIZE
    bitmap = @toggle_btn.bitmap
    bitmap.clear

    # ── Fundo ─────────────────────────────────────────────────────────────────
    bitmap.fill_rect(0, 0, btn_s, btn_s, Configs::MINIMAP_BTN_BG)

    # ── Borda (1px, dourada) ──────────────────────────────────────────────────
    bdr = Configs::MINIMAP_BTN_BORDER
    bitmap.fill_rect(0,         0,         btn_s, 1,     bdr)  # Topo
    bitmap.fill_rect(0,         btn_s - 1, btn_s, 1,     bdr)  # Base
    bitmap.fill_rect(0,         0,         1,     btn_s, bdr)  # Esquerda
    bitmap.fill_rect(btn_s - 1, 0,         1,     btn_s, bdr)  # Direita

    # ── Símbolo ▼/▲ ───────────────────────────────────────────────────────────
    bitmap.font.size  = Configs::MINIMAP_BTN_FONT_SIZE
    bitmap.font.bold  = false
    bitmap.font.color = Configs::MINIMAP_BTN_COLOR
    bitmap.draw_text(0, 0, btn_s, btn_s, @minimap_visible ? '▼' : '▲', 1)
  end

  #----------------------------------------------------------------------------
  # * Alterna a visibilidade do corpo do minimap
  #
  #   Quando oculto:
  #     - self (bitmap principal), sprites de player, pvp e eventos → invisible
  #     - @toggle_btn → permanece VISÍVEL (permite reabrir)
  #     - @tool_tip   → sempre resetado para invisible
  #
  #   Quando visível:
  #     - Todos os sprites são restaurados
  #     - O estado dos sprites de eventos respeita @minimap_visible
  #----------------------------------------------------------------------------
  def toggle_minimap
    @minimap_visible = !@minimap_visible

    self.visible           = @minimap_visible
    @player_sprite.visible = @minimap_visible
    @pvp_sprite.visible    = @minimap_visible
    @tool_tip.visible      = false  # sempre reseta tooltip ao alternar

    @event_sprites.each_value { |s| s.visible = @minimap_visible }

    refresh_toggle_btn
  end

  #----------------------------------------------------------------------------
  # * Verifica se a tecla de toggle foi pressionada
  #
  #   Usa Configs::MINIMAP_TOGGLE_KEY (padrão: :N).
  #   O rescue garante que, caso o módulo Input do VXA-OS não suporte
  #   a constante de tecla configurada, o script não quebre.
  #   Se necessário, substitua Input.trigger? pelo método do seu VXA-OS:
  #     Keyboard.trigger?(:N)   ou similar
  #----------------------------------------------------------------------------
  def toggle_key_triggered?
    Input.trigger?(Configs::MINIMAP_TOGGLE_KEY)
  rescue
    false
  end

  #----------------------------------------------------------------------------
  # * Verifica se o botão de toggle foi clicado com o mouse (botão esquerdo)
  #   A área de clique equivale exatamente ao bitmap do botão
  #----------------------------------------------------------------------------
  def toggle_btn_clicked?
    btn_s = Configs::MINIMAP_BTN_SIZE
    bx    = self.x + Configs::MINIMAP_SIZE - btn_s - 2
    by    = self.y + 2

    Mouse.trigger?(:left)   &&
    Mouse.x >= bx           &&
    Mouse.x <= bx + btn_s   &&
    Mouse.y >= by           &&
    Mouse.y <= by + btn_s
  end

  #----------------------------------------------------------------------------
  # * Processa o input de toggle a cada frame
  #   Prioridade: tecla N → clique no botão
  #   Chamado ANTES do guard `return unless @minimap_visible` para que
  #   o toggle funcione mesmo com o minimap oculto
  #----------------------------------------------------------------------------
  def update_toggle
    if toggle_key_triggered? || toggle_btn_clicked?
      toggle_minimap
    end
  end

  #----------------------------------------------------------------------------
  # * Atualiza o conteúdo do ícone PVP / Safe
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
  # * Define a posição do sprite de ícone PVP / Safe
  #   Como o minimap é fixo, basta chamar uma única vez (em refresh_pvp_icon).
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
    @toggle_btn.bitmap.dispose
    @toggle_btn.dispose
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
  #----------------------------------------------------------------------------
  def object_x(object)
    px     = Configs::MINIMAP_PADDING + object.x * Configs::MINIMAP_MAP_AREA / [$game_map.width,  1].max
    min_px = Configs::MINIMAP_PADDING
    max_px = Configs::MINIMAP_PADDING + Configs::MINIMAP_MAP_AREA - 8
    [[px, min_px].max, max_px].min
  end

  #----------------------------------------------------------------------------
  # * Converte posição Y do objeto (tiles) para pixels na tela do minimap
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
  #   Sequência: fundo → separadores → frame → nome → coords → relógio → PVP → eventos
  #----------------------------------------------------------------------------
  def refresh
    @tool_tip.visible = false
    draw_background
    draw_separators
    draw_frame
    draw_map_name
    draw_coordinates
    draw_clock
    refresh_pvp_icon
    dispose_events

    if FileTest.exist?("Graphics/Minimaps/#{$game_map.map_id}.png")
      draw_map
      draw_events
    else
      @player_sprite.visible = false
    end

    @last_map_id = $game_map.map_id
  end

  #----------------------------------------------------------------------------
  # * Desenha o fundo do minimap
  #   Cobre toda a altura do bitmap: frame + nome + coordenadas + relógio
  #----------------------------------------------------------------------------
  def draw_background
    self.bitmap.clear

    total_h = Configs::MINIMAP_SIZE        +
              Configs::MINIMAP_NAME_HEIGHT  +
              Configs::MINIMAP_COORD_HEIGHT +
              Configs::MINIMAP_CLOCK_HEIGHT

    self.bitmap.fill_rect(
      Rect.new(0, 0, Configs::MINIMAP_SIZE, total_h),
      Configs::MINIMAP_BG_COLOR
    )

    self.bitmap.fill_rect(
      Rect.new(
        Configs::MINIMAP_PADDING,
        Configs::MINIMAP_PADDING,
        Configs::MINIMAP_MAP_AREA,
        Configs::MINIMAP_MAP_AREA
      ),
      Configs::MINIMAP_MAP_BG
    )
  end

  #----------------------------------------------------------------------------
  # * Desenha as linhas separadoras entre as seções de texto
  #   Três linhas de 1px desenhadas nas bordas de cada seção:
  #     1. Entre o frame do mapa e o nome do mapa
  #     2. Entre o nome do mapa e as coordenadas
  #     3. Entre as coordenadas e o relógio
  #----------------------------------------------------------------------------
  def draw_separators
    sep    = Configs::MINIMAP_SEPARATOR_COLOR
    w      = Configs::MINIMAP_SIZE - 8
    x_left = 4

    y1 = Configs::MINIMAP_SIZE
    self.bitmap.fill_rect(Rect.new(x_left, y1, w, 1), sep)

    y2 = Configs::MINIMAP_SIZE + Configs::MINIMAP_NAME_HEIGHT
    self.bitmap.fill_rect(Rect.new(x_left, y2, w, 1), sep)

    y3 = Configs::MINIMAP_SIZE + Configs::MINIMAP_NAME_HEIGHT + Configs::MINIMAP_COORD_HEIGHT
    self.bitmap.fill_rect(Rect.new(x_left, y3, w, 1), sep)
  end

  #----------------------------------------------------------------------------
  # * Desenha o frame quadrado do minimap via Bitmap (sem Windowskin)
  #   Estrutura de bordas (de fora para dentro):
  #     1. Borda EXTERNA  → Configs::MINIMAP_FRAME_OUTER  (dourado)
  #     2. Borda INTERNA  → Configs::MINIMAP_FRAME_INNER  (efeito 3D)
  #     3. Cantos DECORATIVOS 4×4 → Configs::MINIMAP_FRAME_CORNER (ouro brilhante)
  #----------------------------------------------------------------------------
  def draw_frame
    s      = Configs::MINIMAP_SIZE
    p      = Configs::MINIMAP_PADDING
    b      = Configs::MINIMAP_BORDER
    outer  = Configs::MINIMAP_FRAME_OUTER
    inner  = Configs::MINIMAP_FRAME_INNER
    corner = Configs::MINIMAP_FRAME_CORNER

    # ── Borda EXTERNA ──────────────────────────────────────────────────────────
    self.bitmap.fill_rect(0,     0,     s,  b,  outer)  # Topo
    self.bitmap.fill_rect(0,     s - b, s,  b,  outer)  # Base
    self.bitmap.fill_rect(0,     0,     b,  s,  outer)  # Esquerda
    self.bitmap.fill_rect(s - b, 0,     b,  s,  outer)  # Direita

    # ── Borda INTERNA ──────────────────────────────────────────────────────────
    m  = p - b
    ma = Configs::MINIMAP_MAP_AREA + b * 2

    self.bitmap.fill_rect(m,          m,          ma, b,  inner)  # Topo interno
    self.bitmap.fill_rect(m,          m + ma - b, ma, b,  inner)  # Base interna
    self.bitmap.fill_rect(m,          m,          b,  ma, inner)  # Esquerda interna
    self.bitmap.fill_rect(m + ma - b, m,          b,  ma, inner)  # Direita interna

    # ── Cantos DECORATIVOS ─────────────────────────────────────────────────────
    cs = 4
    self.bitmap.fill_rect(m,           m,           cs, cs, corner)
    self.bitmap.fill_rect(m + ma - cs, m,           cs, cs, corner)
    self.bitmap.fill_rect(m,           m + ma - cs, cs, cs, corner)
    self.bitmap.fill_rect(m + ma - cs, m + ma - cs, cs, cs, corner)
  end

  #----------------------------------------------------------------------------
  # * Desenha o nome do mapa centralizado abaixo do frame
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
  # * Desenha as coordenadas X/Y do jogador abaixo do nome do mapa
  #   Otimização: só redesenha quando o jogador se move (@last_player_x/y)
  #   Preservação do separador: fill_rect começa em y_pos + 1
  #----------------------------------------------------------------------------
  def draw_coordinates
    y_pos = Configs::MINIMAP_SIZE + Configs::MINIMAP_NAME_HEIGHT

    self.bitmap.fill_rect(
      Rect.new(0, y_pos + 1, Configs::MINIMAP_SIZE, Configs::MINIMAP_COORD_HEIGHT - 1),
      Configs::MINIMAP_BG_COLOR
    )

    text = Configs::MINIMAP_COORD_FORMAT % [$game_player.x, $game_player.y]
    self.bitmap.draw_text(
      0, y_pos + 1,
      Configs::MINIMAP_SIZE,
      Configs::MINIMAP_COORD_HEIGHT - 1,
      text, 1
    )

    @last_player_x = $game_player.x
    @last_player_y = $game_player.y
  end

  #----------------------------------------------------------------------------
  # * Desenha o relógio em tempo real abaixo das coordenadas
  #   Otimização: só redesenha quando o segundo muda (@last_time)
  #   Preservação do separador: fill_rect começa em y_pos + 1
  #----------------------------------------------------------------------------
  def draw_clock
    y_pos = Configs::MINIMAP_SIZE        +
            Configs::MINIMAP_NAME_HEIGHT  +
            Configs::MINIMAP_COORD_HEIGHT

    current_time = Time.now.strftime(Configs::MINIMAP_CLOCK_FORMAT)

    self.bitmap.fill_rect(
      Rect.new(0, y_pos + 1, Configs::MINIMAP_SIZE, Configs::MINIMAP_CLOCK_HEIGHT - 1),
      Configs::MINIMAP_BG_COLOR
    )

    self.bitmap.draw_text(
      0, y_pos + 1,
      Configs::MINIMAP_SIZE,
      Configs::MINIMAP_CLOCK_HEIGHT - 1,
      current_time, 1
    )

    @last_time = current_time
  end

  #----------------------------------------------------------------------------
  # * Desenha a imagem PNG do mapa na área interna do frame
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
  #----------------------------------------------------------------------------
  def draw_events
    @player_sprite.visible = true

    $game_map.events.each do |event_id, event|
      next unless event.list

      if event.quest_not_started?
        create_event(event_id, Vocab::Quest, 32)
        next
      elsif event.boss?
        create_event(event_id, Vocab::Boss, 96)
        next
      end

      event.list.each do |item|
        if item.code == 302
          create_event(event_id, Vocab::Shop, 16)
          break
        elsif item.code == 355
          param = item.parameters[0]

          if param.include?('open_bank')
            create_event(event_id, Vocab::Bank, 48)
            break
          elsif param.include?('open_teleport')
            create_event(event_id, Vocab::Teleport, 64)
            break
          elsif param.include?('check_point')
            create_event(event_id, Vocab::CheckPoint, 80)
            break
          end
        end
      end
    end
  end

  #----------------------------------------------------------------------------
  # * Update principal
  #
  #   Fluxo:
  #     1. update_toggle  → sempre processado (tecla N + clique no botão)
  #     2. guard          → sai se o minimap estiver oculto (@minimap_visible)
  #     3. refresh        → só se o mapa trocou
  #     4. coordenadas    → só se o jogador se moveu
  #     5. relógio        → só se o segundo mudou
  #     6. sprites        → posições do jogador e eventos
  #
  #   Nota: update_pvp_position não é chamado aqui pois o minimap é fixo —
  #   a posição do ícone PVP é definida uma única vez em refresh_pvp_icon.
  #----------------------------------------------------------------------------
  def update
    super

    # Passo 1: toggle sempre processado, inclusive com minimap oculto
    update_toggle

    # Passo 2: nada mais precisa rodar se o minimap estiver oculto
    return unless @minimap_visible

    # Passo 3: refresh completo apenas na troca de mapa
    refresh if $game_map.map_id != @last_map_id

    # Atualiza opacidade (hover)
    change_opacity(Configs::MINIMAP_PADDING)

    # Passo 4: coordenadas apenas quando o jogador se move
    if $game_player.x != @last_player_x || $game_player.y != @last_player_y
      draw_coordinates
    end

    # Passo 5: relógio apenas quando o segundo muda
    current_time = Time.now.strftime(Configs::MINIMAP_CLOCK_FORMAT)
    draw_clock if current_time != @last_time

    # Passo 6: posição do sprite do jogador no minimap
    @player_sprite.x = self.x + object_x($game_player)
    @player_sprite.y = self.y + object_y($game_player)

    # Posição e tooltip de cada evento
    @event_sprites.each do |event_id, event_sprite|
      event_sprite.x = self.x + object_x($game_map.events[event_id])
      event_sprite.y = self.y + object_y($game_map.events[event_id])
      update_tool_tip(event_id)
    end
  end

  #----------------------------------------------------------------------------
  # * Atualiza o tooltip do evento sob o cursor do mouse
  #----------------------------------------------------------------------------
  def update_tool_tip(event_id)
    return if @tool_tip.visible && @last_tip_name != @event_data[event_id].name

    @tool_tip.visible = in_area?(
      object_x($game_map.events[event_id]) - Configs::MINIMAP_PADDING,
      object_y($game_map.events[event_id]),
      40, 16
    )

    if @tool_tip.visible
      tip_w = @event_data[event_id].width
      tip_h = @tool_tip.bitmap.height

      @tool_tip.x = Mouse.x + 18 + tip_w > Graphics.width  ?
                    Graphics.width  - tip_w : Mouse.x + 18
      @tool_tip.y = Mouse.y + 18 + tip_h > Graphics.height ?
                    Graphics.height - tip_h : Mouse.y + 18

      unless @last_tip_name == @event_data[event_id].name
        refresh_tool_tip(@event_data[event_id].name, tip_w)
      end
    end
  end

end