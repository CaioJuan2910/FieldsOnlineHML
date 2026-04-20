#==============================================================================
# ** Send_Data (Refatorado)
#------------------------------------------------------------------------------
#  Responsável por enviar dados do servidor para os clientes
#
#  🔥 IMPORTANTE:
#  Esse módulo impacta diretamente:
#  - performance
#  - lag
#  - escalabilidade
#==============================================================================

module Send_Data

	#--------------------------------------------------------------------------
	# 🔒 ENVIO SEGURO
	#--------------------------------------------------------------------------
	# Evita crash se o cliente desconectar durante envio
	#--------------------------------------------------------------------------
	def safe_send(client, data)
		return unless client
		return unless client.respond_to?(:send_data)

		begin
			client.send_data(data)
		rescue => e
			puts("[SEND ERROR] #{e.message}")
		end
	end

	#--------------------------------------------------------------------------
	# 🌍 BROADCAST PARA MAPA
	#--------------------------------------------------------------------------
	def send_data_to_map(map_id, data)
		@clients.each_value do |client|
			next unless client&.in_game?
			next unless client.map_id == map_id

			safe_send(client, data)
		end
	end

	#--------------------------------------------------------------------------
	# 🌐 BROADCAST GLOBAL
	#--------------------------------------------------------------------------
	def send_data_to_all(data)
		@clients.each_value do |client|
			next unless client&.in_game?

			safe_send(client, data)
		end
	end

	#--------------------------------------------------------------------------
	# 👥 PARTY
	#--------------------------------------------------------------------------
	def send_data_to_party(party_id, data)
		return unless @parties[party_id]

		@parties[party_id].each do |member|
			safe_send(member, data)
		end
	end

	#--------------------------------------------------------------------------
	# 🛡️ GUILD
	#--------------------------------------------------------------------------
	def send_data_to_guild(guild_name, data)
		@clients.each_value do |client|
			next unless client&.in_game?
			next unless client.guild_name == guild_name

			safe_send(client, data)
		end
	end

	#--------------------------------------------------------------------------
	# 🧠 CRIADOR DE PACOTES (PADRÃO)
	#--------------------------------------------------------------------------
	def create_packet(packet_id)
		buffer = Buffer_Writer.new
		buffer.write_byte(packet_id)
		buffer
	end

	#--------------------------------------------------------------------------
	# 🚶 MOVIMENTO DO PLAYER
	#--------------------------------------------------------------------------
	def send_player_movement(client)
		buffer = create_packet(Enums::Packet::PLAYER_MOVE)

		buffer.write_short(client.id)
		buffer.write_short(client.x)
		buffer.write_short(client.y)
		buffer.write_byte(client.direction)

		send_data_to_map(client.map_id, buffer.to_s)
	end

	#--------------------------------------------------------------------------
	# ❤️ VIDA / MANA (OTIMIZADO)
	#--------------------------------------------------------------------------
	def send_player_vitals(client)
		#--------------------------------------------------------------
		# 🔥 OTIMIZAÇÃO:
		# Só envia se mudou
		#--------------------------------------------------------------
		if client.instance_variable_defined?(:@last_hp)
			return if client.hp == client.instance_variable_get(:@last_hp) &&
			          client.mp == client.instance_variable_get(:@last_mp)
		end

		client.instance_variable_set(:@last_hp, client.hp)
		client.instance_variable_set(:@last_mp, client.mp)

		buffer = create_packet(Enums::Packet::PLAYER_VITALS)

		buffer.write_short(client.id)
		buffer.write_int(client.hp)
		buffer.write_int(client.mp)

		send_data_to_map(client.map_id, buffer.to_s)
	end

	#--------------------------------------------------------------------------
	# 💬 CHAT GLOBAL
	#--------------------------------------------------------------------------
	def global_chat_message(message, color_id = Enums::Chat::GLOBAL)
		buffer = create_packet(Enums::Packet::CHAT_MSG)

		buffer.write_byte(color_id)
		buffer.write_string(message)

		send_data_to_all(buffer.to_s)
	end

	#--------------------------------------------------------------------------
	# 💬 CHAT MAPA
	#--------------------------------------------------------------------------
	def map_chat_message(map_id, message, player_id, color_id = Enums::Chat::MAP)
		buffer = create_packet(Enums::Packet::MAP_MSG)

		buffer.write_short(player_id)
		buffer.write_byte(color_id)
		buffer.write_string(message)

		send_data_to_map(map_id, buffer.to_s)
	end

	#--------------------------------------------------------------------------
	# ⚔️ ATAQUE PLAYER
	#--------------------------------------------------------------------------
	def send_attack_player(map_id, hp_damage, mp_damage, critical, attacker_id, attacker_type, ani_index, player_id, animation_id, not_show_missed)
		buffer = create_packet(Enums::Packet::ATTACK_PLAYER)

		buffer.write_short(attacker_id)
		buffer.write_byte(attacker_type)
		buffer.write_byte(ani_index)
		buffer.write_short(player_id)
		buffer.write_int(hp_damage)
		buffer.write_int(mp_damage)
		buffer.write_boolean(critical)
		buffer.write_short(animation_id)
		buffer.write_boolean(not_show_missed)

		send_data_to_map(map_id, buffer.to_s)
	end

	#--------------------------------------------------------------------------
	# ⚔️ ATAQUE MOB
	#--------------------------------------------------------------------------
	def send_attack_enemy(map_id, hp_damage, mp_damage, critical, attacker_id, attacker_type, ani_index, event_id, animation_id)
		buffer = create_packet(Enums::Packet::ATTACK_ENEMY)

		buffer.write_short(attacker_id)
		buffer.write_byte(attacker_type)
		buffer.write_byte(ani_index)
		buffer.write_short(event_id)
		buffer.write_int(hp_damage)
		buffer.write_int(mp_damage)
		buffer.write_boolean(critical)
		buffer.write_short(animation_id)

		send_data_to_map(map_id, buffer.to_s)
	end

	#--------------------------------------------------------------------------
	# ✨ ANIMAÇÃO
	#--------------------------------------------------------------------------
	def send_animation(character, animation_id, attacker_id, attacker_type, ani_index, character_type)
		buffer = create_packet(Enums::Packet::ANIMATION)

		buffer.write_short(attacker_id)
		buffer.write_byte(attacker_type)
		buffer.write_byte(ani_index)
		buffer.write_short(character.id)
		buffer.write_byte(character_type)
		buffer.write_short(animation_id)

		send_data_to_map(character.map_id, buffer.to_s)
	end

	#--------------------------------------------------------------------------
	# 📦 DROP
	#--------------------------------------------------------------------------
	def send_add_drop(map_id, item_id, kind, amount, x, y)
		buffer = create_packet(Enums::Packet::ADD_DROP)

		buffer.write_short(item_id)
		buffer.write_byte(kind)
		buffer.write_short(amount)
		buffer.write_short(x)
		buffer.write_short(y)

		send_data_to_map(map_id, buffer.to_s)
	end

end