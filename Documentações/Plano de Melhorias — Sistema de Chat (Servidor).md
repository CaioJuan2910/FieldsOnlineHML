# 🗂️ Plano de Melhorias — Sistema de Chat (Servidor)
**Projeto:** Fields Online | **Engine:** VXA-OS / RPG Maker VX Ace | **Linguagem:** Ruby
**Autor:** Caio Juan De Lima Silva | **Data:** 2026-04-03 | **Versão do Plano:** 1.0.0

---

## 📌 Visão Geral

Este documento descreve o plano completo de melhorias para o sistema de Chat no lado do **Servidor** do projeto Fields Online. As melhorias estão organizadas em **4 fases sequenciais**, seguindo a abordagem incremental e iterativa preferida: cada fase entrega valor independente e pode ser testada antes de avançar para a próxima.

> **Filosofia:** Simples primeiro → Funcional → Seguro → Extensível

---

## 📁 Arquivos Envolvidos

| Arquivo | Responsabilidade |
|---|---|
| `Server/Scripts/Network/send_data.rb` | Montagem e envio de pacotes de chat para os clientes |
| `Server/Scripts/Network/handle_data.rb` | Recebimento, validação e roteamento de mensagens de chat |

---

## 🗺️ Mapa Geral das Fases

```
FASE 1 → send_data.rb       → Refatoração e Performance (helper build_chat_packet)
FASE 2 → handle_data.rb     → Validação, Segurança e Antispam
FASE 3 → handle_data.rb     → Logs completos com VS_Logger
FASE 4 → send_data.rb       → Novos métodos de broadcast e padronização
```

---

## 🔧 FASE 1 — `send_data.rb` — Refatoração e Performance

### 🎯 Objetivo
Eliminar duplicação de código nos métodos de envio de chat criando um **helper privado centralizado** para montagem do pacote `CHAT_MSG`.

---

### 🔴 Problema Atual

Cada método de chat (`map_chat_message`, `global_chat_message`, `party_chat_message`, etc.) cria seu próprio `Buffer_Writer` e monta o pacote `CHAT_MSG` de forma **idêntica e repetida**. Isso significa:

- **Código duplicado** em 6+ métodos
- **Manutenção difícil:** qualquer mudança no formato do pacote exige editar todos os métodos
- **Performance:** alocações desnecessárias de objetos sem necessidade
- **Risco de inconsistência:** um método pode ser atualizado e outro esquecido

#### Exemplo do padrão repetido atual (pseudocódigo):
```ruby
# Repetido em TODOS os métodos de chat:
buffer = Buffer_Writer.new
buffer.write_short(PACKET::CHAT_MSG)
buffer.write_byte(color_id)
buffer.write_string(message)
send_data(client, buffer)
```

---

### ✅ Solução: Helper Privado `build_chat_packet`

Criar um único método privado que centraliza a criação do buffer e é reutilizado por todos os métodos de chat.

#### Assinatura do método:
```ruby
# ─────────────────────────────────────────────────────────────────────────────
# build_chat_packet(color_id, message)
# Monta e retorna um Buffer_Writer com o pacote CHAT_MSG pronto para envio.
# Parâmetros:
#   color_id [Integer] → ID da cor do canal (definido em Configs ou enum)
#   message  [String]  → Texto da mensagem já formatado
# Retorno:
#   Buffer_Writer → buffer pronto para ser passado a send_data()
# ─────────────────────────────────────────────────────────────────────────────
def build_chat_packet(color_id, message)
  buffer = Buffer_Writer.new
  buffer.write_short(PACKET::CHAT_MSG)
  buffer.write_byte(color_id)
  buffer.write_string(message)
  buffer
end
private :build_chat_packet
```

---

### 📋 Métodos Afetados e Refatoração

