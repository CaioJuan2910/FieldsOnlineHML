#==============================================================================

# ** [FO] Logger

#------------------------------------------------------------------------------

# Autor: Fields Online

# Versão: 1.0.0

# Data: 2026-04-18

#------------------------------------------------------------------------------

# Descrição:

# > Sistema de log do Fields Online

# > Permite debug em tempo real e gravação em arquivo

#

# Responsabilidade:

# > Registrar eventos do sistema

# > Ajudar na identificação de erros

#

# Dependências:

# > [FO] Core

#==============================================================================

#==============================================================================

# ** FO_LOG_CONFIG

#------------------------------------------------------------------------------

# Configurações do sistema de log

#==============================================================================

module FO_LOG_CONFIG

ENABLE_LOG       = true
LOG_TO_FILE      = true
LOG_FILE_NAME    = "fo_log.txt"

end

#==============================================================================

# ** FO Logger

#==============================================================================

module FO

# ===============================

# Log INFO

# ===============================

def self.info(text)
write_log("INFO", text)
end

# ===============================

# Log WARNING

# ===============================

def self.warn(text)
write_log("WARN", text)
end

# ===============================

# Log ERROR

# ===============================

def self.error(text)
write_log("ERROR", text)
end

# ===============================

# Escrita principal

# ===============================

def self.write_log(type, text)
return unless FO_LOG_CONFIG::ENABLE_LOG


message = "[FO][#{type}] #{text}"

# Console
puts message

# Arquivo
if FO_LOG_CONFIG::LOG_TO_FILE
  begin
    File.open(FO_LOG_CONFIG::LOG_FILE_NAME, "a") do |file|
      file.puts(message)
    end
  rescue
    puts "[FO][ERROR] Falha ao escrever log em arquivo"
  end
end


end

end