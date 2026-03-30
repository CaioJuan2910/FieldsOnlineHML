#==============================================================================
# ** Network
#------------------------------------------------------------------------------
#  Esta classe lida com a rede.
#------------------------------------------------------------------------------
#  Autor: Valentine
#  Revisado: nil safety, double-disconnect, attr_reader incompleto
#==============================================================================

class Network

  include Handle_Data, Send_Data, Game_General, Game_Commands, Game_Data, Game_Guild

  #----------------------------------------------------------------------------
  # FIX: adicionado :blocked_ips ao attr_reader para consistência com :ban_list.
  #
  # PROBLEMA ORIGINAL: :blocked_ips era inicializado em initialize mas não
  # exposto via attr_reader, enquanto :ban_list (estrutura análoga) era exposto.
  #
  # CONSEQUÊNCIA: código externo (ex: ferramentas de admin, logs de auditoria,
  # módulos de segurança) não conseguia consultar @blocked_ips sem acesso
  # direto à instância via instance_variable_get, o que quebra encapsulamento.
  #
  # CORREÇÃO: ambos os hashes de controle de acesso agora são lidos de forma
  # simétrica e consistente via attr_reader.
  #----------------------------------------------------------------------------
  attr_reader :clients, :parties, :party_ids_available, :maps, :switches,
              :guilds, :log, :ban_list, :blocked_ips

  #----------------------------------------------------------------------------
  # * Inicialização
  #----------------------------------------------------------------------------
  def initialize
    puts('Iniciando servidor...')

    # --- Controle de clientes ---
    @clients              = []   # Array indexado por ID de cliente
    @client_ids_available = []   # IDs liberados prontos para reutilização
    @client_high_id       = 0    # Próximo ID virgem a ser emitido

    # --- Controle de partidas ---
    @parties              = []   # Array indexado por ID de partida
    @party_ids_available  = []   # IDs liberados prontos para reutilização
    @party_high_id        = 0    # Próximo ID virgem a ser emitido

    # --- Dados globais do RPG Maker (carregados pelo servidor) ---
    $data_enemies         = []
    $data_states          = []
    $data_animations      = []
    $data_actors          = []
    $data_classes         = []
    $data_skills          = []
    $data_items           = []
    $data_weapons         = []
    $data_armors          = []
    $data_tilesets        = []
    $data_common_events   = []

    # --- Subsistemas do servidor ---
    @switches    = Game_GlobalSwitches.new  # Switches globais compartilhados
    @log         = Logger.new               # Sistema de log do servidor
    @maps        = {}                       # Mapas ativos { map_id => Game_Map }
    @blocked_ips = {}                       # IPs bloqueados temporariamente
    @ban_list    = {}                       # Contas/IPs banidos permanentemente
    @guilds      = {}                       # Guildas ativas { guild_id => Guild }
  end

  #----------------------------------------------------------------------------
  # * Atualização principal — chamada a cada tick do servidor
  #----------------------------------------------------------------------------
  def update
    update_clients
    update_maps
  end

  #----------------------------------------------------------------------------
  # * Atualiza todos os clientes conectados
  #
  # Itera sobre @clients com guard `next unless client` para ignorar slots
  # nil (IDs liberados por disconnect_client que ainda não foram reatribuídos).
  # Sem esse guard, client.in_game? levantaria NoMethodError em slots vazios.
  #----------------------------------------------------------------------------
  def update_clients
    @clients.each do |client|
      next unless client
      if client.in_game?
        client.update_game
      else
        client.update_menu
      end
    end
  end

  #----------------------------------------------------------------------------
  # * Atualiza todos os mapas instanciados
  #----------------------------------------------------------------------------
  def update_maps
    @maps.each_value(&:update)
  end

  #----------------------------------------------------------------------------
  # * Registra um cliente recém-conectado no array de clientes
  #
  # FIX: guard contra client nil.
  #
  # PROBLEMA ORIGINAL: nenhuma verificação era feita antes de acessar client.id.
  #
  # CONSEQUÊNCIA: se o objeto client não fosse inicializado corretamente antes
  # de ser passado aqui (ex: falha parcial na criação da conexão TCP), a chamada
  # client.id levantaria NoMethodError, derrubando a thread do servidor.
  #
  # CORREÇÃO: `return unless client` aborta silenciosamente a operação,
  # evitando crash. O slot simplesmente não é preenchido e o ID permanece
  # disponível para a próxima tentativa.
  #----------------------------------------------------------------------------
  def connect_client(client)
    return unless client
    @clients[client.id] = client
  end

  #----------------------------------------------------------------------------
  # * Remove um cliente do array de clientes e libera seu ID
  #
  # FIX: guard contra double-disconnect.
  #
  # PROBLEMA ORIGINAL: disconnect_client(id) podia ser chamado duas vezes para
  # o mesmo id no mesmo tick (ex: timeout de rede + desconexão manual simultânea).
  # Sem verificação, o id era inserido duas vezes em @client_ids_available.
  #
  # CONSEQUÊNCIA: find_empty_client_id() retornaria o mesmo id para dois clientes
  # distintos. O segundo connect_client sobrescreveria o primeiro em @clients,
  # causando perda silenciosa de referência ao cliente anterior e possível
  # duplicação de sessão — dois jogadores operando com o mesmo slot de memória.
  #
  # CORREÇÃO: `return unless @clients[id]` garante que o slot só é liberado
  # uma vez. Se já for nil, a operação é abortada sem efeitos colaterais.
  #----------------------------------------------------------------------------
  def disconnect_client(id)
    return unless @clients[id]
    @clients[id] = nil
    @client_ids_available << id
  end

  #----------------------------------------------------------------------------
  # * Retorna o próximo ID de cliente disponível
  #
  # Prioriza IDs liberados por disconnect_client (reutilização) antes de
  # incrementar @client_high_id, evitando crescimento ilimitado do array
  # @clients em servidores com alta rotatividade de conexões.
  #----------------------------------------------------------------------------
  def find_empty_client_id
    return @client_ids_available.shift unless @client_ids_available.empty?
    index = @client_high_id
    @client_high_id += 1
    index
  end

  #----------------------------------------------------------------------------
  # * Retorna o próximo ID de partida disponível
  #
  # Mesma lógica de reutilização aplicada a partidas: IDs liberados são
  # consumidos primeiro antes de emitir um ID virgem.
  #----------------------------------------------------------------------------
  def find_empty_party_id
    return @party_ids_available.shift unless @party_ids_available.empty?
    index = @party_high_id
    @party_high_id += 1
    index
  end

end