#==============================================================================
# ** Logger
#------------------------------------------------------------------------------
# Grava informações importantes do servidor: erros, avisos, ações de admins
# e eventos de conexão. Suporta níveis de severidade e salvamento imediato
# para erros críticos, evitando perda de registros em caso de crash.
#
# Compatibilidade retroativa: o método add(type, color, text) original
# continua funcionando normalmente — nenhuma chamada existente precisa mudar.
#
# Uso dos novos métodos:
#   @log.info("Servidor iniciado")
#   @log.warn("Pacote suspeito recebido", client)
#   @log.error("Falha ao processar pacote", client, exception)
#   @log.fatal("Crash irrecuperável", exception)
#   @log.save_all   ← chamado pelo save_game_data
#------------------------------------------------------------------------------
# Autor: Valentine | Melhorado: FieldsOnline
# Versão: 2.0
#==============================================================================
class Logger

  #----------------------------------------------------------------------------
  # Mapeamento de nível de log → cor no console (gem colorize)
  #----------------------------------------------------------------------------
  LEVEL_COLORS = {
    'INFO'    => :cyan,
    'WARN'    => :yellow,
    'ERROR'   => :red,
    'FATAL'   => :light_red,
    'Admin'   => :green,
    'Monitor' => :magenta
  }

  def initialize
    @text = {}
    Dir.mkdir('Logs') unless Dir.exist?('Logs')
  end

  # ============================================================
  # MÉTODOS PÚBLICOS
  # ============================================================

  def add(type, color, text)
    type = resolve_group_type(type)
    timestamp = Time.now.strftime('%X')
    day = day_key(type)
    @text[day] = "#{@text[day]}#{timestamp}: #{text}\n"
    puts(text.colorize(color))
    flush_file(day) if type == 'Error' || type == 'FATAL'
  end

  def info(text, client = nil)
    log_level('INFO', text, client, immediate: false)
  end

  def warn(text, client = nil)
    log_level('WARN', text, client, immediate: false)
  end

  def error(text, client = nil, exception = nil)
    parts = [text]
    if client
      name = client.name rescue 'N/A'
      ip   = client.ip   rescue 'N/A'
      parts << "Jogador: #{name} | IP: #{ip}"
    end
    if exception
      parts << "Exceção: #{exception.message}"
      bt = exception.backtrace rescue nil
      parts << bt.first(8).join("\n") if bt
    end
    log_level('ERROR', parts.join("\n"), nil, immediate: true)
  end

  def fatal(text, exception = nil)
    msg = if exception
      bt = exception.backtrace rescue nil
      bt_text = bt ? bt.first(5).join("\n") : 'backtrace indisponível'
      "#{text}\nExceção: #{exception.message}\n#{bt_text}"
    else
      text
    end
    log_level('FATAL', msg, nil, immediate: true)
  end

  def save_all
    @text.each_key { |day| flush_file(day) }
    @text.clear
  end

  # ============================================================
  # MÉTODOS PRIVADOS
  # ============================================================
  private

  def log_level(level, text, client = nil, immediate: false)
    context   = client_context(client)
    timestamp = Time.now.strftime('%X')
    day       = day_key(level)
    entry     = "#{timestamp}: #{context}#{text}\n"
    @text[day] = "#{@text[day]}#{entry}"
    color = LEVEL_COLORS[level] || :white
    puts("[#{level}] #{context}#{text}".colorize(color))
    flush_file(day) if immediate
  end

  def client_context(client)
    return '' unless client
    name = client.name rescue 'N/A'
    ip   = client.ip   rescue 'N/A'
    "[#{name} | #{ip}] "
  end

  def resolve_group_type(type)
    return type unless type.is_a?(Integer)
    type == Enums::Group::ADMIN ? 'Admin' : 'Monitor'
  end

  def day_key(prefix)
    Time.now.strftime("#{prefix}-%d-%b-%Y")
  end

  def flush_file(day)
    return unless @text[day]
    begin
      File.open("Logs/#{day}.txt", 'a+') { |f| f.write(@text[day]) }
      @text.delete(day)
    rescue => e
      puts("Falha ao salvar log '#{day}': #{e.message}".colorize(:light_red))
    end
  end

end