class LoggerService

  LOG_DIR = "Logs"

  def self.log_file
    File.join(LOG_DIR, "log_#{Time.now.strftime('%Y-%m-%d')}.txt")
  end

  def self.write(level, message, context = {}, data = {})
    timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    # 🔹 Contexto do jogador (padronizado)
    context_info = format_context(context)

    # 🔹 Dados extras
    formatted_data = data.any? ? data.map { |k, v| "#{k}=#{v}" }.join(" ") : ""

    log_message = "[#{timestamp}] [#{level}] #{context_info}#{message} #{formatted_data}\n"

    puts log_message

    begin
      Dir.mkdir(LOG_DIR) unless Dir.exist?(LOG_DIR)

      File.open(log_file, "a") do |file|
        file.write(log_message)
      end
    rescue => e
      puts "[LOGGER ERROR] #{e.message}"
    end
  end

  def self.info(message, context = {}, data = {})
    write("INFO", message, context, data)
  end

  def self.warn(message, context = {}, data = {})
    write("WARN", message, context, data)
  end

  def self.error(message, context = {}, data = {})
    write("ERROR", message, context, data)
  end

  # =========================
  # FORMATA CONTEXTO
  # =========================
  def self.format_context(context)
    return "" if context.nil? || context.empty?

    parts = []

    parts << "account=#{context[:account]}" if context[:account]
    parts << "player=#{context[:player]}" if context[:player]
    parts << "id=#{context[:id]}" if context[:id]
    parts << "ip=#{context[:ip]}" if context[:ip]

    parts.any? ? "[#{parts.join(' ')}] " : ""
  end

end