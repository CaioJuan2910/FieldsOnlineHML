# 🔍 Diagnóstico Técnico — Fields Online HML

> **Projeto:** Fields Online HML
> **Plataforma:** VXA-OS / RPG Maker VX Ace
> **Fase:** 1 — Análise e Documentação
> **Data:** Março 2026
> **Responsável:** Caio Juan De Lima Silva

---

## 📑 Índice

**Módulo Kernel**
1. [enums.rb](#1-enumsrb)
2. [structs.rb](#2-structsrb)
3. [scripts.rb](#3-scriptsrb)
4. [Resumo — Kernel](#4-resumo-do-diagnóstico--kernel)

**Módulo Database**

5. [database.rb](#5-databaserb)
6. [game_data.rb](#6-game_datarb)
7. [logger.rb](#7-loggerrb)
8. [Resumo — Database](#8-resumo-do-diagnóstico--database)

**Módulo Network**

9. [network.rb](#9-networkrb)
10. [handle_data.rb](#10-handle_datarb)
11. [send_data.rb](#11-send_datarb)
12. [game_commands.rb](#12-game_commandsrb)
13. [Resumo — Network](#13-resumo-do-diagnóstico--network)
14. [Prioridades Globais](#14-prioridades-globais)
15. [Próximos Passos](#15-próximos-passos)

---

# 🗂️ Módulo: Server/Kernel

> **Arquivos analisados:** `enums.rb` · `structs.rb` · `scripts.rb`

---

## 📄 1. `enums.rb`

### 1.1 Visão Geral
Este arquivo define o módulo `Enums`, responsável por centralizar todas as enumerações do servidor. Utiliza o helper `enum` (definido no core do VXA-OS) para converter arrays de strings em constantes indexadas automaticamente.

### 1.2 Enumerações Mapeadas

| Enum | Constantes | Qtd | Observação |
|------|-----------|:---:|-----------|
| `Enums::Equip` | `WEAPON, SHIELD, HELMET, ARMOR, ACESSORY, AMULET, COVER, GLOVE, BOOT` | 9 | ⚠️ Typo em `ACESSORY` |
| `Enums::Param` | `MAXHP, MAXMP, ATK, DEF, MAT, MDF, AGI, LUK` | 8 | ✅ Espelha `param_id` 0–7 do VXAce |
| `Enums::Item` | `SCOPE_ENEMY (0), SCOPE_ALL_ALLIES (8), SCOPE_ALLIES_KNOCKED_OUT (10), SCOPE_USER (11)` | 4 | ⚠️ Escopos incompletos |
| `Enums::Move` | `FIXED, RANDOM, TOWARD_PLAYER, CUSTOM` | 4 | ✅ Completo e funcional |

### 1.3 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🟡 Média | Renomear `ACESSORY` → `ACCESSORY` e atualizar **todas** as referências |
| 2 | 🟢 Baixa | Adicionar comentários de índice em cada `enum` para facilitar debug |
| 3 | 🟢 Baixa | Considerar ampliar `Enums::Item` com os demais escopos do VXAce |

---

## 📄 2. `structs.rb`

### 2.1 Visão Geral
Define todas as estruturas de dados (`Struct`) utilizadas pelo servidor. É o **esquema de dados central** do projeto.

### 2.2 Estruturas Mapeadas

| Struct | Campos | Qtd | Finalidade |
|--------|--------|:---:|-----------|
| `Hotbar` | `type, item_id` | 2 | Slot da hotbar do jogador |
| `Target` | `type, id` | 2 | Alvo atual |
| `Region` | `x, y` | 2 | Coordenada no mapa |
| `IP_Blocked` | `attempts, time` | 2 | Controle de bloqueio por IP |
| `Drop` | `item_id, kind, amount, name, party_id, x, y, despawn_time, pick_up_time` | 9 | Item dropado no chão |
| `Reward` | `item_id, item_kind, item_amount, exp, gold` | 5 | Recompensa de quest/batalha |
| `Interpreter` | `list, event_id, index, time` | 4 | Estado do interpretador de eventos |
| `Guild` | `id_db, leader, flag, members, notice` | 5 | Dados de guilda |
| `Account` | `id_db, pass, group, vip_time, actors, friends` | 6 | Dados de conta |
| `Actor` | *(32 campos)* | 32 | Dados completos do personagem |

### 2.3 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🔴 Alta | Auditar `Account.pass` — garantir que nunca é salvo em texto puro |
| 2 | 🟡 Média | Adicionar `owner_id` em `Drop` para proteção individual de loot |
| 3 | 🟢 Baixa | Planejar expansão da `Guild` com campos de progressão |

---

## 📄 3. `scripts.rb`

### 3.1 Visão Geral
Script de bootstrap do servidor. Carrega e executa seletivamente os scripts do client a partir do `Scripts.rvdata2`.

### 3.2 Problemas Identificados

```ruby
eval(Zlib::Inflate.inflate(scripts[1][2]))  # ← índice fixo — frágil
eval(Zlib::Inflate.inflate(scripts[2][2]))  # ← índice fixo — frágil
```

- **Índices hardcoded**: se a ordem dos scripts mudar no RPG Maker Editor, o servidor carrega scripts errados silenciosamente.
- **Sem tratamento de erro**: um `eval` com falha derruba o servidor inteiro durante o boot.

### 3.3 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🔴 Alta | Substituir índices fixos por busca dinâmica por nome do script |
| 2 | 🟡 Média | Adicionar `begin/rescue` ao redor dos `eval` para isolar falhas |
| 3 | 🟢 Baixa | Adicionar log de carregamento dos scripts no boot |

---

## 📊 4. Resumo do Diagnóstico — Kernel

| Arquivo | Status | Bugs | Melhorias |
|---------|:------:|:----:|:---------:|
| `enums.rb` | ✅ Funcional | 1 typo | 3 |
| `structs.rb` | ✅ Funcional | 1 segurança | 3 |
| `scripts.rb` | ⚠️ Risco | 1 crítico | 3 |

---

# 🗂️ Módulo: Server/Database

> **Arquivos analisados:** `database.rb` · `game_data.rb` · `logger.rb`

---

## 📄 5. `database.rb`

### 5.1 Visão Geral

Módulo `Database` com **463 linhas**, responsável por toda a **camada de persistência** do servidor. Utiliza a gem **Sequel** como ORM/query builder sobre SQLite (dev) ou PostgreSQL (produção).

### 5.2 Mapeamento de Funções

| Função | Tabelas | Finalidade |
|--------|---------|-----------|
| `sql_client` | — | Factory de conexão |
| `create_account` | `accounts`, `banks` | Cria conta + bank |
| `load_account` | `accounts`, `actors`, `account_friends` | Carrega conta completa |
| `save_account` | `accounts`, `account_friends` | Salva VIP e amigos |
| `create_player` | `actors` + 5 tabelas `actor_*` | Cria personagem completo |
| `load_player` | `actors` + todas as tabelas `actor_*` | Carrega personagem completo |
| `save_player` | `actors` + todas as tabelas `actor_*` + bank | **Operação mais pesada** |
| `save_items` | `actor_*/bank_*` | Diff inteligente insert/update/delete |
| `remove_player` | `actors` + 10 tabelas | Deleta personagem completo |
| `load_bank` / `save_bank` | `banks`, `bank_*` | Banco do jogador |
| `load_guilds` / `save_guild` | `guilds`, `actors` | Gestão de guildas |
| `load_banlist` / `save_banlist` | `ban_list` | Lista de banimentos |
| `change_whos_online` | `actors` | Status online |

### 5.3 Problemas Identificados

#### 🔴 Problema 1: Sem Pool de Conexões

```ruby
# Cada operação abre e fecha uma conexão TCP
def self.create_account(user, pass, email)
  s_client = sql_client    # ← Nova conexão
  s_client[:accounts].insert(...)
  s_client.disconnect      # ← Fecha imediatamente
end
```

Em produção com PostgreSQL e múltiplos jogadores, esse padrão causa overhead massivo de handshake TCP por operação.

**Solução:**
```ruby
DB = Sequel.connect("postgres://...", max_connections: 10)
def self.create_account(user, pass, email)
  DB[:accounts].insert(...)
end
```

#### 🔴 Problema 2: `save_player` sem Transação

Com 10+ operações sequenciais sem `transaction`, um crash parcial deixa o personagem em estado inconsistente (itens salvos mas stats não, por exemplo).

**Solução:**
```ruby
def self.save_player(client)
  DB.transaction do
    DB[:actors].where(id: client.id_db).update(...)
    save_items(client, client.items, DB, 'item')
    # ... demais operações
  end
end
```

### 5.4 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🔴 Alta | **Connection pool** persistente com Sequel |
| 2 | 🔴 Alta | **Transação** em `save_player` para atomicidade |
| 3 | 🟡 Média | **Renomear** `actors.int` → `mat` e `actors.res` → `mdf` (conflito SQL) |
| 4 | 🟡 Média | Documentar `load_some_player_data` e o `ilike` desativado |
| 5 | 🟢 Baixa | Comentários explicativos em `save_banlist` (lógica bidirecional densa) |
| 6 | 🟢 Baixa | Envolver `remove_player` em transação |

---

## 📄 6. `game_data.rb`

### 6.1 Visão Geral

Módulo `Game_Data` com **297 linhas**. Carrega dados estáticos do RPG Maker (`.rvdata2`) e dados dinâmicos do servidor (motd, ban list, switches, guildas).

### 6.2 Boas Práticas Identificadas

- **Carregamento seletivo**: carrega apenas os campos necessários de cada `.rvdata2`, reduzindo uso de memória (ex: `load_animations` carrega só `frame_max`, `load_tilesets` carrega só `flags`)
- **Sistema de Notas Customizadas**: usa `Note.read_*` para ler propriedades adicionais das notas do RPG Maker Editor (`Sight=5`, `VIP=true`, `Soulbound=true`)

### 6.3 Problemas Identificados

#### 🔴 Problema: `save_all_players_online` sem Isolamento

```ruby
# Antes — erro em um jogador interrompe todo o loop
def save_all_players_online
  @clients.each { |client| Database.save_player(client) if client&.in_game? }
end

# Depois — erro isolado por jogador
def save_all_players_online
  @clients.each do |client|
    next unless client&.in_game?
    begin
      Database.save_player(client)
    rescue => e
      @log.add('Sistema', :red, "Erro ao salvar #{client.name}: #{e.message}")
    end
  end
end
```

#### 🟡 `load_guilds` silencia o erro real

```ruby
rescue  # ← sem "=> e" — mensagem de erro perdida
  puts('Falha ao carregar guildas!')
end
```

### 6.4 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🔴 Alta | `save_all_players_online` com `begin/rescue` por jogador |
| 2 | 🟡 Média | `load_guilds` — capturar erro real (`rescue => e`) |
| 3 | 🟡 Média | Filtros `'notupdate'`/`'notglobal'` como constante nomeada |
| 4 | 🟡 Média | `Note.read_*` — validação de range/tipo nos campos críticos |
| 5 | 🟢 Baixa | Medir e logar tempo de carregamento por recurso no boot |

---

## 📄 7. `logger.rb`

### 7.1 Visão Geral

Classe `Logger` com **32 linhas**. Acumula logs em memória (`@text` hash) e salva em `Logs/[Tipo]-[DD]-[MMM]-[YYYY].txt` em modo append.

### 7.2 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🟡 Média | Flush imediato em erros críticos — crash antes do `save_all` = logs perdidos |
| 2 | 🟡 Média | Documentar dependência implícita de `Enums::Group` |
| 3 | 🟢 Baixa | Suporte a níveis de severidade (`INFO`, `WARN`, `ERROR`) |
| 4 | 🟢 Baixa | Política de rotação de logs (ex: manter últimos 30 dias) |

---

## 📊 8. Resumo do Diagnóstico — Database

| Arquivo | Linhas | Status | Críticos | Melhorias |
|---------|:------:|:------:|:--------:|:---------:|
| `database.rb` | 463 | ⚠️ Funcional com Riscos | 2 | 6 |
| `game_data.rb` | 297 | ⚠️ Funcional com Riscos | 1 | 5 |
| `logger.rb` | 32 | ✅ Funcional | 0 | 4 |

---

# 🗂️ Módulo: Server/Network

> **Arquivos analisados:** `network.rb` · `handle_data.rb` · `send_data.rb` · `game_commands.rb`

---

## 📄 9. `network.rb`

### 9.1 Visão Geral

Classe principal `Network` com **~70 linhas**. É o **núcleo do servidor** — inclui todos os módulos (`Handle_Data`, `Send_Data`, `Game_General`, `Game_Commands`, `Game_Data`, `Game_Guild`) e gerencia o estado global: clientes, partys, mapas, guildas, switches e ban list.

### 9.2 Estrutura de Dados

```ruby
@clients = []          # Array esparso — índice == client.id
@parties = []          # Array esparso — índice == party.id
@maps = {}             # Hash — chave == map_id
@guilds = {}           # Hash — chave == guild_name
@blocked_ips = {}      # Hash — chave == ip string
@ban_list = {}         # Hash — chave == account_id_db ou ip
@switches = Game_GlobalSwitches.new
```

### 9.3 Gerenciamento de IDs

```ruby
def find_empty_client_id
  return @client_ids_available.shift unless @client_ids_available.empty?
  index = @client_high_id
  @client_high_id += 1
  index
end
```

O servidor recicla IDs desconectados via `@client_ids_available`, evitando crescimento ilimitado do array `@clients`. Padrão eficiente e correto.

### 9.4 Loop de Update

```ruby
def update
  update_clients   # itera @clients com next unless client
  update_maps      # itera @maps.each_value
end
```

Como `@clients` é esparso, `update_clients` sempre itera entradas `nil` entre IDs ativos. Com 1000 slots e 50 jogadores conectados, 950 iterações inúteis a cada tick. Aceitável em escala pequena, mas vale monitorar.

### 9.5 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🟡 Média | **Sem limite máximo de conexões** — nenhuma constante ou verificação de `MAX_CLIENTS` ao aceitar novas conexões |
| 2 | 🟢 Baixa | Manter lista auxiliar de clientes ativos para `update_clients` evitar iterar nil |
| 3 | 🟢 Baixa | Documentar por que `@clients` é array esparso (motivo: ID = índice para O(1) lookup) |

---

## 📄 10. `handle_data.rb`

### 10.1 Visão Geral

Módulo `Handle_Data` com **~380 linhas**. É o **roteador de pacotes** do servidor — recebe cada mensagem do cliente, lê o header e despacha para o handler correspondente. Cobre menu (login, criação de conta/personagem) e jogo (movimento, chat, combate, itens, guildas, troca, admin).

### 10.2 Roteamento de Pacotes

#### Menu (não autenticado)
| Packet | Handler | Descrição |
|--------|---------|-----------|
| `LOGIN` | `handle_login` | Autenticação de conta |
| `CREATE_ACCOUNT` | `handle_create_account` | Registro de nova conta |
| `CREATE_ACTOR` | `handle_create_actor` | Criação de personagem |
| `REMOVE_ACTOR` | `handle_remove_actor` | Exclusão de personagem |
| `USE_ACTOR` | `handle_use_actor` | Entrar no jogo com personagem |

#### Jogo (autenticado, in_game)
| Packet | Handler | Descrição |
|--------|---------|-----------|
| `PLAYER_MOVE` | `handle_player_movement` | Movimento do jogador |
| `CHAT_MSG` | `handle_chat_message` | Chat (mapa, global, party, guild, privado) |
| `PLAYER_ATTACK` | `handle_player_attack` | Ataque normal/range |
| `USE_ITEM` / `USE_SKILL` | `handle_use_item/skill` | Usar item ou habilidade |
| `BALLOON` | `handle_balloon` | Balão de expressão |
| `USE_HOTBAR` | `handle_use_hotbar` | Usar slot da hotbar |
| `ADD_DROP` / `REMOVE_DROP` | `handle_add_drop/remove_drop` | Dropar / pegar item do chão |
| `PLAYER_PARAM` | `handle_player_param` | Distribuir pontos de atributo |
| `PLAYER_EQUIP` | `handle_player_equip` | Equipar item |
| `PLAYER_HOTBAR` | `handle_player_hotbar` | Alterar hotbar |
| `TARGET` | `handle_target` | Selecionar alvo |
| `OPEN_FRIENDS` / `REMOVE_FRIEND` | — | Gestão de amigos |
| `CREATE_GUILD` / `OPEN_GUILD` | — | Gestão de guilda |
| `GUILD_LEADER` / `GUILD_NOTICE` | — | Configurações de guilda |
| `REMOVE_GUILD_MEMBER` | — | Remover membro |
| `GUILD_REQUEST` / `LEAVE_GUILD` | — | Convite e saída de guilda |
| `LEAVE_PARTY` | — | Sair do grupo |
| `CHOICE` / `NEXT_COMMAND` | — | Interação com eventos |
| `BANK_ITEM` / `BANK_GOLD` | — | Banco do jogador |
| `CLOSE_WINDOW` | — | Fechar janelas |
| `BUY_ITEM` / `SELL_ITEM` | — | Loja |
| `CHOICE_TELEPORT` | — | Teleporte por menu |
| `REQUEST` / `ACCEPT_REQUEST` / `DECLINE_REQUEST` | — | Sistema de pedidos (troca, party, amizade, guilda) |
| `TRADE_ITEM` / `TRADE_GOLD` | — | Troca entre jogadores |
| `LOGOUT` | `handle_logout` | Deslogar personagem |
| `ADMIN_COMMAND` | `handle_admin_command` | Comandos de administração |

### 10.3 Problemas Identificados

#### 🔴 Problema 1: Senha em Texto Puro

```ruby
def handle_login(client, buffer)
  # ...
  account = Database.load_account(user)
  if pass != account.pass   # ← Comparação de strings em texto puro!
```

A senha enviada pelo cliente é comparada diretamente com o valor armazenado no banco, sem nenhum hash. Se o banco de dados for comprometido, **todas as senhas de todos os jogadores são expostas imediatamente**.

**Solução recomendada:**
```ruby
require 'bcrypt'

# No create_account: armazenar hash
hashed = BCrypt::Password.create(pass)
Database.create_account(user, hashed, email)

# No login: comparar com hash
if BCrypt::Password.new(account.pass) != pass
  # senha incorreta
end
```

#### 🔴 Problema 2: Verificação de Alcance Desativada em `handle_remove_drop`

```ruby
def handle_remove_drop(client, buffer)
  drop = @maps[client.map_id].drops[drop_id]
  return unless drop
  return unless client.pos?(drop.x, drop.y)
  #return unless client.in_range?(drop, 1)   # ← DESATIVADO
```

O comentário desativa a verificação de alcance. `client.pos?` verifica se o jogador **está exatamente na mesma célula** do drop — mas isso pode ser bypassado com teleport hack ou lag exploitation. A verificação `in_range?` era mais segura e deveria ser reativada (ou reescrita de forma robusta).

#### 🔴 Problema 3: Anti-Speed Hack Desativado

```ruby
def handle_player_movement(client, buffer)
  d = buffer.read_byte
  # Anti-speed hack
  #return unless client.movable?   # ← DESATIVADO
```

Sem a verificação de cooldown de movimento, um cliente malicioso pode enviar pacotes `PLAYER_MOVE` em alta frequência e se mover muito mais rápido que o esperado.

#### 🟡 Problema 4: Validação Lógica Quebrada em `handle_create_actor`

```ruby
params = []
8.times { params << buffer.read_byte }
max_params = params.inject(:+)
points = Configs::START_POINTS - max_params
return if max_params + points > Configs::START_POINTS
# ↑ Equivalente a: return if START_POINTS > START_POINTS → sempre falso!
```

A verificação `max_params + points > START_POINTS` é algebricamente impossível de ser verdadeira (já que `points = START_POINTS - max_params`). A verificação correta seria:

```ruby
return if max_params > Configs::START_POINTS  # impede pontos negativos
return if points < 0                           # redundante mas explícito
```

#### 🟡 Problema 5: Lógica Contraditória em `handle_buy_item`

```ruby
amount = buffer.read_short.abs   # ← força positivo
# ...
if client.gold >= price * amount && (!client.full_inventory?(item) || amount < 0)
#                                                                  ↑ sempre falso!
```

`amount` já recebeu `.abs`, portanto `amount < 0` nunca é verdadeiro. A condição `|| amount < 0` é letra morta — o comportamento é sempre `!client.full_inventory?(item)`. A intenção original provavelmente era permitir "comprar" quantidade negativa (devolver), mas o `.abs` quebrou essa lógica.

#### 🟡 Problema 6: `handle_use_actor` sem verificação de mapa

```ruby
def handle_use_actor(client, buffer)
  actor_id = buffer.read_byte
  return unless client.actors.has_key?(actor_id)
  client.load_data(actor_id)
  send_player_data(client, client.map_id)
  @maps[client.map_id].total_players += 1   # ← crash se map_id inválido!
```

Se `client.map_id` referenciar um mapa que não foi carregado em `@maps`, o servidor crashará com `NoMethodError` em `nil`. Falta verificação: `return unless @maps[client.map_id]`.

### 10.4 Boas Práticas Identificadas

- ✅ **`handle_messages`** envolve todo o dispatch em `rescue` — conexão problemática é fechada sem derrubar o servidor
- ✅ **`inactivity_time`** é atualizado a cada mensagem de menu, evitando timeout de jogadores legítimos
- ✅ Múltiplas camadas de validação em `handle_login` (versão, IP, conta, multi-account, senha, banimento)
- ✅ **`handle_create_account`** verifica `client.spawning?` para evitar flood de criação
- ✅ **Antispam**: `client.antispam_time` aplicado em ações críticas (chat, drop, equipar, guilda)
- ✅ **`handle_chat_message`** usa `force_encoding('UTF-8')` — evita crashes por encoding em strings do socket

### 10.5 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🔴 Alta | **Hash de senha:** implementar BCrypt ou SHA256 — senhas em texto puro são inaceitáveis em produção |
| 2 | 🔴 Alta | **Reativar verificação de alcance** em `handle_remove_drop` (`in_range?`) |
| 3 | 🔴 Alta | **Reativar anti-speed hack** em `handle_player_movement` (`client.movable?`) |
| 4 | 🟡 Média | **Corrigir validação** em `handle_create_actor`: `return if max_params > Configs::START_POINTS` |
| 5 | 🟡 Média | **Corrigir lógica** em `handle_buy_item`: remover `.abs` ou remover `\|\| amount < 0` conforme intenção |
| 6 | 🟡 Média | **Verificar `@maps[client.map_id]`** em `handle_use_actor` antes de acessar |
| 7 | 🟢 Baixa | Adicionar validação de tamanho em `buffer.read_string` nos handlers que não o fazem (ex: `handle_chat_message` tem limite via `return if message.strip.empty?`, mas não tem limite de tamanho máximo) |

---

## 📄 11. `send_data.rb`

### 11.1 Visão Geral

Módulo `Send_Data` com **~420 linhas**. É o **emissor de pacotes** do servidor — contém métodos para serializar e enviar cada tipo de dado para clientes individuais, para o mapa, para todos os jogadores, para o grupo ou para a guilda.

### 11.2 Funções de Broadcast

| Método | Escopo | Observação |
|--------|--------|-----------|
| `send_data_to_map` | Mapa | Itera `@clients` filtrando por `map_id` |
| `send_data_to_all` | Global | Itera `@clients` filtrando `in_game?` |
| `send_data_to_party` | Grupo | Itera `@parties[party_id]` (lista já filtrada) |
| `send_data_to_guild` | Guilda | Itera `@clients` filtrando por `guild_name` |

### 11.3 Pacotes Mapeados

| Pacote | Método | Escopo |
|--------|--------|--------|
| Login completo | `send_use_actor` | Individual |
| Dados de jogadores no mapa | `send_map_players` | Individual (N pacotes) |
| Eventos do mapa | `send_map_events` | Individual (N pacotes) |
| Drops do mapa | `send_map_drops` | Individual (N pacotes) |
| Movimento de jogador | `send_player_movement` | Mapa |
| Movimento de evento | `send_event_movement` | Mapa |
| Ataque em jogador/inimigo | `send_attack_player/enemy` | Mapa |
| HP/MP | `send_player_vitals` | Mapa |
| EXP | `send_player_exp` | Mapa |
| Item ganho/perdido | `send_player_item` | Individual |
| Gold | `send_player_gold` | Individual |
| Parâmetro (stat) | `send_player_param` | Mapa |
| Equipamento | `send_player_equip` | Mapa |
| Skill | `send_player_skill` | Individual |
| Switch/Variable/Self-Switch | `send_player_switch/variable/self_switch` | Individual |
| Teleporte | `send_transfer_player` | Individual |
| Banco | `send_open_bank`, `send_bank_item`, `send_bank_gold` | Individual |
| Guilda | `send_open_guild`, `send_guild_name`, `send_guild_leader/notice` | Individual/Mapa |
| Party | `send_join_party`, `send_leave_party`, `send_dissolve_party` | Individual/Grupo |
| Trade | `send_trade_item`, `send_trade_gold` | Individual |
| Chat (todos os tipos) | `map/global/party/guild/private_chat_message` | Variável |
| Admin | `send_admin_command` | Individual |
| Global switches | `send_global_switches`, `send_global_switch` | Individual/Global |

### 11.4 Problemas Identificados

#### 🟡 Problema 1: N Pacotes por Entidade no Carregamento do Mapa

```ruby
def send_map_players(player)
  @clients.each do |client|
    next if !client&.in_game? || client.map_id != player.map_id || client == player
    buffer = Buffer_Writer.new   # ← Novo buffer por jogador
    buffer.write_byte(Enums::Packet::PLAYER_DATA)
    # ...
    player.send_data(buffer.to_s)  # ← Envia pacote individual
  end
end
```

O mesmo padrão ocorre em `send_map_events` e `send_map_drops`. Um mapa com 20 jogadores, 50 eventos e 30 drops envia **100 pacotes separados** para o cliente que está carregando o mapa.

Um pacote único (bulk) seria mais eficiente e reduziria overhead de I/O:

```ruby
def send_map_players(player)
  buffer = Buffer_Writer.new
  buffer.write_byte(Enums::Packet::MAP_PLAYERS)
  players_in_map = @clients.select { |c| c&.in_game? && c.map_id == player.map_id && c != player }
  buffer.write_short(players_in_map.size)
  players_in_map.each do |client|
    buffer.write_short(client.id)
    # ... demais campos
  end
  player.send_data(buffer.to_s)
end
```

> ⚠️ Essa mudança exige atualização do cliente VXA-OS para interpretar o novo formato de pacote bulk.

#### 🟡 Problema 2: `send_data_to_guild` é O(n) sobre todos os clientes

```ruby
def send_data_to_guild(guild_name, data)
  @clients.each { |client| client.send_data(data) if client&.in_game? && client.guild_name == guild_name }
end
```

Para cada mensagem de guilda, o servidor percorre **todos os clientes conectados**. Com uma estrutura auxiliar de membros online por guilda, isso seria O(membros_online) — muito mais eficiente em servidores com muitos jogadores.

#### 🟡 Problema 3: Indentação Inconsistente

Os métodos `send_player_item`, `send_player_gold` e `send_player_hotbar` têm a primeira linha (`buffer = Buffer_Writer.new`) com indentação de 4 espaços, enquanto as demais usam tabs. Embora não cause erro funcional, indica edições manuais descuidadas.

### 11.5 Boas Práticas Identificadas

- ✅ **`send_use_actor`** envia todo o estado inicial do personagem em um único pacote massivo — eficiente para o login
- ✅ Verificações de `zero_players?` antes de enviar para o mapa evitam iterações desnecessárias
- ✅ Separação clara de responsabilidades: cada método lida com exatamente um tipo de pacote
- ✅ `send_data_to_party` usa a lista direta de membros do grupo — O(membros) sem overhead

### 11.6 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🟡 Média | **Pacotes bulk** em `send_map_players`, `send_map_events`, `send_map_drops` para reduzir quantidade de pacotes no carregamento do mapa |
| 2 | 🟡 Média | **`send_data_to_guild`**: manter hash `@guild_members_online[guild_name]` para O(n) → O(membros) |
| 3 | 🟢 Baixa | Corrigir indentação inconsistente em `send_player_item`, `send_player_gold`, `send_player_hotbar` |

---

## 📄 12. `game_commands.rb`

### 12.1 Visão Geral

Módulo `Game_Commands` com **~160 linhas**. Implementa o **painel de administração** do servidor, separado em dois níveis de acesso: `admin` (acesso total) e `monitor` (acesso restrito a `GO`, `PULL`, `MUTE`).

### 12.2 Comandos Disponíveis

| Comando | Acesso | Descrição |
|---------|:------:|-----------|
| `KICK` | Admin | Expulsa jogador do servidor |
| `TELEPORT` | Admin | Teleporta jogador (ou `'all'`) para coordenadas |
| `GO` | Admin + Monitor | Admin vai até jogador |
| `PULL` | Admin + Monitor | Puxa jogador (ou `'all'`) para posição do admin |
| `ITEM/WEAPON/ARMOR` | Admin | Dá item para jogador (ou `'all'`) |
| `GOLD` | Admin | Dá gold para jogador (ou `'all'`) |
| `BAN_IP` | Admin | Bane por IP (afeta todas as contas do IP) |
| `BAN_ACC` | Admin | Bane conta específica por dias |
| `UNBAN` | Admin | Remove banimento |
| `SWITCH` | Admin | Altera switch global |
| `MOTD` | Admin | Altera mensagem do dia |
| `MUTE` | Admin + Monitor | Silencia jogador por 30 segundos |
| `MSG` | Admin | Envia mensagem admin para todos |

### 12.3 Problemas Identificados

#### 🔴 Problema 1: `change_global_switch` não Propaga a Mudança

```ruby
def change_global_switch(switch_id, value)
  return unless switch_id > Configs::MAX_PLAYER_SWITCHES
  @switches[switch_id] = value
  # ← Falta: send_global_switch(switch_id, value)
end
```

A switch global é atualizada em memória no servidor, mas **nenhuma mensagem é enviada aos clientes conectados**. Os jogadores só verão a mudança ao fazer logout/login ou ao trocar de mapa. A correção é adicionar `send_global_switch(switch_id, value)` após atualizar `@switches`.

#### 🟡 Problema 2: `ban` não Valida `days > 0`

```ruby
def ban(client, type, name, days)
  time = days * 86400 + Time.now.to_i
  # Se days == 0: time = Time.now.to_i → ban expira imediatamente (inútil)
  # Se days < 0: time < Time.now.to_i → ban já "expirou" antes de começar
```

Um admin que digitar `0` ou um valor negativo para `days` criará um banimento inválido que expira imediatamente. Falta `return if days <= 0` no início do método.

#### 🟡 Problema 3: Banimentos por IP não são Persistidos Imediatamente

```ruby
else
  @ban_list[player.ip] = time     # ← Apenas em memória
  kick_banned_ip(player.ip)
end
```

Banimentos por conta (`BAN_ACC`) chamam `send_admin_command` que fecha a conexão, mas a persistência depende do ciclo de `save_banlist`. Se o servidor for reiniciado antes do próximo save, o IP não estará na ban list no banco. Solução: chamar `Database.save_banlist(@ban_list)` após banir.

#### 🟡 Problema 4: `mute_player` com Duração Hardcoded

```ruby
player.muted_time = Time.now + 30  # ← Sempre 30 segundos
```

A duração do mute não pode ser configurada pelo admin no momento da ação. Poderia receber `int1` do pacote admin como duração em segundos.

### 12.4 Boas Práticas Identificadas

- ✅ **Separação de privilégios**: `admin_commands` vs `monitor_commands` bem definidos
- ✅ **Proteção de admins**: `kick_player` e `ban` verificam `player.admin?` antes de agir
- ✅ **Logging abrangente**: todas as ações administrativas são registradas em `@log` com usuário e detalhes
- ✅ **Suporte a `'all'`**: `teleport_player`, `pull_player`, `give_item`, `give_gold` suportam broadcast para todos os jogadores

### 12.5 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🔴 Alta | **`change_global_switch`**: adicionar `send_global_switch(switch_id, value)` após atualizar memória |
| 2 | 🟡 Média | **`ban`**: validar `days > 0` antes de processar o banimento |
| 3 | 🟡 Média | **Ban IP**: persistir imediatamente no banco após adicionar à `@ban_list` |
| 4 | 🟡 Média | **`mute_player`**: tornar duração configurável via parâmetro do comando admin |
| 5 | 🟢 Baixa | `give_item` com `name == 'all'`: notificar admin quando inventários estiverem cheios |

---

## 📊 13. Resumo do Diagnóstico — Network

| Arquivo | Linhas | Status | Críticos | Melhorias |
|---------|:------:|:------:|:--------:|:---------:|
| `network.rb` | ~70 | ✅ Funcional | 0 | 3 |
| `handle_data.rb` | ~380 | 🔴 Riscos de Segurança | 3 | 7 |
| `send_data.rb` | ~420 | ✅ Funcional | 0 | 3 |
| `game_commands.rb` | ~160 | ⚠️ Funcional com Riscos | 1 | 5 |

### Problemas por Categoria

| Categoria | Problema | Arquivo | Risco |
|-----------|---------|---------|:-----:|
| **Segurança** | Senhas comparadas em texto puro | `handle_data.rb` | 🔴 Crítico |
| **Segurança** | Verificação de alcance de drop desativada | `handle_data.rb` | 🔴 Crítico |
| **Segurança** | Anti-speed hack desativado | `handle_data.rb` | 🔴 Crítico |
| **Lógica** | `change_global_switch` não propaga aos clientes | `game_commands.rb` | 🔴 Alto |
| **Lógica** | Validação de parâmetros em `create_actor` sempre falsa | `handle_data.rb` | 🟡 Médio |
| **Lógica** | `handle_buy_item` com `.abs` + `< 0` contraditórios | `handle_data.rb` | 🟡 Médio |
| **Estabilidade** | `handle_use_actor` sem check de `@maps[map_id]` | `handle_data.rb` | 🟡 Médio |
| **Segurança** | `ban` aceita `days <= 0` sem validação | `game_commands.rb` | 🟡 Médio |
| **Persistência** | Ban por IP não persiste imediatamente | `game_commands.rb` | 🟡 Médio |
| **Performance** | N pacotes por entidade no carregamento de mapa | `send_data.rb` | 🟡 Médio |
| **Performance** | `send_data_to_guild` itera todos os clientes | `send_data.rb` | 🟡 Médio |

---

## 🎯 14. Prioridades Globais — Todos os Módulos

### 🔴 Alta Prioridade — Ação Imediata

| # | Arquivo | Ação |
|---|---------|------|
| 1 | `handle_data.rb` | Implementar hash de senha (BCrypt/SHA256) |
| 2 | `handle_data.rb` | Reativar verificação de alcance em `handle_remove_drop` |
| 3 | `handle_data.rb` | Reativar anti-speed hack (`client.movable?`) |
| 4 | `game_commands.rb` | Adicionar `send_global_switch` em `change_global_switch` |
| 5 | `database.rb` | Implementar connection pool persistente |
| 6 | `database.rb` | Envolver `save_player` em transação |
| 7 | `game_data.rb` | Isolar erros em `save_all_players_online` |
| 8 | `scripts.rb` | Substituir índices hardcoded por busca por nome |

### 🟡 Média Prioridade — Próximo Ciclo

| # | Arquivo | Ação |
|---|---------|------|
| 9 | `handle_data.rb` | Corrigir validação em `handle_create_actor` |
| 10 | `handle_data.rb` | Corrigir lógica `.abs`/`< 0` em `handle_buy_item` |
| 11 | `handle_data.rb` | Verificar `@maps[client.map_id]` em `handle_use_actor` |
| 12 | `game_commands.rb` | Validar `days > 0` em `ban` |
| 13 | `game_commands.rb` | Persistir ban por IP imediatamente |
| 14 | `game_commands.rb` | Tornar duração do mute configurável |
| 15 | `database.rb` | Renomear `actors.int` → `mat` e `actors.res` → `mdf` |
| 16 | `game_data.rb` | Capturar erro real em `load_guilds` |
| 17 | `send_data.rb` | Implementar pacotes bulk para `send_map_players/events/drops` |

### 🟢 Baixa Prioridade — Backlog

- `send_data.rb` — Cache de membros online por guilda
- `send_data.rb` — Corrigir indentação inconsistente
- `network.rb` — Limite máximo de conexões
- `logger.rb` — Flush imediato para erros críticos
- `enums.rb` — Corrigir typo `ACESSORY`
- `structs.rb` — Adicionar `owner_id` em `Drop`

---

## 📈 15. Estatísticas Gerais do Diagnóstico

| Módulo | Arquivos | Linhas | Críticos | Médios | Total Melhorias |
|--------|:--------:|:------:|:--------:|:------:|:---------------:|
| Kernel | 3 | ~150 | 2 | 2 | 9 |
| Database | 3 | ~792 | 3 | 5 | 15 |
| Network | 4 | ~1.030 | 4 | 7 | 18 |
| **Total** | **10** | **~1.972** | **9** | **14** | **42** |

---

## 🔜 16. Próximos Passos

| Ordem | Módulo | Arquivos | Status |
|:-----:|--------|----------|:------:|
| ✅ 1 | `Server/Kernel` | `enums.rb`, `structs.rb`, `scripts.rb` | Concluído |
| ✅ 2 | `Server/Database` | `database.rb`, `game_data.rb`, `logger.rb` | Concluído |
| ✅ 3 | `Server/Network` | `network.rb`, `handle_data.rb`, `send_data.rb`, `game_commands.rb` | **Concluído** |
| ⏳ 4 | `Server/Client` | `game_character.rb`, `game_client.rb`, `game_account.rb` | Pendente |
| ⏳ 5 | `Server/Combat, Map, Party, Guild, Trade` | A definir | Pendente |
| ⏳ 6 | `Client [VS] scripts` | A definir | Pendente |

---

*Documento gerado em: Março 2026 — Fields Online HML · Diagnóstico Técnico Fase 1*