| # | Método | Canal | Destinatário | Color ID |
|---|---|---|---|---|
| 1 | `map_chat_message` | MAP | Jogadores no mesmo mapa | `Configs::COLOR_MAP` |
| 2 | `global_chat_message` | GLOBAL | Todos os jogadores online | `Configs::COLOR_GLOBAL` |
| 3 | `party_chat_message` | PARTY | Membros do grupo do jogador | `Configs::COLOR_PARTY` |
| 4 | `guild_chat_message` | GUILD | Membros da guilda do jogador | `Configs::COLOR_GUILD` |
| 5 | `private_chat_message` | PRIVATE | Remetente + destinatário | `Configs::COLOR_PRIVATE` |
| 6 | `player_chat_message` | — | Jogador específico (direto) | Variável |
| 7 | `send_whos_online` | GLOBAL | Jogador específico | `Configs::COLOR_GLOBAL` |

#### Exemplo de refatoração — `map_chat_message` (antes → depois):

**Antes:**
```ruby
def map_chat_message(client, message)
  buffer = Buffer_Writer.new
  buffer.write_short(PACKET::CHAT_MSG)
  buffer.write_byte(Configs::COLOR_MAP)
  buffer.write_string(message)
  $clients.each do |other|
    next unless other&.ingame? && other.map_id == client.map_id
    send_data(other, buffer)
  end
end
```

**Depois:**
```ruby
def map_chat_message(client, message)
  # Monta o pacote uma única vez e envia para todos no mesmo mapa
  buffer = build_chat_packet(Configs::COLOR_MAP, message)
  $clients.each do |other|
    next unless other&.ingame? && other.map_id == client.map_id
    send_data(other, buffer)
  end
end
```

---

### 🧪 Critério de Conclusão da Fase 1

- [ ] Método `build_chat_packet` criado e marcado como `private`
- [ ] Todos os 7 métodos de chat refatorados para usar o helper
- [ ] Nenhum método de chat cria `Buffer_Writer` diretamente
- [ ] Testado: mensagens MAP, GLOBAL, PARTY, GUILD e PRIVATE chegam corretamente ao cliente
- [ ] Código revisado e comentado

---

## 🔧 FASE 2 — `handle_data.rb` → `handle_chat_message` — Validação e Segurança

### 🎯 Objetivo
Tornar o método `handle_chat_message` robusto contra entradas maliciosas, flood, spam e pacotes malformados. Implementar validações em camadas, do mais simples ao mais complexo.

---

### 📐 Estrutura de Validação em Camadas

```
Recebe pacote
     │
     ▼
[1] Validação de canal (talk_type válido?)
     │
     ▼
[2] Validação de tamanho da mensagem
     │
     ▼
[3] Sanitização de caracteres
     │
     ▼
[4] Verificação de mute
     │
     ▼
[5] Antispam por canal
     │
     ▼
[6] Validação específica do canal (ex: nome no privado)
     │
     ▼
[7] Processamento e envio
```

---

### 🛡️ Melhorias de Validação — Detalhamento

#### Melhoria 1 — Validação de Canal (`talk_type`)

**Problema:** Se um cliente enviar um `talk_type` fora dos valores válidos (por hacking ou pacote corrompido), o servidor pode se comportar de forma inesperada.

**Solução:**
```ruby
# Constante com canais válidos (definir em Configs ou no próprio handle_data)
VALID_TALK_TYPES = [
  Configs::TALK_MAP,
  Configs::TALK_GLOBAL,
  Configs::TALK_PARTY,
  Configs::TALK_GUILD,
  Configs::TALK_PRIVATE
].freeze

# Validação no início do método:
unless VALID_TALK_TYPES.include?(talk_type)
  @log.log_warning("Canal inválido recebido: #{talk_type} | Cliente: #{client.name}")
  return
end
```

**Configuração em `Configs`:**
```ruby
# ── Chat: Canais válidos ──────────────────────────────────────────────────────
TALK_MAP     = 0  # Chat local do mapa
TALK_GLOBAL  = 1  # Chat global (todos os jogadores)
TALK_PARTY   = 2  # Chat de grupo
TALK_GUILD   = 3  # Chat de guilda
TALK_PRIVATE = 4  # Mensagem privada
```

---

#### Melhoria 2 — Tamanho Máximo de Mensagem

