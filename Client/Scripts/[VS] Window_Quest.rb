#==============================================================================
# [VS] Window_Quest
#------------------------------------------------------------------------------
# Autor: Valentine
# Modificado: Caio Juan (Fase 1 — Bloco de CONFIGS + Reorganização)
# Versão: 1.1 — Fase 1 do Plano de Modernização
# Data: 2026-03-31
#
# Descrição:
#   Sistema de janelas de missão (lista, detalhes e diálogo com NPC).
#   Todos os valores de posição, dimensão e fonte foram migrados para
#   o módulo Configs, eliminando valores hardcoded neste script.
#
# Classes contidas neste arquivo:
#   - Window_Quest        → Lista de missões (em progresso / concluídas)
#   - Window_QuestInfo    → Detalhes de uma missão selecionada
#   - Window_QuestDialogue → Diálogo do NPC ao oferecer uma missão
#
# IMPORTANTE:
#   Para ajustar posições, tamanhos ou fontes, edite APENAS o [VS] Configs.rb.
#   Não altere valores diretamente neste script.
#
# Constantes esperadas no Configs (adicione ao [VS] Configs.rb se ausentes):
#
#   # ── Window_Quest (lista de missões) ──────────────────────────────────────
#   QUEST_WINDOW_X          = 0      # Posição X da janela de lista
#   QUEST_WINDOW_Y          = 0      # Posição Y da janela de lista
#   QUEST_WINDOW_W          = 200    # Largura da janela de lista
#   QUEST_WINDOW_H          = 400    # Altura da janela de lista
#   QUEST_LINE_HEIGHT       = 24     # Altura de cada linha (lista e detalhes)
#   QUEST_IN_PROGRESS_ICON  = 185    # Índice do ícone "em progresso" no Iconset
#   QUEST_FINISHED_ICON     = 186    # Índice do ícone "concluída" no Iconset
#
#   # ── Window_QuestInfo (detalhes da missão) ─────────────────────────────────
#   QUEST_INFO_X            = 200    # Posição X da janela de detalhes
#   QUEST_INFO_Y            = 0      # Posição Y da janela de detalhes
#   QUEST_INFO_W            = 300    # Largura da janela de detalhes
#   QUEST_INFO_H            = 400    # Altura da janela de detalhes
#   QUEST_TITLE_FONT_SIZE   = 18     # Tamanho da fonte do título da missão
#   QUEST_FONT_SIZE         = 14     # Tamanho da fonte do corpo (descrição)
#   QUEST_INFO_TITLE_Y      = 0      # Y do título da missão
#   QUEST_INFO_DESC_Y       = 30     # Y do início da descrição
#   QUEST_INFO_REWARDS_Y    = 200    # Y do label "Recompensas"
#   QUEST_INFO_EXP_Y        = 224    # Y da linha de EXP
#   QUEST_INFO_GOLD_Y       = 248    # Y da linha de Ouro
#   QUEST_INFO_ITEM_Y       = 272    # Y da linha do item de recompensa
#
#   # ── Window_QuestDialogue (diálogo do NPC) ─────────────────────────────────
#   QUEST_DIALOGUE_W        = 280    # Largura da janela de diálogo
#   QUEST_DIALOGUE_H        = 300    # Altura da janela de diálogo
#   QUEST_REWARD_FONT_SIZE  = 12     # Tamanho da fonte dos valores de recompensa
#   EXP_ICON                = 87     # Índice do ícone de EXP no Iconset
#   GOLD_ICON               = 147    # Índice do ícone de Ouro no Iconset
#==============================================================================

