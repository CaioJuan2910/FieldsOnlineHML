# Server/Scripts/Kernel/scripts.rb
#==============================================================================
# ** Scripts
#------------------------------------------------------------------------------
# Executa os scripts Configs, Quests, Kernel e Enums do cliente.
#------------------------------------------------------------------------------
# Autor Original : Valentine
# Modificado por : Caio Juan De Lima Silva — Fields Online
# Data           : Abril 2026
# Versão         : 1.1
#------------------------------------------------------------------------------
# MODIFICAÇÕES APLICADAS (Fields Online):
#
#   [FIX #01] Substituição de índices hardcoded (scripts[1] e scripts[2]) por
#             busca dinâmica pelo NOME do script dentro do array Scripts.rvdata2.
#
#             PROBLEMA ORIGINAL:
#               eval(Zlib::Inflate.inflate(scripts[1][2]))  # índice fixo = frágil
#               eval(Zlib::Inflate.inflate(scripts[2][2]))  # índice fixo = frágil
#
#             Se a ordem dos scripts fosse alterada no RPG Maker Editor,
#             o servidor carregaria silenciosamente scripts errados no boot,
#             causando erros difíceis de rastrear.
#
#   [FIX #02] Adição de begin/rescue ao redor de cada eval, isolando falhas
#             de carregamento. Um script com erro não derruba mais o boot inteiro.
#
#   [FIX #03] Log de carregamento: cada script carregado com sucesso imprime
#             seu nome no console. Erros exibem o nome do script + mensagem.
#
# SCRIPTS CARREGADOS (por nome, em ordem de aparição no array):
#   - 'Configs'  → Configurações gerais do cliente/servidor
#   - 'Quests'   → Definição de missões
#   - Contém 'Kernel' → Scripts de kernel do sistema
#   - Contém 'Enums'  → Enumerações e constantes indexadas
#==============================================================================

# Carrega o arquivo binário comprimido com todos os scripts do RPG Maker VX Ace
scripts = load_data('Scripts.rvdata2')

# Lista de nomes exatos a carregar ANTES dos demais (ordem importa)
# scripts[n][1] = nome do script | scripts[n][2] = código comprimido (Zlib)
PRIORITY_SCRIPTS = ['Configs', 'Quests'].freeze

# ---------------------------------------------------------------------------
# Passo 1: Carrega scripts prioritários em ordem declarada
#           (Configs e Quests precisam estar disponíveis antes de Kernel/Enums)
# ---------------------------------------------------------------------------
PRIORITY_SCRIPTS.each do |target_name|
  # Busca dinâmica pelo nome — independe da posição no array
  script = scripts.find { |s| s[1] == target_name }

  if script
    begin
      eval(Zlib::Inflate.inflate(script[2]))
      puts "[Scripts] Carregado: '#{target_name}'"
    rescue => e
      # Isola a falha: exibe o erro mas não derruba o boot inteiro
      puts "[Scripts] ERRO ao carregar '#{target_name}': #{e.message}"
    end
  else
    # Avisa caso o script não seja encontrado (nome errado no editor, por exemplo)
    puts "[Scripts] AVISO: Script '#{target_name}' não encontrado em Scripts.rvdata2"
  end
end

# ---------------------------------------------------------------------------
# Passo 2: Carrega scripts de Kernel e Enums
#           (itera o array completo e filtra por substring no nome)
# ---------------------------------------------------------------------------
scripts.each do |script|
  name = script[1]

  # Ignora scripts já carregados na etapa prioritária
  next if PRIORITY_SCRIPTS.include?(name)

  # Carrega apenas scripts cujo nome contém 'Kernel' ou 'Enums'
  next unless name.include?('Kernel') || name.include?('Enums')

  begin
    eval(Zlib::Inflate.inflate(script[2]))
    puts "[Scripts] Carregado: '#{name}'"
  rescue => e
    # Isola a falha por script — os demais continuam sendo carregados normalmente
    puts "[Scripts] ERRO ao carregar '#{name}': #{e.message}"
  end
end

puts "[Scripts] Boot concluído — todos os scripts foram processados."