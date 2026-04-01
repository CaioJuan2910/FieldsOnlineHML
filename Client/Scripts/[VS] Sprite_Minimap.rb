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
#   - Minimap sempre visível (sem toggle)
#   - Suporte a imagem de fundo customizada via Graphics/System/HUD_Minimap.png
#
# Inspirado em: Tibia Online, MU Online, Ragnarok Online
#------------------------------------------------------------------------------
# Autor: Valentine
# Refatorado: uso de Configs para facilitar ajustes sem editar este script
#==============================================================================
class Sprite_Minimap < Sprite2

  Event_Data = Struct.new(:name, :width)

  def initialize
    super
    self.bitmap = Bitmap.new(
      Configs::MINIMAP_SIZE,
      Configs::MINIMAP_SIZE +
      Configs::MINIMAP_NAME_HEIGHT +
      Configs::MINIMAP_COORD_HEIGHT +
      Configs::MINIMAP_CLOCK_HEIGHT
    )
    self.x = Graphics.width - Configs::MINIMAP_SIZE - Configs::MINIMAP_X_MARGIN
    self.y = Configs::MINIMAP_Y
    self.z = Configs::MINIMAP_Z
    self.bitmap.font.size = Configs::MINIMAP_FONT_SIZE
    self.bitmap.font.bold = Configs::MINIMAP_FONT_BOLD
    @bitmap = Cache.system('Minimap')
    @dragable      = false
    @event_sprites = {}
    @event_data    = {}
    @last_tip_name = ''
    @last_map_id   = nil
    @last_player_x = nil
    @last_player_y = nil
    @last_time     = nil
    create_player_point
    create_tool_tip
    create_pvp_icon
    refresh
    update
  end

  def line_height
    Configs::MINIMAP_FONT_SIZE + 4
  end

  def adjust_x
    Graphics.width - Configs::MINIMAP_SIZE - Configs::MINIMAP_X_MARGIN
  end

  def in_area?(x = 0, y = 0, w = Configs::MINIMAP_MAP_AREA, h = Configs::MINIMAP_MAP_AREA)
    super(x + Configs::MINIMAP_PADDING, y + Configs::MINIMAP_PADDING, w, h)
  end

  def change_opacity(x = 0, y = 0)
    super()
    @player_sprite.opacity = self.opacity
    @pvp_sprite.opacity    = self.opacity
    @event_sprites.each_value { |sprite| sprite.opacity = self.opacity }
  end

  def create_player_point
    @player_sprite        = Sprite.new
    @player_sprite.bitmap = Bitmap.new(16, 16)
    @player_sprite.bitmap.blt(0, 0, @bitmap, Rect.new(142, 0, 16, 16))
    @player_sprite.z      = self.z + 1
  end

  def create_tool_tip
    @tool_tip        = Sprite.new
    @tool_tip.bitmap = Bitmap.new(Configs::MINIMAP_SIZE, line_height)
    @tool_tip.z      = @player_sprite.z + 1
  end

  def create_pvp_icon
    @pvp_sprite        = Sprite.new
    @pvp_sprite.bitmap = Bitmap.new(24, 24)
    @pvp_sprite.z      = self.z + 1
    refresh_pvp_icon
  end

  def refresh_pvp_icon
    @pvp_sprite.bitmap.clear
    iconset    = Cache.system('Iconset')
    icon_index = $game_map.pvp? ? Configs::MAP_PVP_ICON : Configs::MAP_NONPVP_ICON
    rect       = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    @pvp_sprite.bitmap.blt(0, 0, iconset, rect)
    update_pvp_position
  end

  def update_pvp_position
    @pvp_sprite.x = self.x + Configs::MINIMAP_PVP_X_OFFSET
    @pvp_sprite.y = self.y + Configs::MINIMAP_PVP_Y_OFFSET
  end

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

  def dispose_events
    @event_sprites.each_value do |event|
      event.bitmap.dispose
      event.dispose
    end
    @event_sprites.clear
    @event_data.clear
  end

  def object_x(object)
    px     = Configs::MINIMAP_PADDING + object.x * Configs::MINIMAP_MAP_AREA / [$game_map.width,  1].max
    min_px = Configs::MINIMAP_PADDING
    max_px = Configs::MINIMAP_PADDING + Configs::MINIMAP_MAP_AREA - 8
    [[px, min_px].max, max_px].min
  end

  def object_y(object)
    py     = Configs::MINIMAP_PADDING + object.y * Configs::MINIMAP_MAP_AREA / [$game_map.height, 1].max
    min_py = Configs::MINIMAP_PADDING
    max_py = Configs::MINIMAP_PADDING + Configs::MINIMAP_MAP_AREA - 8
    [[py, min_py].max, max_py].min
  end

  def refresh
    @tool_tip.visible = false
    draw_background
    draw_separators
    draw_frame if !Configs::MINIMAP_BG_IMAGE || Configs::MINIMAP_BG_IMAGE.empty? || Configs::MINIMAP_DRAW_FRAME_OVER_BG
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

  def draw_background
    self.bitmap.clear
    total_h = Configs::MINIMAP_SIZE +
              Configs::MINIMAP_NAME_HEIGHT +
              Configs::MINIMAP_COORD_HEIGHT +
              Configs::MINIMAP_CLOCK_HEIGHT

    if Configs::MINIMAP_BG_IMAGE && !Configs::MINIMAP_BG_IMAGE.empty?
      # ── Imagem customizada como fundo do frame quadrado ───────────────────
      bg_bitmap = Cache.system(Configs::MINIMAP_BG_IMAGE)
      dest_rect = Rect.new(0, 0, Configs::MINIMAP_SIZE, Configs::MINIMAP_SIZE)
      self.bitmap.stretch_blt(dest_rect, bg_bitmap, bg_bitmap.rect)
      # Fundo sólido apenas para a área de texto abaixo do frame
      text_h = Configs::MINIMAP_NAME_HEIGHT +
               Configs::MINIMAP_COORD_HEIGHT +
               Configs::MINIMAP_CLOCK_HEIGHT
      self.bitmap.fill_rect(
        Rect.new(0, Configs::MINIMAP_SIZE, Configs::MINIMAP_SIZE, text_h),
        Configs::MINIMAP_BG_COLOR
      )
    else
      # ── Fundo padrão via fill_rect (sem imagem) ───────────────────────────
      self.bitmap.fill_rect(
        Rect.new(0, 0, Configs::MINIMAP_SIZE, total_h),
        Configs::MINIMAP_BG_COLOR
      )
      self.bitmap.fill_rect(
        Rect.new(Configs::MINIMAP_PADDING, Configs::MINIMAP_PADDING,
                 Configs::MINIMAP_MAP_AREA, Configs::MINIMAP_MAP_AREA),
        Configs::MINIMAP_MAP_BG
      )
    end
  end

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

  def draw_frame
    s      = Configs::MINIMAP_SIZE
    p      = Configs::MINIMAP_PADDING
    b      = Configs::MINIMAP_BORDER
    outer  = Configs::MINIMAP_FRAME_OUTER
    inner  = Configs::MINIMAP_FRAME_INNER
    corner = Configs::MINIMAP_FRAME_CORNER
    self.bitmap.fill_rect(0,     0,     s, b, outer)
    self.bitmap.fill_rect(0,     s - b, s, b, outer)
    self.bitmap.fill_rect(0,     0,     b, s, outer)
    self.bitmap.fill_rect(s - b, 0,     b, s, outer)
    m  = p - b
    ma = Configs::MINIMAP_MAP_AREA + b * 2
    self.bitmap.fill_rect(m,          m,          ma, b,  inner)
    self.bitmap.fill_rect(m,          m + ma - b, ma, b,  inner)
    self.bitmap.fill_rect(m,          m,          b,  ma, inner)
    self.bitmap.fill_rect(m + ma - b, m,          b,  ma, inner)
    cs = 4
    self.bitmap.fill_rect(m,           m,           cs, cs, corner)
    self.bitmap.fill_rect(m + ma - cs, m,           cs, cs, corner)
    self.bitmap.fill_rect(m,           m + ma - cs, cs, cs, corner)
    self.bitmap.fill_rect(m + ma - cs, m + ma - cs, cs, cs, corner)
  end

  def draw_map_name
    self.bitmap.draw_text(
      0, Configs::MINIMAP_SIZE + 2,
      Configs::MINIMAP_SIZE, Configs::MINIMAP_NAME_HEIGHT - 2,
      $game_map.display_name, 1
    )
  end

  def draw_coordinates
    y_pos = Configs::MINIMAP_SIZE + Configs::MINIMAP_NAME_HEIGHT
    self.bitmap.fill_rect(
      Rect.new(0, y_pos + 1, Configs::MINIMAP_SIZE, Configs::MINIMAP_COORD_HEIGHT - 1),
      Configs::MINIMAP_BG_COLOR
    )
    text = Configs::MINIMAP_COORD_FORMAT % [$game_player.x, $game_player.y]
    self.bitmap.draw_text(
      0, y_pos + 1,
      Configs::MINIMAP_SIZE, Configs::MINIMAP_COORD_HEIGHT - 1,
      text, 1
    )
    @last_player_x = $game_player.x
    @last_player_y = $game_player.y
  end

  def draw_clock
    y_pos        = Configs::MINIMAP_SIZE + Configs::MINIMAP_NAME_HEIGHT + Configs::MINIMAP_COORD_HEIGHT
    current_time = Time.now.strftime(Configs::MINIMAP_CLOCK_FORMAT)
    self.bitmap.fill_rect(
      Rect.new(0, y_pos + 1, Configs::MINIMAP_SIZE, Configs::MINIMAP_CLOCK_HEIGHT - 1),
      Configs::MINIMAP_BG_COLOR
    )
    self.bitmap.draw_text(
      0, y_pos + 1,
      Configs::MINIMAP_SIZE, Configs::MINIMAP_CLOCK_HEIGHT - 1,
      current_time, 1
    )
    @last_time = current_time
  end

  def draw_map
    bitmap = Cache.minimap($game_map.map_id.to_s)
    dest   = Rect.new(
      Configs::MINIMAP_PADDING, Configs::MINIMAP_PADDING,
      Configs::MINIMAP_MAP_AREA, Configs::MINIMAP_MAP_AREA
    )
    self.bitmap.stretch_blt(dest, bitmap, bitmap.rect)
  end

  def refresh_tool_tip(event_name, width)
    @last_tip_name = event_name
    @tool_tip.bitmap.clear
    rect = Rect.new(0, 0, width, @tool_tip.bitmap.height)
    @tool_tip.bitmap.fill_rect(rect, Color.new(0, 0, 0, 160))
    @tool_tip.bitmap.draw_text(rect, event_name, 1)
  end

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
          if    param.include?('open_bank')      then create_event(event_id, Vocab::Bank,      48); break
          elsif param.include?('open_teleport')  then create_event(event_id, Vocab::Teleport,  64); break
          elsif param.include?('check_point')    then create_event(event_id, Vocab::CheckPoint, 80); break
          end
        end
      end
    end
  end

  def update
    super
    refresh if $game_map.map_id != @last_map_id
    change_opacity(Configs::MINIMAP_PADDING)
    if $game_player.x != @last_player_x || $game_player.y != @last_player_y
      draw_coordinates
    end
    current_time = Time.now.strftime(Configs::MINIMAP_CLOCK_FORMAT)
    draw_clock if current_time != @last_time
    @player_sprite.x = self.x + object_x($game_player)
    @player_sprite.y = self.y + object_y($game_player)
    @event_sprites.each do |event_id, event_sprite|
      event_sprite.x = self.x + object_x($game_map.events[event_id])
      event_sprite.y = self.y + object_y($game_map.events[event_id])
      update_tool_tip(event_id)
    end
  end

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
      @tool_tip.x = Mouse.x + 18 + tip_w > Graphics.width  ? Graphics.width  - tip_w : Mouse.x + 18
      @tool_tip.y = Mouse.y + 18 + tip_h > Graphics.height ? Graphics.height - tip_h : Mouse.y + 18
      unless @last_tip_name == @event_data[event_id].name
        refresh_tool_tip(@event_data[event_id].name, tip_w)
      end
    end
  end

end