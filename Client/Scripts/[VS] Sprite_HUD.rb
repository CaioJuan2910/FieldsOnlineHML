#==============================================================================
# ** [VS] Sprite_HUD
#------------------------------------------------------------------------------
# Exibe HP, MP, EXP, face e nível do jogador na HUD principal.
# Barras desenhadas inteiramente via código (sem assets externos).
#------------------------------------------------------------------------------
# Autor Original : Valentine
# Modernizado por: Caio Juan De Lima Silva
# Revisão        : Aura AI
# Versão         : 2.0.0
# Data           : 11/04/2026
#==============================================================================

#==============================================================================
# ** HUD_Config — Bloco central de configurações
#------------------------------------------------------------------------------
# Ajuste aqui todas as opções visuais sem precisar editar o código interno.
#==============================================================================
module HUD_Config

  # --- Posição da HUD Principal ---
  HUD_X = 11          # Posição X da HUD na tela
  HUD_Y = 9           # Posição Y da HUD na tela
  HUD_Z = 50          # Profundidade Z (sobrepõe o mapa)

  # --- Dimensões do Bitmap Principal ---
  HUD_WIDTH  = 255    # Largura total do bitmap da HUD
  HUD_HEIGHT = 107    # Altura total do bitmap da HUD

  # --- Face do Personagem ---
  FACE_X    = 8       # Posição X da face dentro da HUD
  FACE_Y    = 1       # Posição Y da face dentro da HUD
  FACE_SIZE = 96      # Tamanho do recorte da face (96x96 px)
  SHOW_FACE = true    # true = exibe a face | false = oculta

  # --- Barras de HP e MP ---
  BAR_X      = 107    # Posição X das barras dentro do bitmap
  BAR_HP_Y   = 2      # Posição Y da barra de HP
  BAR_MP_Y   = 30     # Posição Y da barra de MP
  BAR_WIDTH  = 123    # Largura máxima das barras
  BAR_HEIGHT = 26     # Altura das barras

  # --- Barra de EXP (sprite separado, base da tela) ---
  EXP_WIDTH   = 308   # Largura da barra de EXP
  EXP_HEIGHT  = 22    # Altura da barra de EXP
  EXP_FIXED_X = nil   # nil = centralizado automaticamente | Integer = posição fixa
  EXP_FIXED_Y = nil   # nil = base da tela automaticamente | Integer = posição fixa

  # --- Nível do Personagem ---
  LEVEL_X = 0         # Posição X do texto de nível
  LEVEL_Y = 83        # Posição Y do texto de nível
  LEVEL_W = 30        # Largura do campo de nível

  # --- Fonte ---
  FONT_NAME = 'Arial' # Nome da fonte utilizada
  FONT_SIZE = 18      # Tamanho da fonte
  FONT_BOLD = true    # true = negrito | false = normal

  # --- Visibilidade dos Elementos ---
  SHOW_HP    = true   # Exibir barra de HP
  SHOW_MP    = true   # Exibir barra de MP
  SHOW_EXP   = true   # Exibir barra de EXP
  SHOW_LEVEL = true   # Exibir nível do personagem

  # --- Fundo Geral da HUD ---
  USE_BACKGROUND = true  # true = fundo escuro semitransparente | false = sem fundo

  #----------------------------------------------------------------------------
  # Cores — HP
  #----------------------------------------------------------------------------
  COLOR_HP_BORDER = Color.new( 60,   0,   0, 255)  # Borda externa da barra
  COLOR_HP_BG     = Color.new( 80,  10,  10, 200)  # Fundo interno da barra
  COLOR_HP_FILL   = Color.new(220,  50,  50, 255)  # Preenchimento normal
  COLOR_HP_LOW    = Color.new(255,  80,   0, 255)  # Preenchimento crítico (< 25%)

  #----------------------------------------------------------------------------
  # Cores — MP
  #----------------------------------------------------------------------------
  COLOR_MP_BORDER = Color.new(  0,  10,  60, 255)  # Borda externa da barra
  COLOR_MP_BG     = Color.new( 10,  20,  80, 200)  # Fundo interno da barra
  COLOR_MP_FILL   = Color.new( 50, 100, 220, 255)  # Preenchimento

  #----------------------------------------------------------------------------
  # Cores — EXP
  #----------------------------------------------------------------------------
  COLOR_EXP_BORDER = Color.new( 60,  50,   0, 255)  # Borda externa da barra
  COLOR_EXP_BG     = Color.new( 20,  20,  20, 200)  # Fundo interno da barra
  COLOR_EXP_FILL   = Color.new(200, 150,  30, 255)  # Preenchimento (dourado)

  #----------------------------------------------------------------------------
  # Cores — Fundo e Textos
  #----------------------------------------------------------------------------
  COLOR_HUD_BG     = Color.new(  0,   0,   0, 160)  # Fundo geral da HUD
  COLOR_TEXT_HP    = Color.new(255, 255, 255, 255)  # Texto da barra de HP
  COLOR_TEXT_MP    = Color.new(200, 220, 255, 255)  # Texto da barra de MP (azulado)
  COLOR_TEXT_EXP   = Color.new(255, 220,  80, 255)  # Texto da barra de EXP (dourado)
  COLOR_TEXT_LEVEL = Color.new(255, 220,  80, 255)  # Texto do nível (dourado)

