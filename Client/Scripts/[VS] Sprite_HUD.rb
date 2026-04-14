#==============================================================================
# ** [VS] Sprite_HUD — Fields Online
#------------------------------------------------------------------------------
# Exibe HP, MP, EXP, face e nível do jogador na HUD principal.
# Barras desenhadas inteiramente via código (sem assets externos).
#------------------------------------------------------------------------------
# Autor Original : Valentine
# Modernizado por: Caio Juan De Lima Silva
# Revisão        : Aura AI
# Versão         : 2.3.0
# Data           : 13/04/2026
# Changelog      :
#   v2.3.0 — Configurações Modulares:
#     • HP_CRITICAL_THRESHOLD = 0.25 (era 0.25 hardcoded em draw_hp_bar)
#     • SHADOW_OFFSET = 1 (era +1 hardcoded em 5 métodos de texto)
#     • HP_LABEL = 'HP' (era string literal em draw_hp_bar)
#     • MP_LABEL = 'MP' (era string literal em draw_mp_bar)
#     • BAR_SPACING = 30 (documenta o espaço entre HP e MP)
#     • HUD_Config reorganizado com separadores estilo VS_COORDENADAS
#   v2.2.0 — HUD e EXP bar fixas — drag desabilitado
#     • DRAGGABLE = false no módulo HUD_Config
#     • Sprite_HUD sobrescreve dragable para respeitar a flag
#     • @exp_sprite.dragable vinculado à mesma flag DRAGGABLE
#     • Jogador não pode mais mover a HUD ou a barra de EXP
#   v2.1.0 — Ajustes visuais finais:
#     • BAR_WIDTH 123 → 140 (evita truncamento de texto HP/MP)
#     • LEVEL_W 30 → 100 (espaço suficiente para "Lv. 99")
#     • BAR_HP_Y 2 → 6 (margem interna superior)
#     • BAR_MP_Y 30 → 36 (espaçamento uniforme entre barras)
#     • EXP_HEIGHT 22 → 18 (barra de EXP mais fina e elegante)
#     • HUD_HEIGHT 107 → 110 (leve expansão para acomodar level)
#     • LEVEL_Y 83 → 88 (reposicionado dentro da área útil)
#     • Sombra no texto HP/MP/Level (shadow offset +1px)
#     • Borda colorida na barra de EXP (cor dourada mais vibrante)
#   v2.0.1 — EXP bar: texto alterado para percentual centralizado
#             (estilo Fields Online). Remove rótulo "EXP" lateral.
#==============================================================================

