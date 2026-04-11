#==============================================================================
# ** Handle_Data
#------------------------------------------------------------------------------
#  Este script recebe as mensagens do cliente.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Handle_Data

  # Valida se uma string recebida do cliente é segura para processar.
  # Evita injeção de dados maliciosos, strings nulas ou caracteres de controle.
  def valid_string?(str)
    # Rejeita valores nulos ou que não sejam strings
    return false unless str.is_a?(String)
    # Rejeita strings vazias
    return false if str.empty?
    # Rejeita caracteres de controle (0x00-0x1F) e símbolos perigosos
    return false if str.match?(/[\x00-\x1F<>'"\\\/]/)
    true
  end

	def handle_messages(client, buffer)
		begin
			header = buffer.read_byte
			if client.in_game?
				handle_messages_game(client, header, buffer)
			else
				handle_messages_menu(client, header, buffer)
			end
		rescue => e
			client.close_connection
			@log.add('Error', :red, "Erro: #{e}\n#{e.backtrace.join("\n")}")
		end
	end

	def handle_messages_menu(client, header, buffer)
		case header
		when Enums::Packet::LOGIN
			handle_login(client, buffer)
		when Enums::Packet::CREATE_ACCOUNT
			handle_create_account(client, buffer)
		when Enums::Packet::CREATE_ACTOR
			handle_create_actor(client, buffer)
		when Enums::Packet::REMOVE_ACTOR
			handle_remove_actor(client, buffer)
		when Enums::Packet::USE_ACTOR
			handle_use_actor(client, buffer)
		end
		client.inactivity_time = Time.now + INACTIVITY_TIME
	end

	def handle_messages_game(client, header, buffer)
		case header
		when Enums::Packet::PLAYER_MOVE
			handle_player_movement(client, buffer)
		when Enums::Packet::CHAT_MSG
			handle_chat_message(client, buffer)
		when Enums::Packet::PLAYER_ATTACK
			handle_player_attack(client)
		when Enums::Packet::USE_ITEM
			handle_use_item(client, buffer)
		when Enums::Packet::USE_SKILL
			handle_use_skill(client, buffer)
		when Enums::Packet::BALLOON
			handle_balloon(client, buffer)
		when Enums::Packet::USE_HOTBAR
			handle_use_hotbar(client, buffer)
		when Enums::Packet::ADD_DROP
			handle_add_drop(client, buffer)
		when Enums::Packet::REMOVE_DROP
			handle_remove_drop(client, buffer)
		when Enums::Packet::PLAYER_PARAM
			handle_player_param(client, buffer)
		when Enums::Packet::PLAYER_EQUIP
			handle_player_equip(client, buffer)
		when Enums::Packet::PLAYER_HOTBAR
			handle_player_hotbar(client, buffer)
		when Enums::Packet::TARGET
			handle_target(client, buffer)
		when Enums::Packet::OPEN_FRIENDS
			handle_open_friends(client)
		when Enums::Packet::REMOVE_FRIEND
			handle_remove_friend(client, buffer)
		when Enums::Packet::CREATE_GUILD
			handle_create_guild(client, buffer)
		when Enums::Packet::OPEN_GUILD
			handle_open_guild(client)
		when Enums::Packet::GUILD_LEADER
			handle_guild_leader(client, buffer)
		when Enums::Packet::GUILD_NOTICE
			handle_guild_notice(client, buffer)
		when Enums::Packet::REMOVE_GUILD_MEMBER
			handle_remove_guild_member(client, buffer)
		when Enums::Packet::GUILD_REQUEST
			handle_guild_request(client, buffer)
		when Enums::Packet::LEAVE_GUILD
			handle_leave_guild(client)
		when Enums::Packet::LEAVE_PARTY
			handle_leave_party(client)
		when Enums::Packet::CHOICE
			handle_choice(client, buffer)
		when Enums::Packet::BANK_ITEM
			handle_bank_item(client, buffer)
		when Enums::Packet::BANK_GOLD
			handle_bank_gold(client, buffer)
		when Enums::Packet::CLOSE_WINDOW
			handle_close_window(client)
		when Enums::Packet::BUY_ITEM
			handle_buy_item(client, buffer)
		when Enums::Packet::SELL_ITEM
			handle_sell_item(client, buffer)
		when Enums::Packet::CHOICE_TELEPORT
			handle_choice_teleport(client, buffer)
		when Enums::Packet::NEXT_COMMAND
			handle_next_event_command(client)
		when Enums::Packet::REQUEST
			handle_request(client, buffer)
		when Enums::Packet::ACCEPT_REQUEST
			handle_accept_request(client)
		when Enums::Packet::DECLINE_REQUEST
			handle_decline_request(client)
		when Enums::Packet::TRADE_ITEM
			handle_trade_item(client, buffer)
		when Enums::Packet::TRADE_GOLD
			handle_trade_gold(client, buffer)
		when Enums::Packet::LOGOUT
			handle_logout(client)
		when Enums::Packet::ADMIN_COMMAND
			handle_admin_command(client, buffer)
		end
	end

	def handle_login(client, buffer)
		return if client.in_game?
		return unless $database  # Banco ainda não inicializado
		user = buffer.read_string
		pass = buffer.read_string
		return unless valid_string?(user) && valid_string?(pass)
		# Verifica se a conta existe
		unless $database.account_exist?(user)
			Send_Data.send_login(client, Enums::Login::UNREGISTERED)
			return
		end
		# Verifica a senha
		unless $database.correct_password?(user, pass)
			Send_Data.send_login(client, Enums::Login::WRONG_PASSWORD)
			return
		end
		# Verifica se a conta já está em uso
		if account_in_use?(user)
			Send_Data.send_login(client, Enums::Login::IN_USE)
			return
		end
		# Verifica se a conta está banida
		if $database.account_banned?(user)
			Send_Data.send_login(client, Enums::Login::BANNED)
			return
		end
		client.account = $database.load_account(user)
		Send_Data.send_login(client, Enums::Login::SUCCESS)
		Send_Data.send_actors(client)
	end

	def handle_create_account(client, buffer)
		return if client.in_game?
		return unless $database  # Banco ainda não inicializado
		user = buffer.read_string
		pass = buffer.read_string
		return unless valid_string?(user) && valid_string?(pass)
		# Verifica se a conta já existe
		if $database.account_exist?(user)
			Send_Data.send_create_account(client, Enums::CreateAccount::IN_USE)
			return
		end
		$database.create_account(user, pass)
		client.account = $database.load_account(user)
		Send_Data.send_create_account(client, Enums::CreateAccount::SUCCESS)
		Send_Data.send_actors(client)
	end

	def handle_create_actor(client, buffer)
		return if client.in_game?
		return unless client.account
		name = buffer.read_string
		actor_class = buffer.read_byte
		return unless valid_string?(name)
		# Verifica se o nome já está em uso
		if $database.actor_name_exist?(name)
			Send_Data.send_create_actor(client, Enums::CreateActor::NAME_IN_USE)
			return
		end
		# Verifica se atingiu o limite de atores
		if client.account.actors.size >= MAX_ACTORS
			Send_Data.send_create_actor(client, Enums::CreateActor::LIMIT)
			return
		end
		$database.create_actor(client.account, name, actor_class)
		Send_Data.send_create_actor(client, Enums::CreateActor::SUCCESS)
		Send_Data.send_actors(client)
	end

	def handle_remove_actor(client, buffer)
		return if client.in_game?
		return unless client.account
		index = buffer.read_byte
		return unless client.account.actors[index]
		$database.remove_actor(client.account, index)
		Send_Data.send_actors(client)
	end

	def handle_use_actor(client, buffer)
		return if client.in_game?
		return unless client.account
		index = buffer.read_byte
		return unless client.account.actors[index]
		client.select_actor(index)
		Send_Data.send_use_actor(client)
		Send_Data.send_map(client)
	end

	def handle_player_movement(client, buffer)
		return unless client.in_game?
		return if client.stop_count && Time.now < client.stop_count
		d = buffer.read_byte
		x = buffer.read_short
		y = buffer.read_short
		return unless client.actor.movable?
		return if client.actor.x != x || client.actor.y != y
		client.stop_count = Time.now + 0.170
		if d.odd?
			client.move_diagonal(d)
		else
			client.move_straight(d)
		end
	end

	def handle_chat_message(client, buffer)
		return unless client.in_game?
		msg = buffer.read_string
		return unless valid_string?(msg)
		type = buffer.read_byte
		msg = msg[0, MAX_CHAT_LENGTH]
		case type
		when Enums::Chat::MAP
			Send_Data.send_chat_message(client, client.actor.name, msg, type)
		when Enums::Chat::GLOBAL
			Send_Data.send_chat_message_all(client.actor.name, msg, type)
		when Enums::Chat::WHISPER
			target_name = buffer.read_string
			target = find_player_by_name(target_name)
			if target
				Send_Data.send_chat_message_whisper(client, target, msg)
			else
				Send_Data.send_notification(client, Enums::Notification::PLAYER_NOT_FOUND)
			end
		when Enums::Chat::PARTY
			Send_Data.send_chat_message_party(client, msg)
		when Enums::Chat::GUILD
			Send_Data.send_chat_message_guild(client, msg)
		end
	end

	def handle_player_attack(client)
		return unless client.in_game?
		return unless client.actor.movable?
		return if client.actor.weapon_id > 0 && !client.actor.has_item?(client.actor.weapon_id, Enums::Item::WEAPON)
		client.attack
	end

	def handle_use_item(client, buffer)
		return unless client.in_game?
		item_id = buffer.read_short
		return unless client.actor.movable?
		return unless client.actor.has_item?(item_id, Enums::Item::ITEM)
		client.use_item(item_id)
	end

	def handle_use_skill(client, buffer)
		return unless client.in_game?
		skill_id = buffer.read_short
		return unless client.actor.movable?
		return unless client.actor.has_skill?(skill_id)
		client.use_skill(skill_id)
	end

	def handle_balloon(client, buffer)
		return unless client.in_game?
		balloon_id = buffer.read_byte
		Send_Data.send_balloon(client, balloon_id)
	end

	def handle_use_hotbar(client, buffer)
		return unless client.in_game?
		index = buffer.read_byte
		return unless client.actor.movable?
		hotbar = client.actor.hotbar[index]
		return unless hotbar
		case hotbar.type
		when Enums::Hotbar::ITEM
			return unless client.actor.has_item?(hotbar.id, Enums::Item::ITEM)
			client.use_item(hotbar.id)
		when Enums::Hotbar::SKILL
			return unless client.actor.has_skill?(hotbar.id)
			client.use_skill(hotbar.id)
		end
	end

	def handle_add_drop(client, buffer)
		return unless client.in_game?
		item_id   = buffer.read_short
		item_type = buffer.read_byte
		amount    = buffer.read_short
		return unless client.actor.movable?
		return unless amount > 0
		return unless client.actor.has_item?(item_id, item_type, amount)
		client.add_drop(item_id, item_type, amount)
	end

	def handle_remove_drop(client, buffer)
		return unless client.in_game?
		drop_index = buffer.read_short
		return unless client.actor.movable?
		client.remove_drop(drop_index)
	end

	def handle_player_param(client, buffer)
		return unless client.in_game?
		param_id = buffer.read_byte
		return unless client.actor.param_points > 0
		return unless param_id.between?(0, 5)
		client.actor.add_param(param_id, 1)
		client.actor.param_points -= 1
		client.actor.recover_all
		Send_Data.send_player_param(client)
		Send_Data.send_player_status(client)
	end

	def handle_player_equip(client, buffer)
		return unless client.in_game?
		item_id   = buffer.read_short
		item_type = buffer.read_byte
		slot_id   = buffer.read_byte
		return unless client.actor.movable?
		client.actor.change_equip(slot_id, item_id, item_type)
		Send_Data.send_player_equip(client)
		Send_Data.send_player_status(client)
		Send_Data.send_actor_equip(client)
	end

	def handle_player_hotbar(client, buffer)
		return unless client.in_game?
		index     = buffer.read_byte
		id        = buffer.read_short
		item_type = buffer.read_byte
		client.actor.hotbar[index] = id > 0 ? Game_Hotbar.new(id, item_type) : nil
		Send_Data.send_player_hotbar(client)
	end

	def handle_target(client, buffer)
		return unless client.in_game?
		target_type  = buffer.read_byte
		target_index = buffer.read_short
		client.actor.target_type  = target_type
		client.actor.target_index = target_index
	end

	def handle_open_friends(client)
		return unless client.in_game?
		Send_Data.send_friends(client)
	end

	def handle_remove_friend(client, buffer)
		return unless client.in_game?
		name = buffer.read_string
		return unless valid_string?(name)
		client.actor.friends.delete(name)
		Send_Data.send_friends(client)
	end

	def handle_create_guild(client, buffer)
		return unless client.in_game?
		name = buffer.read_string
		return unless valid_string?(name)
		return if client.actor.guild
		if $database.guild_exist?(name)
			Send_Data.send_notification(client, Enums::Notification::GUILD_NAME_IN_USE)
			return
		end
		unless client.actor.gold >= GUILD_PRICE
			Send_Data.send_notification(client, Enums::Notification::NOT_ENOUGH_GOLD)
			return
		end
		client.actor.gold -= GUILD_PRICE
		$database.create_guild(client, name)
		Send_Data.send_player_gold(client)
		Send_Data.send_guild(client)
	end

	def handle_open_guild(client)
		return unless client.in_game?
		Send_Data.send_guild(client)
	end

	def handle_guild_leader(client, buffer)
		return unless client.in_game?
		name = buffer.read_string
		return unless valid_string?(name)
		return unless client.actor.guild
		return unless client.actor.guild_rank == Enums::GuildRank::LEADER
		return if client.actor.name == name
		guild = client.actor.guild
		return unless guild.member_exist?(name)
		guild.change_leader(client.actor.name, name)
		Send_Data.send_guild_all(guild)
	end

	def handle_guild_notice(client, buffer)
		return unless client.in_game?
		notice = buffer.read_string
		return unless client.actor.guild
		return unless client.actor.guild_rank == Enums::GuildRank::LEADER
		guild = client.actor.guild
		guild.notice = notice
		Send_Data.send_guild_all(guild)
	end

	def handle_remove_guild_member(client, buffer)
		return unless client.in_game?
		name = buffer.read_string
		return unless valid_string?(name)
		return unless client.actor.guild
		return unless client.actor.guild_rank == Enums::GuildRank::LEADER
		return if client.actor.name == name
		guild = client.actor.guild
		return unless guild.member_exist?(name)
		target = find_player_by_name(name)
		if target
			target.actor.guild      = nil
			target.actor.guild_rank = nil
			Send_Data.send_guild(target)
		else
			$database.remove_guild_member(guild, name)
		end
		guild.remove_member(name)
		Send_Data.send_guild_all(guild)
	end

	def handle_guild_request(client, buffer)
		return unless client.in_game?
		name = buffer.read_string
		return unless valid_string?(name)
		return unless client.actor.guild
		return unless client.actor.guild_rank == Enums::GuildRank::LEADER
		target = find_player_by_name(name)
		unless target
			Send_Data.send_notification(client, Enums::Notification::PLAYER_NOT_FOUND)
			return
		end
		if target.actor.guild
			Send_Data.send_notification(client, Enums::Notification::PLAYER_IN_GUILD)
			return
		end
		target.actor.guild_invite = client.actor.guild
		Send_Data.send_request(target, Enums::Request::GUILD, client.actor.name)
	end

	def handle_leave_guild(client)
		return unless client.in_game?
		return unless client.actor.guild
		return if client.actor.guild_rank == Enums::GuildRank::LEADER
		guild = client.actor.guild
		guild.remove_member(client.actor.name)
		client.actor.guild      = nil
		client.actor.guild_rank = nil
		Send_Data.send_guild(client)
		Send_Data.send_guild_all(guild)
	end

	def handle_leave_party(client)
		return unless client.in_game?
		return unless client.actor.party
		client.leave_party
	end

	def handle_choice(client, buffer)
		return unless client.in_game?
		choice = buffer.read_byte
		client.choice = choice
	end

	def handle_bank_item(client, buffer)
		return unless client.in_game?
		item_id   = buffer.read_short
		item_type = buffer.read_byte
		amount    = buffer.read_short
		operation = buffer.read_byte
		return unless client.in_bank?
		return unless amount > 0
		case operation
		when Enums::Bank::DEPOSIT
			return unless client.actor.has_item?(item_id, item_type, amount)
			client.actor.remove_item(item_id, item_type, amount)
			client.account.bank_add_item(item_id, item_type, amount)
		when Enums::Bank::WITHDRAW
			return unless client.account.bank_has_item?(item_id, item_type, amount)
			client.account.bank_remove_item(item_id, item_type, amount)
			client.actor.add_item(item_id, item_type, amount)
		end
		Send_Data.send_player_items(client)
		Send_Data.send_bank(client)
	end

	def handle_bank_gold(client, buffer)
		return unless client.in_game?
		amount    = buffer.read_int
		operation = buffer.read_byte
		return unless client.in_bank?
		return unless amount > 0
		case operation
		when Enums::Bank::DEPOSIT
			return unless client.actor.gold >= amount
			client.actor.gold -= amount
			client.account.bank_gold += amount
		when Enums::Bank::WITHDRAW
			return unless client.account.bank_gold >= amount
			client.account.bank_gold -= amount
			client.actor.gold += amount
		end
		Send_Data.send_player_gold(client)
		Send_Data.send_bank(client)
	end

	def handle_close_window(client)
		return unless client.in_game?
		client.actor.in_event  = false
		client.actor.in_shop   = false
		client.actor.in_bank   = false
		client.actor.in_trade  = false
	end

	def handle_buy_item(client, buffer)
		return unless client.in_game?
		item_index = buffer.read_byte
		amount     = buffer.read_short
		return unless client.in_shop?
		return unless amount > 0
		shop = client.actor.shop
		return unless shop
		item = shop.items[item_index]
		return unless item
		total_price = item.price * amount
		return unless client.actor.gold >= total_price
		client.actor.gold -= total_price
		client.actor.add_item(item.id, item.type, amount)
		Send_Data.send_player_gold(client)
		Send_Data.send_player_items(client)
	end

	def handle_sell_item(client, buffer)
		return unless client.in_game?
		item_id   = buffer.read_short
		item_type = buffer.read_byte
		amount    = buffer.read_short
		return unless client.in_shop?
		return unless amount > 0
		return unless client.actor.has_item?(item_id, item_type, amount)
		item_data = $database.get_item(item_id, item_type)
		return unless item_data
		sell_price = (item_data.price * SELL_FACTOR).to_i
		client.actor.remove_item(item_id, item_type, amount)
		client.actor.gold += sell_price * amount
		Send_Data.send_player_gold(client)
		Send_Data.send_player_items(client)
	end

	def handle_choice_teleport(client, buffer)
		return unless client.in_game?
		index = buffer.read_byte
		return unless client.actor.teleport_choices
		choice = client.actor.teleport_choices[index]
		return unless choice
		client.actor.teleport_choices = nil
		client.teleport(choice[:map_id], choice[:x], choice[:y])
	end

	def handle_next_event_command(client)
		return unless client.in_game?
		client.actor.next_command = true
	end

	def handle_request(client, buffer)
		return unless client.in_game?
		type = buffer.read_byte
		case type
		when Enums::Request::PARTY
			target_name = buffer.read_string
			return unless valid_string?(target_name)
			target = find_player_by_name(target_name)
			unless target
				Send_Data.send_notification(client, Enums::Notification::PLAYER_NOT_FOUND)
				return
			end
			if target.actor.party
				Send_Data.send_notification(client, Enums::Notification::PLAYER_IN_PARTY)
				return
			end
			target.actor.party_invite = client
			Send_Data.send_request(target, Enums::Request::PARTY, client.actor.name)
		end
	end

	def handle_accept_request(client)
		return unless client.in_game?
		if client.actor.guild_invite
			guild = client.actor.guild_invite
			client.actor.guild_invite = nil
			guild.add_member(client.actor.name)
			client.actor.guild      = guild
			client.actor.guild_rank = Enums::GuildRank::MEMBER
			Send_Data.send_guild(client)
			Send_Data.send_guild_all(guild)
		end
		if client.actor.party_invite
			inviter = client.actor.party_invite
			client.actor.party_invite = nil
			client.join_party(inviter)
		end
	end

	def handle_decline_request(client)
		return unless client.in_game?
		client.actor.guild_invite = nil
		client.actor.party_invite = nil
	end

	def handle_trade_item(client, buffer)
		return unless client.in_game?
		item_id   = buffer.read_short
		item_type = buffer.read_byte
		amount    = buffer.read_short
		operation = buffer.read_byte
		return unless client.in_trade?
		return unless amount > 0
		target = client.actor.trade_target
		return unless target
		case operation
		when Enums::Trade::ADD
			return unless client.actor.has_item?(item_id, item_type, amount)
			client.actor.trade_items ||= []
			client.actor.trade_items << { id: item_id, type: item_type, amount: amount }
		when Enums::Trade::REMOVE
			return unless client.actor.trade_items
			client.actor.trade_items.delete_if { |i| i[:id] == item_id && i[:type] == item_type }
		end
		Send_Data.send_trade_items(client, target)
	end

	def handle_trade_gold(client, buffer)
		return unless client.in_game?
		amount = buffer.read_int
		return unless client.in_trade?
		target = client.actor.trade_target
		return unless target
		client.actor.trade_gold = amount
		Send_Data.send_trade_gold(client, target)
	end

	def handle_logout(client)
		return unless client.in_game?
		client.logout
	end

	def handle_admin_command(client, buffer)
		return unless client.in_game?
		return unless client.actor.admin?
		command = buffer.read_byte
		case command
		when Enums::Admin::WARP
			map_id = buffer.read_short
			x      = buffer.read_short
			y      = buffer.read_short
			client.teleport(map_id, x, y)
		when Enums::Admin::SUMMON
			name = buffer.read_string
			return unless valid_string?(name)
			target = find_player_by_name(name)
			return unless target
			client.teleport(target.actor.map_id, target.actor.x, target.actor.y)
		when Enums::Admin::CALL
			name = buffer.read_string
			return unless valid_string?(name)
			target = find_player_by_name(name)
			return unless target
			target.teleport(client.actor.map_id, client.actor.x, client.actor.y)
		when Enums::Admin::KICK
			name = buffer.read_string
			return unless valid_string?(name)
			target = find_player_by_name(name)
			return unless target
			target.close_connection
		when Enums::Admin::BAN
			name = buffer.read_string
			return unless valid_string?(name)
			target = find_player_by_name(name)
			if target
				$database.ban_account(target.account.user)
				target.close_connection
			else
				$database.ban_account(name)
			end
		when Enums::Admin::MUTE
			name = buffer.read_string
			return unless valid_string?(name)
			target = find_player_by_name(name)
			return unless target
			target.actor.muted = !target.actor.muted
		when Enums::Admin::CHANGE_LEVEL
			name  = buffer.read_string
			level = buffer.read_byte
			return unless valid_string?(name)
			target = find_player_by_name(name)
			return unless target
			target.actor.change_level(level)
			Send_Data.send_player_exp(target)
			Send_Data.send_player_status(target)
		when Enums::Admin::CHANGE_GOLD
			name   = buffer.read_string
			amount = buffer.read_int
			return unless valid_string?(name)
			target = find_player_by_name(name)
			return unless target
			target.actor.gold = amount
			Send_Data.send_player_gold(target)
		when Enums::Admin::GIVE_ITEM
			name      = buffer.read_string
			item_id   = buffer.read_short
			item_type = buffer.read_byte
			amount    = buffer.read_short
			return unless valid_string?(name)
			target = find_player_by_name(name)
			return unless target
			target.actor.add_item(item_id, item_type, amount)
			Send_Data.send_player_items(target)
		when Enums::Admin::SPAWN_ENEMY
			enemy_id = buffer.read_short
			map_id   = buffer.read_short
			x        = buffer.read_short
			y        = buffer.read_short
			map = $game_map[map_id]
			return unless map
			map.spawn_enemy(enemy_id, x, y)
		end
	end

end