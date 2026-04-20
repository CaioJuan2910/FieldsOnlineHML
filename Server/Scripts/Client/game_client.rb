#==============================================================================
# ** Game_Client (Refatorado)
#------------------------------------------------------------------------------
#  Classe que representa um jogador conectado ao servidor.
#
#  RESPONSABILIDADES:
#  - Conexão de rede (EventMachine)
#  - Estado do jogador
#  - Lógica de gameplay
#  - Comunicação com o servidor (Network)
#
#  ⚠️ IMPORTANTE:
#  Essa classe é crítica:
#  - Qualquer erro aqui pode afetar TODOS os jogadores
#  - Precisa ser segura e performática
#==============================================================================

class Game_Client < EventMachine::Connection

	include Game_Account, Game_Character, Game_Battler, Game_Party, Game_Trade, Game_Bank

	#--------------------------------------------------------------------------
	# 🔒 CONSTANTES (controle e segurança)
	#--------------------------------------------------------------------------
	MOVE_DELAY        = 0.1   # tempo mínimo entre movimentos
	ACTION_DELAY      = 0.2   # delay entre ações
	PACKET_LIMIT      = 50    # limite de pacotes por segundo

	#--------------------------------------------------------------------------
	# 📦 ATRIBUTOS PRINCIPAIS
	#--------------------------------------------------------------------------
	attr_reader :name, :level, :hp, :mp, :map_id, :x, :y
	attr_accessor :last_ping

	#--------------------------------------------------------------------------
	# 🔧 initialize
	#--------------------------------------------------------------------------
	def initialize
		super
		
		#----------------------------------------------------------------------
		# 🔌 CONTROLE DE CONEXÃO
		#----------------------------------------------------------------------
		@last_ping = Time.now
		@packet_count = 0
		@packet_reset_time = Time.now

		#----------------------------------------------------------------------
		# 🧠 CONTROLE DE AÇÕES (anti-cheat)
		#----------------------------------------------------------------------
		@last_move_time = Time.now
		@last_action_time = Time.now

		#----------------------------------------------------------------------
		# 🎯 SISTEMAS INTERNOS
		#----------------------------------------------------------------------
		@target = Target.new
		@request = Target.new
		@event_interpreter = Game_Interpreter.new

		#----------------------------------------------------------------------
		# 🛑 ESTADOS
		#----------------------------------------------------------------------
		@move_route_forcing = false
		@name = ''

		# Inicializações herdadas
		init_account
		init_trade
		init_bank
	end

	#--------------------------------------------------------------------------
	# 📡 RECEBIMENTO DE DADOS (ENTRY POINT)
	#--------------------------------------------------------------------------
	# Esse método é chamado automaticamente quando o cliente envia dados
	#--------------------------------------------------------------------------
	def receive_data(data)
		begin
			#--------------------------------------------------------------
			# 🔒 Proteção contra flood
			#--------------------------------------------------------------
			check_packet_limit

			#--------------------------------------------------------------
			# Atualiza ping (atividade do jogador)
			#--------------------------------------------------------------
			@last_ping = Time.now

			#--------------------------------------------------------------
			# Processa dados recebidos
			#--------------------------------------------------------------
			handle_data(data)

		rescue => e
			log_error("Erro receive_data: #{e.message}")
			close_connection
		end
	end

	#--------------------------------------------------------------------------
	# 🔒 PROTEÇÃO DE PACOTES (ANTI-FLOOD)
	#--------------------------------------------------------------------------
	def check_packet_limit
		if Time.now - @packet_reset_time >= 1
			@packet_count = 0
			@packet_reset_time = Time.now
		end

		@packet_count += 1

		if @packet_count > PACKET_LIMIT
			log_error("Flood detectado: #{@name}")
			close_connection
		end
	end

	#--------------------------------------------------------------------------
	# 🚶 CONTROLE DE MOVIMENTO
	#--------------------------------------------------------------------------
	def can_move?
		return false if Time.now - @last_move_time < MOVE_DELAY
		return false if @move_route_forcing
		return true
	end

	def register_move
		@last_move_time = Time.now
	end

	#--------------------------------------------------------------------------
	# ⚔️ CONTROLE DE AÇÃO
	#--------------------------------------------------------------------------
	def can_act?
		return false if Time.now - @last_action_time < ACTION_DELAY
		return true
	end

	def register_action
		@last_action_time = Time.now
	end

	#--------------------------------------------------------------------------
	# ❤️ VIDA (com proteção)
	#--------------------------------------------------------------------------
	def hp=(value)
		begin
			@hp = [[value, mhp].min, 0].max

			if dead?
				die
			else
				# Envia apenas se necessário
				$network.send_player_vitals(self)
			end

		rescue => e
			log_error("Erro HP: #{e.message}")
		end
	end

	#--------------------------------------------------------------------------
	# 💧 MANA
	#--------------------------------------------------------------------------
	def mp=(value)
		begin
			super
			$network.send_player_vitals(self)
		rescue => e
			log_error("Erro MP: #{e.message}")
		end
	end

	#--------------------------------------------------------------------------
	# 🗺️ MOVIMENTO (seguro)
	#--------------------------------------------------------------------------
	def safe_move(x, y, direction)
		return unless can_move?

		register_move

		begin
			change_position(x, y, direction)
			$network.send_player_movement(self)

		rescue => e
			log_error("Erro movimento: #{e.message}")
		end
	end

	#--------------------------------------------------------------------------
	# 🔄 LOOP DO JOGADOR
	#--------------------------------------------------------------------------
	def update_game
		begin
			update_recovery
			update_events

		rescue => e
			log_error("Erro update_game: #{e.message}")
		end
	end

	#--------------------------------------------------------------------------
	# ❤️ REGENERAÇÃO OTIMIZADA
	#--------------------------------------------------------------------------
	def update_recovery
		return if @recover_time && @recover_time > Time.now

		@recover_time = Time.now + 2

		if @hp < mhp || @mp < mmp
			change_vitals(@hp + 5, @mp + 5)
		end
	end

	#--------------------------------------------------------------------------
	# 🧠 EVENTOS
	#--------------------------------------------------------------------------
	def update_events
		update_common_events
		update_event_interpreter
	end

	#--------------------------------------------------------------------------
	# 🔌 DESCONECTAR
	#--------------------------------------------------------------------------
	def disconnect
		begin
			log("Jogador #{@name} desconectado")

			# Aqui você pode salvar dados no banco
			save_character if respond_to?(:save_character)

		rescue => e
			log_error("Erro disconnect: #{e.message}")
		end
	end

	#--------------------------------------------------------------------------
	# 📝 LOG
	#--------------------------------------------------------------------------
	def log(msg)
		puts("[CLIENT #{@name}] #{msg}")
	end

	def log_error(msg)
		puts("[ERRO CLIENT #{@name}] #{msg}")
	end

end