#==============================================================================
# ** HUD_Config
#------------------------------------------------------------------------------
# Módulo de configuração central da HUD principal.
# Ajuste as constantes abaixo para personalizar posição, cores e fontes.
#==============================================================================
module HUD_Config

  # ── Posição e dimensões ──────────────────────────────────────
  HUD_X      = 11          # Posição X da HUD na tela
  HUD_Y      = 9           # Posição Y da HUD na tela
  HUD_Z      = 50          # Profundidade (z-order) da HUD
  HUD_WIDTH  = 255         # Largura total do painel da HUD
  HUD_HEIGHT = 110         # Altura total do painel da HUD

  # ── Retrato ──────────────────────────────────────────────────
  FACE_X    = 8            # Posição X do retrato dentro da HUD
  FACE_Y    = 1            # Posição Y do retrato dentro da HUD
  FACE_SIZE = 96           # Tamanho (largura e altura) do retrato
  SHOW_FACE = true         # Exibe o retrato do personagem?

  # ── Barras HP/MP ─────────────────────────────────────────────
  BAR_X      = 107         # Posição X das barras HP e MP
  BAR_HP_Y   = 6           # Posição Y da barra de HP
  BAR_MP_Y   = 36          # Posição Y da barra de MP (BAR_HP_Y + BAR_SPACING)
  BAR_WIDTH  = 140         # Largura das barras HP e MP
  BAR_HEIGHT = 26          # Altura das barras HP e MP
  BAR_SPACING = 30         # Espaço vertical entre as barras HP e MP (BAR_MP_Y = BAR_HP_Y + BAR_SPACING)

  # ── Barra EXP ────────────────────────────────────────────────
  EXP_WIDTH   = 308        # Largura da barra de experiência
  EXP_HEIGHT  = 18         # Altura da barra de experiência
  EXP_FIXED_X = nil        # X fixo da barra EXP (nil = centralizado automaticamente)
  EXP_FIXED_Y = nil        # Y fixo da barra EXP (nil = rodapé automático)

  # ── Nível ────────────────────────────────────────────────────
  LEVEL_X = 107            # Posição X do texto de nível
  LEVEL_Y = 88             # Posição Y do texto de nível
  LEVEL_W = 100            # Largura da área de texto do nível

  # ── Fonte ────────────────────────────────────────────────────
  FONT_NAME = 'Arial'      # Nome da fonte usada na HUD
  FONT_SIZE = 18           # Tamanho da fonte
  FONT_BOLD = true         # Fonte em negrito?

  # ── Visibilidade ─────────────────────────────────────────────
  SHOW_HP    = true        # Exibe a barra de HP?
  SHOW_MP    = true        # Exibe a barra de MP?
  SHOW_EXP   = true        # Exibe a barra de EXP?
  SHOW_LEVEL = true        # Exibe o nível do personagem?

  # ── Fundo ────────────────────────────────────────────────────
  USE_BACKGROUND = true    # Exibe o fundo semitransparente da HUD?

  # ── Movimento ────────────────────────────────────────────────
  DRAGGABLE = false        # Permite arrastar a HUD com o mouse?

  # ── Cores — HP ───────────────────────────────────────────────
  COLOR_HP_BORDER = Color.new( 60,   0,   0, 255)  # Borda da barra de HP
  COLOR_HP_BG     = Color.new( 80,  10,  10, 200)  # Fundo da barra de HP
  COLOR_HP_FILL   = Color.new(220,  50,  50, 255)  # Preenchimento normal de HP
  COLOR_HP_LOW    = Color.new(255,  80,   0, 255)  # Preenchimento de HP crítico
  HP_CRITICAL_THRESHOLD = 0.25  # Percentual de HP abaixo do qual a cor crítica é usada

  # ── Cores — MP ───────────────────────────────────────────────
  COLOR_MP_BORDER = Color.new(  0,  10,  60, 255)  # Borda da barra de MP
  COLOR_MP_BG     = Color.new( 10,  20,  80, 200)  # Fundo da barra de MP
  COLOR_MP_FILL   = Color.new( 50, 100, 220, 255)  # Preenchimento da barra de MP

  # ── Cores — EXP ──────────────────────────────────────────────
  COLOR_EXP_BORDER = Color.new(180, 140,   0, 255)  # Borda da barra de EXP
  COLOR_EXP_BG     = Color.new( 20,  20,  20, 200)  # Fundo da barra de EXP
  COLOR_EXP_FILL   = Color.new(200, 150,  30, 255)  # Preenchimento da barra de EXP

  # ── Cores — Fundo e textos ────────────────────────────────────
  COLOR_HUD_BG      = Color.new(  0,   0,   0, 160)  # Fundo semitransparente da HUD
  COLOR_TEXT_HP     = Color.new(255, 255, 255, 255)  # Cor do texto de HP
  COLOR_TEXT_MP     = Color.new(200, 220, 255, 255)  # Cor do texto de MP
  COLOR_TEXT_EXP    = Color.new(255, 220,  80, 255)  # Cor do texto de EXP
  COLOR_TEXT_LEVEL  = Color.new(255, 220,  80, 255)  # Cor do texto de nível
  COLOR_TEXT_SHADOW = Color.new(  0,   0,   0, 180)  # Cor da sombra dos textos

  # ── Rótulos de texto ─────────────────────────────────────────
  HP_LABEL = 'HP'          # Rótulo exibido na barra de HP
  MP_LABEL = 'MP'          # Rótulo exibido na barra de MP

  # ── Sombra de texto ──────────────────────────────────────────
  SHADOW_OFFSET = 1        # Deslocamento em pixels da sombra dos textos (X e Y)

end # module HUD_Config