**Problema:** Mensagens muito longas podem causar flood, consumir banda e sobrecarregar o buffer.

**Solução:**
```ruby
# Em Configs:
MAX_CHAT_MESSAGE_LENGTH = 200  # Máximo de caracteres por mensagem

# Em handle_chat_message:
if message.size > Configs::MAX_CHAT_MESSAGE_LENGTH
  send_server_message(client, Vocab::CHAT_MSG_TOO_LONG, Configs::COLOR_ERROR)
  @log.log_warning("Mensagem muito longa (#{message.size} chars) | #{client.name}")
  return
end
```

**Configuração em `Configs`:**
```ruby
# ── Chat: Limites de mensagem ─────────────────────────────────────────────────
MAX_CHAT_MESSAGE_LENGTH = 200   # Máximo de caracteres por mensagem
MIN_CHAT_MESSAGE_LENGTH = 1     # Mínimo (evita mensagens vazias)
```

---

#### Melhoria 3 — Sanitização de Caracteres

**Problema:** Caracteres de controle (`\x00`, `\r`, `\n`, `\t`, etc.) podem quebrar o protocolo, causar injeção de dados no log ou comportamento inesperado no cliente.

**Solução:**
```ruby
# ─────────────────────────────────────────────────────────────────────────────
# sanitize_chat_message(message)
# Remove caracteres de controle e nulos da mensagem.
# Retorna a mensagem limpa ou nil se ficar vazia após sanitização.
# ─────────────────────────────────────────────────────────────────────────────
def sanitize_chat_message(message)
  # Remove caracteres de controle (0x00-0x1F) exceto espaço (0x20)
  clean = message.gsub(/[\x00-\x1F\x7F]/, '').strip
  clean.empty? ? nil : clean
end
private :sanitize_chat_message

# Uso em handle_chat_message:
message = sanitize_chat_message(message)
if message.nil?
  @log.log_warning("Mensagem vazia após sanitização | #{client.name}")
  return
end
```

---

#### Melhoria 4 — Antispam por Canal

**Problema:** O canal GLOBAL já possui `global_antispam_time`, mas MAP, PARTY e GUILD não têm proteção individual. Um jogador pode fazer flood nesses canais sem restrição.

**Solução — Antispam genérico por canal:**

```ruby
# Em Configs:
# ── Chat: Antispam ────────────────────────────────────────────────────────────
ANTISPAM_MAP_TIME     = 1.0   # Segundos entre mensagens no canal MAP
ANTISPAM_PARTY_TIME   = 0.5   # Segundos entre mensagens no canal PARTY
ANTISPAM_GUILD_TIME   = 0.5   # Segundos entre mensagens no canal GUILD
ANTISPAM_GLOBAL_TIME  = 3.0   # Segundos entre mensagens no canal GLOBAL (já existente)
ANTISPAM_PRIVATE_TIME = 0.5   # Segundos entre mensagens privadas
```

```ruby
# Mapa de tempo de antispam por canal:
ANTISPAM_TIMES = {
  Configs::TALK_MAP     => Configs::ANTISPAM_MAP_TIME,
  Configs::TALK_GLOBAL  => Configs::ANTISPAM_GLOBAL_TIME,
  Configs::TALK_PARTY   => Configs::ANTISPAM_PARTY_TIME,
  Configs::TALK_GUILD   => Configs::ANTISPAM_GUILD_TIME,
  Configs::TALK_PRIVATE => Configs::ANTISPAM_PRIVATE_TIME
}.freeze

# Verificação no handle_chat_message:
antispam_key = :"antispam_#{talk_type}_time"
if client.respond_to?(antispam_key) && client.send(antispam_key) > Time.now
  send_server_message(client, Vocab::CHAT_ANTISPAM, Configs::COLOR_ERROR)
  @log.log_warning("Antispam ativado [canal #{talk_type}] | #{client.name}")
  return
end
# Atualiza o timer após envio bem-sucedido
client.send(:"#{antispam_key}=", Time.now + ANTISPAM_TIMES[talk_type])
```

---

#### Melhoria 5 — Validação do Nome no Chat Privado