#==============================================================================
# ** Window_Quest
#------------------------------------------------------------------------------
# Janela de listagem de missões do jogador, separadas por abas:
#   Aba 0 → Missões Em Progresso
#   Aba 1 → Missões Concluídas
#
# Ao clicar em uma missão da lista, abre o Window_QuestInfo com os detalhes.
# A janela é registrada em $windows[:quest] pelo sistema de janelas do VXA-OS.
#==============================================================================
class Window_Quest < Window_Selectable

  #----------------------------------------------------------------------------
  # * Inicialização da janela de lista de missões
  #
  #   Posição e dimensões são lidas do Configs para facilitar ajustes futuros
  #   sem necessidade de editar este script diretamente.
  #
  #   O Tab_Control recebe um bloco { refresh } que reconstrói a lista
  #   automaticamente sempre que o jogador troca de aba.
  #----------------------------------------------------------------------------
  def initialize
    super(
      Configs::QUEST_WINDOW_X,  # Posição X — configurável no Configs
      Configs::QUEST_WINDOW_Y,  # Posição Y — configurável no Configs
      Configs::QUEST_WINDOW_W,  # Largura   — configurável no Configs
      Configs::QUEST_WINDOW_H   # Altura    — configurável no Configs
    )

    # Janela começa oculta; é exibida ao abrir o menu de missões
    self.visible  = false

    # Permite fechar a janela pelo botão X padrão do VXA-OS
    self.closable = true

    # Título exibido na barra superior da janela
    self.title = Vocab::Quests

    # Cria as abas de navegação:
    #   Aba 0 → Vocab::InProgress  (missões em andamento)
    #   Aba 1 → Vocab::Completed   (missões concluídas)
    # O bloco { refresh } é chamado automaticamente ao trocar de aba,
    # reconstruindo a lista com os dados corretos.
    @tab_page = Tab_Control.new(
      self,
      [Vocab::InProgress, Vocab::Completed],
      true
    ) { refresh }
  end

  #----------------------------------------------------------------------------
  # * Altura de cada linha da lista
  #
  #   Sobrescreve o padrão do Window_Selectable para usar a constante do
  #   Configs, garantindo consistência visual com outras janelas do sistema.
  #----------------------------------------------------------------------------
  def line_height
    Configs::QUEST_LINE_HEIGHT
  end

  #----------------------------------------------------------------------------
  # * Monta a lista de missões conforme a aba ativa
  #
  #   Aba 0 (index == 0) → quests_in_progress (missões em andamento)
  #   Aba 1 (index == 1) → quests_finished    (missões concluídas)
  #
  #   @data é o array usado pelo Window_Selectable para renderizar os itens.
  #----------------------------------------------------------------------------
  def make_list
    @data = @tab_page.index == 0 \
      ? $game_actors[1].quests_in_progress \
      : $game_actors[1].quests_finished
  end

  #----------------------------------------------------------------------------
  # * Desenha um item individual da lista de missões
  #
  #   Exibe um ícone de status (em progresso ou concluída) seguido do nome
  #   da missão. O ícone ocupa 24px de largura + 3px de margem esquerda,
  #   totalizando 27px de deslocamento para o texto.
  #
  #   Os índices dos ícones são configuráveis via:
  #     Configs::QUEST_IN_PROGRESS_ICON → missão em andamento
  #     Configs::QUEST_FINISHED_ICON    → missão concluída
  #----------------------------------------------------------------------------
  def draw_item(index)
    # Obtém o retângulo de texto do item (já considera padding interno)
    rect = item_rect_for_text(index)

    # Seleciona o ícone correto conforme o estado da missão
    icon_index = @data[index].finished? \
      ? Configs::QUEST_FINISHED_ICON    \
      : Configs::QUEST_IN_PROGRESS_ICON

    # Calcula o recorte do ícone no Iconset (grade de 16 colunas × 24px cada)
    # Fórmula padrão do RPG Maker VX Ace para localizar ícones no Iconset
    rect2  = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    bitmap = Cache.system('Iconset')

    # Desenha o ícone com 3px de margem esquerda, alinhado verticalmente ao item
    contents.blt(3, rect.y, bitmap, rect2)

    # Desloca o texto 27px para a direita para não sobrepor o ícone (24px + 3px)
    rect.x += 27
    draw_text(rect, @data[index].name)
  end

  #----------------------------------------------------------------------------
  # * Atualiza o conteúdo da janela (redesenha itens e bordas das abas)
  #
  #   Chama super para redesenhar todos os itens via draw_item,
  #   depois redesenha as bordas decorativas das abas de navegação.
  #----------------------------------------------------------------------------
  def refresh
    super
    @tab_page.draw_border
  end

  #----------------------------------------------------------------------------
  # * Atualização por frame — captura clique do mouse para abrir detalhes
  #
  #   Ao clicar com o botão esquerdo sobre um item válido (index >= 0),
  #   abre a janela de detalhes (Window_QuestInfo) com os dados da missão
  #   selecionada e reproduz o som de confirmação.
  #----------------------------------------------------------------------------
  def update
    super

    # Verifica clique esquerdo do mouse sobre um item válido da lista
    if Mouse.click?(:L) && index >= 0
      $windows[:quest_info].show(@data[index])
      Sound.play_ok
    end
  end

