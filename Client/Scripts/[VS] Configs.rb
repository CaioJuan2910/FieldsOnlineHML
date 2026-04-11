#==============================================================================
# ** [VS] Configs — Fields Online
#------------------------------------------------------------------------------
#  Módulo central de configurações do cliente Fields Online.
#  Este arquivo é compartilhado entre Cliente e Servidor.
#  Todas as constantes aqui definidas afetam diretamente o comportamento
#  do jogo — edite com atenção.
#------------------------------------------------------------------------------
#  Autor Original : Valentine (VXA-OS)
#  Projeto        : Fields Online HML
#  Versão         : 1.0.0
#  Atualizado em  : 11/04/2026
#==============================================================================

module Configs

  #============================================================================
  # >> SEÇÃO 1 — FONTE PADRÃO
  #----------------------------------------------------------------------------
  #  Define a fonte padrão utilizada em todas as janelas e elementos de texto
  #  do jogo. Certifique-se de que a fonte escolhida está instalada no sistema
  #  ou incluída na pasta do projeto.
  #
  #  Dica: Para usar uma fonte customizada, coloque o arquivo .ttf na pasta
  #  raiz do projeto e referencie o nome exato da família tipográfica.
  #============================================================================

  # Nome da fonte padrão utilizada em todo o jogo
  Font.default_name    = 'VL Gothic'

  # Exibir contorno (outline) ao redor das letras — melhora legibilidade
  Font.default_outline = true

  # Exibir sombra abaixo das letras — efeito visual adicional
  Font.default_shadow  = false

  # Texto em negrito por padrão — false para visual mais limpo
  Font.default_bold    = false

  # Tamanho padrão da fonte em pixels — recomendado entre 14 e 18
  Font.default_size    = 16

  #============================================================================
  # >> SEÇÃO 2 — FONTE DO CHAT
  #----------------------------------------------------------------------------
  #  Configurações específicas de fonte para a janela de bate-papo.
  #  Pode ter valores diferentes da fonte padrão do jogo para destacar
  #  visualmente a área de comunicação entre jogadores.
  #============================================================================

  # Nome da fonte utilizada na janela de chat
  CHAT_FONT_NAME    = 'VL Gothic'

  # Exibir contorno nas letras do chat
  CHAT_FONT_OUTLINE = false

  # Exibir sombra nas letras do chat — recomendado true para legibilidade
  CHAT_FONT_SHADOW  = true

  # Texto em negrito no chat — facilita leitura em fundos escuros
  CHAT_FONT_BOLD    = true

  # Tamanho da fonte do chat em pixels — ligeiramente maior que o padrão
  CHAT_FONT_SIZE    = 17

  #============================================================================
  # >> SEÇÃO 3 — REDE
  #----------------------------------------------------------------------------
  #  Configurações de conexão entre o cliente e o servidor.
  #  Para ambiente de homologação (HML), o HOST aponta para localhost.
  #  Em produção, substitua pelo IP ou domínio público do servidor.
  #
  #  ATENÇÃO: Qualquer alteração na PORT deve ser replicada no arquivo
  #  configs.ini do servidor para manter a sincronização entre cliente
  #  e servidor. Portas abaixo de 1024 podem exigir permissão de root.
  #============================================================================

  # Endereço IP ou domínio do servidor de jogo
  # Ambiente : HML (local)  → '127.0.0.1'
  # Produção : substituir pelo IP/domínio público do servidor
  HOST = '127.0.0.1'

  # Porta de comunicação TCP do servidor
  # Deve coincidir com a porta definida no configs.ini do servidor
  PORT = 5000

  #============================================================================
  # >> SEÇÃO 4 — VERSÃO DO JOGO
  #----------------------------------------------------------------------------
  #  Versão semântica do cliente Fields Online no formato MAJOR.MINOR.PATCH.
  #
  #  Significado de cada segmento:
  #    MAJOR → mudanças incompatíveis com versões anteriores (breaking changes)
  #    MINOR → novas funcionalidades compatíveis com versões anteriores
  #    PATCH → correções de bugs e ajustes menores sem impacto na API
  #
  #  O servidor valida esta versão no momento da conexão. Clientes com
  #  versão diferente da esperada pelo servidor serão recusados
  #  automaticamente com mensagem de atualização obrigatória.
  #============================================================================

  # Versão semântica atual do cliente Fields Online
  GAME_VERSION = '1.0.0'

  #============================================================================
  # >> SEÇÃO 5 — SITE E LOJA
  #----------------------------------------------------------------------------
  #  Endereço do site oficial do Fields Online.
  #  Utilizado como link de redirecionamento para compra de VIP, itens
  #  da loja e acesso ao painel de conta do jogador.
  #============================================================================

  # URL do site oficial / loja do Fields Online (sem protocolo http/https)
  SHOP_WEBSITE = 'www.fieldsonline.com.br'

  #============================================================================
  # >> SEÇÃO 6 — RESOLUÇÕES
  #----------------------------------------------------------------------------
  #  Lista de resoluções disponíveis para o jogador selecionar nas
  #  configurações de vídeo. A resolução ativa é definida pelo campo
  #  ResolutionID no arquivo settings.ini do jogador.
  #
  #  ATENÇÃO: A resolução máxima sem DirectX é 640x480.
  #  As resoluções abaixo requerem o executável com suporte estendido
  #  (ex: mkxp, CustomEXE ou patch de resolução compatível com VXA-OS).
  #
  #  Formato de cada entrada:
  #    :width  → largura da tela em pixels
  #    :height → altura da tela em pixels
  #============================================================================

  # Resoluções disponíveis para seleção pelo jogador
  RESOLUTIONS = [
    { :width => 800,  :height => 608 },   # Resolução padrão (recomendada)
    { :width => 1024, :height => 608 },   # Wide padrão
    { :width => 1024, :height => 672 },   # Wide alta
  ]

  #============================================================================
  # >> SEÇÃO 7 — TELA DE CARREGAMENTO
  #----------------------------------------------------------------------------
  #  Configurações da tela de loading exibida ao iniciar o jogo.
  #  As imagens devem estar na pasta Graphics/Titles1 do projeto.
  #
  #  Uma imagem é sorteada aleatoriamente a cada inicialização, criando
  #  variedade visual para o jogador. Adicione quantas quiser à lista.
  #============================================================================

  # Tempo de exibição da tela de loading em segundos (0 = desativado)
  LOADING_TIME   = 2

  # Lista de imagens de fundo sorteadas aleatoriamente no loading
  # Caminho base: Graphics/Titles1/ — informe apenas o nome do arquivo
  LOADING_TITLES = ['Title1', 'Title2']

  #============================================================================
  # >> SEÇÃO 8 — PERSONAGENS
  #----------------------------------------------------------------------------
  #  Regras e limites relacionados à criação e gerenciamento de personagens.
  #  Estes valores são validados tanto no cliente quanto no servidor para
  #  garantir consistência e segurança nos dados.
  #============================================================================

  # Quantidade mínima de caracteres permitidos no nome do personagem
  MIN_CHARACTERS = 3

  # Quantidade máxima de caracteres permitidos no nome do personagem
  MAX_CHARACTERS = 13

  # Quantidade máxima de heróis (personagens) por conta de jogador
  MAX_ACTORS = 3

  # Nível mínimo para que o jogador possa atacar e ser atacado em mapas PvP
  MIN_LEVEL_PVP = 2

  # Quantidade de pontos de atributos disponíveis na criação do personagem
  START_POINTS = 10

  # Quantidade máxima de classes disponíveis para jogadores comuns (free)
  MAX_DEFAULT_CLASSES = 5

  # Quantidade máxima de classes disponíveis para jogadores VIP (premium)
  MAX_VIP_CLASSES = 9

  #============================================================================
  # >> SEÇÃO 9 — LIMITES DO JOGO
  #----------------------------------------------------------------------------
  #  Define os valores máximos dos principais recursos do jogador.
  #  Estes valores impactam diretamente o balanceamento e a progressão
  #  do personagem ao longo do jogo.
  #
  #  NOTA — MAX_LEVEL: Atualmente definido em 99.
  #  Quando o sistema de progressão for expandido, aumente este valor
  #  e revise as tabelas de EXP e atributos no banco de dados do servidor.
  #============================================================================

  # Quantidade máxima de itens, armas e protetores no inventário e no banco
  MAX_ITEMS  = 999

  # Quantidade máxima de ouro que um jogador pode acumular
  MAX_GOLD   = 99_999_999

  # Valor máximo de qualquer parâmetro de combate (ATK, DEF, MATK, etc.)
  MAX_PARAMS = 999_999

  # Nível máximo atingível pelo jogador
  # TODO: Aumentar futuramente conforme o sistema de progressão for expandido
  MAX_LEVEL  = 99

  #============================================================================
  # >> SEÇÃO 10 — INVENTÁRIO, TROCA E BANCO
  #----------------------------------------------------------------------------
  #  Define os tamanhos dos containers de itens do jogador.
  #  Cada valor representa o número de slots disponíveis no respectivo
  #  container. Alterar estes valores afeta a interface e o banco de dados.
  #============================================================================

  # Slots de itens disponíveis no inventário do jogador
  MAX_PLAYER_ITEMS = 30

  # Slots de itens disponíveis na janela de troca entre jogadores
  MAX_TRADE_ITEMS  = 12

  # Slots de itens disponíveis no banco/armazém do jogador
  MAX_BANK_ITEMS   = 42

  #============================================================================
  # >> SEÇÃO 11 — SWITCHES E VARIÁVEIS
  #----------------------------------------------------------------------------
  #  Quantidade de switches e variáveis individuais por jogador.
  #  Estes valores controlam o espaço alocado por personagem no banco de dados.
  #
  #  ATENÇÃO: Estes valores devem ser definidos ANTES da criação dos
  #  primeiros personagens no banco de dados. Alterações após personagens
  #  já criados podem causar inconsistências e corrupção nos dados salvos.
  #============================================================================

  # Quantidade máxima de switches individuais por jogador
  MAX_PLAYER_SWITCHES  = 100

  # Quantidade máxima de variáveis individuais por jogador
  MAX_PLAYER_VARIABLES = 100

  #============================================================================
  # >> SEÇÃO 12 — SOCIAL (AMIGOS, GRUPO E GUILDA)
  #----------------------------------------------------------------------------
  #  Limites dos sistemas sociais do jogo. Estes valores definem o tamanho
  #  máximo de cada agrupamento social disponível para os jogadores.
  #============================================================================

  # Quantidade máxima de jogadores na lista de amigos de um personagem
  MAX_FRIENDS       = 20

  # Quantidade máxima de membros em um grupo (party) simultâneo
  MAX_PARTY_MEMBERS = 4

  # Quantidade máxima de membros em uma guilda
  MAX_GUILD_MEMBERS = 50

  #============================================================================
  # >> SEÇÃO 13 — CHAT
  #----------------------------------------------------------------------------
  #  Configurações do sistema de chat do jogo, incluindo limites de exibição
  #  e proteção contra spam no canal global.
  #============================================================================

  # Quantidade máxima de linhas visíveis na janela de chat
  # Valores entre 8 e 12 são recomendados para boa legibilidade
  MAX_CHAT_LINES = 10

  # Tempo de espera em segundos entre mensagens no chat global (anti-spam)
  # Aumentar este valor reduz o spam, mas pode prejudicar a comunicação
  GLOBAL_ANTISPAM_TIME = 1

  #============================================================================
  # >> SEÇÃO 14 — HOTBAR E ATALHOS
  #----------------------------------------------------------------------------
  #  Define o tamanho da barra de atalhos rápidos (hotbar) do jogador.
  #  A hotbar permite acesso rápido a habilidades e itens de uso frequente.
  #============================================================================

  # Quantidade máxima de slots na hotbar de habilidades e itens
  MAX_HOTBAR = 9

  #============================================================================
  # >> SEÇÃO 15 — EQUIPAMENTOS (PAPERDOLL)
  #----------------------------------------------------------------------------
  #  Define a quantidade de slots de equipamento e a ordem em que os
  #  gráficos do paperdoll são sobrepostos para cada direção do personagem.
  #
  #  Mapeamento dos slots de equipamento:
  #    0 = Arma        | 1 = Escudo     | 2 = Capacete
  #    3 = Armadura    | 4 = Acessório  | 5 = Amuleto
  #    6 = Capa        | 7 = Luva       | 8 = Bota
  #
  #  As matrizes PAPERDOLL_*_DIR definem a ordem de renderização (z-order)
  #  das camadas de equipamento para cada direção de movimento do sprite.
  #  O primeiro elemento da lista é renderizado primeiro (camada inferior).
  #
  #  ATENÇÃO: MAX_EQUIPS deve corresponder ao número de elementos nas
  #  matrizes abaixo E à definição de equip_slots em [VS] Window_Equip
  #  e draw_paperdolls em [VS] Window_Base.
  #  Este valor deve ser definido ANTES da criação dos personagens.
  #============================================================================

  # Quantidade máxima de slots de equipamento por personagem
  MAX_EQUIPS = 9

  # Ordem de renderização do paperdoll — Direção: Frente (Sul / para baixo)
  PAPERDOLL_DOWN_DIR  = [3, 5, 2, 7, 6, 8, 1, 0, 4]

  # Ordem de renderização do paperdoll — Direção: Esquerda (Oeste)
  PAPERDOLL_LEFT_DIR  = [7, 0, 3, 5, 2, 6, 8, 1, 4]

  # Ordem de renderização do paperdoll — Direção: Direita (Leste)
  PAPERDOLL_RIGHT_DIR = [1, 3, 5, 2, 7, 6, 8, 0, 4]

  # Ordem de renderização do paperdoll — Direção: Costas (Norte / para cima)
  PAPERDOLL_UP_DIR    = [7, 1, 0, 3, 5, 2, 8, 6, 4]

  #============================================================================
  # >> SEÇÃO 16 — CORES DO CHAT
  #----------------------------------------------------------------------------
  #  Índices das cores definidas no arquivo Window.png (pasta Graphics/System).
  #  Cada índice corresponde a uma cor na paleta do WindowSkin padrão.
  #
  #  Referência de índices comuns do WindowSkin padrão do RPG Maker VX Ace:
  #    0  = Branco       | 1  = Amarelo     | 2  = Azul claro
  #    3  = Verde claro  | 4  = Ciano       | 5  = Verde
  #    6  = Roxo         | 7  = Cinza       | 8  = Laranja
  #    9  = Dourado      | 10 = Vermelho    | 17 = Cor especial
  #============================================================================

  NORMAL_COLOR  = 0   # Mensagem normal — branco (padrão)
  GLOBAL_COLOR  = 1   # Mensagem global — amarelo (destaque)
  SUCCESS_COLOR = 5   # Mensagem de sucesso — verde
  ERROR_COLOR   = 10  # Mensagem de erro — vermelho
  ALERT_COLOR   = 8   # Mensagem de alerta — laranja
  ADM_MSG_COLOR = 17  # Mensagem de administrador — cor especial exclusiva

  #============================================================================
  # >> SEÇÃO 17 — CORES DE NOMES
  #----------------------------------------------------------------------------
  #  Índices das cores para nomes de jogadores, inimigos e guildas,
  #  exibidos acima dos sprites no mapa do jogo.
  #  Utiliza os mesmos índices do WindowSkin definidos na seção anterior.
  #============================================================================

  DEFAULT_COLOR = 0   # Jogador comum — branco
  MONITOR_COLOR = 4   # Monitor / Moderador — ciano
  ADMIN_COLOR   = 6   # Administrador / GM — roxo
  ENEMY_COLOR   = 0   # Inimigo comum — branco
  BOSS_COLOR    = 10  # Boss — vermelho (destaque de perigo)
  GUILD_COLOR   = 16  # Tag de guilda — cor especial

  #============================================================================
  # >> SEÇÃO 18 — ÍCONES DO MENU PRINCIPAL
  #----------------------------------------------------------------------------
  #  Índices dos ícones no IconSet (Graphics/System/IconSet.png).
  #  Cada ícone ocupa 24x24 pixels. O índice 0 é o canto superior esquerdo
  #  da imagem, lido da esquerda para a direita, linha por linha.
  #
  #  Para localizar o índice de um ícone: (linha * colunas_por_linha) + coluna
  #  O IconSet padrão do VX Ace possui 16 colunas por linha.
  #============================================================================

  # ── Ícones do menu principal ──────────────────────────────────────────────
  ITEM_ICON   = 260   # Ícone do inventário de itens
  SKILL_ICON  = 96    # Ícone das habilidades
  STATUS_ICON = 121   # Ícone do status do personagem
  QUEST_ICON  = 227   # Ícone das missões (quests)
  FRIEND_ICON = 536   # Ícone da lista de amigos
  GUILD_ICON  = 535   # Ícone da guilda
  MENU_ICON   = 117   # Ícone do menu principal

  # ── Ícones do menu de interação com outros jogadores ─────────────────────
  PRIVATE_ICON = 4    # Ícone de mensagem privada
  BLOCK_ICON   = 538  # Ícone de bloquear jogador
  UNLOCK_ICON  = 539  # Ícone de desbloquear jogador
  TRADE_ICON   = 540  # Ícone de iniciar troca
  PARTY_ICON   = 12   # Ícone de convidar para grupo

  # ── Ícones gerais da interface ────────────────────────────────────────────
  CONFIG_ICON            = 532  # Ícone de configurações
  GOLD_ICON              = 262  # Ícone de ouro / moeda
  EXP_ICON               = 125  # Ícone de experiência
  ADD_GOLD_ICON          = 528  # Ícone de adicionar ouro
  REMOVE_GOLD_ICON       = 529  # Ícone de remover ouro
  MAP_PVP_ICON           = 534  # Ícone de mapa PvP (combate entre jogadores)
  MAP_NONPVP_ICON        = 533  # Ícone de mapa não-PvP (seguro)
  PLAYER_ON_ICON         = 189  # Ícone de jogador online
  PLAYER_OFF_ICON        = 187  # Ícone de jogador offline
  QUEST_NOT_STARTED_ICON = 537  # Ícone de missão não iniciada
  QUEST_FINISHED_ICON    = 190  # Ícone de missão concluída
  QUEST_IN_PROGRESS_ICON = 189  # Ícone de missão em andamento
  LEAVE_PARTY_ICON       = 530  # Ícone de sair do grupo
  EMOJI_ICON             = 541  # Ícone do menu de emojis / expressões

  #============================================================================
  # >> SEÇÃO 19 — ÍCONES DE BUFF E DEBUFF
  #----------------------------------------------------------------------------
  #  Define o índice inicial no IconSet para os ícones de status positivos
  #  (buff) e negativos (debuff). Os ícones são lidos sequencialmente a
  #  partir deste índice, um por estado de status.
  #
  #  Exemplo: Se ICON_BUFF_START = 64, o primeiro buff usa o ícone 64,
  #  o segundo usa 65, o terceiro usa 66, e assim por diante.
  #============================================================================

  # Índice inicial dos ícones de buff (status positivo) no IconSet
  ICON_BUFF_START   = 64

  # Índice inicial dos ícones de debuff (status negativo) no IconSet
  ICON_DEBUFF_START = 80

  #============================================================================
  # >> SEÇÃO 20 — INTERFACE (HUD)
  #----------------------------------------------------------------------------
  #  Configurações visuais da interface principal do jogo (HUD).
  #  Estes valores afetam o layout e o dimensionamento dos elementos
  #  de interface exibidos durante o gameplay.
  #============================================================================

  # Altura da barra de título das janelas em pixels
  # Afeta todas as janelas que utilizam o título padrão do sistema
  TITLE_BAR_HEIGHT = 20

  #============================================================================
  # >> SEÇÃO 21 — GAMEPLAY E COMBATE
  #----------------------------------------------------------------------------
  #  Configurações de tempo e limites relacionados ao combate e à
  #  movimentação no mapa. Estes valores controlam o ritmo e o feel
  #  do combate — ajuste com cuidado para manter o balanceamento.
  #
  #  Referência de unidades:
  #    Tempo em segundos (Float) → ex: 0.8 = 800 milissegundos
  #    Tempo em frames (Integer) → 60 frames = 1 segundo real
  #============================================================================

  # Intervalo em segundos entre ataques consecutivos do jogador e inimigos
  # Valor mínimo recomendado para inimigos: 0.8 segundos (800 ms)
  ATTACK_TIME = 0.8

  # Tempo de cooldown em segundos após o uso de uma habilidade
  COOLDOWN_SKILL_TIME = 1

  # Duração em frames da animação de ataque (60 frames = 1 segundo)
  ATTACK_ANIMATION_TIME = 30

  # ID da animação executada ao subir de nível (banco de dados de animações)
  LEVEL_UP_ANIMATION_ID = 40

  # Quantidade máxima de drops visíveis simultaneamente no mapa
  # Drops acima deste limite são descartados para evitar sobrecarga
  MAX_MAP_DROPS = 20

  #============================================================================
  # >> SEÇÃO 22 — MAPEAMENTO DE TECLAS
  #----------------------------------------------------------------------------
  #  Define as teclas de atalho para ações e menus do jogo.
  #  Os identificadores de tecla devem ser símbolos válidos do módulo Input
  #  do VXA-OS (ex: :CTRL, :SPACE, :TAB, :LETTER_I, :KEY_1, :F3).
  #
  #  Dica: Evite conflitos entre teclas de ação e teclas de menu.
  #  Teclas de função (:F3 a :F12) são ideais para emotes e atalhos
  #  secundários que não interferem na movimentação.
  #============================================================================

  # Tecla de ataque principal do jogador
  ATTACK_KEY       = :CTRL

  # Tecla para coletar drops do chão (itens largados por inimigos)
  GET_DROP_KEY     = :SPACE

  # Tecla para selecionar automaticamente o inimigo mais próximo
  SELECT_ENEMY_KEY = :TAB

  # ── Teclas de atalho para abrir janelas do menu ───────────────────────────
  ITEM_KEY   = :LETTER_I   # Abre o inventário de itens
  SKILL_KEY  = :LETTER_H   # Abre a janela de habilidades
  STATUS_KEY = :LETTER_C   # Abre o status do personagem
  QUEST_KEY  = :LETTER_Q   # Abre a janela de missões
  FRIEND_KEY = :LETTER_F   # Abre a lista de amigos
  GUILD_KEY  = :LETTER_G   # Abre a janela da guilda
  MENU_KEY   = :LETTER_M   # Abre o menu principal

  # ── Teclas numeradas para uso rápido na hotbar ────────────────────────────
  # Cada posição do array corresponde a um slot da hotbar (1 a 9)
  HOTKEYS = [
    :KEY_1, :KEY_2, :KEY_3,
    :KEY_4, :KEY_5, :KEY_6,
    :KEY_7, :KEY_8, :KEY_9,
  ]

  # ── Teclas de função para exibir balões de expressão (emotes) ─────────────
  # Cada tecla exibe um balão de expressão diferente acima do personagem
  BALLOONS_KEYS = [
    :F3,  :F4,  :F5,  :F6,
    :F7,  :F8,  :F9,  :F10,
    :F11, :F12,
  ]

  #============================================================================
  # >> SEÇÃO 23 — NOMES PROIBIDOS
  #----------------------------------------------------------------------------
  #  Lista de termos que jogadores comuns não podem usar no nome do
  #  personagem. A verificação é case-insensitive.
  #
  #  O espaço ao final de cada termo é intencional — evita que palavras
  #  que apenas contenham o termo como prefixo sejam bloqueadas
  #  incorretamente (ex: 'admirable' não seria bloqueado por 'adm ').
  #
  #  Adicione novos termos conforme necessário para proteger a identidade
  #  da equipe de administração do servidor.
  #============================================================================

  # Termos proibidos em nomes de personagens (reservados para a equipe)
  FORBIDDEN_NAMES = ['adm ', 'admin ', 'gm ', 'god ', 'mod ']

  #============================================================================
  # >> SEÇÃO 24 — TELEPORTES
  #----------------------------------------------------------------------------
  #  Define os pontos de teleporte disponíveis no jogo.
  #  Cada entrada representa um par bidirecional [origem, destino] com
  #  mapa, coordenadas e custo em ouro para utilizar o teleporte.
  #
  #  Formato de cada hash de ponto:
  #    :map_id → ID do mapa no banco de dados do RPG Maker
  #    :x      → Coordenada X de chegada no mapa de destino
  #    :y      → Coordenada Y de chegada no mapa de destino
  #    :gold   → Custo em ouro para utilizar este teleporte
  #
  #  Para adicionar novos teleportes, duplique o bloco TELEPORTS << [...].
  #============================================================================

  # Array principal de teleportes disponíveis no jogo
  TELEPORTS = []

  # Teleporte: Mapa 1 (x:21, y:12) ↔ Mapa 2 (x:4, y:20)
  # Custo de ida: 10 ouro | Custo de volta: 20 ouro
  TELEPORTS << [
    { :map_id => 1, :x => 21, :y => 12, :gold => 10 },
    { :map_id => 2, :x => 4,  :y => 20, :gold => 20 },
  ]

  #============================================================================
  # >> SEÇÃO 25 — ARMAS DE LONGO ALCANCE
  #----------------------------------------------------------------------------
  #  Define as armas que disparam projéteis no mapa durante o combate.
  #  A chave do hash é o ID da arma no banco de dados do RPG Maker.
  #
  #  Parâmetros disponíveis por arma:
  #    :projectile_name → Nome do arquivo gráfico do projétil
  #                       Caminho base: Graphics/Characters/
  #    :range           → Alcance máximo em tiles
  #    :item_id         → ID do item de munição consumido por disparo
  #                       Use 0 para munição infinita (sem consumo)
  #    :step_anime      → (Opcional) Animar o sprite durante o voo do projétil
  #    :mp_cost         → (Opcional) Custo de MP por disparo realizado
  #
  #  Para adicionar novas armas de alcance, siga o padrão abaixo usando
  #  o ID correto da arma no banco de dados do RPG Maker.
  #============================================================================

  # Hash principal de armas de longo alcance
  RANGE_WEAPONS = {}

  # Arco Curto (ID 31) — projétil de flecha, alcance 10 tiles, consome munição ID 18
  RANGE_WEAPONS[31] = {
    :projectile_name => 'Arrow',
    :range           => 10,
    :item_id         => 18,
  }

  # Cajado de Madeira (ID 49) — projétil de fogo, alcance 10 tiles, custo 3 MP
  RANGE_WEAPONS[49] = {
    :projectile_name => 'Fire',
    :range           => 10,
    :item_id         => 0,      # Sem consumo de munição
    :step_anime      => false,  # Sem animação de passo durante o voo
    :mp_cost         => 3,      # Consome 3 MP por disparo
  }

  #============================================================================
  # >> SEÇÃO 26 — HABILIDADES DE LONGO ALCANCE
  #----------------------------------------------------------------------------
  #  Define habilidades que lançam projéteis no mapa durante o combate.
  #  A chave do hash é o ID da habilidade no banco de dados do RPG Maker.
  #
  #  Parâmetros disponíveis por habilidade:
  #    :projectile_name → Nome do arquivo gráfico do projétil
  #                       Caminho base: Graphics/Characters/
  #    :step_anime      → (Opcional) Animar o sprite durante o voo do projétil
  #
  #  Para adicionar novas habilidades de alcance, siga o padrão abaixo usando
  #  o ID correto da habilidade no banco de dados do RPG Maker.
  #============================================================================

  # Hash principal de habilidades de longo alcance
  RANGE_SKILLS = {}

  # Habilidade: Fogo (ID 51) — projétil de chama sem animação de passo
  RANGE_SKILLS[51] = {
    :projectile_name => 'Fire',
  }

  # Habilidade: Luz das Estrelas (ID 70) — projétil de luz com animação de movimento
  RANGE_SKILLS[70] = {
    :projectile_name => 'Light',
    :step_anime      => true,   # Ativa animação de passo durante o voo
  }

end