**Problema:** O nome do destinatário recebido no pacote privado não é validado antes de buscar o jogador, podendo causar buscas desnecessárias ou comportamento inesperado.

**Solução:**
```ruby
# Em Configs:
MAX_PLAYER_NAME_LENGTH = 20  # Tamanho máximo do nome de jogador
MIN_PLAYER_NAME_LENGTH = 3   # Tamanho mínimo do nome de jogador

# Em handle_chat_message (canal PRIVATE):
if talk_type == Configs::TALK_PRIVATE
  if target_name.size < Configs::MIN_PLAYER_NAME_LENGTH ||
     target_name.size > Configs::MAX_PLAYER_NAME_LENGTH
    send_server_message(client, Vocab::CHAT_INVALID_NAME, Configs::COLOR_ERROR)
    return
  end

  target = find_client_by_name(target_name)
  if target.nil?
    send_server_message(client, Vocab::CHAT_PLAYER_NOT_FOUND % target_name, Configs::COLOR_ERROR)
    @log.log_chat(client, message, 'PRIVATE', "→ #{target_name} [NÃO ENCONTRADO]")
    return
  end
end
```

---

### ⚙️ Melhorias de Funcionalidade

#### Melhoria 6 — Comando `/me` (Ação Narrativa)

**Descrição:** Permite que o jogador envie uma ação narrativa no chat, similar ao `/me` do IRC e MMORPGs clássicos.

**Exemplo de uso:** O jogador digita `/me acena para todos.`
**Resultado no chat:** `* Caio acena para todos.`

```ruby
# Em Configs:
CHAT_ME_PREFIX    = '/me '           # Prefixo do comando /me
CHAT_ME_FORMAT    = '* %s %s'        # Formato: "* NomeJogador ação"
COLOR_ME_ACTION   = 8                # ID de cor para ações /me

# Em handle_chat_message, antes do roteamento por canal:
if message.start_with?(Configs::CHAT_ME_PREFIX)
  action_text = message[Configs::CHAT_ME_PREFIX.size..]
  message = Configs::CHAT_ME_FORMAT % [client.name, action_text]
  # Força canal MAP para ações /me (ação é sempre local)
  talk_type = Configs::TALK_MAP
  color_override = Configs::COLOR_ME_ACTION
end
```

---

#### Melhoria 7 — Comando `/clear` no Servidor

**Descrição:** O comando `/clear` é processado no cliente (limpa a janela de chat local). No servidor, se recebido, deve ser **ignorado silenciosamente** e registrado em log para auditoria.

```ruby
# Em handle_chat_message:
if message.strip == '/clear'
  # Comando client-side recebido no servidor — ignorar e registrar
  @log.log_info("Comando /clear recebido do servidor | #{client.name} [ignorado]")
  return
end
```

---

#### Melhoria 8 — Cor Diferenciada para Admin (Documentação e Padronização)

**Descrição:** O sistema já usa `15 + client.group` para calcular a cor de admins. Documentar e padronizar esse comportamento.

```ruby
# Em Configs:
# ── Chat: Cores por grupo ─────────────────────────────────────────────────────
# A cor final de um admin é calculada como: COLOR_BASE_ADMIN + client.group
# Grupos: 0 = Jogador, 1 = GM, 2 = Admin, 3 = Dev
COLOR_BASE_ADMIN  = 15   # Offset base para cores de staff
COLOR_PLAYER      = 0    # Cor padrão de jogador

# Em handle_chat_message (documentado):
# Calcula a cor com base no grupo do jogador
# Jogadores normais (group 0) usam COLOR_PLAYER
# Staff usa COLOR_BASE_ADMIN + group para cor diferenciada
color_id = client.group > 0 ? Configs::COLOR_BASE_ADMIN + client.group : channel_color
```

---

### 🧪 Critério de Conclusão da Fase 2

