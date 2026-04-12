#==============================================================================
# ** [VS] Sprite_HUD
#------------------------------------------------------------------------------
# Exibe HP, MP, EXP, face e nível do jogador na HUD principal.
# Barras desenhadas inteiramente via código (sem assets externos).
#------------------------------------------------------------------------------
# Autor Original : Valentine
# Modernizado por: Caio Juan De Lima Silva
# Revisão        : Aura AI
# Versão         : 2.0.1
# Data           : 12/04/2026
# Changelog      : v2.0.1 — EXP bar: texto alterado para percentual centralizado
#                            (estilo Fields Online). Remove rótulo "EXP" lateral.
#==============================================================================

module HUD_Config
  HUD_X      = 11
  HUD_Y      = 9
  HUD_Z      = 50
  HUD_WIDTH  = 255
  HUD_HEIGHT = 107
  FACE_X    = 8
  FACE_Y    = 1
  FACE_SIZE = 96
  SHOW_FACE = true
  BAR_X      = 107
  BAR_HP_Y   = 2
  BAR_MP_Y   = 30
  BAR_WIDTH  = 123
  BAR_HEIGHT = 26
  EXP_WIDTH   = 308
  EXP_HEIGHT  = 22
  EXP_FIXED_X = nil
  EXP_FIXED_Y = nil
  LEVEL_X = 0
  LEVEL_Y = 83
  LEVEL_W = 30
  FONT_NAME = 'Arial'
  FONT_SIZE = 18
  FONT_BOLD = true
  SHOW_HP    = true
  SHOW_MP    = true
  SHOW_EXP   = true
  SHOW_LEVEL = true
  USE_BACKGROUND = true
  COLOR_HP_BORDER  = Color.new(60,  0,   0,   255)
  COLOR_HP_BG      = Color.new(80,  10,  10,  200)
  COLOR_HP_FILL    = Color.new(220, 50,  50,  255)
  COLOR_HP_LOW     = Color.new(255, 80,  0,   255)
  COLOR_MP_BORDER  = Color.new(0,   10,  60,  255)
  COLOR_MP_BG      = Color.new(10,  20,  80,  200)
  COLOR_MP_FILL    = Color.new(50,  100, 220, 255)
  COLOR_EXP_BORDER = Color.new(60,  50,  0,   255)
  COLOR_EXP_BG     = Color.new(20,  20,  20,  200)
  COLOR_EXP_FILL   = Color.new(200, 150, 30,  255)
  COLOR_HUD_BG     = Color.new(0,   0,   0,   160)
  COLOR_TEXT_HP    = Color.new(255, 255, 255, 255)
  COLOR_TEXT_MP    = Color.new(200, 220, 255, 255)
  COLOR_TEXT_EXP   = Color.new(255, 220, 80,  255)
  COLOR_TEXT_LEVEL = Color.new(255, 220, 80,  255)
end