end

#==============================================================================
# ** Window_QuestInfo
#------------------------------------------------------------------------------
# Janela de detalhes de uma missão selecionada na Window_Quest.
#
# Exibe as seguintes informações:
#   - Nome da missão (centralizado, fonte maior)
#   - Descrição completa (com quebra de linha automática via word_wrap)
#   - Recompensas: EXP, Ouro e Item (com ícone e quantidade)
#
# É aberta ao clicar em uma missão na Window_Quest.
# As posições Y de cada seção são configuráveis no Configs para fácil ajuste
# sem necessidade de editar este script.
#==============================================================================
class Window_QuestInfo < Window_Base

  # Expõe a missão atual para leitura externa (útil para debug ou extensões)
  attr_reader :quest

  #----------------------------------------------------------------------------
  # * Inicialização da janela de detalhes
  #
  #   Posição e dimensões são lidas do Configs.
  #   A janela começa oculta e é exibida ao chamar show(quest).
  #----------------------------------------------------------------------------
  def initialize
    super(
      Configs::QUEST_INFO_X,  # Posição X — configurável no Configs
      Configs::QUEST_INFO_Y,  # Posição Y — configurável no Configs
      Configs::QUEST_INFO_W,  # Largura   — configurável no Configs
      Configs::QUEST_INFO_H   # Altura    — configurável no Configs
    )

    # Janela começa oculta; é exibida ao selecionar uma missão
    self.visible  = false

    # Permite fechar a janela pelo botão X padrão do VXA-OS
    self.closable = true

    # Título exibido na barra superior da janela
    self.title = Vocab::Information
  end

  #----------------------------------------------------------------------------
  # * Altura de cada linha
  #
  #   Usa a mesma constante da Window_Quest para consistência visual.
  #----------------------------------------------------------------------------
  def line_height
    Configs::QUEST_LINE_HEIGHT
  end

  #----------------------------------------------------------------------------
  # * Exibe a janela com os detalhes da missão informada
  #
  #   Armazena a referência da missão e chama super() para tornar a janela
  #   visível. O refresh é chamado automaticamente pelo ciclo de visibilidade
  #   do VXA-OS ao exibir a janela.
  #
  #   @param quest [Quest] Objeto de missão com name, description e reward
  #----------------------------------------------------------------------------
  def show(quest)
    @quest = quest
    super()
  end

  #----------------------------------------------------------------------------
  # * Redesenha todo o conteúdo da janela de detalhes
  #
  # Layout vertical (posições Y configuráveis via Configs):
  #
  #   QUEST_INFO_TITLE_Y   → Nome da missão (centralizado, fonte maior)
  #   QUEST_INFO_DESC_Y    → Início da descrição (word_wrap automático)
  #   QUEST_INFO_REWARDS_Y → Label "Recompensas" (cor de crise)
  #   QUEST_INFO_EXP_Y     → Linha de EXP
  #   QUEST_INFO_GOLD_Y    → Linha de Ouro
  #   QUEST_INFO_ITEM_Y    → Ícone + label + quantidade do item de recompensa
  #
  # Nota: O item de recompensa só é desenhado se @quest.reward.item não for nil.
  #----------------------------------------------------------------------------
  def refresh
    # Limpa todo o conteúdo anterior antes de redesenhar
    contents.clear

    # ── Título da missão ──────────────────────────────────────────────────────
    # Usa fonte maior (QUEST_TITLE_FONT_SIZE) e cor de sistema para destaque
    contents.font.size = Configs::QUEST_TITLE_FONT_SIZE
    change_color(system_color)
    draw_text(
      0,                          # X: alinhado à borda esquerda do conteúdo
      Configs::QUEST_INFO_TITLE_Y, # Y: configurável no Configs
      contents_width,             # Largura total disponível
      line_height,                # Altura de uma linha
      @quest.name,                # Nome da missão
      1                           # Alinhamento: 1 = centralizado
    )

    # ── Descrição da missão ───────────────────────────────────────────────────
    # Usa fonte menor (QUEST_FONT_SIZE) e cor normal
    # word_wrap divide o texto em linhas que cabem na largura da janela
    contents.font.size = Configs::QUEST_FONT_SIZE
    change_color(normal_color)
    word_wrap(@quest.description).each_with_index do |text, i|
      draw_text(
        0,                                              # X: borda esquerda
        Configs::QUEST_INFO_DESC_Y + line_height * i,  # Y: empilha as linhas
        contents_width,                                 # Largura total
        line_height,                                    # Altura de uma linha
        text,                                           # Linha de texto atual
        1                                               # Centralizado
      )
    end

    # ── Label "Recompensas" ───────────────────────────────────────────────────
    # Usa cor de crise (amarelo/laranja) para destacar a seção de recompensas
    change_color(crisis_color)
    draw_text(
      0,
      Configs::QUEST_INFO_REWARDS_Y,
      contents_width,
      line_height,
      Vocab::Rewards,
      1  # Centralizado
    )

    # ── EXP ──────────────────────────────────────────────────────────────────
    # Exibe "EXP: <valor formatado>" com separadores de milhar via format_number
    change_color(normal_color)
    draw_text(
      0,
      Configs::QUEST_INFO_EXP_Y,
      contents_width,
      line_height,
      "#{Vocab::Exp}: #{format_number(@quest.reward.exp)}"
    )

    # ── Ouro ─────────────────────────────────────────────────────────────────
    # Exibe "<unidade de moeda>: <valor formatado>"
    draw_text(
      0,
      Configs::QUEST_INFO_GOLD_Y,
      contents_width,
      line_height,
      "#{Vocab.currency_unit}: #{format_number(@quest.reward.gold)}"
    )

    # ── Item de recompensa ────────────────────────────────────────────────────
    # Só desenha se houver item de recompensa definido na missão
    # Layout: label "Item:" | ícone do item | "x<quantidade>"
    if @quest.reward.item
      # Label "Item:" posicionado à esquerda do ícone
      draw_text(130, Configs::QUEST_INFO_ITEM_Y, 45, line_height, "#{Vocab::Item}:")

      # Ícone do item (24×24px) extraído do Iconset
      draw_icon(@quest.reward.item.icon_index, 170, Configs::QUEST_INFO_ITEM_Y)

      # Quantidade do item à direita do ícone (ex: "x3")
      draw_text(200, Configs::QUEST_INFO_ITEM_Y, 25, line_height, "x#{@quest.reward.item_amount}")
    end
  end