#==============================================================================
# ** Sprite_HUD
#------------------------------------------------------------------------------
# Sprite principal da HUD. Exibe HP, MP, EXP, face e nível do jogador.
# Herda de Sprite2 para compatibilidade com o sistema VXA-OS.
#==============================================================================
class Sprite_HUD < Sprite2
  include HUD_Config
  attr_reader :exp_sprite

  #--------------------------------------------------------------------------
  # * Inicialização
  #--------------------------------------------------------------------------
  def initialize
    super
    self.bitmap = Bitmap.new(HUD_WIDTH, HUD_HEIGHT)
    self.x = HUD_X
    self.y = HUD_Y
    self.z = HUD_Z
    apply_font(self.bitmap)
    create_exp_bar
    refresh
    change_opacity
  end

  #--------------------------------------------------------------------------
  # * Controle de arrasto — respeita a flag DRAGGABLE
  #--------------------------------------------------------------------------
  def dragable
    super if DRAGGABLE
  end

  #--------------------------------------------------------------------------
  # * Liberação de recursos
  #--------------------------------------------------------------------------
  def dispose
    @exp_sprite.bitmap.dispose if @exp_sprite && !@exp_sprite.bitmap.disposed?
    @exp_sprite.dispose if @exp_sprite && !@exp_sprite.disposed?
    super
  end

  #--------------------------------------------------------------------------
  # * Aplica configurações de fonte ao bitmap informado
  #--------------------------------------------------------------------------
  def apply_font(bmp)
    bmp.font.name = FONT_NAME
    bmp.font.size = FONT_SIZE
    bmp.font.bold = FONT_BOLD
  end

  #--------------------------------------------------------------------------
  # * Cria o sprite da barra de EXP (posicionado separadamente)
  #--------------------------------------------------------------------------
  def create_exp_bar
    @exp_sprite = Sprite2.new
    @exp_sprite.bitmap = Bitmap.new(EXP_WIDTH, EXP_HEIGHT)
    apply_font(@exp_sprite.bitmap)
    @exp_sprite.x = adjust_x
    @exp_sprite.y = adjust_y
    @exp_sprite.z = HUD_Z + 1
    @exp_sprite.dragable = DRAGGABLE
    @exp_sprite.visible = SHOW_EXP
    @exp_sprite.change_opacity
  end

  #--------------------------------------------------------------------------
  # * Calcula posição X da barra de EXP (centralizada ou fixa)
  #--------------------------------------------------------------------------
  def adjust_x
    EXP_FIXED_X || (Graphics.width / 2 - EXP_WIDTH / 2)
  end

  #--------------------------------------------------------------------------
  # * Calcula posição Y da barra de EXP (rodapé ou fixa)
  #--------------------------------------------------------------------------
  def adjust_y
    EXP_FIXED_Y || (Graphics.height - EXP_HEIGHT - 4)
  end

  #--------------------------------------------------------------------------
  # * Redesenha todos os elementos da HUD
  #--------------------------------------------------------------------------
  def refresh
    self.bitmap.clear
    draw_background if USE_BACKGROUND
    draw_face       if SHOW_FACE
    draw_hp_bar     if SHOW_HP
    draw_mp_bar     if SHOW_MP
    draw_exp_bar    if SHOW_EXP
    draw_level      if SHOW_LEVEL
  end

  #--------------------------------------------------------------------------
  # * Desenha o fundo semitransparente da HUD
  #--------------------------------------------------------------------------
  def draw_background
    self.bitmap.fill_rect(0, 0, HUD_WIDTH, HUD_HEIGHT, COLOR_HUD_BG)
  end

  #--------------------------------------------------------------------------
  # * Desenha o retrato (face) do personagem
  #--------------------------------------------------------------------------
  def draw_face
    actor = $game_actors[1]
    return unless actor
    face_bmp   = Cache.face(actor.face_name)
    face_index = actor.face_index
    src_x      = (face_index % 4) * 96
    src_y      = (face_index / 4) * 96
    src_rect   = Rect.new(src_x, src_y, 96, 96)
    dest_rect  = Rect.new(FACE_X, FACE_Y, FACE_SIZE, FACE_SIZE)
    self.bitmap.stretch_blt(dest_rect, face_bmp, src_rect)
    face_bmp.dispose
  end

  #--------------------------------------------------------------------------
  # * Desenha a barra de HP com rótulo e valores
  #--------------------------------------------------------------------------
  def draw_hp_bar
    actor = $game_actors[1]
    return unless actor
    bmp    = self.bitmap
    w      = BAR_WIDTH
    h      = BAR_HEIGHT
    x      = BAR_X
    y      = BAR_HP_Y
    ratio  = actor.mhp > 0 ? actor.hp.to_f / actor.mhp : 0.0
    fill_w = (w * ratio).to_i
    # Usa cor crítica quando HP está abaixo do limiar configurado
    fill_color = ratio < HP_CRITICAL_THRESHOLD ? COLOR_HP_LOW : COLOR_HP_FILL
    bmp.fill_rect(x,     y,     w,     h,     COLOR_HP_BORDER)
    bmp.fill_rect(x + 1, y + 1, w - 2, h - 2, COLOR_HP_BG)
    bmp.fill_rect(x + 1, y + 1, [fill_w - 2, 0].max, h - 2, fill_color)
    # Sombra do rótulo HP
    bmp.font.color = COLOR_TEXT_SHADOW
    bmp.draw_text(x + SHADOW_OFFSET, y + SHADOW_OFFSET, w, h, HP_LABEL, 0)
    bmp.font.color = COLOR_TEXT_HP
    bmp.draw_text(x, y, w, h, HP_LABEL, 0)
    # Sombra dos valores HP
    hp_text = " #{actor.hp} / #{actor.mhp}"
    bmp.font.color = COLOR_TEXT_SHADOW
    bmp.draw_text(x + SHADOW_OFFSET, y + SHADOW_OFFSET, w, h, hp_text, 2)
    bmp.font.color = COLOR_TEXT_HP
    bmp.draw_text(x, y, w, h, hp_text, 2)
  end

  #--------------------------------------------------------------------------
  # * Desenha a barra de MP com rótulo e valores
  #--------------------------------------------------------------------------
  def draw_mp_bar
    actor = $game_actors[1]
    return unless actor
    bmp    = self.bitmap
    w      = BAR_WIDTH
    h      = BAR_HEIGHT
    x      = BAR_X
    y      = BAR_MP_Y
    ratio  = actor.mmp > 0 ? actor.mp.to_f / actor.mmp : 0.0
    fill_w = (w * ratio).to_i
    bmp.fill_rect(x,     y,     w,     h,     COLOR_MP_BORDER)
    bmp.fill_rect(x + 1, y + 1, w - 2, h - 2, COLOR_MP_BG)
    bmp.fill_rect(x + 1, y + 1, [fill_w - 2, 0].max, h - 2, COLOR_MP_FILL)
    # Sombra do rótulo MP
    bmp.font.color = COLOR_TEXT_SHADOW
    bmp.draw_text(x + SHADOW_OFFSET, y + SHADOW_OFFSET, w, h, MP_LABEL, 0)
    bmp.font.color = COLOR_TEXT_MP
    bmp.draw_text(x, y, w, h, MP_LABEL, 0)
    # Sombra dos valores MP
    mp_text = " #{actor.mp} / #{actor.mmp}"
    bmp.font.color = COLOR_TEXT_SHADOW
    bmp.draw_text(x + SHADOW_OFFSET, y + SHADOW_OFFSET, w, h, mp_text, 2)
    bmp.font.color = COLOR_TEXT_MP
    bmp.draw_text(x, y, w, h, mp_text, 2)
  end

  #--------------------------------------------------------------------------
  # * Desenha o nível do personagem com sombra
  #--------------------------------------------------------------------------
  def draw_level
    actor = $game_actors[1]
    return unless actor
    bmp     = self.bitmap
    lv_text = "Lv. #{actor.level}"
    # Sombra do texto de nível
    bmp.font.color = COLOR_TEXT_SHADOW
    bmp.draw_text(LEVEL_X + SHADOW_OFFSET, LEVEL_Y + SHADOW_OFFSET, LEVEL_W, FONT_SIZE + 2, lv_text, 0)
    bmp.font.color = COLOR_TEXT_LEVEL
    bmp.draw_text(LEVEL_X, LEVEL_Y, LEVEL_W, FONT_SIZE + 2, lv_text, 0)
  end

  #--------------------------------------------------------------------------
  # * Desenha a barra de EXP com percentual centralizado
  #--------------------------------------------------------------------------
  def draw_exp_bar
    actor = $game_actors[1]
    return unless actor
    bmp    = @exp_sprite.bitmap
    w      = EXP_WIDTH
    h      = EXP_HEIGHT
    bmp.clear
    at_max = actor.level >= Configs::MAX_LEVEL
    ratio  = at_max ? 1.0 : actor.now_exp.to_f / [actor.next_exp, 1].max
    fill_w = (w * ratio).to_i
    bmp.fill_rect(0, 0, w, h, COLOR_EXP_BORDER)
    bmp.fill_rect(2, 2, w - 4, h - 4, COLOR_EXP_BG)
    bmp.fill_rect(2, 2, [fill_w - 4, 0].max, h - 4, COLOR_EXP_FILL)
    exp_pct  = (ratio * 100).round(2)
    exp_text = at_max ? Vocab::MaxLevel : " #{exp_pct}%"
    # Sombra do texto de EXP
    bmp.font.color = COLOR_TEXT_SHADOW
    bmp.draw_text(SHADOW_OFFSET, SHADOW_OFFSET, w, h, exp_text, 1)
    bmp.font.color = COLOR_TEXT_EXP
    bmp.draw_text(0, 0, w, h, exp_text, 1)
  end

  #--------------------------------------------------------------------------
  # * Atualização por frame
  #--------------------------------------------------------------------------
  def update
    super
    @exp_sprite.update
    @exp_sprite.change_opacity
  end

end # class Sprite_HUD