class Sprite_HUD < Sprite2
  include HUD_Config
  attr_reader :exp_sprite  # Expõe @exp_sprite para [VS] Scene_Map (linha 70)

  #---initialize: cria bitmap principal, barra de EXP e executa refresh inicial---#
  def initialize
    super
    self.bitmap = Bitmap.new(HUD_WIDTH, HUD_HEIGHT)
    self.x      = HUD_X
    self.y      = HUD_Y
    self.z      = HUD_Z
    apply_font(self.bitmap)
    create_exp_bar
    refresh
    change_opacity
  end

  #---dispose: libera bitmaps e sprites da HUD da memória---#
  def dispose
    @exp_sprite.bitmap.dispose
    @exp_sprite.dispose
    super
  end

  #---apply_font: aplica configurações de fonte ao bitmap informado---#
  def apply_font(bmp)
    bmp.font.name = FONT_NAME
    bmp.font.size = FONT_SIZE
    bmp.font.bold = FONT_BOLD
  end

  #---create_exp_bar: cria o sprite separado da barra de EXP na parte inferior---#
  def create_exp_bar
    @exp_sprite          = Sprite2.new
    @exp_sprite.bitmap   = Bitmap.new(EXP_WIDTH, EXP_HEIGHT)
    apply_font(@exp_sprite.bitmap)
    @exp_sprite.x        = adjust_x
    @exp_sprite.y        = adjust_y
    @exp_sprite.z        = HUD_Z
    @exp_sprite.dragable = true
    @exp_sprite.visible  = SHOW_EXP
    @exp_sprite.change_opacity
  end

  #---adjust_x: retorna posição X da barra de EXP (fixa ou centralizada)---#
  def adjust_x
    EXP_FIXED_X || (Graphics.width / 2 - EXP_WIDTH / 2)
  end

  #---adjust_y: retorna posição Y da barra de EXP (fixa ou na base da tela)---#
  def adjust_y
    EXP_FIXED_Y || (Graphics.height - EXP_HEIGHT - 4)
  end

  #---refresh: limpa e redesenha todos os elementos da HUD---#
  def refresh
    self.bitmap.clear
    draw_background if USE_BACKGROUND
    draw_face       if SHOW_FACE
    draw_hp_bar     if SHOW_HP
    draw_mp_bar     if SHOW_MP
    draw_exp_bar    if SHOW_EXP
    draw_level      if SHOW_LEVEL
  end

  #---draw_background: preenche o fundo semitransparente da HUD---#
  def draw_background
    self.bitmap.fill_rect(0, 0, HUD_WIDTH, HUD_HEIGHT, COLOR_HUD_BG)
  end

  #---draw_face: desenha o rosto do ator principal redimensionado na HUD---#
  def draw_face
    actor      = $game_actors[1]
    face_index = actor.face_index
    face_name  = actor.face_name
    bitmap     = Cache.face(face_name)
    fw         = bitmap.width  / 4
    fh         = bitmap.height / 2
    src_x      = (face_index % 4) * fw
    src_y      = (face_index / 4) * fh
    src_rect   = Rect.new(src_x, src_y, fw, fh)
    dest_rect  = Rect.new(FACE_X, FACE_Y, FACE_SIZE, FACE_SIZE)
    self.bitmap.stretch_blt(dest_rect, bitmap, src_rect)
    bitmap.dispose
  end

  #---draw_hp_bar: desenha a barra de HP com borda, fundo, preenchimento e texto---#
  def draw_hp_bar
    actor = $game_actors[1]
    return if actor.mhp <= 0
    ratio      = actor.hp.to_f / actor.mhp
    fill_w     = (BAR_WIDTH * ratio).to_i
    fill_color = ratio < 0.25 ? COLOR_HP_LOW : COLOR_HP_FILL
    self.bitmap.fill_rect(BAR_X, BAR_HP_Y, BAR_WIDTH, BAR_HEIGHT, COLOR_HP_BORDER)
    self.bitmap.fill_rect(BAR_X + 1, BAR_HP_Y + 1, BAR_WIDTH - 2, BAR_HEIGHT - 2, COLOR_HP_BG)
    self.bitmap.fill_rect(BAR_X + 1, BAR_HP_Y + 1, fill_w - 2, BAR_HEIGHT - 2, fill_color) if fill_w > 2
    self.bitmap.font.color = COLOR_TEXT_HP
    self.bitmap.draw_text(BAR_X + 2, BAR_HP_Y + 4, BAR_WIDTH - 4, FONT_SIZE, Vocab.hp_a, 0)
    self.bitmap.draw_text(BAR_X + 2, BAR_HP_Y + 4, BAR_WIDTH - 4, FONT_SIZE,
                          "#{actor.hp}/#{actor.mhp}", 2)
  end

  #---draw_mp_bar: desenha a barra de MP com borda, fundo, preenchimento e texto---#
  def draw_mp_bar
    actor = $game_actors[1]
    return if actor.mmp <= 0
    ratio  = actor.mp.to_f / actor.mmp
    fill_w = (BAR_WIDTH * ratio).to_i
    self.bitmap.fill_rect(BAR_X, BAR_MP_Y, BAR_WIDTH, BAR_HEIGHT, COLOR_MP_BORDER)
    self.bitmap.fill_rect(BAR_X + 1, BAR_MP_Y + 1, BAR_WIDTH - 2, BAR_HEIGHT - 2, COLOR_MP_BG)
    self.bitmap.fill_rect(BAR_X + 1, BAR_MP_Y + 1, fill_w - 2, BAR_HEIGHT - 2, COLOR_MP_FILL) if fill_w > 2
    self.bitmap.font.color = COLOR_TEXT_MP
    self.bitmap.draw_text(BAR_X + 2, BAR_MP_Y + 4, BAR_WIDTH - 4, FONT_SIZE, Vocab.mp_a, 0)
    self.bitmap.draw_text(BAR_X + 2, BAR_MP_Y + 4, BAR_WIDTH - 4, FONT_SIZE,
                          "#{actor.mp}/#{actor.mmp}", 2)
  end

  #---draw_level: exibe o nível atual do ator na área inferior da HUD---#
  def draw_level
    actor = $game_actors[1]
    self.bitmap.font.color = COLOR_TEXT_LEVEL
    self.bitmap.draw_text(LEVEL_X, LEVEL_Y, LEVEL_W, FONT_SIZE, actor.level.to_s, 1)
  end

  #---update: atualiza a HUD e o sprite de EXP a cada frame---#
  def update
    super
    @exp_sprite.update
    @exp_sprite.change_opacity
  end

  #---draw_exp_bar: desenha a barra de EXP com percentual centralizado (v2.0.1)---#
  def draw_exp_bar
    actor  = $game_actors[1]
    @exp_sprite.bitmap.clear
    at_max = actor.level >= Configs::MAX_LEVEL
    ratio  = at_max ? 1.0 : actor.now_exp.to_f / [actor.next_exp, 1].max
    fill_w = (EXP_WIDTH * ratio).to_i
    @exp_sprite.bitmap.fill_rect(0, 0, EXP_WIDTH, EXP_HEIGHT, COLOR_EXP_BORDER)
    @exp_sprite.bitmap.fill_rect(1, 1, EXP_WIDTH - 2, EXP_HEIGHT - 2, COLOR_EXP_BG)
    @exp_sprite.bitmap.fill_rect(1, 1, fill_w - 2, EXP_HEIGHT - 2, COLOR_EXP_FILL) if fill_w > 2
    # v2.0.1 — Percentual centralizado (sem rótulo lateral "EXP")
    exp_pct  = (ratio * 100).round(2)
    exp_text = at_max ? Vocab::MaxLevel : "#{exp_pct}%"
    @exp_sprite.bitmap.font.color = COLOR_TEXT_EXP
    @exp_sprite.bitmap.draw_text(0, 2, EXP_WIDTH, FONT_SIZE, exp_text, 1)
  end

end # class Sprite_HUD