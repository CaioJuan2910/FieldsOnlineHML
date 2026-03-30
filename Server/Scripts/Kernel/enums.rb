#==============================================================================
# ** Enums
#------------------------------------------------------------------------------
#  Este módulo lida com as enumerações.
#------------------------------------------------------------------------------
#  Autor: Valentine
#  Revisão: Caio Juan De Lima Silva — Março 2026
#==============================================================================

module Enums

	# Equipamentos
	Equip = enum %w(
		WEAPON      # [0] WEAPON
		SHIELD      # [1] SHIELD
		HELMET      # [2] HELMET
		ARMOR       # [3] ARMOR
		ACCESSORY   # [4] ACCESSORY
		             # Era: ACESSORY — corrigido para evitar conflito com referências futuras
		AMULET      # [5] AMULET
		COVER       # [6] COVER
		GLOVE       # [7] GLOVE
		BOOT        # [8] BOOT
	)

	# Parâmetros
	# Espelha o param_id 0–7 do VXAce (usado em Game_BattlerBase#param, etc.)
	Param = enum %w(
		MAXHP  # [0] MAXHP
		MAXMP  # [1] MAXMP
		ATK    # [2] ATK
		DEF    # [3] DEF
		MAT    # [4] MAT
		MDF    # [5] MDF
		AGI    # [6] AGI
		LUK    # [7] LUK
	)

	# Escopos dos itens
	# Espelha o item_scope 0–11 do VXAce (RPG::UsableItem#scope)
	Item = enum %w(
		SCOPE_NONE                 # [0]  Nenhum alvo
		SCOPE_ENEMY                # [1]  1 inimigo
		SCOPE_ALL_ENEMIES          # [2]  Todos os inimigos
		SCOPE_RANDOM_ENEMY_1       # [3]  1 inimigo aleatório
		SCOPE_RANDOM_ENEMY_2       # [4]  2 inimigos aleatórios
		SCOPE_RANDOM_ENEMY_3       # [5]  3 inimigos aleatórios
		SCOPE_RANDOM_ENEMY_4       # [6]  4 inimigos aleatórios
		SCOPE_ONE_ALLY             # [7]  1 aliado
		SCOPE_ALL_ALLIES           # [8]  Todos os aliados
		SCOPE_ONE_ALLY_KNOCKED_OUT # [9]  1 aliado nocauteado
		SCOPE_ALLIES_KNOCKED_OUT   # [10] Todos os aliados nocauteados
		SCOPE_USER                 # [11] Usuário
	)

	# Movimentos dos eventos
	Move = enum %w(
		FIXED          # [0] FIXED
		RANDOM         # [1] RANDOM
		TOWARD_PLAYER  # [2] TOWARD_PLAYER
		CUSTOM         # [3] CUSTOM
	)

end