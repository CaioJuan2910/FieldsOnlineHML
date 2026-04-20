#==============================================================================
# ** Network
#------------------------------------------------------------------------------
#  Classe principal responsável por GERENCIAR o servidor MMORPG.
#
#  Ela controla:
#  - Conexões de jogadores (clients)
#  - Mapas ativos
#  - Parties (grupos)
#  - Guildas
#  - Switches globais
#  - Logs e segurança
#
#  IMPORTANTE:
#  Essa é a "espinha dorsal" do servidor.
#  Se ela falhar → todo o servidor cai.
#------------------------------------------------------------------------------
#  Versão refatorada e otimizada
#==============================================================================

class Network
	
	#--------------------------------------------------------------------------
	# 🔗 Módulos incluídos
	#--------------------------------------------------------------------------
	# Esses módulos adicionam funcionalidades ao Network:
	#
	# Handle_Data   → Recebe dados do cliente
	# Send_Data     → Envia dados ao cliente
	# Game_General  → Funções gerais do jogo
	# Game_Commands → Comandos (chat, admin, etc.)
	# Game_Data     → Manipulação de dados
	# Game_Guild    → Sistema de guildas
	#--------------------------------------------------------------------------
	include Handle_Data, Send_Data, Game_General, Game_Commands, Game_Data, Game_Guild
	
	#--------------------------------------------------------------------------
	# 📦 Atributos públicos (somente leitura)
	#--------------------------------------------------------------------------
	# Permite que outras classes acessem esses dados sem modificar diretamente
	#--------------------------------------------------------------------------
	attr_reader :clients, :parties, :maps, :switches, :guilds, :log, :ban_list

	#--------------------------------------------------------------------------
	# 🔧 initialize
	#--------------------------------------------------------------------------
	# Inicializa o servidor e todas as estruturas principais
	#--------------------------------------------------------------------------
	def initialize
		puts('Iniciando servidor...')
		
		#----------------------------------------------------------------------
		# 👥 CLIENTES
		#----------------------------------------------------------------------
		# Hash ao invés de Array:
		# ✔ Melhor performance
		# ✔ Evita buracos (nil)
		# ✔ Acesso direto por ID
		#----------------------------------------------------------------------
		@clients = {}

		# IDs reutilizáveis (evita crescimento infinito)
		@client_ids_available = []
		@client_high_id = 0
		
		#----------------------------------------------------------------------
		# 👥 PARTIES (GRUPOS)
		#----------------------------------------------------------------------
		@parties = {}
		@party_ids_available = []
		@party_high_id = 0
		
		#----------------------------------------------------------------------
		# 🗺️ MAPAS ATIVOS
		#----------------------------------------------------------------------
		# Cada mapa roda seu próprio update
		#----------------------------------------------------------------------
		@maps = {}
		
		#----------------------------------------------------------------------
		# 🔁 SWITCHES GLOBAIS
		#----------------------------------------------------------------------
		# Usado para eventos globais do jogo
		#----------------------------------------------------------------------
		@switches = Game_GlobalSwitches.new
		
		#----------------------------------------------------------------------
		# 📝 LOG DO SERVIDOR
		#----------------------------------------------------------------------
		# Fundamental para debug e produção
		#----------------------------------------------------------------------
		@log = Logger.new
		
		#----------------------------------------------------------------------
		# 🔒 SEGURANÇA
		#----------------------------------------------------------------------
		@blocked_ips = {} # IPs temporariamente bloqueados
		@ban_list = {}    # IPs permanentemente banidos
		
		#----------------------------------------------------------------------
		# 🛡️ GUILDAS
		#----------------------------------------------------------------------
		@guilds = {}

		#----------------------------------------------------------------------
		# 📊 CACHE DE DADOS DO JOGO
		#----------------------------------------------------------------------
		# Evita leitura constante do banco/disco
		#----------------------------------------------------------------------
		load_database_cache
	end

	#--------------------------------------------------------------------------
	# 📊 load_database_cache
	#--------------------------------------------------------------------------
	# Inicializa os dados do jogo em memória
	#
	# IMPORTANTE:
	# Isso melhora MUITO a performance do servidor
	#--------------------------------------------------------------------------
	def load_database_cache
		$data_enemies = []
		$data_states = []
		$data_animations = []
		$data_actors = []
		$data_classes = []
		$data_skills = []
		$data_items = []
		$data_weapons = []
		$data_armors = []
		$data_tilesets = []
		$data_common_events = []
	end

	#--------------------------------------------------------------------------
	# 🔄 update (Loop principal do servidor)
	#--------------------------------------------------------------------------
	# Chamado continuamente pelo servidor
	#
	# Ordem:
	# 1. Atualiza clientes
	# 2. Atualiza mapas
	#--------------------------------------------------------------------------
	def update
		update_clients
		update_maps
	end

	#--------------------------------------------------------------------------
	# 👥 update_clients
	#--------------------------------------------------------------------------
	# Atualiza todos os jogadores conectados
	#
	# CRÍTICO:
	# - Nunca pode travar
	# - Precisa ser seguro contra erro
	#--------------------------------------------------------------------------
	def update_clients
		@clients.each_value do |client|
			next unless client
			
			begin
				#--------------------------------------------------------------
				# 🔄 Atualização do cliente
				#--------------------------------------------------------------
				if client.in_game?
					client.update_game   # jogador dentro do jogo
				else
					client.update_menu   # login/menu
				end

				#--------------------------------------------------------------
				# ⏱️ Verificação de timeout
				#--------------------------------------------------------------
				check_timeout(client)

			rescue => e
				#--------------------------------------------------------------
				# 💥 Proteção contra crash
				#--------------------------------------------------------------
				# Se um client der erro → NÃO derruba o servidor
				#--------------------------------------------------------------
				log_error("Erro no client #{client.id}: #{e.message}")
				disconnect_client(client.id)
			end
		end
	end

	#--------------------------------------------------------------------------
	# 🗺️ update_maps
	#--------------------------------------------------------------------------
	# Atualiza todos os mapas ativos
	#--------------------------------------------------------------------------
	def update_maps
		@maps.each_value do |map|
			begin
				map.update
			rescue => e
				log_error("Erro no mapa: #{e.message}")
			end
		end
	end

	#--------------------------------------------------------------------------
	# 🔌 connect_client
	#--------------------------------------------------------------------------
	# Chamado quando um jogador se conecta
	#--------------------------------------------------------------------------
	def connect_client(client)
		#--------------------------------------------------------------
		# 🔒 Verifica ban
		#--------------------------------------------------------------
		if banned?(client.ip)
			log("Conexão recusada (ban): #{client.ip}")
			return
		end

		#--------------------------------------------------------------
		# 📌 Adiciona cliente ao servidor
		#--------------------------------------------------------------
		@clients[client.id] = client
		
		log("Cliente #{client.id} conectado (#{client.ip})")
	end

	#--------------------------------------------------------------------------
	# ❌ disconnect_client
	#--------------------------------------------------------------------------
	# Desconexão segura de um jogador
	#--------------------------------------------------------------------------
	def disconnect_client(id)
		client = @clients[id]
		return unless client

		begin
			#----------------------------------------------------------
			# 🧹 Limpeza do client
			#----------------------------------------------------------
			client.disconnect if client.respond_to?(:disconnect)
		rescue => e
			log_error("Erro ao desconectar client #{id}: #{e.message}")
		end

		#--------------------------------------------------------------
		# 🗑️ Remove da lista
		#--------------------------------------------------------------
		@clients.delete(id)

		#--------------------------------------------------------------
		# ♻️ Reutiliza ID
		#--------------------------------------------------------------
		@client_ids_available << id

		log("Cliente #{id} desconectado")
	end

	#--------------------------------------------------------------------------
	# 🔢 find_empty_client_id
	#--------------------------------------------------------------------------
	# Gera ID único para cliente
	#
	# Estratégia:
	# - Reutiliza IDs liberados
	# - Evita crescimento infinito
	#--------------------------------------------------------------------------
	def find_empty_client_id
		return @client_ids_available.shift unless @client_ids_available.empty?
		id = @client_high_id
		@client_high_id += 1
		id
	end

	#--------------------------------------------------------------------------
	# 👥 find_empty_party_id
	#--------------------------------------------------------------------------
	def find_empty_party_id
		return @party_ids_available.shift unless @party_ids_available.empty?
		id = @party_high_id
		@party_high_id += 1
		id
	end

	#--------------------------------------------------------------------------
	# ⏱️ check_timeout
	#--------------------------------------------------------------------------
	# Remove jogadores desconectados silenciosamente
	#
	# IMPORTANTE:
	# Evita "ghost players"
	#--------------------------------------------------------------------------
	def check_timeout(client)
		return unless client.respond_to?(:last_ping)

		if Time.now - client.last_ping > 60
			log("Cliente #{client.id} caiu por timeout")
			disconnect_client(client.id)
		end
	end

	#--------------------------------------------------------------------------
	# 🔒 banned?
	#--------------------------------------------------------------------------
	def banned?(ip)
		@ban_list[ip]
	end

	#--------------------------------------------------------------------------
	# 📝 log
	#--------------------------------------------------------------------------
	def log(msg)
		puts(msg)
		@log.add(msg) if @log
	end

	#--------------------------------------------------------------------------
	# 🚨 log_error
	#--------------------------------------------------------------------------
	def log_error(msg)
		puts("[ERRO] #{msg}")
		@log.add("[ERRO] #{msg}") if @log
	end

end