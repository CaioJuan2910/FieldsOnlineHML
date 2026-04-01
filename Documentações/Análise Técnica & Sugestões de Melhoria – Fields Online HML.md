# Análise Técnica & Sugestões de Melhoria – Fields Online HML

> **Projeto:** Fields Online HML — MMORPG desenvolvido com RPG Maker VX Ace + VXA-OS
> **Repositório:** [CaioJuan2910/FieldsOnlineHML](https://github.com/CaioJuan2910/FieldsOnlineHML)
> **Data da Análise:** 30 de março de 2026
> **Analista:** Revisão técnica baseada nos scripts Ruby do projeto
> **Referências de Design:** Tibia Online · MU Online · Ragnarok Online · Saga Diablo · World of Warcraft

---

## 📋 Índice

1. [Visão Geral da Arquitetura](#-visão-geral-da-arquitetura)
2. [Pontos Positivos Identificados](#-pontos-positivos-identificados)
3. [Problemas & Sugestões — \[VS\] Configs.rb](#-problemas--sugestões---vs-configsrb)
4. [Problemas & Sugestões — \[VS\] Sprite_HUD.rb](#-problemas--sugestões---vs-sprite_hudrb)
5. [Problemas & Sugestões — Server/Combat/game_battle.rb](#-problemas--sugestões---servercombatgame_battlerb)
6. [Problemas & Sugestões — Server/Network/network.rb](#-problemas--sugestões---servernetworknetworkrb)
7. [Problemas & Sugestões — \[VS\] Mouse.rb](#-problemas--sugestões---vs-mouserb)
8. [Problemas & Sugestões — \[VS\] Sprite_Drop.rb](#-problemas--sugestões---vs-sprite_droprb)
9. [Sistemas Ausentes Inspirados nas Referências do MMO](#-sistemas-ausentes-inspirados-nas-referências-do-mmo)
10. [Roadmap Sugerido (Incremental)](#️-roadmap-sugerido-incremental)

---

## 📁 Visão Geral da Arquitetura

### Cliente — `/Client/Scripts`

A estrutura do cliente é dividida em dois grupos principais de scripts, com responsabilidades bem delimitadas:

| Prefixo | Origem | Responsabilidade |
|---|---|---|
| `[RM]` | Base RPG Maker VX Ace | Engine base com modificações pontuais |
| `[VS]` | VXA-OS / Valentine System | Lógica MMO: HUD, Drop, Minimap, Network, Input, Audio, Scenes |

**Destaques da organização do cliente:**

- Separação de camadas de UI e lógica razoavelmente bem feita
- Scripts de interface (`Sprite_HUD`, `Sprite_Drop`, `Sprite_Minimap`) isolados dos scripts de rede
- Sistema de input com módulo `Mouse.rb` dedicado
- Cenas (`Scene_Map`, `Scene_Login`, `Scene_Char`) com responsabilidades claras

---

### Servidor — `/Server/Scripts`

A estrutura do servidor é organizada em pastas temáticas com separação de domínios:

```
Server/
├── Combat/         → game_battle.rb, game_projectile.rb
├── Network/        → network.rb, packets.rb, connection.rb
├── Guild/          → guild.rb, guild_manager.rb
├── Trade/          → trade.rb
├── Party/          → party.rb
├── Map/            → game_map.rb, map_manager.rb
├── Client/         → game_client.rb, game_player.rb
├── Database/       → database.rb, queries.rb
└── Kernel/         → main.rb, configs.rb, utils.rb
```

**Tecnologias utilizadas no servidor:**

- **EventMachine** — I/O assíncrono não-bloqueante para conexões TCP
- **Sequel** — ORM para acesso ao banco de dados relacional
- **Loop de update** com timer de `80ms` (`0.08s`) para ciclos de atualização e save periódico
- Tratamento de sinais `INT` e `TERM` para shutdown gracioso com salvamento de dados

---

## ✅ Pontos Positivos Identificados

O projeto demonstra maturidade técnica em diversas áreas. Abaixo os pontos que merecem destaque:

### 🏗️ Arquitetura e Organização

- ✅ Separação clara entre lógica de servidor e cliente, sem acoplamento direto
- ✅ Estrutura de pastas do servidor bem definida e semântica
- ✅ Sistema de IDs reutilizáveis para clientes e parties (`*_ids_available`), evitando vazamento de memória
- ✅ Comentários em português, facilitando manutenção local pela equipe

### ⚔️ Sistema de Combate

- ✅ Sistema de dano com **variância**, **crítico**, **drain**, **miss** e **evasão** implementados
- ✅ Suporte a armas e habilidades de **longo alcance com projéteis** (`game_projectile.rb`)
- ✅ Sistema de **debuff/buff** seguindo a tabela `ITEM_EFFECT_TABLE`
- ✅ Cálculo de `luk_effect_rate` para influência da sorte nos estados

### 🖥️ Interface e Experiência do Jogador

- ✅ `Sprite_Drop` com **cor diferenciada para key items** e tooltip de nome ao passar o mouse
- ✅ `Mouse.rb` com **correção de offset de display** para tiles acima de 1000px de largura
- ✅ HUD com barra de HP, MP e EXP com suporte a drag (arrastar pela tela)

### 🔧 Infraestrutura do Servidor

- ✅ Tratamento de sinal `INT` e `TERM` para **salvar dados antes de fechar** o servidor
- ✅ Uso de **EventMachine** para I/O assíncrono, adequado para MMO
- ✅ Loop de servidor com timer configurável para update e save periódico

---

## 🔴 Problemas & Sugestões — `[VS] Configs.rb`

### Problemas Identificados

| # | Severidade | Problema |
|---|---|---|
| 1 | 🔴 Crítico | `HOST = '127.0.0.1'` hardcoded — para produção precisa ser dinâmico ou via `.ini` externo |
| 2 | 🟡 Médio | `SHOP_WEBSITE = 'www.aldeiarpg.com'` — referência a site de terceiro deixada no código |
| 3 | 🟡 Médio | `FORBIDDEN_NAMES` incompleto — falta validação de regex para variações como `adm1n`, `@dmin` |
| 4 | 🟡 Médio | `CHAT_EMOJIS` comentado — funcionalidade inativa sem documentação do motivo |
| 5 | 🟢 Baixo | Constantes de cor (`NORMAL_COLOR`, `GLOBAL_COLOR`...) sem tabela de referência visual documentada |
| 6 | 🟡 Médio | `MAX_MAP_DROPS = 20` — valor baixo para um MMORPG inspirado em Diablo/MU onde drops são abundantes |
| 7 | 🔴 Crítico | Ausência de constantes para Minimap, penalidade de morte e multiplicador de crítico |

### Sugestões de Melhoria

```ruby
#==============================================================================
# ** [VS] Configs — Sugestões de Melhoria
#==============================================================================
# Separar configurações sensíveis para um arquivo externo configs_server.ini
# ou carregar via variável de ambiente para ambientes de produção.
#------------------------------------------------------------------------------

module Configs

  #----------------------------------------------------------------------------
  # Rede — usar variável de ambiente ou arquivo externo em produção
  #----------------------------------------------------------------------------
  HOST = ENV['GAME_HOST'] || '127.0.0.1'
  PORT = ENV['GAME_PORT']&.to_i || 2633

  #----------------------------------------------------------------------------
  # Drops — aumentar limite para MMOs com drop abundante (Diablo/MU style)
  #----------------------------------------------------------------------------
  MAX_MAP_DROPS = 50          # Era 20 — aumentado para comportar mais drops

  #----------------------------------------------------------------------------
  # Penalidade de morte — inspirado em Tibia e Diablo
  #----------------------------------------------------------------------------
  DEATH_EXP_LOSS    = 10      # % de EXP perdida ao morrer (estilo Tibia)
  DEATH_ITEM_DROP   = false   # Drop de item ao morrer (estilo Diablo/Tibia)
  DEATH_BLESS_ITEM  = 0       # ID do item que previne penalidade (0 = desativado)

  #----------------------------------------------------------------------------
  # Combate — evitar magic numbers espalhados pelo game_battle.rb
  #----------------------------------------------------------------------------
  CRITICAL_MULTIPLIER = 3.0   # Multiplicador de dano crítico (era hardcoded x3)
  CRITICAL_ANIMATION  = 1     # ID da animação de crítico

  #----------------------------------------------------------------------------
  # Minimap — configurações centralizadas para Sprite_Minimap
  #----------------------------------------------------------------------------
  MINIMAP_SIZE       = 120    # Tamanho do minimap quadrado em pixels
  MINIMAP_SCALE      = 2      # Escala dos tiles no minimap
  MINIMAP_POSITION_X = 10     # Posição X na tela
  MINIMAP_POSITION_Y = 10     # Posição Y na tela
  MINIMAP_OPACITY    = 200    # Opacidade padrão (0-255)

  #----------------------------------------------------------------------------
  # Raridade de itens — sistema de cores inspirado em Diablo/WoW
  #----------------------------------------------------------------------------
  ITEM_RARITY_COLORS = {
    common:    Color.new(255, 255, 255),  # Branco
    uncommon:  Color.new(0,   255,   0),  # Verde
    rare:      Color.new(0,   112, 255),  # Azul
    epic:      Color.new(163,  53, 238),  # Roxo
    legendary: Color.new(255, 165,   0)   # Laranja
  }

  #----------------------------------------------------------------------------
  # Debug — ativar/desativar logs detalhados sem alterar código
  #----------------------------------------------------------------------------
  DEBUG_LOG = false

end
```

---

## 🔴 Problemas & Sugestões — `[VS] Sprite_HUD.rb`

### Problemas Identificados

| # | Severidade | Problema |
|---|---|---|
| 1 | 🔴 Crítico | `$game_actors[1]` **hardcoded** em 6+ métodos — se o índice mudar, quebra tudo |
| 2 | 🟡 Médio | Posições `x = 11`, `y = 9` e `adjust_x = Graphics.width / 2 - 109` são **magic numbers** |
| 3 | 🟡 Médio | Fonte e tamanho definidos inline (`font.size = 18`, `font.bold = true`) — deveria usar Configs |
| 4 | 🟡 Médio | `@exp_sprite` é draggable mas o HUD principal não é — **inconsistência de UX** |
| 5 | 🟡 Médio | Barra de EXP mostra apenas "quanto falta" — referência MU Online é exibir **percentual** visualmente |
| 6 | 🔴 Crítico | Sem **Minimap integrado** à HUD — funcionalidade essencial para MMO |
| 7 | 🟢 Baixo | `draw_face` retorna silenciosamente se `face_name.empty?` — deveria exibir um rosto padrão |
| 8 | 🟡 Médio | Sem constante `ACTOR_INDEX` — referência ao ator do jogador duplicada em todo o arquivo |

### Sugestões de Melhoria

```ruby
#==============================================================================
# ** [VS] Sprite_HUD — Sugestões de Melhoria
#==============================================================================

module Configs
  #----------------------------------------------------------------------------
  # HUD — centralizar todas as configurações de posição e estilo
  #----------------------------------------------------------------------------
  ACTOR_INDEX    = 1      # Índice do ator principal do jogador
  HUD_X          = 11     # Posição X da HUD na tela
  HUD_Y          = 9      # Posição Y da HUD na tela
  HUD_FONT_NAME  = 'Arial'
  HUD_FONT_SIZE  = 18
  HUD_FONT_BOLD  = true
end

class Sprite_HUD < Sprite2

  #----------------------------------------------------------------------------
  # Centralizar referência ao ator — evitar $game_actors[1] espalhado
  #----------------------------------------------------------------------------
  def actor
    $game_actors[Configs::ACTOR_INDEX]
  end

  #----------------------------------------------------------------------------
  # Exibir percentual de EXP — estilo MU Online (preferência do projeto)
  #----------------------------------------------------------------------------
  def draw_exp_bar
    return unless actor
    if actor.level >= Configs::MAX_LEVEL
      exp_text = Vocab::MaxLevel
    else
      pct = (actor.now_exp * 100.0 / [actor.next_exp, 1].max).round(1)
      exp_text = "#{pct}%"
    end
    # Desenhar barra e texto de percentual
    draw_bar(exp_rect, actor.now_exp, actor.next_exp, exp_color1, exp_color2)
    draw_text_with_shadow(exp_rect, exp_text, 1)
  end

  #----------------------------------------------------------------------------
  # Tornar HUD principal também draggable — consistência de UX
  #----------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    self.dragable = true   # Consistência com @exp_sprite
    create_contents
    refresh
  end

  #----------------------------------------------------------------------------
  # draw_face com fallback para rosto padrão
  #----------------------------------------------------------------------------
  def draw_face(face_name, face_index, x, y, size = 96)
    fname = face_name.empty? ? 'Actor1' : face_name  # Fallback para rosto padrão
    findex = face_name.empty? ? 0 : face_index
    bitmap = Cache.face(fname)
    # ...resto do draw usando fname e findex
  end

end
```

---

## 🔴 Problemas & Sugestões — `Server/Combat/game_battle.rb`

### Problemas Identificados

| # | Severidade | Problema |
|---|---|---|
| 1 | 🔴 Crítico | **Critical hardcoded**: `value *= 3` — deveria usar `Configs::CRITICAL_MULTIPLIER` |
| 2 | 🔴 Crítico | `max_passage` usa **loop `while true`** sem guard de iteração máxima → risco de loop infinito |
| 3 | 🔴 Crítico | Sem sistema de **AoE (Area of Effect)** — essencial em MMOs (Ragnarok: Storm Gust; MU: Fireburst) |
| 4 | 🟡 Médio | Sem **knockback** — mecânica presente em Diablo e MU Online |
| 5 | 🟡 Médio | Sem **penalidade de morte** — Tibia perde EXP/itens; Diablo dropa corpo; Ragnarok perde EXP |
| 6 | 🟢 Baixo | `item_effect_add_state_normal` calcula `luk_effect_rate` duas vezes na mesma condição |
| 7 | 🟡 Médio | Sem **resistência elemental** configurável por zona de mapa |

### Sugestões de Melhoria

```ruby
#==============================================================================
# ** Server/Combat/game_battle.rb — Sugestões de Melhoria
#==============================================================================

module GameBattle

  #----------------------------------------------------------------------------
  # Guard no max_passage — evitar loop infinito em mapas com geometria incomum
  #----------------------------------------------------------------------------
  MAX_PROJECTILE_STEPS = 50   # Limite máximo de passos do projétil

  def max_passage(x, y, dir)
    steps = 0
    while steps < MAX_PROJECTILE_STEPS
      steps += 1
      break unless passable?(x, y, dir)
      x, y = next_position(x, y, dir)
    end
    [x, y]
  end

  #----------------------------------------------------------------------------
  # Aplicar multiplicador de crítico via Configs — remover magic number
  #----------------------------------------------------------------------------
  def apply_critical(value)
    value *= Configs::CRITICAL_MULTIPLIER
    value.to_i
  end

  #----------------------------------------------------------------------------
  # Penalidade de morte — configurável via Configs (estilo Tibia/Diablo)
  #----------------------------------------------------------------------------
  def apply_death_penalty(client)
    return unless Configs::DEATH_EXP_LOSS > 0
    loss = (client.exp * Configs::DEATH_EXP_LOSS / 100.0).to_i
    client.exp = [client.exp - loss, 0].max
    client.send_exp_update
    # Drop de item ao morrer (estilo Diablo)
    drop_random_item(client) if Configs::DEATH_ITEM_DROP
  end

  #----------------------------------------------------------------------------
  # Estrutura para AoE — base para habilidades de área (Ragnarok/WoW style)
  #----------------------------------------------------------------------------
  def apply_aoe(user, item, radius)
    map = $network.maps[@map_id]
    return unless map
    map.events.each_value do |target|
      next unless target.in_game?
      next unless target.in_range?(user, radius)
      next if target == user   # Não aplica no próprio usuário (configurável)
      item_apply(user, item, item.animation_id, 0)
    end
  end

  #----------------------------------------------------------------------------
  # Knockback — mecânica presente em Diablo e MU Online
  #----------------------------------------------------------------------------
  def apply_knockback(target, direction, distance = 1)
    distance.times do
      nx, ny = next_position(target.x, target.y, direction)
      break unless target.passable?(nx, ny, direction)
      target.x = nx
      target.y = ny
    end
    target.send_position_update
  end

  #----------------------------------------------------------------------------
  # Corrigir cálculo duplicado de luk_effect_rate
  #----------------------------------------------------------------------------
  def item_effect_add_state_normal(user, item, state_id)
    chance = item.states_rate(state_id)
    # Calcular luk_effect_rate apenas uma vez
    luk_rate = luk_effect_rate(user)
    chance *= luk_rate
    # ...resto da lógica
  end

end
```

---

## 🔴 Problemas & Sugestões — `Server/Network/network.rb`

### Problemas Identificados

| # | Severidade | Problema |
|---|---|---|
| 1 | 🟡 Médio | `@clients = []` — Array usa **índice sequencial**, perdendo performance em buscas; considerar Hash |
| 2 | 🟡 Médio | Logs de conexão/desconexão **comentados** — dificulta diagnóstico em produção |
| 3 | 🔴 Crítico | Sem **limite de conexões por IP** visível no código — vulnerável a flood/DDoS |
| 4 | 🟡 Médio | Sem **timeout de inatividade** para clientes zumbis (conexões mortas que ocupam slot) |
| 5 | 🟢 Baixo | `$data_enemies`, `$data_states`... são variáveis globais — deveriam ser encapsuladas em módulo |

### Sugestões de Melhoria

```ruby
#==============================================================================
# ** Server/Network/network.rb — Sugestões de Melhoria
#==============================================================================

class Network

  #----------------------------------------------------------------------------
  # Usar Hash para clientes — O(1) lookup ao invés de O(n) com Array
  #----------------------------------------------------------------------------
  def initialize
    @clients = {}                    # Era Array — agora Hash keyed por client.id
    @ip_connections = Hash.new(0)    # Contador de conexões por IP
  end

  #----------------------------------------------------------------------------
  # Limite de conexões por IP — proteção contra flood/DDoS
  #----------------------------------------------------------------------------
  MAX_CONNECTIONS_PER_IP = 3

  def connect_client(client)
    ip = client.ip
    if @ip_connections[ip] >= MAX_CONNECTIONS_PER_IP
      client.close_connection
      log_warn("Conexão recusada para #{ip} — limite atingido")
      return
    end
    @ip_connections[ip] += 1
    @clients[client.id] = client
    log_info("Cliente #{client.id} conectado: #{ip}") if Configs::DEBUG_LOG
  end

  def disconnect_client(client)
    @ip_connections[client.ip] -= 1
    @clients.delete(client.id)
    log_info("Cliente #{client.id} desconectado") if Configs::DEBUG_LOG
  end

  #----------------------------------------------------------------------------
  # Timeout de inatividade — remover clientes zumbis após X segundos
  #----------------------------------------------------------------------------
  INACTIVITY_TIMEOUT = 300   # 5 minutos sem atividade

  def check_timeouts
    now = Time.now
    @clients.each_value do |client|
      next unless client.last_activity
      if (now - client.last_activity) > INACTIVITY_TIMEOUT
        log_warn("Cliente #{client.id} removido por inatividade")
        disconnect_client(client)
      end
    end
  end

end

#------------------------------------------------------------------------------
# Encapsular dados globais em módulo — evitar poluição do namespace global
#------------------------------------------------------------------------------
module GameData
  class << self
    attr_accessor :enemies, :states, :animations, :actors,
                  :items, :weapons, :armors, :skills, :classes
  end
end

# Uso: GameData.enemies ao invés de $data_enemies
```

---

## 🔴 Problemas & Sugestões — `[VS] Mouse.rb`

### Problemas Identificados

| # | Severidade | Problema |
|---|---|---|
| 1 | 🔴 Crítico | Módulo **muito limitado** — apenas 4 métodos para um MMO onde o mouse é o principal controle |
| 2 | 🟡 Médio | Sem suporte a **scroll wheel** (zoom no minimap, scroll do chat) |
| 3 | 🟡 Médio | Sem método de **hover** sobre objetos do mapa |
| 4 | 🔴 Crítico | Sem método para **clique em drops** — mecânica essencial para coletar itens |
| 5 | 🟢 Baixo | `repeat?` apenas verifica `LBUTTON` e `RBUTTON` — sem `MBUTTON` (botão do meio) |
| 6 | 🟡 Médio | Sem **efeito visual de rotação** no cursor — melhoria de feedback visual solicitada |

### Sugestões de Melhoria

```ruby
#==============================================================================
# ** [VS] Mouse — Sugestões de Melhoria
# Expandir o módulo para suportar todas as interações de um MMO moderno
#==============================================================================

module Mouse

  #----------------------------------------------------------------------------
  # Clique em drop — coletar item ao clicar no sprite do drop
  #----------------------------------------------------------------------------
  def self.over_drop?(drop_sprite)
    return false unless drop_sprite && drop_sprite.visible
    mx = self.x
    my = self.y
    mx >= drop_sprite.x && mx <= drop_sprite.x + 24 &&
    my >= drop_sprite.y && my <= drop_sprite.y + 24
  end

  def self.click_drop?(drop_sprite)
    over_drop?(drop_sprite) && self.trigger?(:L)
  end

  #----------------------------------------------------------------------------
  # Hover — verificar se o mouse está sobre uma área retangular
  #----------------------------------------------------------------------------
  def self.hover?(x, y, width, height)
    self.x >= x && self.x <= x + width &&
    self.y >= y && self.y <= y + height
  end

  #----------------------------------------------------------------------------
  # Scroll wheel — para zoom no minimap e scroll do chat
  #----------------------------------------------------------------------------
  def self.scroll_up?
    Input.trigger?(:SCROLL_UP)
  end

  def self.scroll_down?
    Input.trigger?(:SCROLL_DOWN)
  end

  #----------------------------------------------------------------------------
  # Botão do meio — expandir suporte além de L e R
  #----------------------------------------------------------------------------
  def self.press?(key)
    case key
    when :L then Input.press?(:LBUTTON)
    when :R then Input.press?(:RBUTTON)
    when :M then Input.press?(:MBUTTON)
    else false
    end
  end

  def self.trigger?(key)
    case key
    when :L then Input.trigger?(:LBUTTON)
    when :R then Input.trigger?(:RBUTTON)
    when :M then Input.trigger?(:MBUTTON)
    else false
    end
  end

  #----------------------------------------------------------------------------
  # Cursor com efeito de rotação — feedback visual ao interagir com objetos
  #----------------------------------------------------------------------------
  CURSOR_ROTATION_SPEED = 5   # Graus por frame durante a rotação

  def self.update_cursor_rotation
    @cursor_angle ||= 0
    if @rotating
      @cursor_angle = (@cursor_angle + CURSOR_ROTATION_SPEED) % 360
      @cursor_sprite&.angle = @cursor_angle
    else
      @cursor_angle = 0
      @cursor_sprite&.angle = 0
    end
  end

  def self.start_rotation
    @rotating = true
  end

  def self.stop_rotation
    @rotating = false
  end

end
```

---

## 🔴 Problemas & Sugestões — `[VS] Sprite_Drop.rb`

### Problemas Identificados

| # | Severidade | Problema |
|---|---|---|
| 1 | 🟡 Médio | `create_name` chama `text_width` — método de `Window_Base`, pode não estar disponível em `Sprite2` |
| 2 | 🟡 Médio | `in_area?` não está definido no arquivo — depende de mixin externo sem documentação |
| 3 | 🟡 Médio | Sem **animação de surgimento** do drop (fade-in, bounce) — Tibia/Diablo têm feedback visual claro |
| 4 | 🔴 Crítico | Sem **timer de desaparecimento** — drops ficam eternamente no mapa; Tibia remove após ~1 min |
| 5 | 🟡 Médio | Cor do item baseada apenas em `key_item?` — falta sistema de **raridade** (comum, raro, lendário) |
| 6 | 🟢 Baixo | Sem **efeito de brilho/pulsação** para itens raros — WoW e Diablo usam esse feedback visual |

### Sugestões de Melhoria

```ruby
#==============================================================================
# ** [VS] Sprite_Drop — Sugestões de Melhoria
#==============================================================================

class Sprite_Drop < Sprite2

  #----------------------------------------------------------------------------
  # Constantes de configuração — centralizadas no topo do script
  #----------------------------------------------------------------------------
  DROP_LIFETIME_FRAMES  = 1800   # 30 segundos a 60fps (estilo Tibia)
  DROP_FADEOUT_FRAMES   = 300    # 5 segundos de fade out antes de sumir
  DROP_BOUNCE_FRAMES    = 20     # Frames da animação de surgimento (bounce)
  DROP_BOUNCE_HEIGHT    = 8      # Altura máxima do bounce em pixels

  #----------------------------------------------------------------------------
  # Sistema de raridade com cores — inspirado em Diablo e WoW
  #----------------------------------------------------------------------------
  DROP_RARITY_COLORS = {
    common:    Color.new(255, 255, 255),   # Branco — item comum
    uncommon:  Color.new(0,   255,   0),   # Verde  — item incomum
    rare:      Color.new(0,   112, 255),   # Azul   — item raro
    epic:      Color.new(163,  53, 238),   # Roxo   — item épico
    legendary: Color.new(255, 165,   0)    # Laranja — item lendário
  }

  #----------------------------------------------------------------------------
  # Inicialização com suporte a lifetime e animação de surgimento
  #----------------------------------------------------------------------------
  def initialize(viewport, item, x, y)
    super(viewport)
    @item      = item
    @lifetime  = 0
    @bounce_frame = 0
    @base_y    = y
    self.x     = x
    self.y     = y
    create_bitmap
    create_name
    start_bounce_animation
  end

  #----------------------------------------------------------------------------
  # Animação de surgimento — bounce ao cair no chão (estilo Diablo)
  #----------------------------------------------------------------------------
  def start_bounce_animation
    @bouncing = true
    @bounce_frame = 0
  end

  def update_bounce
    return unless @bouncing
    @bounce_frame += 1
    progress = @bounce_frame.to_f / DROP_BOUNCE_FRAMES
    # Curva senoidal para efeito de bounce
    offset = (Math.sin(progress * Math::PI) * DROP_BOUNCE_HEIGHT).to_i
    self.y = @base_y - offset
    @bouncing = false if @bounce_frame >= DROP_BOUNCE_FRAMES
  end

  #----------------------------------------------------------------------------
  # Timer de desaparecimento — drops somem após DROP_LIFETIME_FRAMES
  #----------------------------------------------------------------------------
  def update
    super
    @lifetime += 1
    update_bounce
    update_rarity_pulse
    # Fade out nos últimos DROP_FADEOUT_FRAMES frames
    if @lifetime > DROP_LIFETIME_FRAMES - DROP_FADEOUT_FRAMES
      remaining = DROP_LIFETIME_FRAMES - @lifetime
      self.opacity = (255.0 * remaining / DROP_FADEOUT_FRAMES).clamp(0, 255).to_i
    end
    # Marcar para remoção quando lifetime expirar
    @expired = @lifetime >= DROP_LIFETIME_FRAMES
  end

  def expired?
    @expired || false
  end

  #----------------------------------------------------------------------------
  # Pulsação para itens raros/lendários — feedback visual (estilo WoW/Diablo)
  #----------------------------------------------------------------------------
  def update_rarity_pulse
    return if item_rarity == :common || item_rarity == :uncommon
    @pulse_frame ||= 0
    @pulse_frame += 1
    pulse = (Math.sin(@pulse_frame * 0.1) * 30).to_i
    self.opacity = [self.opacity, (200 + pulse).clamp(150, 255)].min
  end

  #----------------------------------------------------------------------------
  # Determinar raridade do item — base para cor e efeitos visuais
  #----------------------------------------------------------------------------
  def item_rarity
    return :legendary if @item.note.include?('<legendary>')
    return :epic      if @item.note.include?('<epic>')
    return :rare      if @item.note.include?('<rare>')
    return :uncommon  if @item.note.include?('<uncommon>') || @item.key_item?
    :common
  end

  #----------------------------------------------------------------------------
  # Cor do nome baseada na raridade — ao invés de apenas key_item?
  #----------------------------------------------------------------------------
  def name_color
    DROP_RARITY_COLORS[item_rarity]
  end

end
```

---

## 🟡 Sistemas Ausentes Inspirados nas Referências do MMO

A tabela abaixo lista funcionalidades presentes nos MMORPGs de referência do projeto que ainda não foram implementadas, ordenadas por prioridade de impacto na experiência do jogador:

| Sistema | Referência Principal | Prioridade | Impacto |
|---|---|---|---|
| **Minimap quadrado** | Tibia, MU Online, Ragnarok | 🔴 Alta | Navegação e orientação no mundo |
| **Penalidade de morte** (EXP/drop) | Tibia, Diablo, Ragnarok | 🔴 Alta | Tensão e risco no gameplay |
| **Sistema de raridade de itens** | Diablo, WoW, MU Online | 🔴 Alta | Progressão e motivação de farm |
| **AoE (Area of Effect)** em habilidades | Ragnarok, WoW, Diablo | 🔴 Alta | Variedade e profundidade de combate |
| **Timer de desaparecimento de drops** | Tibia, WoW | 🔴 Alta | Performance e limpeza do mapa |
| **Clique em drops com mouse** | Tibia, Diablo | 🔴 Alta | Usabilidade e fluidez |
| **Sistema de Craft** | Diablo, WoW, Ragnarok | 🟡 Média | Economia e progressão de itens |
| **Dungeon/Instância** | WoW, Diablo | 🟡 Média | Conteúdo endgame e cooperação |
| **Ciclo dia/noite** | WoW, Tibia | 🟡 Média | Imersão e eventos temporais |
| **Sistema de karma/reputação PvP** | Tibia (skull system), MU Online | 🟡 Média | Equilíbrio e consequências no PvP |
| **Árvore de habilidades/talentos** | WoW, Diablo | 🟡 Média | Customização de personagem |
| **Knockback** | Diablo, MU Online | 🟡 Média | Profundidade tática no combate |
| **Resistência elemental por zona** | Ragnarok, WoW | 🟡 Média | Estratégia e builds diversificadas |
| **Sistema de conquistas** | WoW | 🟢 Baixa | Retenção e metas de longo prazo |
| **Eventos de mundo** (boss, invasão) | MU Online, Ragnarok | 🟢 Baixa | Engajamento da comunidade |
| **Sistema de montaria** | WoW, Ragnarok | 🟢 Baixa | Mobilidade e progressão visual |
| **Pet/summon** | Ragnarok, WoW | 🟢 Baixa | Variedade de builds e companheiros |
| **Auction House** | WoW | 🟢 Baixa | Economia de jogador para jogador |

---

## 🗺️ Roadmap Sugerido (Incremental)

O roadmap foi estruturado seguindo a metodologia incremental preferida pelo projeto — **simples primeiro, complexidade depois** — com cada fase entregando valor jogável antes de avançar para a próxima.

---

### 🔵 Fase 1 — Fundação Sólida
> *Objetivo: Corrigir problemas críticos e estabelecer base técnica robusta*

- [ ] **Corrigir magic numbers** — mover todas as constantes hardcoded para `Configs.rb`
- [ ] **Implementar Minimap quadrado** — Bitmap gerado via script, sem Windowskin
- [ ] **Adicionar guard no `max_passage`** — eliminar risco de loop infinito
- [ ] **Melhorar `Mouse.rb`** — adicionar hover, clique em drops e scroll wheel
- [ ] **Adicionar timer de desaparecimento** nos drops (estilo Tibia)
- [ ] **Exibir EXP em percentual** na HUD (estilo MU Online)
- [ ] **Tornar HUD principal draggable** — consistência com `@exp_sprite`
- [ ] **Centralizar referência ao ator** — substituir `$game_actors[1]` por constante

---

### 🟠 Fase 2 — Combate e Progressão
> *Objetivo: Aprofundar o sistema de combate e adicionar mecânicas de progressão*

- [ ] **Implementar penalidade de morte** configurável (EXP loss + item drop opcional)
- [ ] **Adicionar sistema de raridade de itens** com cores e efeitos visuais
- [ ] **Criar estrutura de AoE** para habilidades de área
- [ ] **Implementar knockback** básico para habilidades específicas
- [ ] **Configurar multiplicador de crítico** via `Configs::CRITICAL_MULTIPLIER`
- [ ] **Animação de surgimento** nos drops (bounce/fade-in)
- [ ] **Efeito de pulsação** para drops raros e lendários
- [ ] **Encapsular dados globais** do servidor em módulo `GameData`

---

### 🟡 Fase 3 — Conteúdo e Mundo
> *Objetivo: Adicionar sistemas de conteúdo que aumentam a retenção e imersão*

- [ ] **Sistema de ciclo dia/noite** com eventos temporais
- [ ] **Sistema de karma/skull PvP** inspirado no Tibia
- [ ] **Dungeon/instância básica** para conteúdo cooperativo
- [ ] **Sistema de craft simples** com receitas configuráveis
- [ ] **Eventos de mundo** — boss spawn e invasões (estilo MU Online)
- [ ] **Resistência elemental** configurável por zona de mapa
- [ ] **Limite de conexões por IP** e timeout de inatividade no servidor

---

### 🟢 Fase 4 — Polimento e Expansão
> *Objetivo: Funcionalidades de longo prazo para retenção e economia do jogo*

- [ ] **Árvore de habilidades/talentos** (estilo WoW/Diablo)
- [ ] **Sistema de conquistas** com recompensas
- [ ] **Sistema de montaria** básico
- [ ] **Pet/summon** configurável
- [ ] **Auction House** para economia entre jogadores
- [ ] **Refatoração geral** — migrar variáveis globais restantes para módulos

---

## 📊 Resumo Executivo

| Categoria | Problemas Críticos | Problemas Médios | Problemas Baixos |
|---|---|---|---|
| `[VS] Configs.rb` | 2 | 3 | 2 |
| `[VS] Sprite_HUD.rb` | 2 | 4 | 2 |
| `game_battle.rb` | 3 | 3 | 1 |
| `network.rb` | 1 | 3 | 1 |
| `[VS] Mouse.rb` | 2 | 2 | 2 |
| `[VS] Sprite_Drop.rb` | 1 | 3 | 2 |
| **Total** | **11** | **18** | **10** |

> **Prioridade imediata:** Os 11 problemas críticos identificados devem ser resolvidos antes de qualquer nova funcionalidade, pois incluem riscos de loop infinito no servidor, ausência de proteção contra flood/DDoS e referências hardcoded que podem causar quebras silenciosas.

---

*Análise realizada com base nos scripts públicos do repositório [CaioJuan2910/FieldsOnlineHML](https://github.com/CaioJuan2910/FieldsOnlineHML), considerando as referências de design de **Tibia Online**, **MU Online**, **Ragnarok Online**, **Saga Diablo** e **World of Warcraft**.*