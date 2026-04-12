#==============================================================================
# ** [VS] Sprite_HUD — Fields Online
#------------------------------------------------------------------------------
# Exibe HP, MP, EXP, face e nível do jogador na HUD principal.
# Barras desenhadas inteiramente via código (sem assets externos).
#------------------------------------------------------------------------------
# Autor Original : Valentine
# Modernizado por: Caio Juan De Lima Silva
# Revisão        : Aura AI
# Versão         : 2.1.0
# Data           : 12/04/2026
# Changelog      :
#   v2.1.0 — Ajustes visuais finais:
#              • BAR_WIDTH 123 → 140 (evita truncamento de texto HP/MP)
#              • LEVEL_W 30 → 100 (espaço suficiente para "Lv. 99")
#              • BAR_HP_Y 2 → 6 (margem interna superior)
#              • BAR_MP_Y 30 → 36 (espaçamento uniforme entre barras)
#              • EXP_HEIGHT 22 → 18 (barra de EXP mais fina e elegante)
#              • HUD_HEIGHT 107 → 110 (leve expansão para acomodar level)
#              • LEVEL_Y 83 → 88 (reposicionado dentro da área útil)
#              • Sombra no texto HP/MP/Level (shadow offset +1px)
#              • Borda colorida na barra de EXP (cor dourada mais vibrante)
#   v2.0.1 — EXP bar: texto alterado para percentual centralizado
#              (estilo Fields Online). Remove rótulo "EXP" lateral.
#==============================================================================

#==============================================================================
# ** HUD_Config
#------------------------------------------------------------------------------
# Módulo de configuração centralizada da HUD principal.
# Todos os valores visuais e de comportamento são definidos aqui.
#==============================================================================
module HUD_Config
  # Posição e dimensões do painel principal
  HUD_X      = 11     # Posição X do painel na tela
  HUD_Y      = 9      # Posição Y do painel na tela
  HUD_Z      = 50     # Z-order do painel
  HUD_WIDTH  = 255    # Largura total do painel
  HUD_HEIGHT = 110    # Altura total do painel (v2.1.0: +3px para acomodar level)

  # Retrato do personagem
  FACE_X    = 8       # Posição X do retrato dentro do painel
  FACE_Y    = 1       # Posição Y do retrato dentro do painel
  FACE_SIZE = 96      # Tamanho do retrato em pixels (quadrado)
  SHOW_FACE = true    # true = exibe retrato; false = oculta

  # Barras de HP e MP
  BAR_X      = 107    # Posição X das barras dentro do painel
  BAR_HP_Y   = 6      # Posição Y da barra de HP (v2.1.0: margem interna +4px)
  BAR_MP_Y   = 36     # Posição Y da barra de MP (v2.1.0: espaçamento uniforme)
  BAR_WIDTH  = 140    # Largura das barras (v2.1.0: 123→140, evita truncamento)
  BAR_HEIGHT = 26     # Altura das barras de HP e MP

  # Barra de EXP (rodapé da tela)
  EXP_WIDTH   = 308   # Largura da barra de EXP
  EXP_HEIGHT  = 18    # Altura da barra de EXP (v2.1.0: 22→18, mais elegante)
  EXP_FIXED_X = nil   # nil = centralizado automaticamente
  EXP_FIXED_Y = nil   # nil = posicionado no rodapé automaticamente

  # Nível do personagem
  LEVEL_X = 107       # Posição X do texto de nível
  LEVEL_Y = 88        # Posição Y do texto de nível (v2.1.0: dentro da área útil)
  LEVEL_W = 100       # Largura da área de nível (v2.1.0: 30→100 para "Lv. 99")

  # Fonte
  FONT_NAME = 'Arial' # Nome da fonte
  FONT_SIZE = 18      # Tamanho da fonte
  FONT_BOLD = true    # true = negrito

  # Visibilidade dos elementos
  SHOW_HP    = true   # Exibe barra de HP
  SHOW_MP    = true   # Exibe barra de MP
  SHOW_EXP   = true   # Exibe barra de EXP
  SHOW_LEVEL = true   # Exibe nível do personagem

  # Fundo semitransparente
  USE_BACKGROUND = true

  # Cores — HP
  COLOR_HP_BORDER = Color.new(60,  0,   0,   255)
  COLOR_HP_BG     = Color.new(80,  10,  10,  200)
  COLOR_HP_FILL   = Color.new(220, 50,  50,  255)
  COLOR_HP_LOW    = Color.new(255, 80,  0,   255)  # HP crítico < 25%

  # Cores — MP
  COLOR_MP_BORDER = Color.new(0,   10,  60,  255)
  COLOR_MP_BG     = Color.new(10,  20,  80,  200)
  COLOR_MP_FILL   = Color.new(50,  100, 220, 255)

  # Cores — EXP (v2.1.0: dourado mais vibrante)
  COLOR_EXP_BORDER = Color.new(180, 140, 0,   255)  # Borda dourada vibrante
  COLOR_EXP_BG     = Color.new(20,  20,  20,  200)
  COLOR_EXP_FILL   = Color.new(200, 150, 30,  255)

  # Fundo do painel
  COLOR_HUD_BG = Color.new(0, 0, 0, 160)

  # Cores dos textos
  COLOR_TEXT_HP     = Color.new(255, 255, 255, 255)
  COLOR_TEXT_MP     = Color.new(200, 220, 255, 255)
  COLOR_TEXT_EXP    = Color.new(255, 220, 80,  255)
  COLOR_TEXT_LEVEL  = Color.new(255, 220, 80,  255)
  COLOR_TEXT_SHADOW = Color.new(0,   0,   0,   180)  # v2.1.0: sombra no texto