end

#==============================================================================
# ** Sprite_HUD
#==============================================================================
class Sprite_HUD < Sprite2

  include HUD_Config

  attr_reader :exp_sprite

  #----------------------------------------------------------------------------
  # * Inicialização
  #----------------------------------------------------------------------------
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

  #----------------------------------------------------------------------------
  # * Liberação de memória
  #----------------------------------------------------------------------------
  def dispose
    super
    @exp_sprite.bitmap.dispose
    @exp_sprite.dispose
  end

  #----------------------------------------------------------------------------
  # * Aplica as configurações de fonte em um bitmap
  # @param bmp [Bitmap] bitmap alvo
  #----------------------------------------------------------------------------
  def apply_font(bmp)
    bmp.font.name = FONT_NAME
    bmp.font.size = FONT_SIZE
    bmp.font.bold = FONT_BOLD
  end

  #----------------------------------------------------------------------------
  # * Cria o sprite separado da barra de EXP (posicionada na base da tela)
  #----------------------------------------------------------------------------
  def create_exp_bar
    @exp_sprite          = Sprite2.new
    @exp_sprite.bitmap   = Bitmap.new(EXP_WIDTH, EXP_HEIGHT)
    apply_font(@exp_sprite.bitmap)
    @exp_sprite.x        = adjust_x
    @exp_sprite.y        = adjust_y
    @exp_sprite.dragable = true
    @exp_sprite.z        = HUD_Z
    @exp_sprite.visible  = SHOW_EXP
    @exp_sprite.change_opacity
  end

  #----------------------------------------------------------------------------
  # * Calcula a posição X da barra de EXP
  # @return [Integer] centralizado ou fixo via EXP_FIXED_X
  #----------------------------------------------------------------------------
  def adjust_x
    EXP_FIXED_X || (Graphics.width / 2 - EXP_WIDTH / 2)
  end

  #----------------------------------------------------------------------------
  # * Calcula a posição Y da barra de EXP
  # @return [Integer] base da tela ou fixo via EXP_FIXED_Y
  #----------------------------------------------------------------------------
  def adjust_y
    EXP_FIXED_Y || (Graphics.height - EXP_HEIGHT - 4)
  end

  #----------------------------------------------------------------------------
  # * Redesenha toda a HUD (chame após qualquer mudança de estado)
  #----------------------------------------------------------------------------
  def refresh
    self.bitmap.clear
    draw_background if USE_BACKGROUND
    draw_face       if SHOW_FACE
    draw_hp_bar     if SHOW_HP
    draw_mp_bar     if SHOW_MP
    draw_exp_bar    if SHOW_EXP
    draw_level      if SHOW_LEVEL
  end

  #----------------------------------------------------------------------------
  # * Desenha o fundo escuro semitransparente da HUD
  #----------------------------------------------------------------------------
  def draw_background
    self.bitmap.fill_rect(self.bitmap.rect, COLOR_HUD_BG)
  end

  #----------------------------------------------------------------------------
  # * Desenha a face do personagem
  #----------------------------------------------------------------------------
  def draw_face
    return if $game_actors[1].face_name.empty?
    face = Cache.face($game_actors[1].face_name)
    idx  = $game_actors[1].face_index
    rect = Rect.new(idx % 4 * 96, idx / 4 * 96, FACE_SIZE, FACE_SIZE)
    self.bitmap.blt(FACE_X, FACE_Y, face, rect)
  end

  #----------------------------------------------------------------------------
  # * Desenha a barra de HP inteiramente via código
  #   - Guard clause evita divisão por zero quando mhp == 0
  #   - Cor muda para HP_LOW quando HP está abaixo de 25%
  #----------------------------------------------------------------------------
  def draw_hp_bar
    actor = $game_actors[1]
    return if actor.mhp <= 0   # Guard: evita divisão por zero

    ratio      = actor.hp.to_f / actor.mhp
    fill_w     = (BAR_WIDTH * ratio).to_i
    fill_color = ratio < 0.25 ? COLOR_HP_LOW : COLOR_HP_FILL

    # Borda → Fundo → Preenchimento
    self.bitmap.fill_rect(BAR_X, BAR_HP_Y, BAR_WIDTH, BAR_HEIGHT, COLOR_HP_BORDER)
    self.bitmap.fill_rect(BAR_X + 1, BAR_HP_Y + 1, BAR_WIDTH - 2, BAR_HEIGHT - 2, COLOR_HP_BG)
    if fill_w > 2
      self.bitmap.fill_rect(BAR_X + 1, BAR_HP_Y + 1, fill_w - 2, BAR_HEIGHT - 2, fill_color)
    end

    # Texto
    self.bitmap.font.color = COLOR_TEXT_HP
    self.bitmap.draw_text(BAR_X + 4, BAR_HP_Y + 4, 25, FONT_SIZE, Vocab::hp_a)
    self.bitmap.draw_text(BAR_X, BAR_HP_Y + 4, BAR_WIDTH, FONT_SIZE,
                          "#{actor.hp}/#{actor.mhp}", 2)
  end

  #----------------------------------------------------------------------------
  # * Desenha a barra de MP inteiramente via código
  #   - Guard clause evita divisão por zero quando mmp == 0
  #----------------------------------------------------------------------------
  def draw_mp_bar
    actor = $game_actors[1]
    return if actor.mmp <= 0   # Guard: evita divisão por zero

    ratio  = actor.mp.to_f / actor.mmp
    fill_w = (BAR_WIDTH * ratio).to_i

    # Borda → Fundo → Preenchimento
    self.bitmap.fill_rect(BAR_X, BAR_MP_Y, BAR_WIDTH, BAR_HEIGHT, COLOR_MP_BORDER)
    self.bitmap.fill_rect(BAR_X + 1, BAR_MP_Y + 1, BAR_WIDTH - 2, BAR_HEIGHT - 2, COLOR_MP_BG)
    if fill_w > 2
      self.bitmap.fill_rect(BAR_X + 1, BAR_MP_Y + 1, fill_w - 2, BAR_HEIGHT - 2, COLOR_MP_FILL)
    end

    # Texto
    self.bitmap.font.color = COLOR_TEXT_MP
    self.bitmap.draw_text(BAR_X + 4, BAR_MP_Y + 4, 25, FONT_SIZE, Vocab::mp_a)
    self.bitmap.draw_text(BAR_X, BAR_MP_Y + 4, BAR_WIDTH, FONT_SIZE,
                          "#{actor.mp}/#{actor.mmp}", 2)
  end

  #----------------------------------------------------------------------------
  # * Desenha a barra de EXP inteiramente via código no sprite separado
  #   - Guard clause via [next_exp, 1].max evita divisão por zero
  #   - Exibe texto "MAX" quando nível máximo atingido
  #----------------------------------------------------------------------------
  def draw_exp_bar
    actor = $game_actors[1]
    @exp_sprite.bitmap.clear

    at_max   = actor.level >= Configs::MAX_LEVEL
    ratio    = at_max ? 1.0 : actor.now_exp.to_f / [actor.next_exp, 1].max
    fill_w   = (EXP_WIDTH * ratio).to_i
    exp_text = at_max ? Vocab::MaxLevel : format_number(actor.next_exp - actor.now_exp)

    # Borda → Fundo → Preenchimento
    @exp_sprite.bitmap.fill_rect(0, 0, EXP_WIDTH, EXP_HEIGHT, COLOR_EXP_BORDER)
    @exp_sprite.bitmap.fill_rect(1, 1, EXP_WIDTH - 2, EXP_HEIGHT - 2, COLOR_EXP_BG)
    if fill_w > 2
      @exp_sprite.bitmap.fill_rect(1, 1, fill_w - 2, EXP_HEIGHT - 2, COLOR_EXP_FILL)
    end

    # Texto
    @exp_sprite.bitmap.font.color = COLOR_TEXT_EXP
    @exp_sprite.bitmap.draw_text(4, 2, 25, FONT_SIZE, Vocab::Exp)
    @exp_sprite.bitmap.draw_text(0, 2, EXP_WIDTH, FONT_SIZE, exp_text, 1)
  end

  #----------------------------------------------------------------------------
  # * Desenha o nível do personagem
  #----------------------------------------------------------------------------
  def draw_level
    self.bitmap.font.color = COLOR_TEXT_LEVEL
    self.bitmap.draw_text(LEVEL_X, LEVEL_Y, LEVEL_W, FONT_SIZE,
                          $game_actors[1].level, 1)
  end

  #----------------------------------------------------------------------------
  # * Atualização por frame
  #----------------------------------------------------------------------------
  def update
    super
    @exp_sprite.update
    @exp_sprite.change_opacity
  end

end