- [ ] Validação de `talk_type` implementada com lista de canais válidos
- [ ] Validação de tamanho mínimo e máximo de mensagem
- [ ] Sanitização de caracteres de controle funcionando
- [ ] Antispam implementado para canais MAP, PARTY e GUILD
- [ ] Validação de nome do destinatário no chat privado
- [ ] Comando `/me` funcionando no canal MAP
- [ ] Comando `/clear` ignorado silenciosamente no servidor
- [ ] Cores de admin documentadas e padronizadas
- [ ] Testado: tentativas de flood são bloqueadas corretamente
- [ ] Testado: mensagens com caracteres especiais são sanitizadas

---

## 🔧 FASE 3 — `handle_data.rb` — Logs Completos com VS_Logger

### 🎯 Objetivo
Garantir **rastreabilidade completa** de todas as mensagens de chat e tentativas bloqueadas, padronizando o uso do `VS_Logger` em todos os fluxos do sistema de chat.

---

### 📊 Mapa de Logs por Evento

| Evento | Nível de Log | Informações Registradas |
|---|---|---|
| Mensagem MAP enviada | `log_chat` | cliente, mensagem, canal `'MAP'`, mapa_id |
| Mensagem GLOBAL enviada | `log_chat` | cliente, mensagem, canal `'GLOBAL'` |
| Mensagem PARTY enviada | `log_chat` | cliente, mensagem, canal `'PARTY'`, party_id |
| Mensagem GUILD enviada | `log_chat` | cliente, mensagem, canal `'GUILD'`, guild_name |
| Mensagem PRIVATE enviada | `log_chat` | cliente, mensagem, canal `'PRIVATE'`, destinatário |
| Mensagem PRIVATE — destinatário não encontrado | `log_chat` | cliente, mensagem, canal `'PRIVATE'`, `[NÃO ENCONTRADO]` |
| Bloqueio por antispam | `log_warning` | cliente, canal, tempo restante |
| Bloqueio por mute | `log_warning` | cliente, duração do mute restante |
| Canal inválido recebido | `log_warning` | cliente, valor do `talk_type` inválido |
| Mensagem muito longa | `log_warning` | cliente, tamanho recebido vs. máximo |
| Mensagem vazia após sanitização | `log_warning` | cliente |
| Comando `/clear` recebido | `log_info` | cliente |
| Comando `/me` usado | `log_chat` | cliente, ação, canal `'MAP'` |

---

### 🔧 Padronização do Formato de Log

#### Formato atual (inconsistente):
```ruby
@log.log_chat(client, message, 'MAP')          # Alguns métodos
@log.log_chat(client, message)                  # Outros sem canal
# Alguns fluxos sem log algum
```

#### Formato padronizado proposto:
```ruby
# ─────────────────────────────────────────────────────────────────────────────
# Padrão de log para chat:
# log_chat(client, message, canal, contexto_extra = '')
#
# Exemplos:
@log.log_chat(client, message, 'MAP',     "mapa:#{client.map_id}")
@log.log_chat(client, message, 'GLOBAL',  '')
@log.log_chat(client, message, 'PARTY',   "party:#{client.party_id}")
@log.log_chat(client, message, 'GUILD',   "guild:#{client.guild_name}")
@log.log_chat(client, message, 'PRIVATE', "→ #{target.name}")
@log.log_chat(client, message, 'ME',      "mapa:#{client.map_id}")
# ─────────────────────────────────────────────────────────────────────────────
```

---

### 🔧 Implementação dos Logs de Bloqueio

```ruby
# ── Log de bloqueio por antispam ──────────────────────────────────────────────
@log.log_warning(
  "[CHAT][ANTISPAM] #{client.name} | Canal: #{canal_name} | " \
  "Aguarde #{(client.antispam_time - Time.now).round(1)}s"
)

# ── Log de bloqueio por mute ──────────────────────────────────────────────────
@log.log_warning(
  "[CHAT][MUTE] #{client.name} | Tempo restante: #{client.mute_time}s"
)

# ── Log de canal inválido ─────────────────────────────────────────────────────
@log.log_warning(
  "[CHAT][INVALID_CHANNEL] #{client.name} | talk_type recebido: #{talk_type}"
)

# ── Log de mensagem muito longa ───────────────────────────────────────────────
@log.log_warning(
  "[CHAT][MSG_TOO_LONG] #{client.name} | " \
  "Tamanho: #{message.size}/#{Configs::MAX_CHAT_MESSAGE_LENGTH}"
)
```

