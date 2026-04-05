# encoding: utf-8
#==============================================================================
# ** Enums
#------------------------------------------------------------------------------
# Projeto      : Fields Online (VXA-OS)
# Arquivo      : Server/Scripts/Kernel/enums.rb
# Autor        : Caio Juan De Lima Silva
# Versão       : 2.0.0
# Data         : 2026-04-05
#------------------------------------------------------------------------------
# Descrição:
#   Este arquivo define todos os enumeradores (enums) utilizados pelo servidor.
#
#   PARTE 1 — Enums do cliente ([VS] Enums.rb):
#     Quando o servidor carrega scripts.rb com sucesso, ele executa o arquivo
#     Scripts.rvdata2 do cliente, que já popula o module Enums com estes valores.
#     Os guards `unless const_defined?(:Nome)` garantem idempotência: se o enum
#     já foi definido pelo cliente, ele NÃO é redefinido aqui (evitando conflito
#     de IDs). Se scripts.rb falhar (modo standalone/fallback), este arquivo
#     define os enums por conta própria.
#
#   PARTE 2 — Enums exclusivos do servidor:
#     Enums que NÃO existem no cliente [VS] Enums.rb. Também protegidos por
#     guards para segurança em recarregamentos.
#
#   PARTE 3 — Reabertura de module Packet com aliases:
#     O module Packet é reaberto para adicionar constantes com nomes usados
#     internamente pelo servidor (ex: EVENT_MOVEMENT) que apontam para os IDs
#     definidos pelo cliente (ex: EVENT_MOVE). Isso corrige bugs de pacotes
#     não encontrados sem alterar os arquivos de lógica do servidor.
#
#   AVISO IMPORTANTE — MAP_DROPS:
#     MAP_DROPS = 87 é um pacote NOVO exclusivo do Fields Online.
#     NET_SWITCHES ocupa o ID 86 (último do enum Packet do cliente).
#     O ID 87 é o próximo livre e deve ser registrado no cliente também
#     caso a funcionalidade de drops em mapa seja implementada no lado cliente.
#==============================================================================

