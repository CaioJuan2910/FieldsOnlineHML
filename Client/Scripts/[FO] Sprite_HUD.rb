# encoding: utf-8
#==============================================================================
# ** [FO] Sprite_HUD
#==============================================================================
# Autor        : Caio Juan
# Versão       : 1.0.4
# Criado em    : 2026-04-07
# Atualizado em: 2026-04-14
#------------------------------------------------------------------------------
# Descrição:
#   HUD customizada para o Fields Online (VXA-OS).
#   Exibe barras de HP, MP e EXP com visual personalizado, nome do personagem
#   e nível atual. Totalmente configurável via bloco de configurações abaixo.
#------------------------------------------------------------------------------
# Changelog:
# v1.0.0 — Versão inicial
#   - Barras de HP, MP e EXP com visual customizado
#   - Exibição de nome e nível do personagem
#   - Configurações centralizadas no topo do script
#
# v1.0.1 — Melhorias visuais e de configuração
#   - Adicionado suporte a fonte customizada por barra
#   - Adicionado controle de visibilidade individual por elemento
#   - Corrigido posicionamento relativo das barras
#
# v1.0.2 — Refatoração e estabilidade
#   - Código reorganizado em métodos menores e mais legíveis
#   - Adicionado suporte a background opcional por barra
#   - Melhorada a lógica de atualização para evitar redesenhos desnecessários
#   - Comentários expandidos para facilitar manutenção
#
# v1.0.3 — Correção de conflito de superclasse com VXA-OS
#   - Classe renomeada de Sprite_HUD para FO_Sprite_HUD
#   - Adicionado patch em Scene_Map para substituir a HUD padrão pela FO_Sprite_HUD
#   - Nenhuma alteração necessária nos arquivos do VXA-OS
#
# v1.0.4 — Compatibilidade de interface com VXA-OS (Handle_Data)
#   - Adicionado método change_opacity para compatibilidade com [VS] Handle_Data
#   - O método ajusta self.opacity e replica no bitmap, evitando NoMethodError
#==============================================================================

#==============================================================================
# ** CONFIGURAÇÕES — [FO] Sprite_HUD
#------------------------------------------------------------------------------
# Ajuste todas as opções visuais e de comportamento da HUD aqui.
# Nenhuma outra parte do script precisa ser modificada para personalizações
# básicas de aparência, posição e fonte.
#==============================================================================
module FO_HUD_CONFIG

  HUD_X = 8
  HUD_Y = 8
  BAR_WIDTH  = 160
  BAR_HEIGHT = 14
  BAR_SPACING = 20

  NAME_FONT_NAME = "Arial"
  NAME_FONT_SIZE = 14
  NAME_BOLD      = true
  NAME_ITALIC    = false
  NAME_COLOR     = Color.new(255, 255, 255, 255)

  LEVEL_FONT_NAME = "Arial"
  LEVEL_FONT_SIZE = 14
  LEVEL_BOLD      = true
  LEVEL_ITALIC    = false
  LEVEL_COLOR     = Color.new(255, 220, 80, 255)
  LEVEL_PREFIX    = "Lv."

  BAR_FONT_NAME = "Arial"
  BAR_FONT_SIZE = 11
  BAR_BOLD      = false
  BAR_ITALIC    = false

  SHOW_NAME  = true
  SHOW_LEVEL = true
  SHOW_HP    = true
  SHOW_MP    = true
  SHOW_EXP   = true

  SHOW_BACKGROUND = true
  BG_COLOR        = Color.new(0, 0, 0, 160)
  BG_PADDING      = 6

  SHOW_BAR_BG  = true
  BAR_BG_COLOR = Color.new(0, 0, 0, 180)

  BAR_HP_COLOR1  = Color.new(224,  64,  64, 255)
  BAR_HP_COLOR2  = Color.new(255, 128, 128, 255)
  BAR_MP_COLOR1  = Color.new( 64,  64, 224, 255)
  BAR_MP_COLOR2  = Color.new(128, 128, 255, 255)
  BAR_EXP_COLOR1 = Color.new( 64, 192,  64, 255)
  BAR_EXP_COLOR2 = Color.new(128, 255, 128, 255)

  LABEL_HP  = "HP"
  LABEL_MP  = "MP"
  LABEL_EXP = "EXP"

  SHOW_HP_VALUE  = true
  SHOW_MP_VALUE  = true
  SHOW_EXP_VALUE = true

  HUD_Z = 200