---

### 🔧 Helper Privado `canal_name_for_log`

Para evitar repetição na conversão de `talk_type` para string legível nos logs:

```ruby
# ─────────────────────────────────────────────────────────────────────────────
# canal_name_for_log(talk_type)
# Retorna o nome legível do canal para uso em logs.
# ─────────────────────────────────────────────────────────────────────────────
CANAL_LOG_NAMES = {
  Configs::TALK_MAP     => 'MAP',
  Configs::TALK_GLOBAL  => 'GLOBAL',
  Configs::TALK_PARTY   => 'PARTY',
  Configs::TALK_GUILD   => 'GUILD',
  Configs::TALK_PRIVATE => 'PRIVATE'
}.freeze

def canal_name_for_log(talk_type)
  CANAL_LOG_NAMES[talk_type] || "UNKNOWN(#{talk_type})"
end
private :canal_name_for_log
```

---

### 🧪 Critério de Conclusão da Fase 3

- [ ] Todos os canais de chat têm log de envio bem-sucedido
- [ ] Todos os bloqueios (antispam, mute, canal inválido, msg longa) têm log de warning
- [ ] Chat privado registra nome do destinatário e se foi encontrado
- [ ] Helper `canal_name_for_log` implementado e usado em todos os logs
- [ ] Formato de log padronizado e consistente em todos os fluxos
- [ ] Testado: logs aparecem corretamente no arquivo de log do servidor

---

## 🔧 FASE 4 — `send_data.rb` — Novos Métodos e Padronização

### 🎯 Objetivo
Adicionar métodos de broadcast do sistema/servidor e padronizar nomenclatura para facilitar uso em outros módulos do servidor.

---

### 📢 Novo Método: `broadcast_server_message`

**Descrição:** Envia uma mensagem do sistema para **todos os jogadores online**. Útil para avisos de manutenção, eventos globais, anúncios do servidor, etc.

```ruby
# ─────────────────────────────────────────────────────────────────────────────
# broadcast_server_message(message, color_id)
# Envia uma mensagem do sistema para todos os jogadores online.
# Parâmetros:
#   message  [String]  → Texto do aviso do servidor
#   color_id [Integer] → ID da cor (padrão: Configs::COLOR_SERVER)
# Uso:
#   broadcast_server_message("Manutenção em 5 minutos!", Configs::COLOR_SERVER)
# ─────────────────────────────────────────────────────────────────────────────
def broadcast_server_message(message, color_id = Configs::COLOR_SERVER)
  buffer = build_chat_packet(color_id, "[Sistema] #{message}")
  $clients.each do |client|
    next unless client&.ingame?
    send_data(client, buffer)
  end
  @log.log_info("[CHAT][BROADCAST] #{message}")
end
```

---

### 📩 Padronização: `send_server_message`

**Descrição:** Renomear/padronizar o método que envia mensagem do sistema para um **jogador específico**. O método `player_chat_message` já faz isso, mas o nome não é semântico para mensagens do sistema.

```ruby
# ─────────────────────────────────────────────────────────────────────────────
# send_server_message(client, message, color_id)
# Envia uma mensagem do sistema para um jogador específico.
# Parâmetros:
#   client   [Client]  → Instância do cliente destinatário
#   message  [String]  → Texto da mensagem do sistema
#   color_id [Integer] → ID da cor (padrão: Configs::COLOR_SERVER)
# Uso:
#   send_server_message(client, "Você foi silenciado por 5 minutos.")
#   send_server_message(client, "Mensagem muito longa!", Configs::COLOR_ERROR)
# ─────────────────────────────────────────────────────────────────────────────
def send_server_message(client, message, color_id = Configs::COLOR_SERVER)
  buffer = build_chat_packet(color_id, "[Sistema] #{message}")
  send_data(client, buffer)
end
```

