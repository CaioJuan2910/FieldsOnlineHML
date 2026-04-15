# encoding: utf-8
#==============================================================================
# ** [FO] Sprite_HUD
#==============================================================================
# Autor        : Caio Juan
# Versão       : 1.0.5
# Criado em    : 2026-04-07
# Atualizado em: 2026-04-14
#------------------------------------------------------------------------------
# Descrição:
#   HUD customizada para o Fields Online (VXA-OS).
#   Exibe barras de HP, MP e EXP com visual personalizado, nome do personagem
#   e nível atual. Totalmente configurável via bloco de configurações abaixo.
#------------------------------------------------------------------------------
# Instalação:
#   1. Copiar este arquivo para Client/Scripts/
#   2. Adicionar [FO] Sprite_HUD no !script_order.csv, DEPOIS de [VS] Scene_Map
#      (dentro da seção ▼ Scenes~blank)
#   3. Salvar e testar o jogo
#
# ⚠️  ATENÇÃO: A ordem no CSV é crítica! Inverter causará NameError.
#------------------------------------------------------------------------------
# Changelog:
#   v1.0.0 — Versão inicial
#             · Barras de HP, MP e EXP com visual customizado
#             · Exibição de nome e nível do personagem
#             · Configurações centralizadas no topo do script
#
#   v1.0.1 — Melhorias visuais e de configuração
#             · Adicionado suporte a fonte customizada por barra
#             · Adicionado controle de visibilidade individual por elemento
#             · Corrigido posicionamento relativo das barras
#
#   v1.0.2 — Refatoração e estabilidade
#             · Código reorganizado em métodos menores e mais legíveis
#             · Adicionado suporte a background opcional por barra
#             · Melhorada lógica de atualização para evitar redesenhos desnecessários
#             · Comentários expandidos para facilitar manutenção
#
#   v1.0.3 — Correção de conflito de superclasse com VXA-OS
#             · Classe renomeada de Sprite_HUD para FO_Sprite_HUD
#             · Adicionado patch em Scene_Map para substituir a HUD padrão
#             · Nenhuma alteração necessária nos arquivos do VXA-OS
#
#   v1.0.4 — Compatibilidade de interface com VXA-OS (Handle_Data)
#             · Adicionado método change_opacity para compatibilidade com [VS] Handle_Data
#             · O método ajusta self.opacity e replica no bitmap, evitando NoMethodError
#
#   v1.0.5 — Fix crítico + Etapa 2.3: Configs Modulares
#             · FIX: change_opacity(value = 255) — parâmetro agora opcional
#               Resolve ArgumentError quando [VS] Handle_Data chama sem argumento
#             · NOVO: BAR_X e BAR_Y como constantes configuráveis (Etapa 2.3)
#             · NOVO: FONT_NAME e FONT_SIZE como base unificada de tipografia
#             · NOVO: FONT_BOLD como padrão global de negrito
#             · Constantes individuais por elemento ainda disponíveis para override
#==============================================================================

