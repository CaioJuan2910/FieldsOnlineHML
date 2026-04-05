#==============================================================================
# ** Enums
#------------------------------------------------------------------------------
# Autor: Caio Juan De Lima Silva
# Projeto: Fields Online (VXA-OS)
# Arquivo: Server/Scripts/Kernel/enums.rb
#------------------------------------------------------------------------------
# Descrição:
#   Define os enumeradores globais utilizados pelo servidor VXA-OS e adiciona
#   aliases de pacotes no módulo Enums::Packet.
#
#   Por que os aliases existem?
#   O cliente VXA-OS define os IDs de pacote com nomes próprios (ex: EVENT_MOVE,
#   FAIL_LOGIN, ALERT_MSG). O servidor, em vários scripts, referencia esses
#   mesmos pacotes com nomes ligeiramente diferentes (ex: EVENT_MOVEMENT,
#   FAILED_LOGIN, ALERT). Para evitar erros de "constante não definida" sem
#   alterar o código original do cliente, este arquivo cria aliases seguros
#   usando `unless const_defined?(:NOME)`, garantindo que:
#     1. Se o cliente já definiu o nome alternativo, nada é sobrescrito.
#     2. Se o cliente não definiu, o alias aponta para o ID correto.
#
#   ATENÇÃO — MAP_DROPS:
#   O valor 87 foi atribuído ao pacote MAP_DROPS para o Fields Online.
#   Antes de usar em produção, verifique se o cliente já define
#   Enums::Packet::MAP_DROPS com outro valor. Caso positivo, remova ou ajuste
#   a linha correspondente neste arquivo para evitar conflito de IDs.
#==============================================================================