---

### 🎨 Novas Constantes de Cor em `Configs`

```ruby
# ── Chat: Cores do sistema ────────────────────────────────────────────────────
COLOR_SERVER  = 20   # Cor para mensagens do sistema/servidor
COLOR_ERROR   = 21   # Cor para mensagens de erro (spam, mute, etc.)
COLOR_SUCCESS = 22   # Cor para mensagens de sucesso
COLOR_INFO    = 23   # Cor para mensagens informativas
```

---

### 📋 Tabela Completa de Métodos de Chat em `send_data.rb` (Estado Final)

| Método | Tipo | Destinatário | Descrição |
|---|---|---|---|
| `build_chat_packet` | `private` | — | Helper: monta buffer CHAT_MSG |
| `canal_name_for_log` | `private` | — | Helper: nome do canal para log |
| `map_chat_message` | `public` | Jogadores no mapa | Chat local do mapa |
| `global_chat_message` | `public` | Todos online | Chat global |
| `party_chat_message` | `public` | Membros do grupo | Chat de grupo |
| `guild_chat_message` | `public` | Membros da guilda | Chat de guilda |
| `private_chat_message` | `public` | Remetente + alvo | Mensagem privada |
| `player_chat_message` | `public` | Jogador específico | Envio direto (legado) |
| `send_whos_online` | `public` | Jogador específico | Lista de online |
| `send_server_message` | `public` | Jogador específico | Mensagem do sistema |
| `broadcast_server_message` | `public` | Todos online | Broadcast do sistema |

---

### 🧪 Critério de Conclusão da Fase 4

- [ ] `broadcast_server_message` implementado e testado
- [ ] `send_server_message` implementado com nome padronizado
- [ ] Constantes de cor do sistema adicionadas em `Configs`
- [ ] `player_chat_message` mantido como alias ou deprecado com comentário
- [ ] Testado: broadcast chega para todos os jogadores online
- [ ] Testado: mensagem de sistema chega para jogador específico
- [ ] Documentação dos métodos atualizada

---

## 📋 Ordem de Execução — Resumo Completo

| Etapa | Fase | Arquivo | Tarefa | Prioridade |
|---|---|---|---|---|
| **1.1** | FASE 1 | `send_data.rb` | Criar helper privado `build_chat_packet` | 🔴 Alta |
| **1.2** | FASE 1 | `send_data.rb` | Refatorar `map_chat_message` | 🔴 Alta |
| **1.3** | FASE 1 | `send_data.rb` | Refatorar `global_chat_message` | 🔴 Alta |
| **1.4** | FASE 1 | `send_data.rb` | Refatorar `party_chat_message` | 🔴 Alta |
| **1.5** | FASE 1 | `send_data.rb` | Refatorar `guild_chat_message` | 🔴 Alta |
| **1.6** | FASE 1 | `send_data.rb` | Refatorar `private_chat_message` | 🔴 Alta |
| **1.7** | FASE 1 | `send_data.rb` | Refatorar `player_chat_message` e `send_whos_online` | 🔴 Alta |
| **2.1** | FASE 2 | `handle_data.rb` | Validação de `talk_type` (canal válido) | 🔴 Alta |
| **2.2** | FASE 2 | `handle_data.rb` | Validação de tamanho de mensagem | 🔴 Alta |
| **2.3** | FASE 2 | `handle_data.rb` | Sanitização de caracteres de controle | 🔴 Alta |
| **2.4** | FASE 2 | `handle_data.rb` | Antispam para canais MAP, PARTY e GUILD | 🟡 Média |
| **2.5** | FASE 2 | `handle_data.rb` | Validação de nome no chat privado | 🟡 Média |
| **2.6** | FASE 2 | `handle_data.rb` | Comando `/me` | 🟢 Baixa |
| **2.7** | FASE 2 | `handle_data.rb` | Comando `/clear` ignorado no servidor | 🟢 Baixa |
| **2.8** | FASE 2 | `handle_data.rb` | Documentar e padronizar cores de admin | 🟢 Baixa |
| **3.1** | FASE 3 | `handle_data.rb` | Helper `canal_name_for_log` | 🟡 Média |
| **3.2** | FASE 3 | `handle_data.rb` | Log padronizado para todos os canais | 🟡 Média |
| **3.3** | FASE 3 | `handle_data.rb` | Log de bloqueios (antispam, mute, canal inválido) | 🟡 Média |
| **3.4** | FASE 3 | `handle_data.rb` | Log de chat privado com destinatário | 🟡 Média |
| **4.1** | FASE 4 | `send_data.rb` | Constantes de cor do sistema em `Configs` | 🟡 Média |
| **4.2** | FASE 4 | `send_data.rb` | Implementar `send_server_message` | 🟡 Média |
| **4.3** | FASE 4 | `send_data.rb` | Implementar `broadcast_server_message` | 🟢 Baixa |
| **4.4** | FASE 4 | `send_data.rb` | Deprecar/alias `player_chat_message` | 🟢 Baixa |