#==============================================================================
# ** FO_HUD_CONFIG
#------------------------------------------------------------------------------
# Módulo de configurações centralizadas da HUD.
# Todas as constantes aqui definidas controlam aparência e comportamento
# da HUD sem necessidade de alterar o código interno da classe.
#==============================================================================
module FO_HUD_CONFIG

  # ── Posição e dimensões ───────────────────────────────────────────────────
  HUD_X = 8     # Posição X da HUD na tela
  HUD_Y = 8     # Posição Y da HUD na tela
  HUD_Z = 200   # Camada Z (acima de outros sprites)

  # ── Tipografia — Base unificada (Etapa 2.3) ───────────────────────────────
  # Estas constantes servem como padrão global herdado pelos elementos abaixo.
  # Para personalizar um elemento específico, altere apenas a constante dele.
  FONT_NAME = "Arial"  # Fonte padrão para todos os elementos
  FONT_SIZE = 14       # Tamanho base da fonte
  FONT_BOLD = true     # Negrito padrão

  # ── Tipografia — Nome do personagem ───────────────────────────────────────
  NAME_FONT_NAME = FONT_NAME   # Herda fonte base (altere se quiser override)
  NAME_FONT_SIZE = FONT_SIZE   # Herda tamanho base
  NAME_BOLD      = FONT_BOLD   # Herda negrito base
  NAME_ITALIC    = false
  NAME_COLOR     = Color.new(255, 255, 255, 255)

  # ── Tipografia — Nível ────────────────────────────────────────────────────
  LEVEL_FONT_NAME = FONT_NAME
  LEVEL_FONT_SIZE = FONT_SIZE
  LEVEL_BOLD      = FONT_BOLD
  LEVEL_ITALIC    = false
  LEVEL_COLOR     = Color.new(255, 220, 80, 255)
  LEVEL_PREFIX    = "Lv."   # Prefixo exibido antes do número do nível

  # ── Tipografia — Texto das barras ─────────────────────────────────────────
  BAR_FONT_NAME = FONT_NAME
  BAR_FONT_SIZE = 11          # Fonte menor para as barras (override intencional)
  BAR_BOLD      = false
  BAR_ITALIC    = false

  # ── Barras HP/MP/EXP — Dimensões (Etapa 2.3) ─────────────────────────────
  BAR_X       = 0    # Deslocamento X das barras em relação ao padding da HUD
  BAR_Y       = 0    # Deslocamento Y das barras em relação ao início calculado
  BAR_WIDTH   = 160  # Largura total das barras
  BAR_HEIGHT  = 14   # Altura das barras
  BAR_SPACING = 20   # Espaçamento vertical entre barras

  # ── Visibilidade ──────────────────────────────────────────────────────────
  SHOW_NAME  = true   # Exibir nome do personagem
  SHOW_LEVEL = true   # Exibir nível do personagem
  SHOW_HP    = true   # Exibir barra de HP
  SHOW_MP    = true   # Exibir barra de MP
  SHOW_EXP   = true   # Exibir barra de EXP

  # ── Background da HUD ─────────────────────────────────────────────────────
  SHOW_BACKGROUND = true
  BG_COLOR        = Color.new(0, 0, 0, 160)   # Cor do fundo semi-transparente
  BG_PADDING      = 6                          # Espaçamento interno (px)

  # ── Background das barras ─────────────────────────────────────────────────
  SHOW_BAR_BG  = true
  BAR_BG_COLOR = Color.new(0, 0, 0, 180)   # Cor do fundo de cada barra

  # ── Cores das barras ──────────────────────────────────────────────────────
  # Cada barra usa gradiente de color1 (esquerda) para color2 (direita)
  BAR_HP_COLOR1  = Color.new(224,  64,  64, 255)   # Vermelho escuro
  BAR_HP_COLOR2  = Color.new(255, 128, 128, 255)   # Vermelho claro
  BAR_MP_COLOR1  = Color.new( 64,  64, 224, 255)   # Azul escuro
  BAR_MP_COLOR2  = Color.new(128, 128, 255, 255)   # Azul claro
  BAR_EXP_COLOR1 = Color.new( 64, 192,  64, 255)   # Verde escuro
  BAR_EXP_COLOR2 = Color.new(128, 255, 128, 255)   # Verde claro

  # ── Labels e valores ──────────────────────────────────────────────────────
  LABEL_HP  = "HP"
  LABEL_MP  = "MP"
  LABEL_EXP = "EXP"

  SHOW_HP_VALUE  = true   # Exibir "HP atual / HP máximo"
  SHOW_MP_VALUE  = true   # Exibir "MP atual / MP máximo"
  SHOW_EXP_VALUE = true   # Exibir "XX%" de experiência

end # FO_HUD_CONFIG