module Enums

  #============================================================================
  # PARTE 1: Enums originais do VXA-OS
  # Mantidos EXATAMENTE iguais ao repositório original.
  # Não altere a ordem nem os valores — o sistema enum %w() gera IDs
  # sequenciais a partir de 0 (ou do número inline indicado).
  #============================================================================

  # Slots de equipamento do personagem
  Equip = enum %w( WEAPON SHIELD HELMET ARMOR ACESSORY AMULET COVER GLOVE BOOT )

  # Parâmetros base do personagem (espelha RPG::Actor params)
  Param = enum %w( MAXHP MAXMP ATK DEF MAT MDF AGI LUK )

  # Escopos de habilidades/itens (valores inline = IDs do RPG Maker VX Ace)
  Item = enum %w( SCOPE_ENEMY 1 SCOPE_ALL_ALLIES 8 SCOPE_ALLIES_KNOCKED_OUT 10 SCOPE_USER 11 )

  # Tipos de movimento de evento
  Move = enum %w( FIXED RANDOM TOWARD_PLAYER CUSTOM )

  #============================================================================
  # PARTE 2: Aliases do módulo Packet
  #----------------------------------------------------------------------------
  # O módulo Enums::Packet já é criado pelo sistema enum do cliente com todos
  # os IDs numéricos. Aqui apenas reabrimos o módulo para adicionar nomes
  # alternativos usados internamente pelo servidor.
  #
  # Padrão de cada linha:
  #   NOME_SERVIDOR = NOME_CLIENTE  unless const_defined?(:NOME_SERVIDOR)
  #
  # O guard `unless const_defined?` garante idempotência: se o cliente já
  # definiu o nome alternativo com o mesmo (ou diferente) ID, não haverá
  # sobrescrita silenciosa.
  #============================================================================
  module Packet

    # Movimento de evento no mapa
    # Usado em: send_data.rb:317 — nome original do cliente: EVENT_MOVE
    # Nota: renomeado para EVENT_MOVEMENT para maior clareza semântica no servidor
    EVENT_MOVEMENT      = EVENT_MOVE        unless const_defined?(:EVENT_MOVEMENT)

    # Dados de eventos do mapa (lista completa)
    # Usado em: map_events.rb — nome original do cliente: EVENT_DATA
    MAP_EVENTS          = EVENT_DATA        unless const_defined?(:MAP_EVENTS)

    # Falha no processo de login
    # Usado em: login.rb — nome original do cliente: FAIL_LOGIN
    FAILED_LOGIN        = FAIL_LOGIN        unless const_defined?(:FAILED_LOGIN)

    # Falha na criação de personagem
    # Usado em: create_actor.rb — nome original do cliente: FAIL_CREATE_ACTOR
    FAILED_CREATE_ACTOR = FAIL_CREATE_ACTOR unless const_defined?(:FAILED_CREATE_ACTOR)

    # Mensagem de alerta exibida ao jogador (popup/janela de aviso)
    # Usado em: alert.rb — nome original do cliente: ALERT_MSG
    ALERT               = ALERT_MSG         unless const_defined?(:ALERT)

    # Teleporte/transferência de mapa do jogador
    # Usado em: transfer.rb — nome original do cliente: TRANSFER
    TRANSFER_PLAYER     = TRANSFER          unless const_defined?(:TRANSFER_PLAYER)

    # Switch (interruptor) individual do jogador
    # Usado em: switches.rb — nome original do cliente: SWITCH
    # ATENÇÃO: PLAYER_SWITCH e GLOBAL_SWITCH compartilham o mesmo ID numérico.
    # A distinção entre switch de jogador e switch global é feita pelo contexto
    # do handler, não pelo ID do pacote.
    PLAYER_SWITCH       = SWITCH            unless const_defined?(:PLAYER_SWITCH)

    # Switch global (compartilhado entre todos os jogadores)
    # Mesmo ID que PLAYER_SWITCH — veja nota acima
    GLOBAL_SWITCH       = SWITCH            unless const_defined?(:GLOBAL_SWITCH)

    # Variável individual do jogador
    # Usado em: variables.rb — nome original do cliente: VARIABLE
    PLAYER_VARIABLE     = VARIABLE          unless const_defined?(:PLAYER_VARIABLE)

    # Self-switch de evento individual do jogador
    # Usado em: self_switches.rb — nome original do cliente: SELF_SWITCH
    PLAYER_SELF_SWITCH  = SELF_SWITCH       unless const_defined?(:PLAYER_SELF_SWITCH)

    # Pacote de sincronização de switches globais (todos de uma vez)
    # Usado em: net_switches.rb — nome original do cliente: NET_SWITCHES
    GLOBAL_SWITCHES     = NET_SWITCHES      unless const_defined?(:GLOBAL_SWITCHES)

    # Comando de processo paralelo de evento
    # Usado em: parallel_process.rb — nome original do cliente: EVENT_COMMAND
    PARALLEL_PROCESS_COMMAND = EVENT_COMMAND unless const_defined?(:PARALLEL_PROCESS_COMMAND)

    # Movimento do jogador no mapa
    # Usado em: player_move.rb — nome original do cliente: PLAYER_MOVE
    PLAYER_MOVEMENT     = PLAYER_MOVE       unless const_defined?(:PLAYER_MOVEMENT)

    # -------------------------------------------------------------------------
    # NOVO PACOTE — Fields Online
    # -------------------------------------------------------------------------
    # Lista de drops presentes no mapa (itens no chão visíveis ao jogador)
    # ID: 87 — atribuído manualmente para o Fields Online.
    #
    # VERIFICAÇÃO OBRIGATÓRIA:
    #   Antes de usar em produção, confirme que o cliente NÃO define
    #   Enums::Packet::MAP_DROPS com outro valor. Para verificar, procure
    #   por "MAP_DROPS" ou pelo número 87 nos scripts do cliente.
    #   Se houver conflito, altere o valor 87 para um ID livre e atualize
    #   o handler correspondente no cliente.
    MAP_DROPS           = 87                unless const_defined?(:MAP_DROPS)

  end # module Packet

end # module Enums