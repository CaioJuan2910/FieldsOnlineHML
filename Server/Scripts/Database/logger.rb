#==============================================================================
# ** Logger
#------------------------------------------------------------------------------
#  Esta classe grava informações importantes do servidor, como erros e comandos
# executados por administradores e monitores.
#------------------------------------------------------------------------------
#  Autor: Valentine
#  Revisado: correções de robustez, segurança e legibilidade
#==============================================================================

class Logger

  def initialize
    # Usa Hash.new("") para evitar nil na primeira concatenação de cada chave.
    # Sem isso, @text[day] += "..." lançaria NoMethodError em chaves inexistentes.
    @text = Hash.new("")
  end

  # Registra uma entrada de log na memória e exibe no console colorido.
  #
  # Parâmetros:
  #   [type]  : Integer (Enums::Group) ou String com o nome do grupo
  #   [color] : símbolo de cor para colorize (ex: :red, :yellow)
  #   [text]  : mensagem a ser registrada
  def add(type, color, text)
    # Converte Integer para String legível ("Admin" / "Monitor") se necessário
    type = resolve_type(type)

    # Monta a chave do dia no formato "Admin-30-Mar-2026" (ou "Monitor-...")
    # Essa chave também será usada como nome do arquivo de log
    day = Time.now.strftime("#{type}-%d-%b-%Y")

    # CORREÇÃO: timestamp formatado em variável separada para evitar que
    # caracteres especiais no conteúdo de `text` (ex: %, \n) sejam
    # interpretados pelo strftime como diretivas de formato
    timestamp = Time.now.strftime("%X")

    # Acumula a entrada no buffer em memória para persistência posterior
    @text[day] += "#{timestamp}: #{text}\n"

    # Exibe a mensagem colorida no console do servidor para monitoramento em tempo real
    puts(text.colorize(color))
  end

  # Persiste todos os logs acumulados em memória nos arquivos correspondentes
  # e limpa o buffer interno após a gravação.
  #
  # Deve ser chamado periodicamente (ex: a cada ciclo de save do servidor)
  # para evitar acúmulo excessivo de dados na memória.
  def save_all
    # CORREÇÃO: garante que o diretório Logs/ existe antes de tentar escrever.
    # Sem essa verificação, File.open lançaria Errno::ENOENT se a pasta não existir.
    Dir.mkdir("Logs") unless Dir.exist?("Logs")

    @text.each do |day, text|
      begin
        # CORREÇÃO: block form do File.open garante fechamento automático do
        # arquivo mesmo que uma exceção seja levantada durante a escrita.
        # Modo "a+" abre para append e cria o arquivo caso não exista.
        File.open("Logs/#{day}.txt", "a+") do |file|
          file.write(text)
        end
      rescue => e
        # Falha isolada: um log com problema não interrompe os demais
        puts("[Logger] Falha ao salvar log '#{day}': #{e.message}")
      end
    end

    # Limpa o buffer após persistência para liberar memória
    @text.clear
  end

  private

  # Converte um Integer de grupo (Enums::Group) para String legível.
  #
  # CORREÇÃO: lógica extraída do ternário aninhado original para método
  # dedicado — melhora legibilidade, facilita testes unitários e centraliza
  # a regra de mapeamento de grupos.
  #
  # Retorna o próprio valor se já for String (passagem direta de nome de grupo).
  def resolve_type(type)
    return type unless type.is_a?(Integer)

    # Mapeia os valores do enum para strings descritivas usadas nos nomes de arquivo
    type == Enums::Group::ADMIN ? "Admin" : "Monitor"
  end

end