#==============================================================================
# ** FO_Sprite_HUD
#------------------------------------------------------------------------------
# Sprite principal da HUD customizada do Fields Online.
# Herda de Sprite (RGSS3) e inclui FO_HUD_CONFIG para acesso direto
# às constantes de configuração sem prefixo de módulo.
#==============================================================================
class FO_Sprite_HUD < Sprite
  include FO_HUD_CONFIG

  #--------------------------------------------------------------------------
  # * Inicialização
  #   Cria o bitmap com dimensões calculadas dinamicamente, posiciona o
  #   sprite na tela e realiza o primeiro desenho da HUD.
  #--------------------------------------------------------------------------
  def initialize
    super()
    @bitmap      = Bitmap.new(calculate_hud_width, calculate_hud_height)
    self.bitmap  = @bitmap
    self.x       = HUD_X
    self.y       = HUD_Y
    self.z       = HUD_Z
    # Cache para detectar mudanças e evitar redesenhos desnecessários
    @cache_hp    = nil
    @cache_mp    = nil
    @cache_exp   = nil
    @cache_level = nil
    @cache_name  = nil
    refresh
  end

  #--------------------------------------------------------------------------
  # * Atualização por frame
  #   Compara os valores atuais do ator com o cache. Só chama refresh
  #   quando há mudança real, evitando redesenhos a cada frame.
  #--------------------------------------------------------------------------
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

  #--------------------------------------------------------------------------
  # * Redesenho completo da HUD
  #   Limpa o bitmap e redesenha todos os elementos visíveis com base
  #   nas configurações do módulo FO_HUD_CONFIG.
  #--------------------------------------------------------------------------
  def refresh
    @bitmap.clear
    return unless $game_party && $game_party.members[0]
    actor = $game_party.members[0]

    # Atualiza cache com os valores atuais do ator
    @cache_hp    = actor.hp
    @cache_mp    = actor.mp
    @cache_level = actor.level
    @cache_name  = actor.name
    @cache_exp   = current_exp_rate(actor)

    # Fundo da HUD (se habilitado)
    draw_background if SHOW_BACKGROUND

    # Calcula offsets internos com base no padding do background
    offset_y = SHOW_BACKGROUND ? BG_PADDING : 0
    offset_x = SHOW_BACKGROUND ? BG_PADDING : 0

    # Desenha nome e nível na linha superior
    draw_name_and_level(actor, offset_x, offset_y)

    # Calcula posição inicial das barras (abaixo do nome + deslocamento configurável)
    bar_start_y = offset_y + NAME_FONT_SIZE + 4 + BAR_Y
    bar_start_x = offset_x + BAR_X

    # Desenha barras visíveis em sequência, incrementando o índice de linha
    bar_index = 0

    if SHOW_HP
      draw_bar_hp(actor, bar_start_x, bar_start_y + bar_index * BAR_SPACING)
      bar_index += 1
    end

    if SHOW_MP
      draw_bar_mp(actor, bar_start_x, bar_start_y + bar_index * BAR_SPACING)
      bar_index += 1
    end

    if SHOW_EXP
      draw_bar_exp(actor, bar_start_x, bar_start_y + bar_index * BAR_SPACING)
    end
  end

  #--------------------------------------------------------------------------
  # * Liberação segura de memória
  #   Garante que o bitmap seja descartado antes do sprite pai.
  #--------------------------------------------------------------------------
  def dispose
    @bitmap.dispose if @bitmap && !@bitmap.disposed?
    super
  end

  #--------------------------------------------------------------------------
  # * Compatibilidade com VXA-OS — [VS] Handle_Data
  #   O sistema VXA-OS chama change_opacity no objeto $windows[:hud].
  #
  #   v1.0.5 FIX: parâmetro agora opcional (value = 255).
  #     · Sem argumento → opacidade total (HUD sempre visível).
  #     · Com argumento → aplica valor informado pelo VXA-OS.
  #
  #   @param value [Integer] 0 (transparente) a 255 (opaco). Padrão: 255
  #--------------------------------------------------------------------------
  def change_opacity(value = 255)
    self.opacity = value
  end

  private

  #--------------------------------------------------------------------------
  # * Calcula a largura total do bitmap da HUD
  #   Considera padding do background e espaço extra para o label lateral.
  #--------------------------------------------------------------------------
  def calculate_hud_width
    padding = SHOW_BACKGROUND ? BG_PADDING * 2 : 0
    BAR_WIDTH + padding + 30
  end

  #--------------------------------------------------------------------------
  # * Calcula a altura total do bitmap da HUD
  #   Considera padding, linha de nome/nível, barras visíveis e deslocamento Y.
  #--------------------------------------------------------------------------
  def calculate_hud_height
    padding      = SHOW_BACKGROUND ? BG_PADDING * 2 : 0
    bars_visible = [SHOW_HP, SHOW_MP, SHOW_EXP].count(true)
    NAME_FONT_SIZE + 4 + bars_visible * BAR_SPACING + padding + BAR_Y + 4
  end

  #--------------------------------------------------------------------------
  # * Desenha o fundo semi-transparente da HUD
  #   Preenche todo o bitmap com a cor BG_COLOR definida nas configurações.
  #--------------------------------------------------------------------------
  def draw_background
    @bitmap.fill_rect(0, 0, @bitmap.width, @bitmap.height, BG_COLOR)
  end

  #--------------------------------------------------------------------------
  # * Desenha nome e nível do personagem lado a lado
  #   Nome alinhado à esquerda; nível alinhado à direita na mesma linha.
  #
  #   @param actor [Game_Actor] ator atual do jogador
  #   @param x     [Integer]    posição X de início
  #   @param y     [Integer]    posição Y de início
  #--------------------------------------------------------------------------
  def draw_name_and_level(actor, x, y)
    # Nome do personagem (metade esquerda da linha)
    if SHOW_NAME
      @bitmap.font.name   = NAME_FONT_NAME
      @bitmap.font.size   = NAME_FONT_SIZE
      @bitmap.font.bold   = NAME_BOLD
      @bitmap.font.italic = NAME_ITALIC
      @bitmap.font.color  = NAME_COLOR
      @bitmap.draw_text(x, y, BAR_WIDTH / 2, NAME_FONT_SIZE + 2, actor.name)
    end

    # Nível do personagem (metade direita da linha, alinhado à direita)
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

  #--------------------------------------------------------------------------
  # * Desenha a barra de HP do ator
  #   @param actor [Game_Actor]
  #   @param x     [Integer] posição X
  #   @param y     [Integer] posição Y
  #--------------------------------------------------------------------------
  def draw_bar_hp(actor, x, y)
    rate       = actor.mhp > 0 ? actor.hp.to_f / actor.mhp : 0.0
    value_text = SHOW_HP_VALUE ? "#{actor.hp}/#{actor.mhp}" : nil
    draw_bar(x, y, rate, LABEL_HP, BAR_HP_COLOR1, BAR_HP_COLOR2, value_text)
  end

  #--------------------------------------------------------------------------
  # * Desenha a barra de MP do ator
  #   @param actor [Game_Actor]
  #   @param x     [Integer] posição X
  #   @param y     [Integer] posição Y
  #--------------------------------------------------------------------------
  def draw_bar_mp(actor, x, y)
    rate       = actor.mmp > 0 ? actor.mp.to_f / actor.mmp : 0.0
    value_text = SHOW_MP_VALUE ? "#{actor.mp}/#{actor.mmp}" : nil
    draw_bar(x, y, rate, LABEL_MP, BAR_MP_COLOR1, BAR_MP_COLOR2, value_text)
  end

  #--------------------------------------------------------------------------
  # * Desenha a barra de EXP do ator
  #   @param actor [Game_Actor]
  #   @param x     [Integer] posição X
  #   @param y     [Integer] posição Y
  #--------------------------------------------------------------------------
  def draw_bar_exp(actor, x, y)
    rate       = current_exp_rate(actor)
    value_text = SHOW_EXP_VALUE ? "#{(rate * 100).round}%" : nil
    draw_bar(x, y, rate, LABEL_EXP, BAR_EXP_COLOR1, BAR_EXP_COLOR2, value_text)
  end

  #--------------------------------------------------------------------------
  # * Método central de desenho de barra com gradiente horizontal
  #
  #   Estrutura visual de cada barra:
  #     [LABEL] [====BARRA PREENCHIDA====          ] [valor]
  #
  #   @param x          [Integer] posição X de início
  #   @param y          [Integer] posição Y de início
  #   @param rate       [Float]   proporção preenchida (0.0 a 1.0)
  #   @param label      [String]  rótulo da barra (ex: "HP")
  #   @param color1     [Color]   cor inicial do gradiente (esquerda)
  #   @param color2     [Color]   cor final do gradiente (direita)
  #   @param value_text [String]  texto de valor (ex: "150/200") ou nil
  #--------------------------------------------------------------------------
  def draw_bar(x, y, rate, label, color1, color2, value_text)
    # Reserva espaço para o label à esquerda (0 se label vazio)
    label_w = label.empty? ? 0 : 28
    bar_x   = x + label_w
    bar_y   = y
    bar_w   = BAR_WIDTH - label_w
    bar_h   = BAR_HEIGHT

    # Garante que rate esteja no intervalo válido [0.0, 1.0]
    rate = [[rate, 0.0].max, 1.0].min

    # Fundo escuro da barra (se habilitado)
    @bitmap.fill_rect(bar_x, bar_y, bar_w, bar_h, BAR_BG_COLOR) if SHOW_BAR_BG

    # Preenchimento com gradiente horizontal coluna a coluna
    filled_w = (bar_w * rate).round
    if filled_w > 0
      filled_w.times do |i|
        # Interpolação linear entre color1 e color2 ao longo da largura total
        t = bar_w > 1 ? i.to_f / (bar_w - 1) : 0.0
        r = (color1.red   + (color2.red   - color1.red)   * t).round
        g = (color1.green + (color2.green - color1.green) * t).round
        b = (color1.blue  + (color2.blue  - color1.blue)  * t).round
        a = (color1.alpha + (color2.alpha - color1.alpha) * t).round
        @bitmap.fill_rect(bar_x + i, bar_y, 1, bar_h, Color.new(r, g, b, a))
      end
    end

    # Rótulo da barra (ex: "HP"), desenhado à esquerda da barra
    unless label.empty?
      @bitmap.font.name   = BAR_FONT_NAME
      @bitmap.font.size   = BAR_FONT_SIZE
      @bitmap.font.bold   = BAR_BOLD
      @bitmap.font.italic = BAR_ITALIC
      @bitmap.font.color  = Color.new(255, 255, 255, 255)
      @bitmap.draw_text(x, bar_y, label_w - 2, bar_h, label, 0)
    end

    # Valor numérico centralizado sobre a barra (ex: "150/200" ou "75%")
    if value_text
      @bitmap.font.name   = BAR_FONT_NAME
      @bitmap.font.size   = BAR_FONT_SIZE
      @bitmap.font.bold   = BAR_BOLD
      @bitmap.font.italic = BAR_ITALIC
      @bitmap.font.color  = Color.new(255, 255, 255, 220)
      @bitmap.draw_text(bar_x, bar_y, bar_w, bar_h, value_text, 1)
    end
  end

  #--------------------------------------------------------------------------
  # * Calcula a taxa de EXP atual do ator no nível corrente
  #   Retorna 1.0 se o ator estiver no nível máximo.
  #
  #   @param actor [Game_Actor]
  #   @return [Float] proporção de EXP no nível atual (0.0 a 1.0)
  #--------------------------------------------------------------------------
  def current_exp_rate(actor)
    return 1.0 if actor.max_level?
    current = actor.exp - actor.exp_for_level(actor.level)
    needed  = actor.exp_for_level(actor.level + 1) - actor.exp_for_level(actor.level)
    return 0.0 if needed <= 0
    [[current.to_f / needed, 0.0].max, 1.0].min
  end

