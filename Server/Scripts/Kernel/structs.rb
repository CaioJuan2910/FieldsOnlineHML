#==============================================================================
# ** Structs
#------------------------------------------------------------------------------
#  Este script lida com as estruturas.
#------------------------------------------------------------------------------
#  Autor: Valentine
#  Revisão: Caio Juan De Lima Silva — Março 2026
#==============================================================================

# --- Interface ---

Hotbar = Struct.new(
	:type,
	:item_id
)

# --- Combate / Mundo ---

Target = Struct.new(
	:type,
	:id
)

Region = Struct.new(
	:x,
	:y
)

# --- Rede / Segurança ---

IP_Blocked = Struct.new(
	:attempts,
	:time
)

# --- Drops e Recompensas ---

# Lógica de visibilidade do drop:
#   - :party_id preenchido  → drop restrito ao grupo (party)
#   - :owner_id preenchido  → drop restrito a um jogador específico
#   - Ambos nil             → drop público, qualquer jogador pode coletar
Drop = Struct.new(
	:item_id,
	:kind,
	:amount,
	:name,
	:party_id,
	:owner_id,     # ID do jogador que causou o drop (nil = drop livre)
	:x,
	:y,
	:despawn_time,
	:pick_up_time
)

Reward = Struct.new(
	:item_id,
	:item_kind,
	:item_amount,
	:exp,
	:gold
)

# --- Sistema ---

Interpreter = Struct.new(
	:list,
	:event_id,
	:index,
	:time
)

# --- Social ---

# Campos marcados com [planejado] estão reservados para expansão futura
# de funcionalidades de MMO e podem ser nil no estado atual do sistema.
Guild = Struct.new(
	:id_db,
	:leader,
	:flag,
	:members,
	:notice,
	:tag,          # [planejado] Sigla/abreviação da guilda (ex: [WAR])
	:level,        # [planejado] Nível da guilda
	:exp,          # [planejado] Experiência acumulada da guilda
	:max_members,  # [planejado] Limite máximo de membros
	:vault         # [planejado] Inventário/baú compartilhado da guilda (Array)
)

# --- Conta e Personagem ---

# AVISO DE SEGURANÇA — campo :pass_hash
#   - Este campo deve armazenar APENAS o hash da senha (ex: SHA256, BCrypt).
#   - NUNCA armazene a senha em texto puro neste campo.
#   - A responsabilidade de realizar o hash é do servidor, antes de preencher
#     esta struct. O hash deve ser gerado no momento do cadastro ou login.
#   - NUNCA logue, exiba ou transmita o conteúdo deste campo ao cliente.
Account = Struct.new(
	:id_db,
	:pass_hash,
	:group,
	:vip_time,
	:actors,
	:friends
)

Actor = Struct.new(
	:id_db,
	:name,
	:character_name,
	:character_index,
	:face_name,
	:face_index,
	:class_id,
	:sex,
	:level,
	:exp,
	:hp,
	:mp,
	:param_base,
	:equips,
	:points,
	:guild_name,
	:revive_map_id,
	:revive_x,
	:revive_y,
	:map_id,
	:x,
	:y,
	:direction,
	:gold,
	:items,
	:weapons,
	:armors,
	:skills,
	:quests,
	:hotbar,
	:switches,
	:variables,
	:self_switches
)