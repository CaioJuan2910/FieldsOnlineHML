#==============================================================================
# ■ [VS] Logger — Sistema de Logs do Fields Online
#------------------------------------------------------------------------------
#  Registra todos os eventos do servidor em arquivos organizados por data
#  e categoria. Substitui o Logger padrão do VXA-OS com retrocompatibilidade
#  total, mantendo o método add(category, color, message) intacto.
#
#  Estrutura de diretórios gerada automaticamente:
#
#    Server/
#    └── Logs/
#        └── YYYY-MM-DD/
#            ├── server.log    → Inicialização e eventos gerais
#            ├── errors.log    → Erros e exceções do sistema
#            ├── accounts.log  → Login, logout, contas e personagens
#            ├── chat.log      → Todas as mensagens de chat
#            ├── trade.log     → Trocas entre jogadores
#            ├── drops.log     → Drops e coleta de itens
#            ├── combat.log    → Mortes de mobs (PvE)
#            ├── pvp.log       → Combate entre jogadores (PvP)
#            ├── economy.log   → Banco e operações de loja
#            ├── guild.log     → Guildas (criação, entrada, saída)
#            ├── events.log    → Eventos de mapa, NPCs e teleportes
#            └── admin.log     → Comandos administrativos
#
#  Formato de cada entrada de log:
#    [YYYY-MM-DD HH:MM:SS] [CATEGORIA] IP=x.x.x.x | Conta=xxx | Personagem=xxx | Mensagem
#
#  Instalação:
#    1. Salve este arquivo em: Server/Scripts/Logger/vs_logger.rb
#    2. No arquivo main.rb do servidor, adicione no topo (antes dos outros requires):
#         require_relative 'Scripts/Logger/vs_logger'
#    3. Em network.rb, altere a linha:
#         @log = Logger.new
#       Para:
#         @log = VS_Logger.new
#    4. Aplique os hooks nos arquivos indicados na documentação.
#
#  Autor: Fields Online Dev Team
#  Versão: 1.0.0
#  Data: 2026
#==============================================================================

require 'fileutils'

module VS_Logger_Config

  #----------------------------------------------------------------------------
  # ► CONFIGURAÇÕES GERAIS
  #----------------------------------------------------------------------------

  # Diretório raiz onde os logs serão salvos (relativo à pasta Server/)
  LOG_DIR = 'Logs'

  # Quantos dias manter os arquivos de log. 0 = nunca deletar automaticamente.
  LOG_KEEP_DAYS = 30

  # Exibir entradas de log também no console do servidor?
  CONSOLE_OUTPUT = true

  #----------------------------------------------------------------------------
  # ► ATIVAR / DESATIVAR CATEGORIAS INDIVIDUALMENTE
  #----------------------------------------------------------------------------

  LOG_ENABLED = {
    server:   true,   # Eventos gerais (start/stop do servidor)
    error:    true,   # Erros e exceções do sistema
    chat:     true,   # Todas as mensagens de chat (map, global, party, guild, private)
    trade:    true,   # Trocas finalizadas entre jogadores
    drops:    true,   # Drops de mobs e coleta de itens
    combat:   true,   # Mortes de mobs (kills PvE)
    accounts: true,   # Login, logout, criação e remoção de contas/personagens
    economy:  true,   # Operações de banco e lojas
    guild:    true,   # Criação, entrada e saída de guildas
    events:   true,   # Interações com eventos/NPCs e teleportes
    admin:    true,   # Comandos administrativos (kick, ban, give, etc.)
    pvp:      true,   # Combate jogador vs. jogador
  }

  #----------------------------------------------------------------------------
  # ► CORES ANSI PARA EXIBIÇÃO NO CONSOLE DO SERVIDOR
  #----------------------------------------------------------------------------

  COLORS = {
    red:     "\e[31m",
    green:   "\e[32m",
    yellow:  "\e[33m",
    blue:    "\e[34m",
    magenta: "\e[35m",
    cyan:    "\e[36m",
    white:   "\e[37m",
    reset:   "\e[0m",
  }

  #----------------------------------------------------------------------------
  # ► MAPEAMENTO: categoria da entrada → cor do console
  #   (usado internamente para colorir as mensagens exibidas)
  #----------------------------------------------------------------------------

  CATEGORY_COLOR = {
    'SERVER'       => :cyan,
    'ERROR'        => :red,
    'LOGIN'        => :green,
    'LOGIN_FAIL'   => :yellow,
    'LOGOUT'       => :cyan,
    'NEW_ACCOUNT'  => :green,
    'NEW_ACTOR'    => :green,
    'DEL_ACTOR'    => :yellow,
    'ENTER_GAME'   => :green,
    'CHAT_MAP'     => :white,
    'CHAT_GLOBAL'  => :white,
    'CHAT_PARTY'   => :white,
    'CHAT_GUILD'   => :white,
    'CHAT_PRIVATE' => :white,
    'TRADE'        => :magenta,
    'ITEM_DROP'    => :blue,
    'ITEM_PICKUP'  => :blue,
    'MOB_DROP'     => :blue,
    'MOB_KILL'     => :yellow,
    'PLAYER_DEATH' => :red,
    'PVP_KILL'     => :red,
    'SHOP_BUY'     => :magenta,
    'SHOP_SELL'    => :magenta,
    'BANK_ITEM'    => :magenta,
    'BANK_GOLD'    => :magenta,
    'GUILD_CREATE' => :cyan,
    'GUILD_JOIN'   => :cyan,
    'GUILD_LEAVE'  => :yellow,
    'GUILD_DELETE' => :yellow,
    'EVENT'        => :blue,
    'TELEPORT'     => :blue,
    'IP_BLOCKED'   => :red,
    'ADMIN_CMD'    => :yellow,
  }