end # FO_Sprite_HUD

#==============================================================================
# ** Scene_Map — Patch [FO] Sprite_HUD
#------------------------------------------------------------------------------
# Substitui a HUD padrão do VXA-OS (Sprite_HUD) pela HUD customizada
# do Fields Online (FO_Sprite_HUD) após a inicialização das janelas.
#
# Como funciona:
#   1. create_all_windows original executa (cria Sprite_HUD padrão)
#   2. adjust_windows_position roda sobre a HUD original (sem NoMethodError)
#   3. O alias então substitui $windows[:hud] pela FO_Sprite_HUD
#
# ⚠️  Este patch usa alias — o script DEVE ser carregado DEPOIS de
#     [VS] Scene_Map no !script_order.csv. Inverter causa NameError.
#==============================================================================
class Scene_Map
  alias fo_hud_v105_create_all_windows create_all_windows
  def create_all_windows
    fo_hud_v105_create_all_windows
    if $windows[:hud]
      $windows[:hud].dispose rescue nil
    end
    $windows[:hud] = FO_Sprite_HUD.new
  end
end

#==============================================================================
# ** RESUMO DE INSTALAÇÃO
#==============================================================================
#
# PASSO 1 — Arquivo
#   Salvar este arquivo como: Client/Scripts/[FO] Sprite_HUD.rb
#
# PASSO 2 — !script_order.csv
#   Localizar a seção "▼ Scenes~blank" e inserir APÓS [VS] Scene_Map:
#
#     ▼ Scenes~blank
#     [VS] Scene_Base
#     [VS] Scene_Login
#     [VS] Scene_Character
#     [VS] Scene_Map
#     [FO] Sprite_HUD       ← INSERIR AQUI
#
#     ▼ Main~blank
#     no_script_name
#     [RM] Main
#
# PASSO 3 — Testar
#   Abrir o RPG Maker VX Ace, iniciar o jogo e verificar que a HUD aparece
#   no canto superior esquerdo com as barras de HP, MP e EXP.
#
# ⚠️  ATENÇÃO: Se a HUD não aparecer, verificar se [FO] Sprite_HUD está
#     registrado no !script_order.csv e posicionado APÓS [VS] Scene_Map.
#
#==============================================================================