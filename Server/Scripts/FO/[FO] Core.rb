#==============================================================================

# ** [FO] Core

#------------------------------------------------------------------------------

# Autor: Fields Online

# Versão: 1.0.0

# Data: 2026-04-18

#------------------------------------------------------------------------------

# Descrição:

# > Núcleo principal do sistema FO.

# > Responsável por inicialização, utilidades globais e acesso central.

#

# Responsabilidade:

# > Controlar estados globais do FO

# > Fornecer métodos utilitários

#

# Dependências:

# > Nenhuma (script base)

#==============================================================================

#==============================================================================

# ** FO_CONFIG

#------------------------------------------------------------------------------

# Configurações globais do sistema

#==============================================================================

module FO_CONFIG

# ===============================

# Sistema

# ===============================

DEBUG_MODE   = true     # Ativa logs no console
VERSION      = "1.0.0"  # Versão atual do FO

end

#==============================================================================

# ** FO

#------------------------------------------------------------------------------

# Módulo principal do sistema Fields Online

#==============================================================================

module FO

# ===============================

# Inicialização

# ===============================

def self.init
log("Inicializando Fields Online Core v#{FO_CONFIG::VERSION}")
end

# ===============================

# Logger básico (temporário)

# ===============================

def self.log(text)
return unless FO_CONFIG::DEBUG_MODE
puts "[FO] #{text}"
end

end

# Inicializa automaticamente

FO.init