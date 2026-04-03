# scripts_loader.rb
# ==============================================================================
# ** Scripts
# ------------------------------------------------------------------------------
# Executa os scripts Configs, Quests, Kernel e Enums do cliente.
# ------------------------------------------------------------------------------
# Autor Original : Valentine
# Modificado por : Caio Juan De Lima Silva — Fields Online
# Data           : Abril 2026
# Versão         : 1.2
# ------------------------------------------------------------------------------
# MODIFICAÇÕES APLICADAS (Fields Online):
#
#   [FIX #01] Substituição de índices hardcoded (scripts[1] e scripts[2]) por
#             busca dinâmica pelo NOME do script dentro do array Scripts.rvdata2.
#
#             PROBLEMA ORIGINAL:
#               eval(Zlib::Inflate.inflate(scripts[1][2]))  # índice fixo = frágil
#               eval(Zlib::Inflate.inflate(scripts[2][2]))  # índice fixo = frágil
#
#   [FIX #02] Adição de begin/rescue ao redor de cada eval, isolando falhas
#             de carregamento. Um script com erro não derruba mais o boot inteiro.
#
#   [FIX #03] Log de carregamento: cada script carregado com sucesso imprime
#             seu nome no console. Erros exibem o nome do script + mensagem.
#
#   [FIX #04 - v1.2] Corrigido bug onde 'Configs' e 'Quests' não eram encontrados.
#             CAUSA: busca usava == (match exato), mas os nomes reais no arquivo
#             contêm prefixos como '[VS] Configs', '[VS] Quests', etc.
#             SOLUÇÃO: substituído == por .include?() em ambas as etapas,
#             tornando a busca consistente e resistente a prefixos/sufixos.
#
# SCRIPTS CARREGADOS (por substring do nome, em ordem):
#   - Contém 'Configs' → Ex: '[VS] Configs' — configurações gerais
#   - Contém 'Quests'  → Ex: '[VS] Quests'  — definição de missões
#   - Contém 'Kernel'  → Ex: '[VS] Kernel', '♥ Kernel' — kernel do sistema
#   - Contém 'Enums'   → Ex: '[VS] Enums'   — enumerações e constantes
# ==============================================================================

# Carrega o arquivo binário comprimido com todos os scripts do RPG Maker VX Ace
scripts = load_data('Scripts.rvdata2')

# Substrings dos scripts prioritários — carregados ANTES de Kernel/Enums
# Usa include? para ser resistente a prefixos como '[VS]', '♥', etc.
PRIORITY_SCRIPTS = ['Configs', 'Quests'].freeze

# Controla quais scripts já foram carregados (evita duplicatas)
loaded_names = []

# ---------------------------------------------------------------------------
# Passo 1: Carrega scripts prioritários em ordem declarada
#           (Configs e Quests precisam estar disponíveis antes de Kernel/Enums)
# ---------------------------------------------------------------------------
PRIORITY_SCRIPTS.each do |target_name|
  # [FIX #04] Usa include? em vez de == para suportar nomes com prefixos/sufixos
  script = scripts.find { |s| s[1].include?(target_name) }

  if script
    begin
      eval(Zlib::Inflate.inflate(script[2]))
      loaded_names << script[1]
      puts "[Scripts] Carregado: '#{script[1]}'"
    rescue => e
      puts "[Scripts] ERRO ao carregar '#{script[1]}': #{e.message}"
    end
  else
    puts "[Scripts] AVISO: Nenhum script contendo '#{target_name}' foi encontrado em Scripts.rvdata2"
  end
end

# ---------------------------------------------------------------------------
# Passo 2: Carrega scripts de Kernel e Enums
#           (itera o array completo e filtra por substring no nome)
# ---------------------------------------------------------------------------
scripts.each do |script|
  name = script[1]

  # Ignora scripts já carregados na etapa prioritária
  next if loaded_names.include?(name)

  # Carrega apenas scripts cujo nome contém 'Kernel' ou 'Enums'
  next unless name.include?('Kernel') || name.include?('Enums')

  begin
    eval(Zlib::Inflate.inflate(script[2]))
    loaded_names << name
    puts "[Scripts] Carregado: '#{name}'"
  rescue => e
    puts "[Scripts] ERRO ao carregar '#{name}': #{e.message}"
  end
end

puts "[Scripts] Boot concluído — #{loaded_names.size} script(s) processado(s): #{loaded_names.join(', ')}"