end # VS_Logger_Config


#==============================================================================
# ■ VS_Logger
#==============================================================================

class VS_Logger
  include VS_Logger_Config

  def initialize
    @mutex = Mutex.new
    ensure_directory(LOG_DIR)
    cleanup_old_logs if LOG_KEEP_DAYS > 0
    log_server('=' * 60)
    log_server('Fields Online — Servidor iniciado.')
    log_server("VS_Logger v1.0.0 | Logs: #{File.expand_path(LOG_DIR)}")
    log_server('=' * 60)
  end

  #============================================================================
  # ► RETROCOMPATIBILIDADE COM O LOGGER ORIGINAL DO VXA-OS
  #   Mantém o funcionamento de toda chamada existente:
  #     @log.add('Error', :red, "mensagem")
  #     @log.add(client.group, :blue, "mensagem de admin")
  #============================================================================

  def add(category, color = :white, message)
    cat_str  = category.to_s.upcase
    entry    = build_entry(cat_str, message)
    cat_sym  = category.to_s.downcase.to_sym
    file_cat = LOG_ENABLED.key?(cat_sym) ? cat_sym : :server
    write_log(file_cat, entry)
    console_print(color, entry)
  end

  #============================================================================
  # ► LOGS DE SERVIDOR
  #============================================================================

  # Registra um evento geral do servidor (start, stop, avisos críticos).
  def log_server(message)
    return unless LOG_ENABLED[:server]
    entry = build_entry('SERVER', message)
    write_log(:server, entry)
    console_print(:cyan, entry)
  end

  #============================================================================
  # ► LOGS DE ERROS
  #============================================================================

  # Registra um erro ou exceção do sistema.
  # @param error     [Exception|String] o erro ocorrido
  # @param backtrace [Array<String>]    stack trace opcional
  # @param client    [Game_Client]      cliente relacionado, se houver
  def log_error(error, backtrace: nil, client: nil)
    return unless LOG_ENABLED[:error]
    ctx   = client_context(client)
    msg   = "#{ctx}ERRO: #{error}"
    msg  += "\n    >> #{backtrace.first(3).join("\n    >> ")}" if backtrace
    entry = build_entry('ERROR', msg)
    write_log(:error, entry)
    console_print(:red, entry)
  end

  #============================================================================
  # ► LOGS DE CONTAS E PERSONAGENS
  #============================================================================

  # Login realizado com sucesso.
  def log_login(client)
    return unless LOG_ENABLED[:accounts]
    entry = build_entry('LOGIN', "#{client_context(client)}Login realizado com sucesso.")
    write_log(:accounts, entry)
    console_print(:green, entry)
  end

  # Tentativa de login que falhou.
  # @param reason [String] motivo da falha (senha inválida, IP bloqueado, etc.)
  # @param user   [String] nome de usuário digitado (antes do client ter .user definido)
  def log_login_failed(client, reason, user: nil)
    return unless LOG_ENABLED[:accounts]
    entry = build_entry('LOGIN_FAIL',
      "#{client_context(client, user: user)}Falha no login. Motivo: #{reason}")
    write_log(:accounts, entry)
    console_print(:yellow, entry)
  end

  # Logout do servidor (voluntário ou por inatividade).
  def log_logout(client)
    return unless LOG_ENABLED[:accounts]
    entry = build_entry('LOGOUT', "#{client_context(client)}Desconectou do servidor.")
    write_log(:accounts, entry)
    console_print(:cyan, entry)
  end

  # Nova conta criada com sucesso.
  # @param user [String] nome de usuário cadastrado
  def log_create_account(client, user)
    return unless LOG_ENABLED[:accounts]
    entry = build_entry('NEW_ACCOUNT',
      "#{client_context(client, user: user)}Conta criada com sucesso.")
    write_log(:accounts, entry)
    console_print(:green, entry)
  end

  # Novo personagem criado com sucesso.
  # @param name       [String] nome do personagem
  # @param class_name [String] nome da classe escolhida
  def log_create_actor(client, name, class_name)
    return unless LOG_ENABLED[:accounts]
    entry = build_entry('NEW_ACTOR',
      "#{client_context(client)}Personagem criado: '#{name}' | Classe: #{class_name}")
    write_log(:accounts, entry)
    console_print(:green, entry)
  end

  # Personagem deletado.
  # @param name [String] nome do personagem removido
  def log_remove_actor(client, name)
    return unless LOG_ENABLED[:accounts]
    entry = build_entry('DEL_ACTOR',
      "#{client_context(client)}Personagem deletado: '#{name}'")
    write_log(:accounts, entry)
    console_print(:yellow, entry)
  end

  # Jogador entrou no jogo (selecionou o personagem e carregou o mapa).
  def log_enter_game(client)
    return unless LOG_ENABLED[:accounts]
    entry = build_entry('ENTER_GAME',
      "#{client_context(client)}" \
      "Entrou no jogo. Mapa: #{client.map_id} | Pos: (#{client.x}, #{client.y})")
    write_log(:accounts, entry)
    console_print(:green, entry)
  end

  #============================================================================
  # ► LOGS DE CHAT
  #============================================================================

  # Registra qualquer mensagem de chat enviada.
  # @param type_name [String] tipo: MAP, GLOBAL, PARTY, GUILD, PRIVATE
  def log_chat(client, message, type_name)
    return unless LOG_ENABLED[:chat]
    # Chat não exibe no console por padrão (muito verboso — altere se quiser)
    entry = build_entry("CHAT_#{type_name.upcase}", "#{client_context(client)}#{message}")
    write_log(:chat, entry)
  end

  #============================================================================
  # ► LOGS DE TROCA ENTRE JOGADORES
  #============================================================================

  # Registra uma troca finalizada com sucesso entre dois jogadores.
  # Deve ser chamado ANTES de os itens serem trocados (enquanto trade_items ainda existem).
  # @param client1 [Game_Client] jogador que iniciou a troca
  # @param client2 [Game_Client] jogador que aceitou a troca
  def log_trade_complete(client1, client2)
    return unless LOG_ENABLED[:trade]
    items1 = format_trade_items(
      client1.trade_items, client1.trade_weapons, client1.trade_armors, client1.trade_gold
    )
    items2 = format_trade_items(
      client2.trade_items, client2.trade_weapons, client2.trade_armors, client2.trade_gold
    )
    sep = '-' * 56
    write_log(:trade, build_entry('TRADE', sep))
    write_log(:trade, build_entry('TRADE',
      "#{client_context(client1)}<=> #{client2.name}"))
    write_log(:trade, build_entry('TRADE',
      "  #{client1.name} ofereceu : [#{items1}]"))
    write_log(:trade, build_entry('TRADE',
      "  #{client2.name} ofereceu : [#{items2}]"))
    write_log(:trade, build_entry('TRADE', sep))
    console_print(:magenta, build_entry('TRADE',
      "#{client1.name} <=> #{client2.name} | " \
      "[#{client1.name}: #{items1}] <=> [#{client2.name}: #{items2}]"))
  end

  #============================================================================
  # ► LOGS DE DROPS E COLETA DE ITENS
  #============================================================================

  # Jogador dropou um item manualmente no chão.
  # @param kind [Integer] 1=Item, 2=Arma, 3=Armadura
  def log_player_drop(client, item_name, kind, amount, map_id, x, y)
    return unless LOG_ENABLED[:drops]
    entry = build_entry('ITEM_DROP',
      "#{client_context(client)}Dropou #{amount}x " \
      "[#{kind_name(kind)}] '#{item_name}' | Mapa: #{map_id} | Pos: (#{x}, #{y})")
    write_log(:drops, entry)
  end

  # Jogador coletou um item do chão.
  # @param original_owner [String] nome do dono original do drop (se houver)
  def log_player_pickup(client, item_name, kind, amount, map_id, x, y,
                        original_owner: nil)
    return unless LOG_ENABLED[:drops]
    owner_str = original_owner && !original_owner.empty? ?
      " | Dono original: #{original_owner}" : ''
    entry = build_entry('ITEM_PICKUP',
      "#{client_context(client)}Coletou #{amount}x " \
      "[#{kind_name(kind)}] '#{item_name}' | Mapa: #{map_id} | Pos: (#{x}, #{y})#{owner_str}")
    write_log(:drops, entry)
  end

  # Mob dropou um item ao morrer.
  # @param killer_name [String] nome do jogador que matou o mob
  # @param mob_name    [String] nome do mob
  # @param kind        [Integer] 1=Item, 2=Arma, 3=Armadura
  def log_mob_drop(killer_name, mob_name, item_name, kind, amount, map_id, x, y)
    return unless LOG_ENABLED[:drops]
    entry = build_entry('MOB_DROP',
      "Mob '#{mob_name}' dropou #{amount}x [#{kind_name(kind)}] '#{item_name}' | " \
      "Assassino: #{killer_name} | Mapa: #{map_id} | Pos: (#{x}, #{y})")
    write_log(:drops, entry)
  end

  #============================================================================
  # ► LOGS DE COMBATE (PvE)
  #============================================================================

  # Jogador matou um mob.
  # @param exp  [Integer] experiência ganha
  # @param gold [Integer] ouro ganho
  def log_mob_kill(client, mob_name, mob_id, exp, gold, map_id, x, y)
    return unless LOG_ENABLED[:combat]
    entry = build_entry('MOB_KILL',
      "#{client_context(client)}Matou '#{mob_name}' (ID: #{mob_id}) | " \
      "EXP: +#{exp} | Ouro: +#{gold}g | Mapa: #{map_id} | Pos: (#{x}, #{y})")
    write_log(:combat, entry)
  end

  # Jogador morreu para um mob.
  # @param mob_name [String] nome do mob que causou a morte (pode ser 'Desconhecido' se N/A)
  def log_player_death_mob(client, mob_name, map_id, x, y)
    return unless LOG_ENABLED[:combat]
    entry = build_entry('PLAYER_DEATH',
      "#{client_context(client)}Morreu para o mob '#{mob_name}' | " \
      "Mapa: #{map_id} | Pos: (#{x}, #{y})")
    write_log(:combat, entry)
    console_print(:red, entry)
  end

  #============================================================================
  # ► LOGS DE PvP
  #============================================================================

  # Jogador matou outro jogador em combate PvP.
  # @param attacker [Game_Client] o atacante
  # @param victim   [Game_Client] a vítima
  def log_pvp_kill(attacker, victim, map_id)
    return unless LOG_ENABLED[:pvp]
    entry = build_entry('PVP_KILL',
      "#{client_context(attacker)}Matou o jogador '#{victim.name}' | " \
      "Nível vítima: #{victim.level} | Mapa: #{map_id}")
    write_log(:pvp, entry)
    console_print(:red, entry)
  end

  #============================================================================
  # ► LOGS DE ECONOMIA (LOJA E BANCO)
  #============================================================================

  # Jogador comprou item em uma loja.
  # @param kind        [Integer] 1=Item, 2=Arma, 3=Armadura (kind+1 vindo do shop_goods)
  # @param price_total [Integer] valor total pago
  def log_shop_buy(client, item_name, kind, amount, price_total, map_id)
    return unless LOG_ENABLED[:economy]
    entry = build_entry('SHOP_BUY',
      "#{client_context(client)}Comprou #{amount}x [#{kind_name(kind)}] '#{item_name}' | " \
      "Total: #{price_total}g | Mapa: #{map_id}")
    write_log(:economy, entry)
  end

  # Jogador vendeu item em uma loja.
  def log_shop_sell(client, item_name, kind, amount, price_total, map_id)
    return unless LOG_ENABLED[:economy]
    entry = build_entry('SHOP_SELL',
      "#{client_context(client)}Vendeu #{amount}x [#{kind_name(kind)}] '#{item_name}' | " \
      "Total: #{price_total}g | Mapa: #{map_id}")
    write_log(:economy, entry)
  end

  # Jogador depositou ou retirou item do banco.
  # @param amount [Integer] positivo = depósito, negativo = retirada
  def log_bank_item(client, item_name, kind, amount)
    return unless LOG_ENABLED[:economy]
    action = amount > 0 ? 'Depositou' : 'Retirou'
    entry  = build_entry('BANK_ITEM',
      "#{client_context(client)}#{action} #{amount.abs}x " \
      "[#{kind_name(kind)}] '#{item_name}' no banco.")
    write_log(:economy, entry)
  end

  # Jogador depositou ou retirou ouro do banco.
  # @param amount [Integer] positivo = depósito, negativo = retirada
  def log_bank_gold(client, amount)
    return unless LOG_ENABLED[:economy]
    action = amount > 0 ? 'Depositou' : 'Retirou'
    entry  = build_entry('BANK_GOLD',
      "#{client_context(client)}#{action} #{amount.abs}g no banco.")
    write_log(:economy, entry)
  end

  #============================================================================
  # ► LOGS DE GUILDAS
  #============================================================================

  # Uma nova guilda foi criada.
  def log_guild_create(client, guild_name)
    return unless LOG_ENABLED[:guild]
    entry = build_entry('GUILD_CREATE',
      "#{client_context(client)}Criou a guilda '#{guild_name}'.")
    write_log(:guild, entry)
    console_print(:cyan, entry)
  end

  # Um jogador entrou em uma guilda.
  # @param recruiter_name [String] quem recrutou
  def log_guild_join(member_name, guild_name, recruiter_name)
    return unless LOG_ENABLED[:guild]
    entry = build_entry('GUILD_JOIN',
      "Jogador '#{member_name}' entrou na guilda '#{guild_name}' | " \
      "Recrutado por: '#{recruiter_name}'.")
    write_log(:guild, entry)
  end

  # Um jogador saiu ou foi removido de uma guilda.
  # @param kicked_by [String|nil] nil = saiu voluntariamente, String = removido por alguém
  def log_guild_leave(member_name, guild_name, kicked_by: nil)
    return unless LOG_ENABLED[:guild]
    reason = kicked_by ?
      "foi removido por '#{kicked_by}'" : 'saiu voluntariamente'
    entry = build_entry('GUILD_LEAVE',
      "Jogador '#{member_name}' #{reason} da guilda '#{guild_name}'.")
    write_log(:guild, entry)
  end

  # Uma guilda foi dissolvida.
  def log_guild_delete(guild_name, leader_name)
    return unless LOG_ENABLED[:guild]
    entry = build_entry('GUILD_DELETE',
      "Guilda '#{guild_name}' dissolvida pelo líder '#{leader_name}'.")
    write_log(:guild, entry)
    console_print(:yellow, entry)
  end

  #============================================================================
  # ► LOGS DE EVENTOS DE MAPA / NPCs / TELEPORTES
  #============================================================================

  # Jogador interagiu com um evento ou NPC.
  # @param event_name [String] nome do evento (ou ID se sem nome)
  def log_event(client, event_name, map_id, x, y)
    return unless LOG_ENABLED[:events]
    entry = build_entry('EVENT',
      "#{client_context(client)}Interagiu com '#{event_name}' | " \
      "Mapa: #{map_id} | Pos: (#{x}, #{y})")
    write_log(:events, entry)
  end

  # Jogador usou um teleporte.
  # @param gold_cost [Integer] custo em ouro (0 se gratuito)
  def log_teleport(client, from_map, to_map, to_x, to_y, gold_cost: 0)
    return unless LOG_ENABLED[:events]
    cost_str = gold_cost > 0 ? " | Custo: #{gold_cost}g" : ''
    entry = build_entry('TELEPORT',
      "#{client_context(client)}Mapa #{from_map} → Mapa #{to_map} " \
      "(#{to_x}, #{to_y})#{cost_str}")
    write_log(:events, entry)
  end

  #============================================================================
  # ► LOGS DE SEGURANÇA
  #============================================================================

  # IP foi bloqueado por excesso de tentativas falhas de login.
  def log_ip_blocked(ip, attempts)
    return unless LOG_ENABLED[:accounts]
    entry = build_entry('IP_BLOCKED',
      "IP bloqueado: #{ip} | Tentativas falhas: #{attempts}")
    write_log(:accounts, entry)
    console_print(:red, entry)
  end

  #============================================================================
  # ► LOGS DE ADMINISTRAÇÃO
  #============================================================================

  # Um admin ou monitor executou um comando pelo painel de administração.
  # @param command_id  [Integer] ID do enum do comando
  # @param params_str  [String]  parâmetros formatados como string legível
  def log_admin_command(client, command_id, params_str)
    return unless LOG_ENABLED[:admin]
    entry = build_entry('ADMIN_CMD',
      "#{client_context(client)}Comando ID: #{command_id} | Params: #{params_str}")
    write_log(:admin, entry)
    console_print(:yellow, entry)
  end

  #============================================================================
  # ► MÉTODOS PRIVADOS
  #============================================================================

  private

  #----------------------------------------------------------------------------
  # Garante que um diretório existe, criando-o se necessário.
  #----------------------------------------------------------------------------
  def ensure_directory(path)
    FileUtils.mkdir_p(path) unless Dir.exist?(path)
  end

  #----------------------------------------------------------------------------
  # Retorna o caminho do diretório do dia corrente (ex: Logs/2026-04-03),
  # criando-o automaticamente na primeira chamada do dia.
  #----------------------------------------------------------------------------
  def daily_dir
    dir = "#{LOG_DIR}/#{Time.now.strftime('%Y-%m-%d')}"
    ensure_directory(dir)
    dir
  end

  #----------------------------------------------------------------------------
  # Remove diretórios de log mais antigos que LOG_KEEP_DAYS dias.
  # Executado uma vez na inicialização do servidor.
  #----------------------------------------------------------------------------
  def cleanup_old_logs
    return unless Dir.exist?(LOG_DIR)
    cutoff = Time.now - (LOG_KEEP_DAYS * 86_400)
    Dir.glob("#{LOG_DIR}/*/").each do |dir|
      begin
        dir_date = Time.strptime(File.basename(dir), '%Y-%m-%d')
        FileUtils.rm_rf(dir) if dir_date < cutoff
      rescue
        # Ignora entradas com nome inválido (não são pastas de data)
      end
    end
  end

  #----------------------------------------------------------------------------
  # Escreve uma linha no arquivo de log da categoria especificada.
  # Thread-safe via Mutex para ambientes EventMachine.
  #----------------------------------------------------------------------------
  def write_log(category, message)
    @mutex.synchronize do
      begin
        File.open("#{daily_dir}/#{category}.log", 'a:UTF-8') do |f|
          f.puts(message)
        end
      rescue => e
        puts "#{COLORS[:red]}[LOGGER ERROR] Falha ao escrever '#{category}.log': " \
             "#{e.message}#{COLORS[:reset]}"
      end
    end
  end

  #----------------------------------------------------------------------------
  # Constrói a string de entrada de log no formato padrão:
  #   [2026-04-03 21:34:58] [CATEGORIA] mensagem
  #----------------------------------------------------------------------------
  def build_entry(category, message)
    "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] [#{category}] #{message}"
  end

  #----------------------------------------------------------------------------
  # Monta o contexto do cliente como prefixo de log:
  #   IP=x.x.x.x | Conta=username | Personagem=charname |
  # Todos os campos são "N/A" se indisponíveis (ex: cliente ainda no menu).
  #----------------------------------------------------------------------------
  def client_context(client, user: nil)
    return 'IP=N/A | Conta=N/A | Personagem=N/A | ' if client.nil?
    ip   = begin; client.ip;   rescue; 'N/A'; end
    acc  = begin; client.user; rescue; nil;   end || user || 'N/A'
    char = begin
             client.in_game? ? client.name : nil
           rescue
             nil
           end || 'N/A'
    "IP=#{ip} | Conta=#{acc} | Personagem=#{char} | "
  end

  #----------------------------------------------------------------------------
  # Retorna o nome legível do tipo (kind) de item.
  #   1 = Item, 2 = Arma, 3 = Armadura
  #----------------------------------------------------------------------------
  def kind_name(kind)
    case kind
    when 1 then 'Item'
    when 2 then 'Arma'
    when 3 then 'Armadura'
    else        'Desconhecido'
    end
  end

  #----------------------------------------------------------------------------
  # Formata os itens de uma troca em string legível.
  # Ex: "Poção HP x3, Espada Longa x1, 500g"
  #----------------------------------------------------------------------------
  def format_trade_items(items, weapons, armors, gold)
    parts = []
    (items   || {}).each do |id, qty|
      parts << "#{$data_items[id]&.name   || "Item##{id}"} x#{qty}"
    end
    (weapons || {}).each do |id, qty|
      parts << "#{$data_weapons[id]&.name || "Arma##{id}"} x#{qty}"
    end
    (armors  || {}).each do |id, qty|
      parts << "#{$data_armors[id]&.name  || "Armor##{id}"} x#{qty}"
    end
    parts << "#{gold}g" if gold.to_i > 0
    parts.empty? ? 'Nada' : parts.join(', ')
  end

  #----------------------------------------------------------------------------
  # Exibe a mensagem no console do servidor com a cor ANSI especificada.
  #----------------------------------------------------------------------------
  def console_print(color, message)
    return unless CONSOLE_OUTPUT
    color_code = COLORS[color] || ''
    puts "#{color_code}#{message}#{COLORS[:reset]}"
  rescue
    puts message
  end

end # VS_Logger