---

## 🔗 Dependências Entre Fases

```
FASE 1 (build_chat_packet)
    └── É pré-requisito para FASE 4 (send_server_message usa o helper)

FASE 2 (validações)
    └── Depende de constantes em Configs (MAX_CHAT_MESSAGE_LENGTH, VALID_TALK_TYPES)
    └── Usa send_server_message da FASE 4 para feedback ao jogador
        └── Pode ser implementado com player_chat_message temporariamente

FASE 3 (logs)
    └── Depende de FASE 2 (os logs de bloqueio são adicionados junto com as validações)
    └── Helper canal_name_for_log pode ser criado independentemente

FASE 4 (novos métodos)
    └── Depende de FASE 1 (usa build_chat_packet)
    └── Depende de constantes de cor em Configs
```

---

## ✅ Resultado Esperado — Estado Final do Sistema

### 🚀 Performance
- Buffer `CHAT_MSG` montado em **um único lugar** (`build_chat_packet`)
- Código **DRY** — sem duplicação nos métodos de chat
- Menos alocações desnecessárias de objetos `Buffer_Writer`

### 🛡️ Segurança
- Mensagens sanitizadas (sem caracteres de controle)
- Canal validado antes de qualquer processamento
- Antispam ativo em **todos os canais** (MAP, GLOBAL, PARTY, GUILD, PRIVATE)
- Nome do destinatário validado antes de busca no chat privado
- Tamanho de mensagem limitado e verificado

### 📋 Logs e Rastreabilidade
- **100% dos fluxos** de chat têm log registrado
- Tentativas bloqueadas (spam, mute, canal inválido) são registradas como `warning`
- Chat privado registra remetente, destinatário e status de entrega
- Formato de log **padronizado e consistente** em todos os canais

### 🔧 Manutenibilidade
- Código **modular** com helpers privados bem definidos
- **Comentários** em todos os métodos (parâmetros, retorno, uso)
- Constantes centralizadas em `Configs` para fácil ajuste
- Nomenclatura **semântica** e consistente (`send_server_message` vs `player_chat_message`)
- Fácil extensão para novos canais ou comandos de chat

---

## 📝 Notas de Implementação

> **⚠️ Atenção ao implementar FASE 2 (antispam por canal):**
> Os timers de antispam precisam de atributos no objeto `client`. Verificar se a classe `Client` suporta atributos dinâmicos ou se é necessário adicionar `attr_accessor` para cada canal.

> **⚠️ Atenção ao implementar `/me`:**
> O comando `/me` força o canal MAP. Garantir que o cliente não consiga usar `/me` em canais GLOBAL ou GUILD para evitar abuso.

> **💡 Sugestão futura (fora do escopo deste plano):**
> Implementar sistema de histórico de chat no servidor para moderação (últimas N mensagens por jogador armazenadas em memória).

> **💡 Sugestão futura (fora do escopo deste plano):**
> Implementar sistema de palavras proibidas (filtro de palavrões) com lista configurável em `Configs`.

---

*Documento gerado em: 2026-04-03 | Fields Online — VXA-OS Server Chat System*