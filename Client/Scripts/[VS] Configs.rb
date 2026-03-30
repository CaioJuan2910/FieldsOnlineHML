#==============================================================================
# [VS] Configs
#------------------------------------------------------------------------------
# Autor: Valentine
# Descrição: Configurações globais do sistema VXA-OS.
#             Todas as constantes do projeto são centralizadas aqui para
#             facilitar manutenção, ajustes e personalização sem precisar
#             editar scripts individuais.
#==============================================================================

module Configs

  #============================================================================
  # ── FONTE PADRÃO ────────────────────────────────────────────────────────────
  # Configurações globais de fonte aplicadas a todos os elementos do jogo.
  #============================================================================
  Font.default_name    = 'VL Gothic'
  Font.default_outline = true
  Font.default_shadow  = false
  Font.default_bold    = false
  Font.default_size    = 16

  #============================================================================
  # ── FONTE DO CHAT ────────────────────────────────────────────────────────────
  # Configurações de fonte específicas para a janela de chat.
  #============================================================================
  CHAT_FONT_NAME    = 'VL Gothic'
  CHAT_FONT_OUTLINE = false
  CHAT_FONT_SHADOW  = true
  CHAT_FONT_BOLD    = true
  CHAT_FONT_SIZE    = 17

  #============================================================================
  # ── REDE / SERVIDOR ──────────────────────────────────────────────────────────
  # Endereço do servidor, porta de conexão, versão do jogo e site da loja.
  #============================================================================
  HOST         = '127.0.0.1'
  PORT         = 5000
  GAME_VERSION = 12983
  SHOP_WEBSITE = 'www.aldeiarpg.com'

  #============================================================================
  # ── RESOLUÇÕES ───────────────────────────────────────────────────────────────
  # Lista de resoluções disponíveis para o jogador selecionar nas opções.
  # Cada entrada é um hash com :width e :height.
  #============================================================================
  RESOLUTIONS = [
    { :width => 800,  :height => 608 },
    { :width => 1024, :height => 608 },
    { :width => 1024, :height => 672 },
    { :width => 1152, :height => 768 }
  ]

  #============================================================================
  # ── TELA DE CARREGAMENTO ─────────────────────────────────────────────────────
  # Tempo de exibição (em segundos) e lista de imagens de título usadas
  # na tela de loading.
  #============================================================================
  LOADING_TIME   = 2
  LOADING_TITLES = ['Title1', 'Title2']

  #============================================================================
  # ── PERSONAGENS ──────────────────────────────────────────────────────────────
  # Limites de caracteres no nome, nível mínimo para PVP e número máximo
  # de personagens por conta.
  #============================================================================
  MIN_CHARACTERS = 3
  MAX_CHARACTERS = 13
  MIN_LEVEL_PVP  = 2

  #============================================================================
  # ── LIMITES GERAIS ───────────────────────────────────────────────────────────
  # Quantidade máxima de atores, slots de hotbar, classes padrão e VIP.
  #============================================================================
  MAX_ACTORS          = 3
  MAX_HOTBAR          = 9
  MAX_DEFAULT_CLASSES = 5
  MAX_VIP_CLASSES     = 9

  #============================================================================
  # ── LIMITES DE VALORES ───────────────────────────────────────────────────────
  # Caps de itens, ouro, atributos e nível máximo do personagem.
  #============================================================================
  MAX_ITEMS  = 999
  MAX_GOLD   = 99_999_999
  MAX_PARAMS = 999_999
  MAX_LEVEL  = 99

  #============================================================================
  # ── LIMITES DE SISTEMAS ──────────────────────────────────────────────────────
  # Capacidade máxima de cada sistema: switches, variáveis, amigos, guilda,
  # inventário, troca, banco, chat, grupo e equipamentos.
  #============================================================================
  MAX_PLAYER_SWITCHES   = 100
  MAX_PLAYER_VARIABLES  = 100
  MAX_FRIENDS           = 20
  MAX_GUILD_MEMBERS     = 50
  MAX_PLAYER_ITEMS      = 30
  MAX_TRADE_ITEMS       = 12
  MAX_BANK_ITEMS        = 42
  MAX_CHAT_LINES        = 10
  MAX_PARTY_MEMBERS     = 4
  MAX_EQUIPS            = 9

  #============================================================================
  # ── PAPERDOLL (DIREÇÕES) ─────────────────────────────────────────────────────
  # Ordem dos frames do paperdoll para cada direção de movimento do personagem.
  # Os índices correspondem às posições no spritesheet de equipamentos.
  #============================================================================
  PAPERDOLL_DOWN_DIR  = [3, 5, 2, 7, 6, 8, 1, 0, 4]
  PAPERDOLL_LEFT_DIR  = [7, 0, 3, 5, 2, 6, 8, 1, 4]
  PAPERDOLL_RIGHT_DIR = [1, 3, 5, 2, 7, 6, 8, 0, 4]
  PAPERDOLL_UP_DIR    = [7, 1, 0, 3, 5, 2, 8, 6, 4]

  #============================================================================
  # ── CORES DO CHAT ────────────────────────────────────────────────────────────
  # Índices de cor usados nas mensagens do chat (referência à paleta do sistema).
  #============================================================================
  NORMAL_COLOR  = 0
  GLOBAL_COLOR  = 1
  SUCCESS_COLOR = 5
  ERROR_COLOR   = 10
  ALERT_COLOR   = 8
  ADM_MSG_COLOR = 17

  #============================================================================
  # ── CORES DE ENTIDADES ───────────────────────────────────────────────────────
  # Índices de cor para nomes de jogadores, NPCs, inimigos e guildas
  # exibidos acima dos personagens no mapa.
  #============================================================================
  DEFAULT_COLOR = 0
  MONITOR_COLOR = 4
  ADMIN_COLOR   = 6
  ENEMY_COLOR   = 0
  BOSS_COLOR    = 10
  GUILD_COLOR   = 16

  #============================================================================
  # ── ÍCONES DE MENU ───────────────────────────────────────────────────────────
  # Índices dos ícones usados nos botões e abas do menu principal.
  #============================================================================
  ITEM_ICON    = 260
  SKILL_ICON   = 96
  STATUS_ICON  = 121
  QUEST_ICON   = 227
  FRIEND_ICON  = 536
  GUILD_ICON   = 535
  MENU_ICON    = 117

  #============================================================================
  # ── ÍCONES DE AÇÃO (JOGADOR) ─────────────────────────────────────────────────
  # Ícones usados em menus de contexto e ações sobre outros jogadores
  # (mensagem privada, bloquear, desbloquear, trocar, grupo).
  #============================================================================
  PRIVATE_ICON = 4
  BLOCK_ICON   = 538
  UNLOCK_ICON  = 539
  TRADE_ICON   = 540
  PARTY_ICON   = 12

  #============================================================================
  # ── ÍCONES DE SISTEMA ────────────────────────────────────────────────────────
  # Ícones usados em janelas de configuração, ouro, EXP, mapa, status
  # de jogadores online/offline, missões e grupo.
  #============================================================================
  CONFIG_ICON        = 532
  GOLD_ICON          = 262
  EXP_ICON           = 125
  ADD_GOLD_ICON      = 528
  REMOVE_GOLD_ICON   = 529
  MAP_PVP_ICON       = 534
  MAP_NONPVP_ICON    = 533
  PLAYER_ON_ICON     = 189
  PLAYER_OFF_ICON    = 187
  QUEST_NOT_STARTED_ICON = 537
  QUEST_FINISHED_ICON    = 190
  QUEST_IN_PROGRESS_ICON = 189
  LEAVE_PARTY_ICON   = 530
  EMOJI_ICON         = 541

  #============================================================================
  # ── ÍCONES DE BUFF / DEBUFF ──────────────────────────────────────────────────
  # Índice inicial dos ícones de buff e debuff no iconset.
  # Os ícones são lidos sequencialmente a partir desses índices.
  #============================================================================
  ICON_BUFF_START   = 64
  ICON_DEBUFF_START = 80

  #============================================================================
  # ── PONTOS INICIAIS / INTERFACE ──────────────────────────────────────────────
  # Pontos de atributo disponíveis ao criar um personagem e altura da
  # barra de título das janelas.
  #============================================================================
  START_POINTS      = 10
  TITLE_BAR_HEIGHT  = 20

  #============================================================================
  # ── TELEPORTES ───────────────────────────────────────────────────────────────
  # Lista de destinos de teleporte disponíveis no jogo.
  # Cada entrada contém: mapa de destino, coordenadas X/Y e custo em ouro.
  #============================================================================
  TELEPORTS = []
  TELEPORTS << [
    { :map_id => 1, :x => 21, :y => 12, :gold => 10 },
    { :map_id => 2, :x => 4,  :y => 20, :gold => 20 }
  ]

  #============================================================================
  # ── ARMAS DE ALCANCE ─────────────────────────────────────────────────────────
  # Define quais armas (por ID) disparam projéteis.
  # Chave: ID da arma no banco de dados.
  # Valores:
  #   :projectile_name => nome do arquivo de animação do projétil
  #   :range           => alcance máximo em tiles
  #   :item_id         => ID do item consumido por disparo (0 = nenhum)
  #   :step_anime      => anima o projétil passo a passo (opcional)
  #   :mp_cost         => custo de MP por disparo (opcional)
  #============================================================================
  RANGE_WEAPONS = {}
  RANGE_WEAPONS[31] = {
    :projectile_name => 'Arrow',
    :range           => 10,
    :item_id         => 18
  }
  RANGE_WEAPONS[49] = {
    :projectile_name => 'Fire',
    :range           => 10,
    :item_id         => 0,
    :step_anime      => false,
    :mp_cost         => 3
  }

  #============================================================================
  # ── HABILIDADES DE ALCANCE ───────────────────────────────────────────────────
  # Define quais habilidades (por ID) disparam projéteis.
  # Chave: ID da habilidade no banco de dados.
  # Valores:
  #   :projectile_name => nome do arquivo de animação do projétil
  #   :step_anime      => anima o projétil passo a passo (opcional)
  #============================================================================
  RANGE_SKILLS = {}
  RANGE_SKILLS[51] = { :projectile_name => 'Fire' }
  RANGE_SKILLS[70] = {
    :projectile_name => 'Light',
    :step_anime      => true
  }

  #============================================================================
  # ── NOMES PROIBIDOS ──────────────────────────────────────────────────────────
  # Lista de prefixos de nomes que não podem ser usados por jogadores comuns.
  # Impede que jogadores se passem por administradores ou moderadores.
  #============================================================================
  FORBIDDEN_NAMES = ['adm ', 'admin ', 'gm ', 'god ', 'mod ']

  #============================================================================
  # ── TEMPOS E ANIMAÇÕES ───────────────────────────────────────────────────────
  # Intervalos de tempo (em segundos ou frames) para ações de combate,
  # cooldowns, antispam e animações especiais.
  #============================================================================
  ATTACK_TIME           = 0.8   # Intervalo entre ataques normais (segundos)
  COOLDOWN_SKILL_TIME   = 1     # Cooldown padrão de habilidades (segundos)
  GLOBAL_ANTISPAM_TIME  = 1     # Intervalo mínimo entre mensagens no chat (segundos)
  ATTACK_ANIMATION_TIME = 30    # Duração da animação de ataque (frames)
  LEVEL_UP_ANIMATION_ID = 40    # ID da animação exibida ao subir de nível
  MAX_MAP_DROPS         = 20    # Número máximo de drops simultâneos no mapa

  #============================================================================
  # ── TECLAS DE AÇÃO ───────────────────────────────────────────────────────────
  # Mapeamento das teclas de atalho para ações principais do jogador.
  #============================================================================
  ATTACK_KEY       = :CTRL
  GET_DROP_KEY     = :SPACE
  SELECT_ENEMY_KEY = :TAB

  #============================================================================
  # ── TECLAS DE MENU ───────────────────────────────────────────────────────────
  # Teclas de atalho para abrir cada janela/aba do menu principal.
  #============================================================================
  ITEM_KEY   = :LETTER_I
  SKILL_KEY  = :LETTER_H
  STATUS_KEY = :LETTER_C
  QUEST_KEY  = :LETTER_Q
  FRIEND_KEY = :LETTER_F
  GUILD_KEY  = :LETTER_G
  MENU_KEY   = :LETTER_M

  #============================================================================
  # ── HOTKEYS DA HOTBAR ────────────────────────────────────────────────────────
  # Teclas numéricas associadas aos slots da hotbar (1 a 9).
  #============================================================================
  HOTKEYS = [:KEY_1, :KEY_2, :KEY_3, :KEY_4, :KEY_5, :KEY_6, :KEY_7, :KEY_8, :KEY_9]

  #============================================================================
  # ── TECLAS DE BALÕES (EMOTES) ────────────────────────────────────────────────
  # Teclas de função (F3–F12) usadas para exibir balões de emote no mapa.
  #============================================================================
  BALLOONS_KEYS = [:F3, :F4, :F5, :F6, :F7, :F8, :F9, :F10, :F11, :F12]

  #============================================================================
  # ── HUD (Sprite_HUD) ─────────────────────────────────────────────────────────
  # Configurações da HUD principal (barras de HP, MP, EXP, face e nível).
  # Todas as posições e dimensões podem ser ajustadas aqui sem precisar
  # editar o Sprite_HUD diretamente.
  #============================================================================

  # Índice do ator principal exibido na HUD (padrão: 1)
  HUD_ACTOR_INDEX = 1

  # Posição da HUD na tela (canto superior esquerdo)
  HUD_X = 11
  HUD_Y = 9
  HUD_Z = 50

  # Dimensões do bitmap principal da HUD
  HUD_WIDTH  = 255
  HUD_HEIGHT = 107

  # Fonte da HUD
  HUD_FONT_SIZE = 18
  HUD_FONT_BOLD = true

  # Dimensões do recorte do fundo (HUDBase)
  HUD_BG_RECT_W = 248
  HUD_BG_RECT_H = 98

  # Posição da face do personagem dentro da HUD
  HUD_FACE_X = 8
  HUD_FACE_Y = 1

  # Configurações das barras de HP e MP
  HUD_BAR_MAX_WIDTH = 123
  HUD_HP_BAR_X      = 107
  HUD_HP_BAR_Y      = 2
  HUD_HP_LABEL_X    = 111
  HUD_HP_LABEL_Y    = 7
  HUD_HP_TEXT_Y     = 7
  HUD_MP_BAR_X      = 107
  HUD_MP_BAR_Y      = 30
  HUD_MP_LABEL_X    = 111
  HUD_MP_LABEL_Y    = 35
  HUD_MP_TEXT_Y     = 35

  # Configurações da barra de EXP (sprite separado, centralizado na base da tela)
  HUD_EXP_WIDTH    = 308
  HUD_EXP_HEIGHT   = 22
  HUD_EXP_OFFSET_X = -109
  HUD_EXP_OFFSET_Y = -28

  # Se true, exibe o percentual de EXP restante (ex: "72.4%") no estilo MU Online
  # Se false, exibe o valor numérico de EXP faltante (comportamento original)
  HUD_EXP_SHOW_PERCENT = true

  # Configurações do nível exibido na HUD
  HUD_LEVEL_X      = 0
  HUD_LEVEL_Y      = 77
  HUD_LEVEL_TEXT_Y = 83

  #============================================================================
  # ── COMBATE (game_battle) ────────────────────────────────────────────────────
  # Configurações do sistema de combate em tempo real.
  #============================================================================

  # Multiplicador de dano crítico
  CRITICAL_MULTIPLIER = 3.0

  # Número máximo de passos do loop de trajetória de projétil
  MAX_PROJECTILE_STEPS = 50

  #============================================================================
  # ── DROPS (Sprite_Drop) ──────────────────────────────────────────────────────
  # Configurações visuais dos drops no mapa.
  #============================================================================

  # Tamanho da fonte do nome do item exibido ao passar o mouse
  DROP_FONT_SIZE = 15

  # Distância vertical (em pixels) do nome acima do ícone do drop
  DROP_NAME_OFFSET_Y = 18

  #============================================================================
  # ── MINIMAP (Sprite_Minimap) ─────────────────────────────────────────────────
  # Configurações do Minimap QUADRADO com frame desenhado via Bitmap.
  # Inspirado em Tibia Online, MU Online e Ragnarok Online.
  #============================================================================

  # ── Dimensões ────────────────────────────────────────────────────────────────

  # Tamanho total do minimap (largura = altura = quadrado)
  MINIMAP_SIZE     = 160

  # Tamanho da área de mapa interna (dentro do frame)
  # Regra: MINIMAP_SIZE - 2 * MINIMAP_PADDING = 160 - 2*16 = 128
  MINIMAP_MAP_AREA = 128

  # Espaço entre a borda do frame e a borda da área do mapa (em pixels)
  MINIMAP_PADDING  = 16

  # Espessura das linhas do frame (bordas externa e interna), em pixels
  MINIMAP_BORDER   = 2

  # Altura da área do nome do mapa abaixo do quadrado do frame (em pixels)
  MINIMAP_NAME_HEIGHT = 20

  # Altura da linha de coordenadas (X/Y do jogador) abaixo do nome do mapa
  MINIMAP_COORD_HEIGHT = 16

  # Formato do texto de coordenadas — %d é substituído por X e Y respectivamente
  MINIMAP_COORD_FORMAT = 'X: %d  Y: %d'

  # Altura da linha do relógio em tempo real abaixo das coordenadas
  MINIMAP_CLOCK_HEIGHT = 16

  # Formato do relógio — padrão strftime do Ruby
  # '%H:%M:%S' → 14:32:07 (com segundos)
  # '%H:%M'    → 14:32    (sem segundos)
  MINIMAP_CLOCK_FORMAT = '%H:%M:%S'

  # ── Posição na tela ───────────────────────────────────────────────────────────

  # Margem em pixels entre o minimap e a borda direita da tela
  MINIMAP_X_MARGIN = 10

  # Posição Y do minimap (pixels a partir do topo da tela)
  MINIMAP_Y = 8

  # Z index do minimap
  MINIMAP_Z = 50

  # ── Fonte ────────────────────────────────────────────────────────────────────

  # Tamanho da fonte para o nome do mapa, coordenadas, relógio e tooltips
  MINIMAP_FONT_SIZE = 14

  # Negrito para os textos do minimap
  MINIMAP_FONT_BOLD = false

  # ── Cores do fundo ───────────────────────────────────────────────────────────

  # Cor de fundo do bitmap completo do minimap
  MINIMAP_BG_COLOR  = Color.new(0, 0, 0, 200)

  # Cor de fundo específica da área do mapa interno
  MINIMAP_MAP_BG    = Color.new(20, 20, 40, 200)

  # ── Cores do frame ───────────────────────────────────────────────────────────
  # Frame desenhado via fill_rect — sem Windowskin
  # Inspirado nos frames dourados de Tibia Online e MU Online

  # Borda EXTERNA ao redor de todo o minimap
  MINIMAP_FRAME_OUTER  = Color.new(180, 150, 80, 255)

  # Borda INTERNA ao redor da área de mapa
  MINIMAP_FRAME_INNER  = Color.new(80, 60, 20, 220)

  # Cantos DECORATIVOS (4×4 px) nos 4 cantos da borda interna
  MINIMAP_FRAME_CORNER = Color.new(255, 220, 120, 255)

  # ── Separadores de seção ─────────────────────────────────────────────────────
  # Linhas horizontais de 1px que dividem visualmente as seções de texto
  # abaixo do frame do mapa (nome → coordenadas → relógio).
  # A linha tem margem de 4px em cada lado para não tocar as bordas do frame.
  # Ajuste a cor e a opacidade (4º parâmetro) conforme o estilo desejado.
  MINIMAP_SEPARATOR_COLOR = Color.new(180, 150, 80, 160)

  # ── Ícone PVP / Safe ─────────────────────────────────────────────────────────
  # Sprite separado posicionado ao lado esquerdo do minimap.
  # Os offsets são relativos à posição self.x / self.y do Sprite_Minimap.
  # Ajuste MINIMAP_PVP_X_OFFSET para mover horizontalmente (negativo = esquerda).
  # Ajuste MINIMAP_PVP_Y_OFFSET para mover verticalmente.
  MINIMAP_PVP_X_OFFSET = -28   # 28px à esquerda da borda esquerda do minimap
  MINIMAP_PVP_Y_OFFSET = 0     # Alinhado ao topo do minimap

  #============================================================================
  # ── DEBUG ─────────────────────────────────────────────────────────────────────
  # Flags de debug para desenvolvimento. Desative em produção.
  #============================================================================

  # Se true, exibe logs de conexão/desconexão de clientes no console do servidor
  DEBUG_LOG = false

end