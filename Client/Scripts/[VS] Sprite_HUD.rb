#==============================================================================
# ** Sprite_HUD
#------------------------------------------------------------------------------
# Esta classe lida com a exibição de HP, MP, experiência,
# face e nível do jogador.
#------------------------------------------------------------------------------
# Autor: Valentine
# Refatorado: uso de Configs para facilitar ajustes sem editar o script
#==============================================================================
class Sprite_HUD < Sprite2

  # Expõe o sprite da barra de EXP para acesso externo (ex: Scene_Map)
  attr_reader :exp_sprite

  #----------------------------------------------------------------------------
  # * Inicialização
  #   Cria o bitmap principal da HUD e o sprite separado da barra de EXP.
  #   Todas as dimensões e posições vêm de Configs.
  #----------------------------------------------------------------------------
  def initialize
    super
    # Cria o bitmap principal com dimensões definidas em Configs::HUD_WIDTH/HEIGHT
    self.bitmap       = Bitmap.new(Configs::HUD_WIDTH, Configs::HUD_HEIGHT)
    # Posição X da HUD na tela – ajuste em Configs::HUD_X
    self.x            = Configs::HUD_X
    # Posição Y da HUD na tela – ajuste em Configs::HUD_Y
    self.y            = Configs::HUD_Y
    # Profundidade de renderização – ajuste em Configs::HUD_Z
    self.z            = Configs::HUD_Z
    # Permite arrastar a HUD com o mouse (consistência com exp_sprite)
    self.dragable     = true
    # Tamanho da fonte definido em Configs::HUD_FONT_SIZE
    self.bitmap.font.size = Configs::HUD_FONT_SIZE
    # Negrito da fonte definido em Configs::HUD_FONT_BOLD
    self.bitmap.font.bold = Configs::HUD_FONT_BOLD
    # Carrega os gráficos da HUD da pasta Graphics/System
    @back = Cache.system('HUDBase')
    @bars = Cache.system('HUDBars')
    # Cria o sprite separado da barra de EXP
    create_exp_bar
    # Desenha todos os elementos pela primeira vez
    refresh
    # Aplica a opacidade inicial conforme configuração
    change_opacity
  end

  #----------------------------------------------------------------------------
  # * Dispose – libera bitmaps e sprites da memória ao destruir a HUD
  #----------------------------------------------------------------------------
  def dispose
    super
    # Libera o bitmap do sprite de EXP antes de destruir o sprite
    @exp_sprite.bitmap.dispose
    @exp_sprite.dispose
  end

  #----------------------------------------------------------------------------
  # * Cria a barra de EXP (sprite separado, centralizado na base da tela)
  #   Dimensões e offsets definidos em Configs::HUD_EXP_*
  #----------------------------------------------------------------------------
  def create_exp_bar
    @exp_sprite = Sprite2.new
    # Bitmap com largura e altura definidas em Configs::HUD_EXP_WIDTH/HEIGHT
    @exp_sprite.bitmap           = Bitmap.new(Configs::HUD_EXP_WIDTH, Configs::HUD_EXP_HEIGHT)
    # Herda o tamanho de fonte da HUD principal
    @exp_sprite.bitmap.font.size = Configs::HUD_FONT_SIZE
    # Herda o negrito da HUD principal
    @exp_sprite.bitmap.font.bold = Configs::HUD_FONT_BOLD
    # Posição X calculada: centro da tela + offset configurável
    @exp_sprite.x                = adjust_x
    # Posição Y calculada: base da tela + offset configurável
    @exp_sprite.y                = adjust_y
    # Permite arrastar a barra de EXP com o mouse
    @exp_sprite.dragable         = true
    # Mesma profundidade de renderização da HUD principal
    @exp_sprite.z                = self.z
    # Aplica opacidade inicial
    @exp_sprite.change_opacity
  end

  #----------------------------------------------------------------------------
  # * Posição X da barra de EXP: centralizada + offset configurável
  #   Configs::HUD_EXP_OFFSET_X controla o deslocamento horizontal
  #   Valor negativo move para a esquerda, positivo para a direita
  #----------------------------------------------------------------------------
  def adjust_x
    Graphics.width / 2 + Configs::HUD_EXP_OFFSET_X
  end

  #----------------------------------------------------------------------------
  # * Posição Y da barra de EXP: base da tela + offset configurável
  #   Configs::HUD_EXP_OFFSET_Y controla o deslocamento vertical
  #   Valor negativo move para cima (acima da borda inferior da tela)
  #----------------------------------------------------------------------------
  def adjust_y
    Graphics.height + Configs::HUD_EXP_OFFSET_Y
  end

  #----------------------------------------------------------------------------
  # * Redesenha todos os elementos visuais da HUD
  #   Chamado na inicialização e sempre que os dados do ator mudarem
  #----------------------------------------------------------------------------
  def refresh
    draw_background
    draw_face
    draw_hp_bar
    draw_mp_bar
    draw_exp_bar
    draw_level
  end

  #----------------------------------------------------------------------------
  # * Desenha o fundo da HUD usando o gráfico HUDBase
  #   Configs::HUD_BG_RECT_W e HUD_BG_RECT_H definem o recorte do sprite
  #   O offset de 7 pixels no X é para alinhar corretamente o gráfico
  #----------------------------------------------------------------------------
  def draw_background
    # Limpa o bitmap antes de redesenhar para evitar sobreposição
    self.bitmap.clear
    # Recorte do gráfico HUDBase para o fundo principal
    rect = Rect.new(0, 0, Configs::HUD_BG_RECT_W, Configs::HUD_BG_RECT_H)
    self.bitmap.blt(7, 0, @back, rect)
  end

  #----------------------------------------------------------------------------
  # * Desenha a face do personagem na HUD
  #   Configs::HUD_FACE_X/Y definem a posição dentro do bitmap da HUD
  #   Configs::HUD_ACTOR_INDEX determina qual ator é exibido (via método actor)
  #----------------------------------------------------------------------------
  def draw_face
    # Não desenha se o ator não tiver face configurada
    return if actor.face_name.empty?
    face = Cache.face(actor.face_name)
    # Calcula o recorte correto da face no spritesheet (grade 4x2 de 96x96)
    rect = Rect.new(
      actor.face_index % 4 * 96,  # Coluna da face no spritesheet
      actor.face_index / 4 * 96,  # Linha da face no spritesheet
      96, 96                       # Tamanho padrão de face no RPG Maker VX Ace
    )
    # Desenha a face na posição definida em Configs::HUD_FACE_X/Y
    self.bitmap.blt(Configs::HUD_FACE_X, Configs::HUD_FACE_Y, face, rect)
  end

  #----------------------------------------------------------------------------
  # * Desenha a barra de HP
  #   Configs::HUD_BAR_MAX_WIDTH define a largura máxima da barra preenchida
  #   Configs::HUD_HP_BAR_X/Y  – posição da barra no bitmap
  #   Configs::HUD_HP_LABEL_X/Y – posição do rótulo "HP"
  #   Configs::HUD_HP_TEXT_Y   – posição Y do texto "HP atual / HP máximo"
  #----------------------------------------------------------------------------
  def draw_hp_bar
    # Calcula a largura proporcional ao HP atual vs máximo
    bar_w = (Configs::HUD_BAR_MAX_WIDTH * actor.hp / actor.mhp.to_f).to_i
    # Recorte da barra de HP no spritesheet HUDBars (linha 0, altura 26)
    rect  = Rect.new(0, 0, bar_w, 26)
    # Desenha a barra na posição definida em Configs::HUD_HP_BAR_X/Y
    self.bitmap.blt(Configs::HUD_HP_BAR_X, Configs::HUD_HP_BAR_Y, @bars, rect)
    # Rótulo "HP" (abreviação do vocabulário do jogo)
    self.bitmap.draw_text(Configs::HUD_HP_LABEL_X, Configs::HUD_HP_LABEL_Y, 25, 18, Vocab::hp_a)
    # Texto com valor atual e máximo, alinhado à direita (alinhamento 2)
    self.bitmap.draw_text(0, Configs::HUD_HP_TEXT_Y, 229, 18, "#{actor.hp} / #{actor.mhp}", 2)
  end

  #----------------------------------------------------------------------------
  # * Desenha a barra de MP
  #   Configs::HUD_MP_BAR_X/Y  – posição da barra no bitmap
  #   Configs::HUD_MP_LABEL_X/Y – posição do rótulo "MP"
  #   Configs::HUD_MP_TEXT_Y   – posição Y do texto "MP atual / MP máximo"
  #   Usa [actor.mmp, 1].max para evitar divisão por zero quando mmp = 0
  #----------------------------------------------------------------------------
  def draw_mp_bar
    # Calcula a largura proporcional ao MP atual vs máximo (mínimo 1 para evitar divisão por zero)
    bar_w = (Configs::HUD_BAR_MAX_WIDTH * actor.mp / [actor.mmp, 1].max.to_f).to_i
    # Recorte da barra de MP no spritesheet HUDBars (linha 26, altura 26)
    rect  = Rect.new(0, 26, bar_w, 26)
    # Desenha a barra na posição definida em Configs::HUD_MP_BAR_X/Y
    self.bitmap.blt(Configs::HUD_MP_BAR_X, Configs::HUD_MP_BAR_Y, @bars, rect)
    # Rótulo "MP" (abreviação do vocabulário do jogo)
    self.bitmap.draw_text(Configs::HUD_MP_LABEL_X, Configs::HUD_MP_LABEL_Y, 25, 18, Vocab::mp_a)
    # Texto com valor atual e máximo, alinhado à direita (alinhamento 2)
    self.bitmap.draw_text(0, Configs::HUD_MP_TEXT_Y, 229, 18, "#{actor.mp} / #{actor.mmp}", 2)
  end

  #----------------------------------------------------------------------------
  # * Desenha a barra de EXP no sprite separado (base da tela)
  #   Configs::HUD_EXP_SHOW_PERCENT controla o formato do texto exibido:
  #     true  = exibe percentual (ex: "72.4%") – estilo MU Online / Ragnarok
  #     false = exibe valor numérico restante para o próximo nível (original)
  #   Usa [actor.next_exp, 1].max para evitar divisão por zero no nível máximo
  #----------------------------------------------------------------------------
  def draw_exp_bar
    # Limpa o bitmap do sprite de EXP antes de redesenhar
    @exp_sprite.bitmap.clear
    # Recorte do fundo da barra de EXP no spritesheet HUDBase (linha 98)
    rect_bg  = Rect.new(0, 98, @exp_sprite.bitmap.width, @exp_sprite.bitmap.height)
    # Calcula a largura proporcional à EXP atual vs necessária para o próximo nível
    bar_w    = (Configs::HUD_EXP_WIDTH * actor.now_exp / [actor.next_exp, 1].max.to_f).to_i
    # Recorte da barra de EXP no spritesheet HUDBars (linha 52)
    rect_bar = Rect.new(0, 52, bar_w, @exp_sprite.bitmap.height)

    # Determina o texto a exibir conforme nível e configuração
    exp_text = if actor.level >= Configs::MAX_LEVEL
      # Ator no nível máximo: exibe o vocabulário de nível máximo
      Vocab::MaxLevel
    elsif Configs::HUD_EXP_SHOW_PERCENT
      # Formato percentual: calcula % com 1 casa decimal – estilo MU Online
      # Ex: "72.4%" – mais intuitivo para o jogador visualizar o progresso
      pct = (actor.now_exp * 100.0 / [actor.next_exp, 1].max).round(1)
      "#{pct}%"
    else
      # Formato original: exibe quanto de EXP ainda falta para o próximo nível
      # Usa format_number para formatar com separadores de milhar se disponível
      format_number(actor.next_exp - actor.now_exp)
    end

    # Desenha o fundo da barra de EXP
    @exp_sprite.bitmap.blt(0, 0, @back, rect_bg)
    # Desenha a barra de EXP preenchida proporcionalmente
    @exp_sprite.bitmap.blt(0, 0, @bars, rect_bar)
    # Rótulo "EXP" alinhado à esquerda
    @exp_sprite.bitmap.draw_text(4, 2, 25, 18, Vocab::Exp)
    # Texto de EXP centralizado (alinhamento 1) na largura total da barra
    @exp_sprite.bitmap.draw_text(0, 2, Configs::HUD_EXP_WIDTH, 18, exp_text, 1)
  end

  #----------------------------------------------------------------------------
  # * Desenha o nível do personagem
  #   Configs::HUD_LEVEL_X/Y  – posição do ícone de nível no bitmap
  #   Configs::HUD_LEVEL_TEXT_Y – posição Y do número do nível
  #   Recorte do ícone de nível no HUDBase: linha 120, altura 30, largura 29
  #----------------------------------------------------------------------------
  def draw_level
    # Recorte do ícone/fundo do nível no spritesheet HUDBase
    rect = Rect.new(0, 120, 29, 30)
    # Desenha o ícone de nível na posição definida em Configs::HUD_LEVEL_X/Y
    self.bitmap.blt(Configs::HUD_LEVEL_X, Configs::HUD_LEVEL_Y, @back, rect)
    # Desenha o número do nível centralizado (alinhamento 1) sobre o ícone
    self.bitmap.draw_text(0, Configs::HUD_LEVEL_TEXT_Y, 30, 18, actor.level, 1)
  end

  #----------------------------------------------------------------------------
  # * Update – atualiza a HUD e o sprite de EXP a cada frame
  #   Delega o update ao Sprite2 pai (que trata drag, opacidade, etc.)
  #   e também atualiza o sprite de EXP separadamente
  #----------------------------------------------------------------------------
  def update
    super
    # Atualiza o sprite de EXP (posição, drag, visibilidade)
    @exp_sprite.update
    # Reaplica a opacidade do sprite de EXP conforme estado do jogo
    @exp_sprite.change_opacity
  end

  private

  #----------------------------------------------------------------------------
  # * Retorna o ator principal exibido na HUD
  #   O índice é definido em Configs::HUD_ACTOR_INDEX (padrão: 1)
  #   Centralizar aqui evita repetir $game_actors[1] em cada método,
  #   facilitando a troca do ator exibido sem alterar múltiplos locais
  #----------------------------------------------------------------------------
  def actor
    $game_actors[Configs::HUD_ACTOR_INDEX]
  end

end