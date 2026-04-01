#==============================================================================
# ** VS_Logger
#------------------------------------------------------------------------------
#  Sistema de logs do cliente FieldsOnline.
#  Registra eventos de rede, erros e informações de sessão em arquivo.
#------------------------------------------------------------------------------
#  Autor: Valentine / FieldsOnline
#  Uso:
#    $log = VS_Logger.new
#    $log.info("Mensagem")
#    $log.error("Erro", exception)
#==============================================================================

class VS_Logger

  # Tamanho máximo do arquivo de log antes da rotação (2 MB)
  MAX_SIZE = 2 * 1024 * 1024

  # Pasta onde os arquivos de log serão salvos
  LOG_DIR = 'Logs'

  #----------------------------------------------------------------------------
  # * Inicialização
  #    Cria a pasta de logs (se necessário), abre o arquivo e registra o início
  #    da sessão.
  #----------------------------------------------------------------------------
  def initialize
    # Garante que a pasta Logs/ existe antes de tentar escrever
    Dir.mkdir(LOG_DIR) unless Dir.exist?(LOG_DIR)

    # Monta o caminho do arquivo com a data atual
    @file_path = File.join(LOG_DIR, "client_#{date_stamp}.log")

    # Abre o arquivo em modo append (cria se não existir)
    @file = File.open(@file_path, 'a')

    # Registra o início da sessão
    write('INFO', '=== Sessão iniciada ===')
  end

  #----------------------------------------------------------------------------
  # * Registra mensagem de nível INFO
  #    msg : String com a mensagem a ser registrada
  #----------------------------------------------------------------------------
  def info(msg)
    write('INFO', msg)
  end

  #----------------------------------------------------------------------------
  # * Registra mensagem de nível WARN
  #    msg : String com a mensagem de aviso
  #----------------------------------------------------------------------------
  def warn(msg)
    write('WARN', msg)
  end

  #----------------------------------------------------------------------------
  # * Registra mensagem de nível ERROR
  #    msg       : String com a descrição do erro
  #    exception : Exception opcional — registra classe, mensagem e backtrace
  #----------------------------------------------------------------------------
  def error(msg, exception = nil)
    write('ERROR', msg)

    # Se uma exception foi fornecida, registra detalhes adicionais
    if exception
      write('ERROR', "  Classe    : #{exception.class}")
      write('ERROR', "  Mensagem  : #{exception.message}")

      # Registra até 5 linhas do backtrace para facilitar o diagnóstico
      if exception.backtrace && !exception.backtrace.empty?
        write('ERROR', '  Backtrace :')
        exception.backtrace.first(5).each_with_index do |line, index|
          write('ERROR', "    [#{index + 1}] #{line}")
        end
      end
    end
  end

  #----------------------------------------------------------------------------
  # * Encerra a sessão de log e fecha o arquivo
  #    Registra a mensagem de encerramento antes de fechar.
  #----------------------------------------------------------------------------
  def close
    write('INFO', '=== Sessão encerrada ===')

    # Fecha o arquivo apenas se ainda estiver aberto
    @file.close unless @file.closed?
  end

  #============================================================================
  # MÉTODOS PRIVADOS
  #============================================================================
  private

  #----------------------------------------------------------------------------
  # * Retorna a data atual formatada para uso no nome do arquivo
  #    Formato: YYYY-MM-DD
  #----------------------------------------------------------------------------
  def date_stamp
    Time.now.strftime('%Y-%m-%d')
  end

  #----------------------------------------------------------------------------
  # * Retorna o timestamp completo para o corpo da linha de log
  #    Formato: YYYY-MM-DD HH:MM:SS
  #----------------------------------------------------------------------------
  def time_stamp
    Time.now.strftime('%Y-%m-%d %H:%M:%S')
  end

  #----------------------------------------------------------------------------
  # * Escreve uma linha formatada no arquivo de log
  #    level : String com o nível (INFO, WARN, ERROR)
  #    msg   : String com o conteúdo da mensagem
  #
  #    Formato da linha:
  #      [YYYY-MM-DD HH:MM:SS] [LEVEL] mensagem
  #
  #    O level é justificado à esquerda com 5 caracteres:
  #      INFO  → "INFO "
  #      WARN  → "WARN "
  #      ERROR → "ERROR"
  #----------------------------------------------------------------------------
  def write(level, msg)
    # Não tenta escrever se o arquivo já foi fechado
    return if @file.closed?

    # Verifica se o arquivo atingiu o tamanho máximo e realiza rotação
    rotate if File.exist?(@file_path) && File.size(@file_path) >= MAX_SIZE

    # Monta a linha de log com timestamp e level justificado
    line = "[#{time_stamp}] [#{level.ljust(5)}] #{msg}"

    # Escreve a linha e força o flush para garantir persistência imediata
    @file.puts(line)
    @file.flush rescue nil
  end

  #----------------------------------------------------------------------------
  # * Rotação do arquivo de log
  #    Renomeia o arquivo atual para *_old.log e abre um novo arquivo.
  #    Usa rescue nil para evitar crash caso o rename falhe (ex: permissão).
  #----------------------------------------------------------------------------
  def rotate
    # Fecha o arquivo atual antes de renomear
    @file.close unless @file.closed?

    # Monta o caminho do arquivo de backup com sufixo _old
    old_path = @file_path.sub('.log', '_old.log')

    # Renomeia o arquivo atual — falha silenciosa se não for possível
    File.rename(@file_path, old_path) rescue nil

    # Atualiza o caminho (pode ter mudado de data após meia-noite)
    @file_path = File.join(LOG_DIR, "client_#{date_stamp}.log")

    # Abre o novo arquivo de log em modo append
    @file = File.open(@file_path, 'a')
  end

end