#==============================================================================
# [VS] Configs
#------------------------------------------------------------------------------
# Autor: Valentine
# Descrição: Configurações globais do sistema VXA-OS.
#            Todas as constantes do projeto são centralizadas aqui para
#            facilitar manutenção, ajustes e personalização sem precisar
#            editar scripts individuais.
#==============================================================================
module Configs

  Font.default_name    = 'VL Gothic'
  Font.default_outline = true
  Font.default_shadow  = false
  Font.default_bold    = false
  Font.default_size    = 16

  CHAT_FONT_NAME    = 'VL Gothic'
  CHAT_FONT_OUTLINE = false
  CHAT_FONT_SHADOW  = true
  CHAT_FONT_BOLD    = true
  CHAT_FONT_SIZE    = 17

  HOST         = '127.0.0.1'
  PORT         = 5000
  GAME_VERSION = 12983
  SHOP_WEBSITE = 'www.aldeiarpg.com'

  RESOLUTIONS = [
    { :width => 800,  :height => 608 },
    { :width => 1024, :height => 608 },
    { :width => 1024, :height => 672 },
    { :width => 1152, :height => 768 }
  ]

  LOADING_TIME   = 2
  LOADING_TITLES = ['Title1', 'Title2']

  MIN_CHARACTERS = 3
  MAX_CHARACTERS = 13
  MIN_LEVEL_PVP  = 2

  MAX_ACTORS          = 3
  MAX_HOTBAR          = 9
  MAX_DEFAULT_CLASSES = 5
  MAX_VIP_CLASSES     = 9

  MAX_ITEMS  = 999
  MAX_GOLD   = 99_999_999
  MAX_PARAMS = 999_999
  MAX_LEVEL  = 99

  MAX_PLAYER_SWITCHES  = 100
  MAX_PLAYER_VARIABLES = 100
  MAX_FRIENDS          = 20
  MAX_GUILD_MEMBERS    = 50
  MAX_PLAYER_ITEMS     = 30
  MAX_TRADE_ITEMS      = 12
  MAX_BANK_ITEMS       = 42
  MAX_CHAT_LINES       = 10
  MAX_PARTY_MEMBERS    = 4
  MAX_EQUIPS           = 9

  PAPERDOLL_DOWN_DIR  = [3, 5, 2, 7, 6, 8, 1, 0, 4]
  PAPERDOLL_LEFT_DIR  = [7, 0, 3, 5, 2, 6, 8, 1, 4]
  PAPERDOLL_RIGHT_DIR = [1, 3, 5, 2, 7, 6, 8, 0, 4]
  PAPERDOLL_UP_DIR    = [7, 1, 0, 3, 5, 2, 8, 6, 4]

  NORMAL_COLOR  = 0
  GLOBAL_COLOR  = 1
  SUCCESS_COLOR = 5
  ERROR_COLOR   = 10
  ALERT_COLOR   = 8
  ADM_MSG_COLOR = 17

  DEFAULT_COLOR = 0
  MONITOR_COLOR = 4
  ADMIN_COLOR   = 6
  ENEMY_COLOR   = 0
  BOSS_COLOR    = 10
  GUILD_COLOR   = 16

  ITEM_ICON   = 260
  SKILL_ICON  = 96
  STATUS_ICON = 121
  QUEST_ICON  = 227
  FRIEND_ICON = 536
  GUILD_ICON  = 535
  MENU_ICON   = 117

  PRIVATE_ICON = 4
  BLOCK_ICON   = 538
  UNLOCK_ICON  = 539
  TRADE_ICON   = 540
  PARTY_ICON   = 12

  CONFIG_ICON            = 532
  GOLD_ICON              = 262
  EXP_ICON               = 125
  ADD_GOLD_ICON          = 528
  REMOVE_GOLD_ICON       = 529
  MAP_PVP_ICON           = 534
  MAP_NONPVP_ICON        = 533
  PLAYER_ON_ICON         = 189
  PLAYER_OFF_ICON        = 187
  QUEST_NOT_STARTED_ICON = 537
  QUEST_FINISHED_ICON    = 190
  QUEST_IN_PROGRESS_ICON = 189
  LEAVE_PARTY_ICON       = 530
  EMOJI_ICON             = 541

  ICON_BUFF_START   = 64
  ICON_DEBUFF_START = 80

  START_POINTS     = 10
  TITLE_BAR_HEIGHT = 20

  TELEPORTS = []
  TELEPORTS << [
    { :map_id => 1, :x => 21, :y => 12, :gold => 10 },
    { :map_id => 2, :x => 4,  :y => 20, :gold => 20 }
  ]

  RANGE_WEAPONS = {}
  RANGE_WEAPONS[31] = { :projectile_name => 'Arrow', :range => 10, :item_id => 18 }
  RANGE_WEAPONS[49] = { :projectile_name => 'Fire',  :range => 10, :item_id => 0,
                        :step_anime => false, :mp_cost => 3 }

  RANGE_SKILLS = {}
  RANGE_SKILLS[51] = { :projectile_name => 'Fire' }
  RANGE_SKILLS[70] = { :projectile_name => 'Light', :step_anime => true }

  FORBIDDEN_NAMES = ['adm ', 'admin ', 'gm ', 'god ', 'mod ']

  ATTACK_TIME            = 0.8
  COOLDOWN_SKILL_TIME    = 1
  GLOBAL_ANTISPAM_TIME   = 1
  ATTACK_ANIMATION_TIME  = 30
  LEVEL_UP_ANIMATION_ID  = 40
  MAX_MAP_DROPS          = 20

  ATTACK_KEY       = :CTRL
  GET_DROP_KEY     = :SPACE
  SELECT_ENEMY_KEY = :TAB

  ITEM_KEY   = :LETTER_I
  SKILL_KEY  = :LETTER_H
  STATUS_KEY = :LETTER_C
  QUEST_KEY  = :LETTER_Q
  FRIEND_KEY = :LETTER_F
  GUILD_KEY  = :LETTER_G
  MENU_KEY   = :LETTER_M

  HOTKEYS = [:KEY_1, :KEY_2, :KEY_3, :KEY_4, :KEY_5,
             :KEY_6, :KEY_7, :KEY_8, :KEY_9]

  BALLOONS_KEYS = [:F3, :F4, :F5, :F6, :F7, :F8, :F9, :F10, :F11, :F12]

  HUD_ACTOR_INDEX = 1
  HUD_X = 11
  HUD_Y = 9
  HUD_Z = 50
  HUD_WIDTH  = 255
  HUD_HEIGHT = 107
  HUD_FONT_SIZE = 18
  HUD_FONT_BOLD = true
  HUD_BG_RECT_W = 248
  HUD_BG_RECT_H = 98
  HUD_FACE_X = 8
  HUD_FACE_Y = 1
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
  HUD_EXP_WIDTH    = 308
  HUD_EXP_HEIGHT   = 22
  HUD_EXP_OFFSET_X = -109
  HUD_EXP_OFFSET_Y = -28
  HUD_EXP_SHOW_PERCENT = true
  HUD_LEVEL_X      = 0
  HUD_LEVEL_Y      = 77
  HUD_LEVEL_TEXT_Y = 83

  CRITICAL_MULTIPLIER  = 3.0
  MAX_PROJECTILE_STEPS = 50

  DROP_FONT_SIZE     = 15
  DROP_NAME_OFFSET_Y = 18

  #============================================================================
  # ── MINIMAP (Sprite_Minimap) ──────────────────────────────────────────────
  # Configurações do Minimap QUADRADO com frame desenhado via Bitmap.
  # Inspirado em Tibia Online, MU Online e Ragnarok Online.
  #============================================================================

  MINIMAP_SIZE         = 160
  MINIMAP_MAP_AREA     = 128
  MINIMAP_PADDING      = 16
  MINIMAP_BORDER       = 2
  MINIMAP_NAME_HEIGHT  = 20
  MINIMAP_COORD_HEIGHT = 16
  MINIMAP_COORD_FORMAT = 'X: %d  Y: %d'
  MINIMAP_CLOCK_HEIGHT = 16
  MINIMAP_CLOCK_FORMAT = '%H:%M:%S'

  MINIMAP_X_MARGIN = 10
  MINIMAP_Y        = 8
  MINIMAP_Z        = 50

  MINIMAP_FONT_SIZE = 14
  MINIMAP_FONT_BOLD = false

  MINIMAP_BG_COLOR = Color.new(0, 0, 0, 200)
  MINIMAP_MAP_BG   = Color.new(20, 20, 40, 200)

  MINIMAP_FRAME_OUTER  = Color.new(180, 150, 80, 255)
  MINIMAP_FRAME_INNER  = Color.new(80, 60, 20, 220)
  MINIMAP_FRAME_CORNER = Color.new(255, 220, 120, 255)

  MINIMAP_SEPARATOR_COLOR = Color.new(180, 150, 80, 160)

  # ── Ícone PVP / Safe ──
  MINIMAP_PVP_X_OFFSET = -28
  MINIMAP_PVP_Y_OFFSET = 0

  #============================================================================
  # ── IMAGEM DE FUNDO DO MINIMAP ────────────────────────────────────────────
  # Nome do arquivo PNG em Graphics/System/ usado como fundo do frame quadrado.
  # Defina o nome sem extensão (ex: 'HUD_Minimap' → Graphics/System/HUD_Minimap.png)
  # Se nil ou string vazia, o fundo é desenhado via fill_rect com as cores acima.
  #============================================================================
  MINIMAP_BG_IMAGE = 'HUD_Minimap'

  # Se true, o frame decorativo via Bitmap ainda é desenhado sobre a imagem.
  # Se false (recomendado), o frame é omitido quando MINIMAP_BG_IMAGE está ativo,
  # pois presume-se que o PNG já contém o frame desenhado.
  MINIMAP_DRAW_FRAME_OVER_BG = false

  #============================================================================
  # ── DEBUG ─────────────────────────────────────────────────────────────────
  #============================================================================
  DEBUG_LOG = false

end