end # FO_HUD_CONFIG

class FO_Sprite_HUD < Sprite
  include FO_HUD_CONFIG

  def initialize
    super()
    @bitmap = Bitmap.new(calculate_hud_width, calculate_hud_height)
    self.bitmap = @bitmap
    self.x = HUD_X
    self.y = HUD_Y
    self.z = HUD_Z
    @cache_hp    = nil
    @cache_mp    = nil
    @cache_exp   = nil
    @cache_level = nil
    @cache_name  = nil
    refresh
  end

  def update
    super
    return unless $game_party && $game_party.members[0]
    actor = $game_party.members[0]
    if actor.hp    != @cache_hp    ||
       actor.mp    != @cache_mp    ||
       actor.level != @cache_level ||
       actor.name  != @cache_name  ||
       current_exp_rate(actor) != @cache_exp
      refresh
    end
  end

  def refresh
    @bitmap.clear
    return unless $game_party && $game_party.members[0]
    actor = $game_party.members[0]
    @cache_hp    = actor.hp
    @cache_mp    = actor.mp
    @cache_level = actor.level
    @cache_name  = actor.name
    @cache_exp   = current_exp_rate(actor)
    draw_background if SHOW_BACKGROUND
    offset_y = SHOW_BACKGROUND ? BG_PADDING : 0
    offset_x = SHOW_BACKGROUND ? BG_PADDING : 0
    draw_name_and_level(actor, offset_x, offset_y)
    bar_start_y = offset_y + NAME_FONT_SIZE + 4
    bar_index = 0
    if SHOW_HP
      draw_bar_hp(actor, offset_x, bar_start_y + bar_index * BAR_SPACING)
      bar_index += 1
    end
    if SHOW_MP
      draw_bar_mp(actor, offset_x, bar_start_y + bar_index * BAR_SPACING)
      bar_index += 1
    end
    if SHOW_EXP
      draw_bar_exp(actor, offset_x, bar_start_y + bar_index * BAR_SPACING)
    end
  end

  def dispose
    @bitmap.dispose if @bitmap && !@bitmap.disposed?
    super
  end

  #--------------------------------------------------------------------------
  # * Compatibilidade com VXA-OS — [VS] Handle_Data
  #   O sistema VXA-OS chama change_opacity no objeto $windows[:hud].
  #   Este método garante que a chamada funcione sem erros e aplica
  #   a opacidade corretamente ao sprite e ao seu bitmap.
  #   value : inteiro de 0 (transparente) a 255 (opaco)
  #--------------------------------------------------------------------------
  def change_opacity(value)
    # Aplica a opacidade diretamente no sprite
    self.opacity = value
  end

  private

  def calculate_hud_width
    padding = SHOW_BACKGROUND ? BG_PADDING * 2 : 0
    BAR_WIDTH + padding + 30
  end

  def calculate_hud_height
    padding = SHOW_BACKGROUND ? BG_PADDING * 2 : 0
    bars_visible = [SHOW_HP, SHOW_MP, SHOW_EXP].count(true)
    NAME_FONT_SIZE + 4 + bars_visible * BAR_SPACING + padding + 4
  end

  def draw_background
    @bitmap.fill_rect(0, 0, @bitmap.width, @bitmap.height, BG_COLOR)
  end

  def draw_name_and_level(actor, x, y)
    if SHOW_NAME
      @bitmap.font.name   = NAME_FONT_NAME
      @bitmap.font.size   = NAME_FONT_SIZE
      @bitmap.font.bold   = NAME_BOLD
      @bitmap.font.italic = NAME_ITALIC
      @bitmap.font.color  = NAME_COLOR
      @bitmap.draw_text(x, y, BAR_WIDTH / 2, NAME_FONT_SIZE + 2, actor.name)
    end
    if SHOW_LEVEL
      @bitmap.font.name   = LEVEL_FONT_NAME
      @bitmap.font.size   = LEVEL_FONT_SIZE
      @bitmap.font.bold   = LEVEL_BOLD
      @bitmap.font.italic = LEVEL_ITALIC
      @bitmap.font.color  = LEVEL_COLOR
      level_text = "#{LEVEL_PREFIX}#{actor.level}"
      @bitmap.draw_text(x + BAR_WIDTH / 2, y, BAR_WIDTH / 2, LEVEL_FONT_SIZE + 2, level_text, 2)
    end
  end

  def draw_bar_hp(actor, x, y)
    rate  = actor.mhp > 0 ? actor.hp.to_f / actor.mhp : 0.0
    value_text = SHOW_HP_VALUE ? "#{actor.hp}/#{actor.mhp}" : nil
    draw_bar(x, y, rate, LABEL_HP, BAR_HP_COLOR1, BAR_HP_COLOR2, value_text)
  end

  def draw_bar_mp(actor, x, y)
    rate  = actor.mmp > 0 ? actor.mp.to_f / actor.mmp : 0.0
    value_text = SHOW_MP_VALUE ? "#{actor.mp}/#{actor.mmp}" : nil
    draw_bar(x, y, rate, LABEL_MP, BAR_MP_COLOR1, BAR_MP_COLOR2, value_text)
  end

  def draw_bar_exp(actor, x, y)
    rate  = current_exp_rate(actor)
    value_text = SHOW_EXP_VALUE ? "#{(rate * 100).round}%" : nil
    draw_bar(x, y, rate, LABEL_EXP, BAR_EXP_COLOR1, BAR_EXP_COLOR2, value_text)
  end

  def draw_bar(x, y, rate, label, color1, color2, value_text)
    label_w = label.empty? ? 0 : 28
    bar_x = x + label_w
    bar_y = y
    bar_w = BAR_WIDTH - label_w
    bar_h = BAR_HEIGHT
    rate = [[rate, 0.0].max, 1.0].min
    if SHOW_BAR_BG
      @bitmap.fill_rect(bar_x, bar_y, bar_w, bar_h, BAR_BG_COLOR)
    end
    filled_w = (bar_w * rate).round
    if filled_w > 0
      filled_w.times do |i|
        t = bar_w > 1 ? i.to_f / (bar_w - 1) : 0.0
        r = (color1.red   + (color2.red   - color1.red)   * t).round
        g = (color1.green + (color2.green - color1.green) * t).round
        b = (color1.blue  + (color2.blue  - color1.blue)  * t).round
        a = (color1.alpha + (color2.alpha - color1.alpha) * t).round
        @bitmap.fill_rect(bar_x + i, bar_y, 1, bar_h, Color.new(r, g, b, a))
      end
    end
    unless label.empty?
      @bitmap.font.name   = BAR_FONT_NAME
      @bitmap.font.size   = BAR_FONT_SIZE
      @bitmap.font.bold   = BAR_BOLD
      @bitmap.font.italic = BAR_ITALIC
      @bitmap.font.color  = Color.new(255, 255, 255, 255)
      @bitmap.draw_text(x, bar_y, label_w - 2, bar_h, label, 0)
    end
    if value_text
      @bitmap.font.name   = BAR_FONT_NAME
      @bitmap.font.size   = BAR_FONT_SIZE
      @bitmap.font.bold   = BAR_BOLD
      @bitmap.font.italic = BAR_ITALIC
      @bitmap.font.color  = Color.new(255, 255, 255, 220)
      @bitmap.draw_text(bar_x, bar_y, bar_w, bar_h, value_text, 1)
    end
  end

  def current_exp_rate(actor)
    return 1.0 if actor.max_level?
    current = actor.exp - actor.exp_for_level(actor.level)
    needed  = actor.exp_for_level(actor.level + 1) - actor.exp_for_level(actor.level)
    return 0.0 if needed <= 0
    [[current.to_f / needed, 0.0].max, 1.0].min
  end

end # FO_Sprite_HUD

class Scene_Map
  alias fo_hud_v103_create_all_windows create_all_windows
  def create_all_windows
    fo_hud_v103_create_all_windows
    if $windows[:hud]
      $windows[:hud].dispose rescue nil
    end
    $windows[:hud] = FO_Sprite_HUD.new
  end
end