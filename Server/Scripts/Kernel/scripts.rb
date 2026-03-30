#==============================================================================
# ** Scripts
#------------------------------------------------------------------------------
#  Executa os scripts Configs, Quests, Kernel e Enums do cliente.
#------------------------------------------------------------------------------
#  Autor: Valentine
#  Revisão: Caio Juan De Lima Silva — Março 2026
#==============================================================================

# Nomes dos scripts que devem ser carregados primeiro, na ordem definida.
# Altere esta constante para adicionar ou reordenar scripts de inicialização.
BOOTSTRAP_SCRIPTS = ['Configs', 'Quests'].freeze

# Carrega o arquivo de dados contendo todos os scripts do projeto
scripts = load_data('Scripts.rvdata2')

#------------------------------------------------------------------------------
# Bloco 1: Carregamento dos scripts de bootstrap (Configs e Quests)
# Utiliza busca dinâmica pelo nome para evitar dependência de índices fixos.
#------------------------------------------------------------------------------
BOOTSTRAP_SCRIPTS.each do |nome|
  # Busca o script pelo nome em vez de usar índice hardcoded
  entry = scripts.find { |s| s[1] == nome }

  if entry.nil?
    # Aviso no boot caso o script esperado não seja encontrado
    puts "[Boot] AVISO: Script '#{nome}' não encontrado em Scripts.rvdata2."
    next
  end

  begin
    eval(Zlib::Inflate.inflate(entry[2]))
    puts "[Boot] Script carregado: #{nome}"
  rescue => e
    # Registra o erro sem derrubar o processo de inicialização
    puts "[Boot] ERRO ao carregar '#{nome}': #{e.message}"
  end
end

#------------------------------------------------------------------------------
# Bloco 2: Carregamento dos scripts Kernel e Enums
# Itera sobre todos os scripts e executa os que correspondem aos filtros.
#------------------------------------------------------------------------------
scripts.each do |script|
  nome = script[1]

  # Filtra apenas scripts cujo nome contenha 'Kernel' ou 'Enums'
  next unless nome.include?('Kernel') || nome.include?('Enums')

  begin
    eval(Zlib::Inflate.inflate(script[2]))
    puts "[Boot] Script carregado: #{nome}"
  rescue => e
    # Registra o erro sem derrubar o processo de inicialização
    puts "[Boot] ERRO ao carregar '#{nome}': #{e.message}"
  end
end