end

#==============================================================================
# ** Sprite_HUD
#------------------------------------------------------------------------------
# Sprite principal da HUD. Herda de Sprite2 (VXA-OS) para suporte a
# drag, opacidade e ciclo de vida gerenciado pelo sistema.
#==============================================================================
class Sprite_HUD < Sprite2
  include HUD_Config

  # Expõe o sprite da barra de EXP para acesso externo (ex.: reposicionamento)
  attr_reader :exp_sprite

  #---initialize: cria o sprite da HUD, bitmap, posição e sub-elementos---#
  def initialize
    super
    # Cria o bitmap principal com as dimensões configuradas
    self.bitmap = Bitmap.new(HUD_WIDTH, HUD_HEIGHT)
    # Posiciona o painel na tela conforme configuração
    self.x = HUD_X
    self.y = HUD_Y
    self.z = HUD_Z
    # Aplica configurações de fonte ao bitmap principal
    apply_font(self.bitmap)
    # Cria o sprite separado da barra de EXP (rodapé)
    create_exp_bar
    # Desenha todos os elementos visuais pela primeira vez
    refresh
    # Aplica opacidade inicial (método herdado de Sprite2)
    change_opacity
  end

  #---dispose: libera todos os recursos de bitmap e sprites da HUD---#
  def dispose
    # Libera o bitmap da barra de EXP antes de descartar o sprite
    @exp_sprite.bitmap.dispose if @exp_sprite && !@exp_sprite.bitmap.disposed?
    # Descarta o sprite da barra de EXP
    @exp_sprite.dispose if @exp_sprite && !@exp_sprite.disposed?
    # Chama dispose da classe pai (Sprite2), que libera o bitmap principal
    super
  end

  #---apply_font: configura nome, tamanho e estilo da fonte no bitmap---#
  def apply_font(bmp)
    bmp.font.name = FONT_NAME
    bmp.font.size = FONT_SIZE
    bmp.font.bold = FONT_BOLD
  end

  #---create_exp_bar: instancia e posiciona o sprite da barra de EXP---#
  def create_exp_bar
    @exp_sprite          = Sprite2.new
    @exp_sprite.bitmap   = Bitmap.new(EXP_WIDTH, EXP_HEIGHT)
    # Aplica a mesma fonte do painel principal à barra de EXP
    apply_font(@exp_sprite.bitmap)
    # Posiciona horizontalmente (centralizado ou fixo)
    @exp_sprite.x        = adjust_x
    # Posiciona verticalmente (rodapé ou fixo)
    @exp_sprite.y        = adjust_y
    # Mantém a barra de EXP acima do painel principal
    @exp_sprite.z        = HUD_Z + 1
    # Permite que o jogador arraste a barra de EXP pela tela
    @exp_sprite.dragable = true
    # Visibilidade controlada pela flag de configuração
    @exp_sprite.visible  = SHOW_EXP
    # Aplica opacidade inicial
    @exp_sprite.change_opacity
  end

  #---adjust_x: calcula posição X da barra de EXP (centralizada ou fixa)---#
  def adjust_x
    # Usa valor fixo se definido; caso contrário, centraliza na tela
    EXP_FIXED_X || (Graphics.width / 2 - EXP_WIDTH / 2)
  end

  #---adjust_y: calcula posição Y da barra de EXP (rodapé ou fixa)---#
  def adjust_y
    # Usa valor fixo se definido; caso contrário, posiciona no rodapé com margem
    EXP_FIXED_Y || (Graphics.height - EXP_HEIGHT - 4)
  end

  #---refresh: redesenha todos os elementos visuais da HUD---#
  def refresh
    # Limpa o bitmap principal antes de redesenhar
    self.bitmap.clear
    # Fundo semitransparente do painel (se habilitado)
    draw_background if USE_BACKGROUND
    # Retrato do personagem
    draw_face       if SHOW_FACE
    # Barra e texto de HP
    draw_hp_bar     if SHOW_HP
    # Barra e texto de MP
    draw_mp_bar     if SHOW_MP
    # Barra de EXP no rodapé
    draw_exp_bar    if SHOW_EXP
    # Texto de nível do personagem
    draw_level      if SHOW_LEVEL
  end

  #---draw_background: preenche o fundo do painel com cor semitransparente---#
  def draw_background
    self.bitmap.fill_rect(0, 0, HUD_WIDTH, HUD_HEIGHT, COLOR_HUD_BG)
  end

  #---draw_face: renderiza o retrato (face) do personagem no painel---#
  def draw_face
    actor = $game_actors[1]
    return unless actor
    # Carrega o arquivo de faces do personagem
    face_bmp = Cache.face(actor.face_name)
    # Cada face ocupa 96x96 pixels; calcula a posição no arquivo de faces
    face_index = actor.face_index
    src_x = (face_index % 4) * 96
    src_y = (face_index / 4) * 96
    src_rect = Rect.new(src_x, src_y, 96, 96)
    # Desenha o retrato redimensionado para FACE_SIZE×FACE_SIZE
    dest_rect = Rect.new(FACE_X, FACE_Y, FACE_SIZE, FACE_SIZE)
    self.bitmap.stretch_blt(dest_rect, face_bmp, src_rect)
    face_bmp.dispose
  end

  #---draw_hp_bar: desenha a barra de HP com borda, fundo, preenchimento e texto---#
  def draw_hp_bar
    actor = $game_actors[1]
    return unless actor
    bmp = self.bitmap
    w   = BAR_WIDTH
    h   = BAR_HEIGHT
    x   = BAR_X
    y   = BAR_HP_Y
    # Calcula a proporção atual de HP (0.0 a 1.0)
    ratio  = actor.mhp > 0 ? actor.hp.to_f / actor.mhp : 0.0
    fill_w = (w * ratio).to_i
    # Seleciona cor de preenchimento: vermelho crítico se HP < 25%
    fill_color = ratio < 0.25 ? COLOR_HP_LOW : COLOR_HP_FILL
    # --- Desenha a barra ---
    # Borda externa
    bmp.fill_rect(x, y, w, h, COLOR_HP_BORDER)
    # Fundo interno (1px de margem para a borda)
    bmp.fill_rect(x + 1, y + 1, w - 2, h - 2, COLOR_HP_BG)
    # Preenchimento proporcional ao HP atual
    bmp.fill_rect(x + 1, y + 1, [fill_w - 2, 0].max, h - 2, fill_color)
    # --- Rótulo "HP" à esquerda com sombra ---
    bmp.font.color = COLOR_TEXT_SHADOW
    bmp.draw_text(x + 1, y + 1, w, h, 'HP', 0)
    bmp.font.color = COLOR_TEXT_HP
    bmp.draw_text(x, y, w, h, 'HP', 0)
    # --- Valor "atual / máximo" à direita com sombra ---
    hp_text = "#{actor.hp} / #{actor.mhp}"
    bmp.font.color = COLOR_TEXT_SHADOW
    bmp.draw_text(x + 1, y + 1, w, h, hp_text, 2)
    bmp.font.color = COLOR_TEXT_HP
    bmp.draw_text(x, y, w, h, hp_text, 2)
  end

  #---draw_mp_bar: desenha a barra de MP com borda, fundo, preenchimento e texto---#
  def draw_mp_bar
    actor = $game_actors[1]
    return unless actor
    bmp = self.bitmap
    w   = BAR_WIDTH
    h   = BAR_HEIGHT
    x   = BAR_X
    y   = BAR_MP_Y
    # Calcula a proporção atual de MP (0.0 a 1.0)
    ratio  = actor.mmp > 0 ? actor.mp.to_f / actor.mmp : 0.0
    fill_w = (w * ratio).to_i
    # --- Desenha a barra ---
    # Borda externa
    bmp.fill_rect(x, y, w, h, COLOR_MP_BORDER)
    # Fundo interno (1px de margem para a borda)
    bmp.fill_rect(x + 1, y + 1, w - 2, h - 2, COLOR_MP_BG)
    # Preenchimento proporcional ao MP atual
    bmp.fill_rect(x + 1, y + 1, [fill_w - 2, 0].max, h - 2, COLOR_MP_FILL)
    # --- Rótulo "MP" à esquerda com sombra ---
    bmp.font.color = COLOR_TEXT_SHADOW
    bmp.draw_text(x + 1, y + 1, w, h, 'MP', 0)
    bmp.font.color = COLOR_TEXT_MP
    bmp.draw_text(x, y, w, h, 'MP', 0)
    # --- Valor "atual / máximo" à direita com sombra ---
    mp_text = "#{actor.mp} / #{actor.mmp}"
    bmp.font.color = COLOR_TEXT_SHADOW
    bmp.draw_text(x + 1, y + 1, w, h, mp_text, 2)
    bmp.font.color = COLOR_TEXT_MP
    bmp.draw_text(x, y, w, h, mp_text, 2)
  end

  #---draw_level: exibe o nível do personagem com sombra e cor dourada---#
  def draw_level
    actor = $game_actors[1]
    return unless actor
    bmp       = self.bitmap
    lv_text   = "Lv. #{actor.level}"
    # --- Sombra do texto de nível (offset +1,+1) ---
    bmp.font.color = COLOR_TEXT_SHADOW
    bmp.draw_text(LEVEL_X + 1, LEVEL_Y + 1, LEVEL_W, FONT_SIZE + 2, lv_text, 0)
    # --- Texto de nível em dourado ---
    bmp.font.color = COLOR_TEXT_LEVEL
    bmp.draw_text(LEVEL_X, LEVEL_Y, LEVEL_W, FONT_SIZE + 2, lv_text, 0)
  end

  #---draw_exp_bar: desenha a barra de EXP com borda dourada e percentual centralizado---#
  def draw_exp_bar
    actor = $game_actors[1]
    return unless actor
    bmp = @exp_sprite.bitmap
    w   = EXP_WIDTH
    h   = EXP_HEIGHT
    # Limpa o bitmap da barra de EXP antes de redesenhar
    bmp.clear
    # Verifica se o personagem atingiu o nível máximo
    at_max = actor.level >= Configs::MAX_LEVEL
    # Calcula a proporção de EXP (1.0 se nível máximo)
    ratio  = at_max ? 1.0 : actor.now_exp.to_f / [actor.next_exp, 1].max
    fill_w = (w * ratio).to_i
    # --- Borda dourada com 2px de espessura (v2.1.0) ---
    # Preenche toda a área com a cor de borda
    bmp.fill_rect(0, 0, w, h, COLOR_EXP_BORDER)
    # Sobrepõe o interior com a cor de fundo (recuo de 2px em cada lado)
    bmp.fill_rect(2, 2, w - 4, h - 4, COLOR_EXP_BG)
    # --- Preenchimento proporcional à EXP atual ---
    # Respeita a margem interna de 2px da borda
    bmp.fill_rect(2, 2, [fill_w - 4, 0].max, h - 4, COLOR_EXP_FILL)
    # --- Texto percentual centralizado com sombra ---
    exp_pct  = (ratio * 100).round(2)
    exp_text = at_max ? Vocab::MaxLevel : "#{exp_pct}%"
    # Sombra do texto (offset +1,+1)
    bmp.font.color = COLOR_TEXT_SHADOW
    bmp.draw_text(1, 1, w, h, exp_text, 1)
    # Texto dourado centralizado
    bmp.font.color = COLOR_TEXT_EXP
    bmp.draw_text(0, 0, w, h, exp_text, 1)
  end

  #---update: atualiza a HUD e a barra de EXP a cada frame---#
  def update
    # Atualiza o sprite principal (Sprite2: drag, visibilidade, etc.)
    super
    # Atualiza o sprite da barra de EXP (drag, visibilidade, etc.)
    @exp_sprite.update
    # Sincroniza a opacidade da barra de EXP com o estado atual
    @exp_sprite.change_opacity
  end

end # class Sprite_HUD