end

#==============================================================================
# ** Window_QuestDialogue
#------------------------------------------------------------------------------
# Janela de diálogo exibida quando um NPC oferece uma missão ao jogador.
#
# Exibe:
#   - Nome da missão (linha superior, cor de destaque)
#   - Descrição justificada (texto do servidor, com tag QT<id>: removida)
#   - Label "Recompensas" centralizado
#   - Ícones de EXP, Ouro e Item com valores abaixo (exibidos apenas se > 0)
#   - Botão "Aceitar" que envia send_choice(0) ao servidor
#
# A janela é centralizada automaticamente na tela usando as dimensões
# QUEST_DIALOGUE_W e QUEST_DIALOGUE_H definidas no Configs.
#
# Comunicação com o servidor:
#   Aceitar  → send_choice(0)
#   Recusar  → send_choice(1)  (via botão X ou hide_window)
#
# Nota: Na Fase 3 do plano de modernização será adicionado um botão
#       "Recusar" separado. Por ora, fechar pelo X envia send_choice(1).
#==============================================================================
class Window_QuestDialogue < Window_Base2

  #----------------------------------------------------------------------------
  # * Inicialização da janela de diálogo de missão
  #
  #   A posição é calculada pelos métodos adjust_x e adjust_y para centralizar
  #   a janela na tela com base nas dimensões definidas no Configs.
  #
  #   O terceiro argumento 'QuestDialogueWindow' é o identificador de skin
  #   usado pelo Window_Base2 para carregar o visual correto da janela.
  #
  #   O botão "Aceitar" é criado com posição fixa (92, 244) e chama o método
  #   accept ao ser clicado, que envia a confirmação ao servidor.
  #----------------------------------------------------------------------------
  def initialize
    super(
      adjust_x,              # X centralizado — calculado por adjust_x
      adjust_y,              # Y centralizado — calculado por adjust_y
      'QuestDialogueWindow'  # Identificador de skin da janela
    )

    # Janela começa oculta; é exibida ao receber mensagem de missão do servidor
    self.visible  = false

    # Permite fechar a janela pelo botão X (envia recusa ao servidor via hide_window)
    self.closable = true

    # Botão "Aceitar" — ao clicar, chama o método accept
    # Posição (92, 244) relativa ao conteúdo da janela
    Button.new(self, 92, 244, Vocab::Accept) { accept }
  end

  #----------------------------------------------------------------------------
  # * Calcula a posição X para centralizar a janela horizontalmente na tela
  #
  #   Fórmula: (largura da tela / 2) - (largura da janela / 2)
  #   Usa Graphics.width para compatibilidade com diferentes resoluções.
  #----------------------------------------------------------------------------
  def adjust_x
    Graphics.width / 2 - Configs::QUEST_DIALOGUE_W / 2
  end

  #----------------------------------------------------------------------------
  # * Calcula a posição Y para centralizar a janela verticalmente na tela
  #
  #   Fórmula: (altura da tela / 2) - (altura da janela / 2)
  #   Usa Graphics.height para compatibilidade com diferentes resoluções.
  #----------------------------------------------------------------------------
  def adjust_y
    Graphics.height / 2 - Configs::QUEST_DIALOGUE_H / 2
  end

  #----------------------------------------------------------------------------
  # * Exibe a janela e carrega os dados da missão a partir da mensagem do servidor
  #
  #   O servidor envia o ID da missão embutido no texto da mensagem no formato:
  #     "QT<id>: <descrição da missão>"
  #   Exemplo: "QT3: Colete 10 ervas medicinais."
  #
  #   A regex /QT(.*):/  extrai o ID (grupo de captura 1), converte para inteiro
  #   e subtrai 1 para acessar o índice correto no array Quests::DATA (base 0).
  #----------------------------------------------------------------------------
  def show
    # Extrai o ID da missão do texto da mensagem e carrega os dados do Quests::DATA
    @quest = Quests::DATA[$game_message.texts.first[/QT(.*):/,1].to_i - 1]
    super
  end

  #----------------------------------------------------------------------------
  # * Fecha a janela e notifica o servidor sobre a recusa da missão
  #
  #   Chamado ao clicar no botão X da janela (comportamento de recusa).
  #   Envia send_choice(1) ao servidor para indicar que o jogador recusou.
  #   Limpa a mensagem do sistema e chama super para ocultar a janela.
  #
  #   Nota: Na Fase 3 será adicionado um botão "Recusar" dedicado.
  #         Por ora, fechar pelo X é o único meio de recusar a missão.
  #----------------------------------------------------------------------------
  def hide_window
    # Não faz nada se a janela já estiver oculta (evita envio duplo ao servidor)
    return unless visible

    # Notifica o servidor: jogador recusou a missão (choice = 1)
    $network.send_choice(1)

    # Limpa a mensagem do sistema para liberar o fluxo de diálogo
    $game_message.clear

    # Chama super para executar o comportamento padrão de ocultação
    super
  end

  #----------------------------------------------------------------------------
  # * Redesenha todo o conteúdo da janela de diálogo
  #
  # Layout vertical (posições Y fixas, mantidas do original para compatibilidade):
  #
  #   y=4   → Nome da missão (cor de destaque, fonte padrão)
  #   y=28  → Descrição justificada (tag QT<id>: removida, quebras limpas)
  #   y=147 → Label "Recompensas" (centralizado, cor de gauge de HP)
  #   y=181 → Ícones de EXP / Ouro / Item (alinhados horizontalmente)
  #   y=191 → Valores numéricos abaixo dos ícones (fonte menor)
  #
  # Os ícones de recompensa são exibidos apenas se o valor for maior que 0,
  # e são posicionados sequencialmente da esquerda para a direita (x += 35).
  #
  # Nota: As posições Y internas desta janela são fixas pois dependem do
  #       layout da skin 'QuestDialogueWindow'. Serão migradas para Configs
  #       na Fase 2 do plano de modernização.
  #----------------------------------------------------------------------------
  def refresh
    # Limpa todo o conteúdo anterior antes de redesenhar
    contents.clear

    # Restaura o tamanho de fonte padrão para o início do desenho
    contents.font.size = Font.default_size

    # ── Nome da missão ────────────────────────────────────────────────────────
    # Usa cor de crise (amarelo/laranja) para destacar o título da missão
    change_color(crisis_color)
    draw_text(32, 4, contents_width, Configs::QUEST_LINE_HEIGHT, @quest[:name])

    # ── Descrição justificada ─────────────────────────────────────────────────
    # Remove quebras de linha do texto original e limpa a tag interna "QT<id>:"
    # que o servidor usa para identificar a missão, mas não deve ser exibida.
    change_color(normal_color)
    draw_justified_texts(
      10,                          # X: margem esquerda de 10px
      28,                          # Y: abaixo do título
      contents_width + 20,         # Largura: ligeiramente maior para justificação
      Configs::QUEST_LINE_HEIGHT,  # Altura de linha configurável
      $game_message.all_text.gsub("\n", '').sub(/QT(.*):/, '')
      # gsub("\n", '') → remove todas as quebras de linha do texto do servidor
      # sub(/QT(.*):/, '') → remove apenas a primeira ocorrência da tag QT<id>:
    )

    # ── Label "Recompensas" ───────────────────────────────────────────────────
    # Usa a cor hp_gauge_color2 (vermelho/laranja) para diferenciar da seção anterior
    change_color(hp_gauge_color2)
    draw_text(0, 147, contents_width, Configs::QUEST_LINE_HEIGHT, Vocab::Rewards, 1)

    # Restaura cor normal para os valores de recompensa
    change_color(normal_color)

    # ── Ícones e valores de recompensa ────────────────────────────────────────
    # Usa fonte menor para os valores numéricos abaixo dos ícones
    contents.font.size = Configs::QUEST_REWARD_FONT_SIZE

    # Posição X inicial dos ícones (centralizado visualmente na janela)
    x = 67

    # EXP — exibe ícone e valor apenas se a recompensa de EXP for maior que 0
    if @quest[:rew_exp] > 0
      draw_icon(Configs::EXP_ICON, x, 181)
      # Valor formatado com separadores de milhar, alinhado à direita do ícone
      draw_text(x - 4, 191, 31, Configs::QUEST_LINE_HEIGHT, format_number(@quest[:rew_exp]), 2)
      x += 35  # Avança 35px para o próximo ícone (24px ícone + 11px margem)
    end

    # Ouro — exibe ícone e valor apenas se a recompensa de ouro for maior que 0
    if @quest[:rew_gold] > 0
      draw_icon(Configs::GOLD_ICON, x, 181)
      draw_text(x - 4, 191, 31, Configs::QUEST_LINE_HEIGHT, format_number(@quest[:rew_gold]), 2)
      x += 35  # Avança para o próximo ícone
    end

    # Item — exibe ícone e quantidade apenas se houver item de recompensa definido
    if @quest[:rew_item_id] > 0
      # Obtém o objeto do item a partir do tipo (kind) e ID para acessar o ícone
      # $game_party.item_object converte kind+id no objeto correto (item/arma/armadura)
      draw_icon(
        $game_party.item_object(@quest[:rew_item_kind], @quest[:rew_item_id]).icon_index,
        x, 181
      )
      # Exibe a quantidade do item (ex: "3" para "x3 Poções")
      draw_text(x - 4, 191, 31, Configs::QUEST_LINE_HEIGHT, @quest[:rew_item_amount], 2)
    end
  end

  #----------------------------------------------------------------------------
  # * Aceita a missão — confirma ao servidor e fecha a janela
  #
  #   Chamado ao clicar no botão "Aceitar".
  #   Envia send_choice(0) ao servidor para indicar aceitação da missão.
  #   Limpa a mensagem do sistema e oculta a janela de diálogo.
  #----------------------------------------------------------------------------
  def accept
    # Notifica o servidor: jogador aceitou a missão (choice = 0)
    $network.send_choice(0)

    # Limpa a mensagem do sistema para liberar o fluxo de diálogo
    $game_message.clear

    # Oculta a janela de diálogo
    hide
  end

end