module Enums

  #============================================================================
  # PARTE 1 — Enums do cliente ([VS] Enums.rb)
  # Guards garantem que, se scripts.rb já os definiu, não serão redefinidos.
  # Se scripts.rb falhou (modo standalone), são definidos aqui como fallback.
  #============================================================================

  # Sexo do personagem
  Sex      = enum %w( MALE FEMALE ) unless const_defined?(:Sex)

  # Identificadores de pacotes de rede (núcleo do protocolo VXA-OS)
  Packet   = enum %w(
    NONE              LOGIN             FAIL_LOGIN        CREATE_ACCOUNT
    CREATE_ACTOR      FAIL_CREATE_ACTOR ACTOR             REMOVE_ACTOR
    USE_ACTOR         MOTD              PLAYER_DATA       REMOVE_PLAYER
    PLAYER_MOVE       MAP_MSG           CHAT_MSG          ALERT_MSG
    PLAYER_ATTACK     ATTACK_PLAYER     ATTACK_ENEMY      USE_ITEM
    USE_SKILL         ANIMATION         BALLOON           USE_HOTBAR
    ENEMY_REVIVE      EVENT_DATA        EVENT_MOVE        ADD_DROP
    REMOVE_DROP       ADD_PROJECTILE    PLAYER_VITALS     PLAYER_EXP
    PLAYER_STATE      PLAYER_BUFF       PLAYER_ITEM       PLAYER_GOLD
    PLAYER_PARAM      PLAYER_EQUIP      PLAYER_SKILL      PLAYER_CLASS
    PLAYER_SEX        PLAYER_GRAPHIC    PLAYER_POINTS     PLAYER_HOTBAR
    TARGET            TRANSFER          OPEN_FRIENDS      ADD_FRIEND
    REMOVE_FRIEND     OPEN_CREATE_GUILD CREATE_GUILD      OPEN_GUILD
    GUILD_NAME        GUILD_LEADER      GUILD_NOTICE      REMOVE_GUILD_MEMBER
    GUILD_REQUEST     LEAVE_GUILD       JOIN_PARTY        LEAVE_PARTY
    DISSOLVE_PARTY    CHOICE            OPEN_BANK         BANK_ITEM
    BANK_GOLD         CLOSE_WINDOW      OPEN_SHOP         BUY_ITEM
    SELL_ITEM         OPEN_TELEPORT     CHOICE_TELEPORT   EVENT_COMMAND
    NEXT_COMMAND      REQUEST           ACCEPT_REQUEST    DECLINE_REQUEST
    TRADE_ITEM        TRADE_GOLD        ADD_QUEST         FINISH_QUEST
    VIP_DAYS          LOGOUT            ADMIN_COMMAND     SWITCH
    VARIABLE          SELF_SWITCH       NET_SWITCHES
  ) unless const_defined?(:Packet)

  # Grupo/nível de permissão do jogador
  Group    = enum %w( STANDARD MONITOR ADMIN ) unless const_defined?(:Group)

  # Direções de movimento (compatível com RPG Maker VX Ace)
  # Inclui valores numéricos intermediários para manter compatibilidade
  # com o sistema de direções do RPG Maker (1-9, exceto 5)
  Dir      = enum %w(
    DOWN_LEFT 1 DOWN 2 DOWN_RIGHT 3
    LEFT      4 RIGHT 6
    UP_LEFT   7 UP    8 UP_RIGHT  9
  ) unless const_defined?(:Dir)

  # Canais de chat disponíveis
  Chat     = enum %w( MAP GLOBAL PARTY GUILD PRIVATE ) unless const_defined?(:Chat)

  # Códigos de falha de login
  Login    = enum %w(
    SERVER_FULL  IP_BANNED    OLD_VERSION  ACC_BANNED
    INVALD_USER  MULTI_ACCOUNT INVALID_PASS IP_BLOCKED
    INACTIVITY
  ) unless const_defined?(:Login)

  # Resultados do registro de conta
  Register = enum %w( ACC_EXIST SUCCESSFUL ) unless const_defined?(:Register)

  # Mensagens de alerta enviadas ao jogador
  Alert    = enum %w(
    INVALID_NAME      TELEPORTED        PULLED            ATTACK_ADMIN
    BUSY              IN_PARTY          IN_GUILD          GUILD_EXIST
    NOT_GUILD_LEADER  FULL_GUILD        NOT_PICK_UP_DROP  REQUEST_DECLINED
    TRADE_DECLINED    TRADE_FINISHED    FULL_INV          FULL_TRADE
    FULL_BANK         MUTED
  ) unless const_defined?(:Alert)

  # Tipos de slot na hotbar de ações rápidas
  Hotbar   = enum %w( NONE ITEM SKILL ) unless const_defined?(:Hotbar)

  # Comandos administrativos disponíveis
  Command  = enum %w(
    KICK    TELEPORT GO     PULL   ITEM   WEAPON ARMOR  GOLD
    BAN_IP  BAN_ACC  UNBAN  SWITCH MOTD   MUTE   MSG
  ) unless const_defined?(:Command)

  # Tipos de projétil (arma física ou habilidade)
  Projectile = enum %w( WEAPON SKILL ) unless const_defined?(:Projectile)

  # Tipos de alvo selecionável
  Target   = enum %w( NONE PLAYER ENEMY ) unless const_defined?(:Target)

  # Modos do cursor do mouse na interface
  Mouse    = enum %w( NONE ITEM SKILL EQUIP SHOP TRADE BANK ) unless const_defined?(:Mouse)

  # Tipos de cursor exibido no mapa
  Cursor   = enum %w( NONE EVENT ENEMY PLAYER DROP ) unless const_defined?(:Cursor)

  # Contextos de entrada de quantidade (janelas de input numérico)
  Amount   = enum %w(
    BUY_ITEM      SELL_ITEM      DROP_ITEM
    ADD_TRADE_ITEM ADD_TRADE_GOLD REMOVE_TRADE_ITEM REMOVE_TRADE_GOLD
    DEPOSIT_ITEM  DEPOSIT_GOLD   WITHDRAW_ITEM     WITHDRAW_GOLD
  ) unless const_defined?(:Amount)

  # Tipos de confirmação em janelas de escolha (sim/não)
  Choice   = enum %w(
    REMOVE_FRIEND     REQUEST           FINISH_TRADE
    LEAVE_PARTY       LEAVE_GUILD       REMOVE_GUILD_MEMBER
    CHANGE_GUILD_LEADER
  ) unless const_defined?(:Choice)

  # Tipos de requisição/convite entre jogadores
  Request  = enum %w( NONE TRADE FINISH_TRADE PARTY FRIEND GUILD ) unless const_defined?(:Request)

  # Estados de progresso de uma quest
  Quest    = enum %w( IN_PROGRESS FINISHED ) unless const_defined?(:Quest)

  #============================================================================
  # PARTE 2 — Enums exclusivos do servidor
  # Estes enums NÃO existem no cliente [VS] Enums.rb.
  # São utilizados apenas pela lógica interna do servidor Fields Online.
  # Guards mantidos por consistência e segurança em recarregamentos.
  #============================================================================

  # Slots de equipamento do personagem (ordem dos slots no banco de dados)
  Equip         = enum %w(
    WEAPON  SHIELD  HELMET  ARMOR
    ACESSORY AMULET COVER   GLOVE   BOOT
  ) unless const_defined?(:Equip)

  # Parâmetros base do personagem (compatível com RPG Maker VX Ace)
  # Ordem: MaxHP, MaxMP, Ataque, Defesa, M.Ataque, M.Defesa, Agilidade, Sorte
  Param         = enum %w( MAXHP MAXMP ATK DEF MAT MDF AGI LUK ) unless const_defined?(:Param)

  # Escopos de uso de item (IDs compatíveis com RPG Maker VX Ace)
  # Inclui valores numéricos para manter os IDs corretos do RPG Maker
  Item          = enum %w(
    SCOPE_ENEMY 1 SCOPE_ALL_ALLIES 8
    SCOPE_ALLIES_KNOCKED_OUT 10 SCOPE_USER 11
  ) unless const_defined?(:Item)

  # Tipos de movimento de evento/inimigo no mapa
  Move          = enum %w( FIXED RANDOM TOWARD_PLAYER CUSTOM ) unless const_defined?(:Move)

  # Tipos de entidade/personagem no mundo do jogo
  CharacterType = enum %w( PLAYER ENEMY ) unless const_defined?(:CharacterType)

  #============================================================================
  # PARTE 3 — Reabertura de module Packet para aliases do servidor
  #
  # O module Packet está GARANTIDAMENTE definido neste ponto:
  #   - Ou foi definido pelo cliente via scripts.rb (Parte 1 pulada pelos guards)
  #   - Ou foi definido pela Parte 1 deste arquivo (modo standalone/fallback)
  #
  # Os aliases mapeiam os nomes usados internamente pelos arquivos do servidor
  # para os IDs numéricos corretos definidos pelo cliente. Isso permite que o
  # código do servidor use nomes semânticos sem depender de renomear o protocolo.
  #
  # Formato dos comentários: ALIAS_SERVIDOR → CONSTANTE_CLIENTE
  #   Arquivo(s) do servidor que utilizam o alias.
  #============================================================================
  module Packet

    # BUG FIX CRÍTICO: send_data.rb usa Packet::EVENT_MOVEMENT mas o cliente
    # define apenas EVENT_MOVE. Sem este alias, eventos não se movem no cliente.
    EVENT_MOVEMENT           = EVENT_MOVE     unless const_defined?(:EVENT_MOVEMENT)

    # send_data.rb:send_map_events — envia dados de todos os eventos do mapa
    MAP_EVENTS               = EVENT_DATA     unless const_defined?(:MAP_EVENTS)

    # login.rb:send_failed_login — notifica falha na autenticação
    FAILED_LOGIN             = FAIL_LOGIN     unless const_defined?(:FAILED_LOGIN)

    # create_actor.rb:send_failed_create_actor — notifica falha na criação de personagem
    FAILED_CREATE_ACTOR      = FAIL_CREATE_ACTOR unless const_defined?(:FAILED_CREATE_ACTOR)

    # alert.rb:send_alert — envia mensagem de alerta ao jogador
    ALERT                    = ALERT_MSG      unless const_defined?(:ALERT)

    # transfer.rb:send_transfer_player — teleporta jogador para outro mapa
    TRANSFER_PLAYER          = TRANSFER       unless const_defined?(:TRANSFER_PLAYER)

    # switches.rb:send_player_switch — atualiza switch local do jogador
    PLAYER_SWITCH            = SWITCH         unless const_defined?(:PLAYER_SWITCH)

    # switches.rb:send_global_switch — atualiza switch global (mesmo ID que SWITCH,
    # o contexto/escopo diferencia o comportamento no cliente)
    GLOBAL_SWITCH            = SWITCH         unless const_defined?(:GLOBAL_SWITCH)

    # variables.rb:send_player_variable — atualiza variável local do jogador
    PLAYER_VARIABLE          = VARIABLE       unless const_defined?(:PLAYER_VARIABLE)

    # self_switches.rb:send_player_self_switch — atualiza self switch de evento
    PLAYER_SELF_SWITCH       = SELF_SWITCH    unless const_defined?(:PLAYER_SELF_SWITCH)

    # net_switches.rb:send_global_switches — envia batch de switches de rede
    # ATENÇÃO: NET_SWITCHES é um ID diferente de SWITCH (batch vs. individual)
    GLOBAL_SWITCHES          = NET_SWITCHES   unless const_defined?(:GLOBAL_SWITCHES)

    # parallel_process.rb:send_parallel_process_command — envia comando de processo paralelo
    PARALLEL_PROCESS_COMMAND = EVENT_COMMAND  unless const_defined?(:PARALLEL_PROCESS_COMMAND)

    # player_move.rb:send_player_movement — sincroniza movimento do jogador entre clientes
    PLAYER_MOVEMENT          = PLAYER_MOVE    unless const_defined?(:PLAYER_MOVEMENT)

    # NOVO PACOTE — Fields Online exclusivo
    # MAP_DROPS = 87: envia lista de drops presentes no mapa ao jogador
    # NET_SWITCHES ocupa o ID 86 (último do enum Packet do cliente).
    # ID 87 é o próximo livre. REGISTRAR NO CLIENTE quando implementar
    # a funcionalidade de drops em mapa no lado cliente.
    MAP_DROPS                = 87             unless const_defined?(:MAP_DROPS)

  end # module Packet (reopen)

end # module Enums

#==============================================================================
# ** Fim de Server/Scripts/Kernel/enums.rb
#==============================================================================