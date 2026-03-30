# 🔍 Diagnóstico Técnico — Server/Kernel
> **Projeto:** Fields Online HML
> **Plataforma:** VXA-OS / RPG Maker VX Ace
> **Fase:** 1 — Análise e Documentação
> **Módulo:** `Server/Scripts/Kernel/`
> **Arquivos analisados:** `enums.rb` · `structs.rb` · `scripts.rb`
> **Data:** Março 2026
> **Responsável:** Caio Juan De Lima Silva

---

## 📑 Índice

1. [enums.rb](#1-enumsrb)
2. [structs.rb](#2-structsrb)
3. [scripts.rb](#3-scriptsrb)
4. [Resumo do Diagnóstico — Kernel](#4-resumo-do-diagnóstico)
5. [Prioridades de Correção — Kernel](#5-prioridades-de-correção)

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

### 1.3 Observações Técnicas
- **`Enums::Equip`**: define 9 slots de equipamento. O campo `ACESSORY` contém **erro de ortografia** (correto: `ACCESSORY`). Não causa falha em runtime, mas compromete legibilidade.
- **`Enums::Param`**: espelha exatamente os 8 parâmetros base do RPG Maker VX Ace (`param_id` 0–7). Coerência total com o engine.
- **`Enums::Item`**: utiliza valores não-sequenciais (`0, 8, 10, 11`) intencionalmente para compatibilidade com os escopos do VXAce. Apenas 4 dos 12 escopos estão mapeados.
- **`Enums::Move`**: cobre os 4 tipos de movimento de eventos do RPG Maker. Completo e funcional.

### 1.4 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🟡 Média | Renomear `ACESSORY` → `ACCESSORY` e atualizar **todas** as referências |
| 2 | 🟢 Baixa | Adicionar comentários de índice em cada `enum` para facilitar debug |
| 3 | 🟢 Baixa | Considerar ampliar `Enums::Item` com os demais escopos do VXAce |
| 4 | 🟢 Baixa | Adicionar valor `NONE`/`EMPTY` para representar "sem equipamento" explicitamente |

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

### 2.3 Observações Técnicas
- **`Drop`**: possui `party_id` para proteção por grupo, `despawn_time` e `pick_up_time` para controle de expiração. Ausência de `owner_id` impede proteção individual de loot.
- **`IP_Blocked`**: permite bloqueio progressivo por tentativas falhas — boa prática de segurança já estruturada.
- **`Actor`**: inclui `revive_map_id/x/y` para ponto de renascimento e `switches`, `variables`, `self_switches` para persistência de progresso de eventos.
- **`Guild`**: estrutura básica, sem campos de progressão (`exp`, `level`, `bank`, `ranks`).
- **`Account.pass`**: verificar obrigatoriamente se há hash criptográfico aplicado antes de persistir no banco.

### 2.4 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🔴 Alta | Auditar `Account.pass` — garantir que nunca é salvo em texto puro |
| 2 | 🟡 Média | Adicionar `owner_id` em `Drop` para proteção individual de loot |
| 3 | 🟡 Média | Documentar `Actor.param_base` como `Array[8]` espelhando `Enums::Param` |
| 4 | 🟢 Baixa | Planejar expansão da `Guild` com campos de progressão |
| 5 | 🟢 Baixa | Refatorar `Reward` para suportar array de múltiplos itens |

---

## 📄 3. `scripts.rb`

### 3.1 Visão Geral
Script de bootstrap do servidor. Carrega e executa seletivamente os scripts do client a partir do `Scripts.rvdata2`.

### 3.2 Lógica Atual
```ruby
scripts = load_data('Scripts.rvdata2')
eval(Zlib::Inflate.inflate(scripts[1][2]))  # índice fixo — frágil
eval(Zlib::Inflate.inflate(scripts[2][2]))  # índice fixo — frágil
scripts.each { |script| eval(...) if script[1].include?('Kernel') || script[1].include?('Enums') }
```

### 3.3 Observações Técnicas
- **Índices hardcoded**: `scripts[1]` e `scripts[2]` são completamente frágeis. Se a ordem dos scripts mudar no RPG Maker Editor, o servidor carrega scripts errados silenciosamente.
- **Sem tratamento de erro**: um `eval` com falha derruba o servidor inteiro durante o boot.
- **Sem log de carregamento**: impossível saber quais scripts foram executados sem inserir prints manualmente.

### 3.4 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🔴 Alta | Substituir índices fixos por busca dinâmica por nome do script |
| 2 | 🟡 Média | Adicionar `begin/rescue` ao redor dos `eval` para isolar falhas |
| 3 | 🟢 Baixa | Adicionar log de carregamento dos scripts no boot |

---

## 📊 4. Resumo do Diagnóstico — Kernel

| Arquivo | Status | Bugs | Melhorias |
|---------|:------:|:----:|:---------:|
| `enums.rb` | ✅ Funcional | 1 typo | 4 |
| `structs.rb` | ✅ Funcional | 1 segurança | 5 |
| `scripts.rb` | ⚠️ Risco | 1 crítico | 3 |

---

## 🎯 5. Prioridades de Correção — Kernel

- 🔴 **`scripts.rb`** — Eliminar índices hardcoded (risco de boot incorreto)
- 🔴 **`structs.rb`** — Auditar hash de `Account.pass`
- 🟡 **`enums.rb`** — Corrigir typo `ACESSORY` e atualizar referências
- 🟡 **`structs.rb`** — Adicionar `owner_id` em `Drop`
- 🟡 **`scripts.rb`** — Adicionar `begin/rescue` nos `eval`
- 🟢 Demais melhorias de baixa prioridade (backlog)

---

---

# 🔍 Diagnóstico Técnico — Server/Database

> **Módulo:** `Server/Scripts/Database/`
> **Arquivos analisados:** `database.rb` · `game_data.rb` · `logger.rb`
> **Data:** Março 2026

---

## 📑 Índice

6. [database.rb](#6-databaserb)
7. [game_data.rb](#7-game_datarb)
8. [logger.rb](#8-loggerrb)
9. [Resumo do Diagnóstico — Database](#9-resumo-do-diagnóstico--database)
10. [Prioridades de Correção — Database](#10-prioridades-de-correção--database)
11. [Próximos Passos](#11-próximos-passos)

---

## 📄 6. `database.rb`

### 6.1 Visão Geral

O maior e mais crítico arquivo do módulo, com **463 linhas**. É o módulo `Database`, responsável por toda a **camada de persistência** do servidor — contas, personagens, bank, guildas, ban list, distribuidor de itens e status online. Utiliza a gem **Sequel** como ORM/query builder sobre SQLite ou PostgreSQL.

---

### 6.2 Suporte a Múltiplos Bancos de Dados

```ruby
def self.sql_client
  if DATABASE_PATH.empty?
    Sequel.connect("postgres://#{DATABASE_USER}:#{DATABASE_PASS}@#{DATABASE_HOST}/#{DATABASE_NAME}")
  else
    Sequel.connect("sqlite://Data/#{DATABASE_PATH}.db")
  end
end
```

O servidor suporta dois backends de banco de dados controlados pela config `DATABASE_PATH`:
- **SQLite** (quando `DATABASE_PATH` não é vazio) — modo local/desenvolvimento
- **PostgreSQL** (quando `DATABASE_PATH` é vazio) — modo produção/multiplayer real

> ⚠️ Há uma string MySQL comentada no código (`mysql2://...`), indicando que o projeto já passou por MySQL antes de migrar para PostgreSQL.

---

### 6.3 Mapeamento de Funções

| Função | Tabelas Envolvidas | Finalidade |
|--------|--------------------|-----------|
| `sql_client` | — | Cria e retorna uma conexão com o banco |
| `create_account` | `accounts`, `banks` | Cria conta + bank vazio para novo usuário |
| `load_account` | `accounts`, `actors`, `account_friends` | Carrega conta completa com personagens |
| `save_account` | `accounts`, `account_friends` | Salva VIP e lista de amigos |
| `account_exist?` | `accounts` | Verifica se username já existe |
| `create_player` | `actors`, `actor_equips`, `actor_skills`, `actor_hotbars`, `actor_switches`, `actor_variables` | Cria personagem completo com todas as tabelas auxiliares |
| `load_player` | `actors` + todas as tabelas `actor_*` | Carrega personagem completo do banco |
| `load_player_equips` | `actor_equips` | Carrega equipamentos com validação de existência |
| `load_player_items` | `actor_items` | Carrega itens com validação de existência |
| `load_player_weapons` | `actor_weapons` | Carrega armas com validação de existência |
| `load_player_armors` | `actor_armors` | Carrega armaduras com validação de existência |
| `load_player_quests` | `actor_quests` | Carrega estado das quests |
| `load_player_hotbar` | `actor_hotbars` | Carrega hotbar com validação de itens/skills |
| `save_player` | `actors` + todas as tabelas `actor_*` + bank | Salva personagem completo (operação mais pesada do servidor) |
| `save_items` | `actor_items/weapons/armors` ou `bank_items/weapons/armors` | Salva inventário com diff (insert/update/delete) |
| `save_player_skills` | `actor_skills` | Salva skills com diff |
| `save_player_quests` | `actor_quests` | Salva quests com diff |
| `save_player_self_switches` | `actor_self_switches` | Salva self-switches de eventos |
| `player_exist?` | `actors` | Verifica se nome de personagem já existe |
| `remove_player` | `actors` + todas as tabelas `actor_*` | Remove personagem e todos os dados relacionados |
| `load_bank` | `banks`, `bank_items/weapons/armors` | Carrega banco do jogador |
| `save_bank` | `banks`, `bank_items/weapons/armors` | Salva banco do jogador |
| `load_distributor` | `distributor` | Carrega itens comprados na loja do site |
| `create_guild` | `guilds` | Cria nova guilda |
| `load_guilds` | `guilds`, `actors` | Carrega todas as guildas do banco |
| `save_guild` | `guilds` | Atualiza líder e aviso da guilda |
| `remove_guild` | `guilds`, `actors` | Remove guilda e desvincula membros |
| `remove_guild_member` | `actors` | Remove um membro da guilda |
| `load_banlist` | `ban_list` | Carrega lista de IPs/contas banidos |
| `save_banlist` | `ban_list` | Sincroniza ban list (diff bidirecional) |
| `unban` | `actors`, ban_list in-memory | Remove banimento de jogador por nome |
| `change_whos_online` | `actors` | Atualiza coluna `online` do personagem |

---

### 6.4 Esquema de Tabelas Deduzido

Com base nas queries do código, o banco possui as seguintes tabelas:

| Tabela | Colunas Principais |
|--------|-------------------|
| `accounts` | `id, username, password, email, group, vip_time, creation_date, cash` |
| `account_friends` | `id, account_id, name` |
| `actors` | `id, slot_id, account_id, name, character_name, character_index, face_name, face_index, class_id, sex, level, exp, hp, mp, mhp, mmp, atk, def, int, res, agi, luk, points, guild_id, revive_map_id, revive_x, revive_y, map_id, x, y, direction, gold, creation_date, last_login, online` |
| `actor_equips` | `id, actor_id, slot_id, equip_id` |
| `actor_items` | `id, actor_id, item_id, amount` |
| `actor_weapons` | `id, actor_id, weapon_id, amount` |
| `actor_armors` | `id, actor_id, armor_id, amount` |
| `actor_skills` | `id, actor_id, skill_id` |
| `actor_quests` | `id, actor_id, quest_id, state, kills` |
| `actor_hotbars` | `id, actor_id, slot_id, type, item_id` |
| `actor_switches` | `id, actor_id, switch_id, value` |
| `actor_variables` | `id, actor_id, variable_id, value` |
| `actor_self_switches` | `id, actor_id, map_id, event_id, ch, value` |
| `banks` | `id, account_id, gold` |
| `bank_items` | `id, bank_id, item_id, amount` |
| `bank_weapons` | `id, bank_id, weapon_id, amount` |
| `bank_armors` | `id, bank_id, armor_id, amount` |
| `guilds` | `id, name, leader, flag, notice, creation_date` |
| `ban_list` | `id, account_id, ip, time, ban_date` |
| `distributor` | `id, account_id, kind, item_id, amount` |

---

### 6.5 Observações Técnicas

#### 🔵 Conexão por Chamada — Padrão de Conexão Preocupante
Cada operação de banco chama `sql_client` no início e `s_client.disconnect` no final. Isso significa que **uma nova conexão TCP é aberta e fechada a cada operação** (login, save, load, etc.).

Em SQLite isso é aceitável, mas em **PostgreSQL em produção com múltiplos jogadores simultâneos**, esse padrão pode:
- Esgotar o pool de conexões disponíveis
- Introduzir latência de handshake TCP em cada operação
- Causar erros de conexão sob carga

A solução ideal é um **connection pool** persistente (o próprio Sequel suporta isso nativamente com `Sequel.connect(..., max_connections: N)`).

#### 🔵 `save_items` — Algoritmo de Diff Inteligente
A função `save_items` implementa um diff eficiente entre o estado atual do inventário em memória e o estado salvo no banco:
- **Novos itens** → `INSERT`
- **Quantidade alterada** → `UPDATE`
- **Itens removidos** → `DELETE`

Isso evita apagar e recriar o inventário inteiro a cada save — boa prática de performance.

#### 🔵 `save_player` — Operação Mais Pesada
Chama sequencialmente: update de actor + equips + hotbar + switches + variables + items + weapons + armors + skills + quests + self_switches + account + bank.

Todas essas operações ocorrem em uma única `sql_client` compartilhada, mas **não estão envolvidas em uma transação**. Se o servidor cair no meio de um `save_player`, o personagem pode ficar em estado inconsistente (ex: itens do inventário salvos, mas stats do personagem não).

#### 🔵 `load_player` — Validação de Dados ao Carregar
O código já possui validações defensivas ao carregar:
- Equipamentos inválidos são zerados (`equip_id = 0`)
- Itens/armas/armaduras sem correspondência no `$data_*` são ignorados
- Hotbar com item/skill inexistente é zerada

Esse padrão é robusto e evita crashes por inconsistência de dados.

#### 🔵 `actors.int` e `actors.res` — Nomes de Coluna Conflitantes
As colunas `int` e `res` no banco representam `MAT` (Magic Attack) e `MDF` (Magic Defense) conforme `Enums::Param`. O nome `int` é uma **palavra reservada em SQL**! Embora Sequel trate isso com aspas automaticamente em alguns dialetos, pode causar erros em queries diretas (ex: via admin SQL) ou em migrações futuras.

#### 🔵 `load_distributor` — Sistema de Loja Web Integrado
A função `load_distributor` carrega itens comprados em uma **loja externa (site)** via tabela `distributor`, adicionando ao bank do jogador. O design é correto: carrega e apaga da tabela distribuidor para evitar duplicações, mesmo que o jogador esteja com o bank aberto.

#### 🔵 `save_banlist` — Sincronização Bidirecional Complexa
O método compara a ban list em memória com o banco em **dois sentidos**:
1. Remove do banco entradas que não estão mais em memória
2. Insere no banco entradas novas que ainda não estão persistidas

Funciona corretamente, mas a lógica é densa. Um comentário explicativo seria valioso.

---

### 6.6 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🔴 Alta | **Connection pool:** substituir conexão por chamada por um pool persistente do Sequel (crítico para produção com PostgreSQL) |
| 2 | 🔴 Alta | **Transações em `save_player`:** envolver todo o save em `s_client.transaction { ... }` para garantir atomicidade |
| 3 | 🟡 Média | **Coluna `actors.int`:** renomear para `mat` para evitar conflito com palavra reservada SQL e alinhar com `Enums::Param::MAT` |
| 4 | 🟡 Média | **Coluna `actors.res`:** renomear para `mdf` para alinhar com `Enums::Param::MDF` |
| 5 | 🟡 Média | **`load_some_player_data`:** comentar que o ilike está desativado (comentado) e documentar o motivo |
| 6 | 🟢 Baixa | **`save_banlist`:** adicionar comentários explicando a lógica de sincronização bidirecional |
| 7 | 🟢 Baixa | **`remove_player`:** envolver em transação para garantir remoção atômica de todas as tabelas relacionadas |
| 8 | 🟢 Baixa | **`create_account`:** considerar criação de personagem default opcional já no momento do cadastro |

---

### 6.7 Exemplo de Melhoria — Connection Pool + Transação em `save_player`

```ruby
# ============================================================
# Inicialização do pool de conexões (uma vez no boot do servidor)
# ============================================================
DB = if DATABASE_PATH.empty?
  Sequel.connect("postgres://#{DATABASE_USER}:#{DATABASE_PASS}@#{DATABASE_HOST}/#{DATABASE_NAME}",
                 max_connections: 10)
else
  Sequel.connect("sqlite://Data/#{DATABASE_PATH}.db",
                 max_connections: 5)
end

# ============================================================
# save_player com transação atômica
# ============================================================
def self.save_player(client)
  DB.transaction do
    DB[:actors].where(id: client.id_db).update(...)
    save_items(client, client.items, DB, 'item')
    save_items(client, client.weapons, DB, 'weapon')
    save_items(client, client.armors, DB, 'armor')
    save_player_skills(client, DB)
    save_player_quests(client, DB)
    save_player_self_switches(client, DB)
    save_account(client, DB)
    save_bank(client, DB)
  end
  # Se qualquer operação falhar, TODAS são revertidas automaticamente
end
```

---

## 📄 7. `game_data.rb`

### 7.1 Visão Geral

Módulo `Game_Data` com **297 linhas**, responsável por **carregar os dados estáticos do RPG Maker VX Ace** (inimigos, estados, animações, atores, classes, habilidades, itens, armas, armaduras, tilesets, mapas, eventos comuns e sistema) e também os dados dinâmicos do servidor (motd, ban list, switches globais, guildas). É o **inicializador completo do estado do servidor**.

---

### 7.2 Funções de Carregamento

| Função | Fonte | Dados Carregados |
|--------|-------|-----------------|
| `load_game_data` | — | Orquestra todos os loads + log de inicialização |
| `load_enemies` | `Enemies.rvdata2` | Nome, params, gold, exp, drops, ações, features + notas customizadas |
| `load_states` | `States.rvdata2` | Features, restriction, remove conditions |
| `load_animations` | `Animations.rvdata2` | Apenas `frame_max` (otimizado) |
| `load_actors` | `Actors.rvdata2` | Level inicial, equips base, features |
| `load_classes` | `Classes.rvdata2` | Exp params, learnings, params, features, graphics (via Note) |
| `load_skills` | `Skills.rvdata2` | Todos os campos relevantes + range, aoe, level, ani_index via notas |
| `load_items` | `Items.rvdata2` | Todos os campos + range, aoe, level, ani_index, soulbound via notas |
| `load_weapons` | `Weapons.rvdata2` | Todos os campos + level, ani_index, vip, soulbound via notas |
| `load_armors` | `Armors.rvdata2` | Todos os campos + level, vip, soulbound, sex via notas |
| `load_tilesets` | `Tilesets.rvdata2` | Apenas `flags` de colisão (otimizado) |
| `load_maps` | `MapInfos.rvdata2` + `Map###.rvdata2` | Todos os mapas + eventos (exceto `notupdate` e `notglobal`) |
| `load_common_events` | `CommonEvents.rvdata2` | Eventos comuns com id, trigger, switch_id, list |
| `load_system` | `System.rvdata2` | opt_floor_death, start_map_id, start_x, start_y |
| `load_motd` | `motd.txt` | Mensagem do dia (UTF-8 com BOM) |
| `load_banlist` | SQL via `Database` | Ban list com tratamento de erro |
| `load_global_switches` | `Data/switches.json` | Switches globais persistidas em JSON |
| `load_guilds` | SQL via `Database` | Guildas com tratamento de erro |

### 7.3 Funções de Salvamento

| Função | Destino | O que Salva |
|--------|---------|-------------|
| `save_game_data` | — | Orquestra todos os saves + log |
| `save_motd` | `motd.txt` | Mensagem do dia atualizada |
| `save_global_switches` | `Data/switches.json` | Switches globais em JSON |
| `save_all_players_online` | SQL via `Database` | Todos os jogadores in-game |

---

### 7.4 Observações Técnicas

#### 🔵 Carregamento Seletivo — Boa Prática de Performance
O servidor **não carrega todos os campos** dos objetos do RPG Maker — apenas os que realmente serão utilizados. Por exemplo:
- `load_animations` carrega apenas `frame_max` (ignora frames, nome, posição, etc.)
- `load_tilesets` carrega apenas `flags` de colisão
- `load_states` carrega apenas campos de remoção e restriction

Isso reduz significativamente o uso de memória em servidores com muitos dados.

#### 🔵 Sistema de Notas Customizadas (`Note.read_*`)
Os objetos do RPG Maker VX Ace possuem um campo `note` (anotações em texto livre). O VXA-OS implementou um parser de notas (`Note.read_number`, `Note.read_boolean`, `Note.read_graphics`) para adicionar propriedades customizadas sem modificar o schema do engine:
- `Sight=5` → alcance de visão do inimigo
- `ReviveTime=300` → tempo de respawn em frames
- `SwitchID=10` → switch que desativa o inimigo
- `VIP=true` → item exclusivo para VIP
- `Soulbound=true` → item intransferível
- `Range=3` → alcance da habilidade
- `AOE=2` → raio de área de efeito

Essa abordagem é elegante e extensível, mas **não tem validação de tipo nem valor padrão explícito** para todos os campos — erros de digitação nas notas do RPG Maker resultam em `0` ou `nil` silenciosamente.

#### 🔵 `load_maps` — Filtro de Eventos por Nome
```ruby
next if event.name == 'notupdate' || event.name == 'notglobal'
```
Eventos com nome `notupdate` ou `notglobal` são ignorados pelo servidor — convenção do VXA-OS para marcar eventos que não devem ser sincronizados com os clientes. Funcional, mas baseado em **string magic** — qualquer erro de digitação no nome do evento no RPG Maker quebra o filtro silenciosamente.

#### 🔵 `load_motd` — BOM UTF-8
O arquivo `motd.txt` é lido com `'r:bom|UTF-8'`, tratando corretamente o Byte Order Mark. Detalhe importante para evitar caracteres estranhos no início da mensagem em sistemas Windows.

#### 🔵 `load_banlist` e `load_guilds` — Tratamento de Erro Assimétrico
- `load_banlist` tem `rescue => e` com impressão do erro detalhado ✅
- `load_guilds` tem `rescue` **sem capturar o erro** (`rescue` sem `=> e`) — a mensagem de erro real é silenciada ⚠️

#### 🔵 `save_game_data` — Sem Tratamento de Erro no Save
`save_all_players_online` itera sobre todos os clientes e chama `Database.save_player(client)` sem `begin/rescue`. Se um save falhar para um jogador específico, pode interromper o loop e impedir que outros jogadores sejam salvos.

---

### 7.5 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🔴 Alta | **`save_all_players_online`**: adicionar `begin/rescue` por jogador para não interromper o loop de save em caso de erro individual |
| 2 | 🟡 Média | **`load_guilds`**: capturar o erro (`rescue => e`) e logar a mensagem real, igual ao `load_banlist` |
| 3 | 🟡 Média | **`load_maps` filtro de eventos**: considerar usar uma constante ou tag estruturada no lugar de strings hardcoded `'notupdate'` / `'notglobal'` |
| 4 | 🟡 Média | **`Note.read_*`**: adicionar validação de range/tipo nos campos críticos (ex: `Sight`, `ReviveTime`) para evitar valores absurdos por erro de digitação no RPG Maker |
| 5 | 🟢 Baixa | **`load_game_data`**: considerar medir e logar o tempo de carregamento por recurso para identificar gargalos no boot |
| 6 | 🟢 Baixa | **`AniIndex` regex**: o padrão `/AniIndex=(.*)/` captura qualquer coisa após o `=` — usar `/AniIndex=(\d+)/` para garantir que apenas números sejam aceitos |

---

### 7.6 Exemplo de Melhoria — `save_all_players_online` com isolamento de erros

```ruby
# Antes — um erro interrompe o loop inteiro
def save_all_players_online
  @clients.each { |client| Database.save_player(client) if client&.in_game? }
end

# Depois — erros individuais são isolados e logados
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

---

## 📄 8. `logger.rb`

### 8.1 Visão Geral

Classe `Logger` simples com **32 linhas**, responsável por **registrar eventos importantes do servidor** em arquivos de log separados por tipo e data. Cobre ações de administradores, monitores e erros operacionais.

---

### 8.2 Estrutura

```ruby
class Logger
  def initialize
    @text = {}  # Hash: "TipoLog-DD-Mon-YYYY" => "texto acumulado"
  end

  def add(type, color, text)
    # Converte group numérico (ADMIN/MONITOR) para string legível
    # Formata a chave do dia: "Admin-30-Mar-2026"
    # Acumula texto com timestamp: "11:00:05: mensagem\n"
    # Imprime no console com cor (gem colorize)
  end

  def save_all
    # Escreve cada entrada de @text em "Logs/[chave].txt" (modo append)
    # Limpa @text após salvar
  end
end
```

---

### 8.3 Observações Técnicas

#### 🔵 Acúmulo em Memória
Os logs são acumulados em `@text` (hash em memória) e salvos em disco apenas quando `save_all` é chamado. O intervalo de save é controlado externamente (provavelmente junto com o `save_game_data`). Em caso de crash do servidor, **os logs acumulados desde o último save são perdidos**.

#### 🔵 Separação por Tipo e Data
Os arquivos de log são separados por tipo (`Admin`, `Monitor`) e data (`30-Mar-2026`), resultando em arquivos como `Logs/Admin-30-Mar-2026.txt`. Organização clara e fácil de auditar.

#### 🔵 Dependência de `Enums::Group`
O método `add` converte `type` numérico usando `Enums::Group::ADMIN` e `Enums::Group::MONITOR`. Porém, `Enums::Group` **não está definido em `enums.rb`** — está presumivelmente em outro arquivo do Kernel ou do Client. Essa dependência implícita é um ponto de fragilidade.

#### 🔵 Modo `append` no Save
O arquivo é aberto com `'a+'` (append + leitura), o que garante que logs antigos do mesmo dia não sejam sobrescritos. Comportamento correto.

#### 🔵 Ausência de Níveis de Severidade
O sistema de log atual registra apenas ações administrativas. Não há suporte a níveis de severidade estruturados (`DEBUG`, `INFO`, `WARN`, `ERROR`) para logs de sistema, erros de rede ou falhas de banco.

---

### 8.4 Pontos de Melhoria

| # | Prioridade | Descrição |
|---|:----------:|-----------|
| 1 | 🟡 Média | **Flush imediato em erros críticos**: salvar no disco imediatamente quando o `type` for `ERROR` ou similar, sem esperar o próximo `save_all` |
| 2 | 🟡 Média | **Documentar dependência de `Enums::Group`**: comentar explicitamente que o método depende dessa constante estar carregada |
| 3 | 🟢 Baixa | **Níveis de severidade**: considerar adicionar suporte a `INFO`, `WARN`, `ERROR` para logs de sistema além dos logs administrativos |
| 4 | 🟢 Baixa | **Rotação de logs**: logs antigos podem acumular indefinidamente na pasta `Logs/`. Considerar política de limpeza automática (ex: manter últimos 30 dias) |
| 5 | 🟢 Baixa | **Thread safety**: se o servidor for multi-thread, acessos concorrentes ao hash `@text` precisam de mutex |

---

## 📊 9. Resumo do Diagnóstico — Database

| Arquivo | Linhas | Status | Problemas Críticos | Melhorias |
|---------|:------:|:------:|:-----------------:|:---------:|
| `database.rb` | 463 | ⚠️ Funcional com Riscos | 2 (conexão + transação) | 8 |
| `game_data.rb` | 297 | ⚠️ Funcional com Riscos | 1 (save sem isolamento) | 6 |
| `logger.rb` | 32 | ✅ Funcional | 0 | 5 |

### Problemas Identificados por Categoria

| Categoria | Problema | Arquivo | Risco |
|-----------|---------|---------|:-----:|
| Performance | Conexão nova por operação (sem pool) | `database.rb` | 🔴 Crítico em produção |
| Integridade | `save_player` sem transação atômica | `database.rb` | 🔴 Alto |
| Resiliência | `save_all_players_online` sem rescue por jogador | `game_data.rb` | 🔴 Alto |
| Nomenclatura | Colunas `int` e `res` conflitam com SQL | `database.rb` | 🟡 Médio |
| Observabilidade | `load_guilds` silencia erros reais | `game_data.rb` | 🟡 Médio |
| Validação | `Note.read_*` sem validação de tipo/range | `game_data.rb` | 🟡 Médio |
| Logs | Flush apenas no `save_all` (crash = perda) | `logger.rb` | 🟡 Médio |
| Manutenção | Strings hardcoded `'notupdate'`/`'notglobal'` | `game_data.rb` | 🟢 Baixo |

---

## 🎯 10. Prioridades de Correção — Database

### 🔴 Alta Prioridade — Ação Imediata
- [ ] **`database.rb`** — Implementar connection pool persistente com Sequel (`max_connections: N`)
- [ ] **`database.rb`** — Envolver `save_player` em `s_client.transaction { ... }` para atomicidade
- [ ] **`game_data.rb`** — Adicionar `begin/rescue` por jogador em `save_all_players_online`

### 🟡 Média Prioridade — Próximo Ciclo
- [ ] **`database.rb`** — Renomear colunas `actors.int` → `mat` e `actors.res` → `mdf`
- [ ] **`game_data.rb`** — Corrigir `load_guilds` para capturar e logar o erro real (`rescue => e`)
- [ ] **`game_data.rb`** — Adicionar validação de tipo/range nos `Note.read_*` críticos
- [ ] **`logger.rb`** — Implementar flush imediato para eventos de erro crítico

### 🟢 Baixa Prioridade — Backlog
- [ ] **`database.rb`** — Envolver `remove_player` em transação
- [ ] **`game_data.rb`** — Substituir strings `'notupdate'`/`'notglobal'` por constante nomeada
- [ ] **`game_data.rb`** — Adicionar medição de tempo de boot por recurso
- [ ] **`logger.rb`** — Adicionar suporte a níveis de severidade e política de rotação de logs

---

## 🔜 11. Próximos Passos

| Ordem | Módulo | Arquivos | Status |
|:-----:|--------|----------|:------:|
| ✅ 1 | `Server/Kernel` | `enums.rb`, `structs.rb`, `scripts.rb` | Concluído |
| ✅ 2 | `Server/Database` | `database.rb`, `game_data.rb`, `logger.rb` | Concluído |
| ▶️ 3 | `Server/Network` | `network.rb`, `handle_data.rb`, `send_data.rb`, `game_commands.rb` | **Próximo** |
| ⏳ 4 | `Server/Client` | `game_character.rb`, `game_client.rb`, `game_account.rb` | Pendente |
| ⏳ 5 | `Server/Combat, Map, Party, Guild, Trade` | A definir | Pendente |
| ⏳ 6 | `Client [VS] scripts` | A definir | Pendente |

---

*Documento gerado em: Março 2026 — Fields Online HML · Diagnóstico Técnico Fase 1*