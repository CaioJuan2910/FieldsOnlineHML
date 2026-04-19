#==============================================================================

# ** [FO] Safe

#------------------------------------------------------------------------------

# Autor: Fields Online

# Versão: 1.1.0

# Data: 2026-04-19

#------------------------------------------------------------------------------

# Descrição:

# > Sistema de proteção contra erros comuns (nil / disposed)

# > Evita crashes em sprites, scenes e objetos

#

# Responsabilidade:

# > Validar objetos antes de uso

# > Proteger chamadas críticas

#

# Dependências:

# > [FO] Core

# > [FO] Logger

#==============================================================================

#==============================================================================

# ** FO_SAFE_CONFIG

#==============================================================================

module FO_SAFE_CONFIG

ENABLE_SAFE_MODE = true

end

#==============================================================================

# ** FO Safe

#==============================================================================

module FO

# ===============================

# Verifica se objeto é válido

# ===============================

def self.valid?(obj)
return false if obj.nil?
return false if obj.respond_to?(:disposed?) && obj.disposed?
return true
end

# ===============================

# Execução protegida

# ===============================

def self.safe_call(description = "Unknown")
return yield unless FO_SAFE_CONFIG::ENABLE_SAFE_MODE


begin
  yield
rescue => e
  FO.error("SAFE ERROR (#{description}): #{e.message}") if defined?(FO)
  FO.error(e.backtrace.join("\n")) if defined?(FO)
end


end

end

#==============================================================================

# ** Patch seguro para Sprite

#==============================================================================

class Sprite

alias_method :fo_safe_dispose, :dispose rescue nil

def dispose
return unless FO.valid?(self)
fo_safe_dispose if defined?(fo_safe_dispose)
end

end

#==============================================================================

# ** Patch seguro para Window

#==============================================================================

class Window

alias_method :fo_safe_dispose, :dispose rescue nil

def dispose
return unless FO.valid?(self)
fo_safe_dispose if defined?(fo_safe_dispose)
end

end

#==============================================================================

# ** Patch seguro para Scene_Base (VERSÃO CORRETA)

#==============================================================================

class Scene_Base

def update(*args)
FO.safe_call("Scene Update") do
super
end
end

end
