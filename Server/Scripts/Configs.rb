#==============================================================================

# ** Configs (Servidor)

#------------------------------------------------------------------------------

# Compatibilidade com VXA-OS

# Espelhamento das constantes essenciais do cliente

#==============================================================================

module Configs

# ===============================

# COMBATE

# ===============================

ATTACK_TIME = 0.8
COOLDOWN_SKILL_TIME = 1

# ===============================

# LIMITES

# ===============================

MAX_ITEMS  = 999
MAX_GOLD   = 99_999_999
MAX_PARAMS = 999_999
MAX_LEVEL  = 99

# ===============================

# PLAYER

# ===============================

MAX_PLAYER_SWITCHES   = 100
MAX_PLAYER_VARIABLES  = 100

# ===============================

# SISTEMA

# ===============================

MAX_PARTY_MEMBERS = 4
MAX_MEMBERS       = 4 rescue 4 # fallback

MIN_CHARACTERS = 3
MAX_CHARACTERS = 12

end
