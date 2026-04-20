#==============================================================================
# ** Handle_Data (Refatorado)
#------------------------------------------------------------------------------
#  RESPONSABILIDADE:
#  - Receber pacotes do cliente
#  - Validar dados
#  - Direcionar para handlers corretos
#
#  ⚠️ CRÍTICO:
#  Essa é a principal camada de segurança do servidor
#==============================================================================

module Handle_Data

	#--------------------------------------------------------------------------
	# 📡 ENTRY POINT (recebimento de pacotes)
	#--------------------------------------------------------------------------
	def handle_messages(client, buffer)
		begin
			header = buffer.read_byte

			#--------------------------------------------------------------
			# 🔒 Validação básica
			#--------------------------------------------------------------
			return unless valid_client?(client)

			#--------------------------------------------------------------
			# 🧠 Direcionamento de estado
			#--------------------------------------------------------------
			if client.in_game?
				dispatch_game_packet(client, header, buffer)
			else
				dispatch_menu_packet(client, header, buffer)
			end

		rescue => e
			log_error("Erro handle_messages: #{e.message}")
			client.close_connection
		end
	end

	#--------------------------------------------------------------------------
	# 🔒 VALIDAÇÃO DE CLIENTE
	#--------------------------------------------------------------------------
	def valid_client?(client)
		return false if client.nil?
		return false if client.disconnected?
		return true
	end

	#--------------------------------------------------------------------------
	# 🧭 DISPATCH MENU
	#--------------------------------------------------------------------------
	def dispatch_menu_packet(client, header, buffer)
		case header
		when Enums::Packet::LOGIN           then safe_handle(client) { handle_login(client, buffer) }
		when Enums::Packet::CREATE_ACCOUNT  then safe_handle(client) { handle_create_account(client, buffer) }
		when Enums::Packet::CREATE_ACTOR    then safe_handle(client) { handle_create_actor(client, buffer) }
		when Enums::Packet::REMOVE_ACTOR    then safe_handle(client) { handle_remove_actor(client, buffer) }
		when Enums::Packet::USE_ACTOR       then safe_handle(client) { handle_use_actor(client, buffer) }
		else
			log_error("Pacote inválido MENU: #{header}")
		end

		client.inactivity_time = Time.now + INACTIVITY_TIME
	end

	#--------------------------------------------------------------------------
	# 🎮 DISPATCH GAME
	#--------------------------------------------------------------------------
	def dispatch_game_packet(client, header, buffer)
		case header

		#------------------ MOVIMENTO ------------------
		when Enums::Packet::PLAYER_MOVE
			safe_handle(client) { handle_player_movement_secure(client, buffer) }

		#------------------ COMBATE ------------------
		when Enums::Packet::PLAYER_ATTACK
			safe_handle(client) { handle_player_attack_secure(client) }

		#------------------ CHAT ------------------
		when Enums::Packet::CHAT_MSG
			safe_handle(client) { handle_chat_message(client, buffer) }

		#------------------ ITEM ------------------
		when Enums::Packet::USE_ITEM
			safe_handle(client) { handle_use_item_secure(client, buffer) }

		#------------------ SKILL ------------------
		when Enums::Packet::USE_SKILL
			safe_handle(client) { handle_use_skill_secure(client, buffer) }

		else
			# Outros handlers (mantidos)
			handle_messages_game(client, header, buffer)
		end
	end

	#--------------------------------------------------------------------------
	# 🛡️ WRAPPER DE SEGURANÇA
	#--------------------------------------------------------------------------
	def safe_handle(client)
		begin
			yield
		rescue => e
			log_error("Erro handler (#{client.name}): #{e.message}")
			client.close_connection
		end
	end

	#--------------------------------------------------------------------------
	# 🚶 MOVIMENTO SEGURO
	#--------------------------------------------------------------------------
	def handle_player_movement_secure(client, buffer)
		direction = buffer.read_byte

		#--------------------------------------------------------------
		# 🔒 Validação de direção
		#--------------------------------------------------------------
		return unless valid_direction?(direction)

		#--------------------------------------------------------------
		# 🔒 Anti-speed hack
		#--------------------------------------------------------------
		return unless client.can_move?

		client.register_move

		#--------------------------------------------------------------
		# Executa movimento
		#--------------------------------------------------------------
		client.move_straight(direction)

		if client.move_succeed
			client.check_floor_effect
			client.check_touch_event
		end
	end

	def valid_direction?(d)
		d >= Enums::Dir::DOWN_LEFT && d <= Enums::Dir::UP_RIGHT
	end

	#--------------------------------------------------------------------------
	# ⚔️ ATAQUE SEGURO
	#--------------------------------------------------------------------------
	def handle_player_attack_secure(client)
		return unless client.can_act?

		client.register_action

		if client.using_range_weapon?
			client.attack_range
		elsif client.using_normal_weapon?
			client.attack_normal
		end
	end

	#--------------------------------------------------------------------------
	# 🎒 USO DE ITEM SEGURO
	#--------------------------------------------------------------------------
	def handle_use_item_secure(client, buffer)
		item_id = buffer.read_short
		item = $data_items[item_id]

		return unless item
		return unless client.has_item?(item)
		return unless client.can_act?

		client.register_action
		client.use_item(item)
	end

	#--------------------------------------------------------------------------
	# ✨ USO DE SKILL SEGURO
	#--------------------------------------------------------------------------
	def handle_use_skill_secure(client, buffer)
		skill_id = buffer.read_short
		skill = $data_skills[skill_id]

		return unless skill
		return unless client.skill_learn?(skill_id)
		return unless client.can_act?

		client.register_action
		client.use_item(skill)
	end

	#--------------------------------------------------------------------------
	# 📝 LOG
	#--------------------------------------------------------------------------
	def log_error(msg)
		puts("[HANDLE_DATA ERROR] #{msg}")
	end

end