#==============================================================================

# ** [FO] Safe

#------------------------------------------------------------------------------

# Autor: Fields Online

# Versão: 1.1.0

#------------------------------------------------------------------------------

# Descrição:

# > Sistema de proteção contra erros

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

# Validação de objeto

# ===============================

def self.valid?(obj)
return false if obj.nil?
return false if obj.respond_to?(:disposed?) && obj.disposed?
return true
end

# ===============================

# Execução segura

# ===============================

def self.safe_call(description = "Unknown")


return yield unless FO_SAFE_CONFIG::ENABLE_SAFE_MODE

begin
  yield
rescue => e
  FO.error("SAFE ERROR (#{description}): #{e.message}")
  FO.error(e.backtrace.join("\n"))
end


end

end
