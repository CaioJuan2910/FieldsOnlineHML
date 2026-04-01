# 🗺️ Análise Técnica — Sistema de Quests (Window_Quest)
**Fields Online — RPG Maker VX Ace / VXA-OS**
*Documento gerado em: 31/03/2026 | Autor: Caio Juan De Lima Silva*

---

## 📋 Visão Geral do Sistema Atual

O sistema de Quests do **Fields Online** é composto por **5 arquivos principais** que trabalham em conjunto para gerenciar o ciclo completo de missões — desde a definição dos dados até a interface visual exibida ao jogador.

| Arquivo | Responsabilidade |
|---|---|
| `[VS] Quests.rb` | Módulo de dados estáticos das missões |
| `[VS] Game_Quest.rb` | Classe de objeto de missão em tempo de execução |
| `[VS] Window_Quest.rb` | Janela principal com lista de missões (Em Progresso / Concluídas) |
| `[VS] Window_QuestInfo.rb` | Janela de detalhes da missão selecionada |
| `[VS] Window_QuestDialogue.rb` | Janela de diálogo de NPC para aceitar missões |

O fluxo básico funciona da seguinte forma:

```
NPC (evento) → Window_QuestDialogue → aceitar → Game_Quest criado
     ↓
Window_Quest (lista) → selecionar → Window_QuestInfo (detalhes)
     ↓
Objetivo cumprido → NPC entrega → recompensa distribuída
```

> **Nota:** O sistema é funcional para um MVP, mas apresenta diversas limitações estruturais que o distanciam dos padrões esperados para um MMORPG inspirado em Tibia Online, Ragnarok Online e World of Warcraft.

---

## 🔍 Análise por Componente

---

### 📦 `[VS] Quests.rb` — Módulo de Dados

Este arquivo define toda a estrutura estática das missões através de um módulo `Quests` com uma constante `DATA` do tipo `Array` de `Hash`.

#### ✅ O que faz bem

- **Estrutura clara de dados** em Hash com Array — fácil de ler e adicionar novas missões
- **Suporte a `repeat`** — permite missões repetíveis (diárias, semanais)
- **Múltiplos tipos de recompensa** — suporte a `exp`, `gold` e `item` na mesma missão
- **Diferentes tipos de objetivo** — suporte a `switch`, `variável`, `item` e `inimigo`

#### ❌ Limitações Identificadas

| # | Limitação | Impacto |
|---|---|---|
| 1 | Suporta apenas **um** objetivo por missão (inimigo **OU** item **OU** switch **OU** variável) — sem múltiplos objetivos simultâneos | Alto |
| 2 | Sem campo de **categoria** (principal, secundária, diária, guilda) | Médio |
| 3 | Sem campo de **dificuldade** (fácil, normal, difícil, élite) | Médio |
| 4 | Sem **pré-requisitos** ou encadeamento de quests (quest chains) | Alto |
| 5 | Sem **requisito de nível mínimo** para aceitar a missão | Médio |
| 6 | Sem identificação do **NPC que deu** e do **NPC que recebe** a missão | Baixo |
| 7 | Sem **tempo limite** para missões timed | Médio |
| 8 | Sem **múltiplas recompensas de item** — apenas 1 item por recompensa | Médio |

---

### ⚙️ `[VS] Game_Quest.rb` — Objeto de Missão

Esta classe representa uma instância de missão em tempo de execução, armazenada no array de quests do jogador (`$game_party.quests` ou equivalente).

#### ✅ O que faz bem

- **Interface simples** com métodos `in_progress?` e `finished?` — fácil de usar em eventos
- **Lazy loading** de dados do módulo `Quests` — evita duplicação de dados em memória
- **Objeto `Reward` encapsulado** corretamente — separação de responsabilidades adequada

#### ❌ Limitações Identificadas

| # | Limitação | Impacto |
|---|---|---|
| 1 | Apenas **2 estados**: `IN_PROGRESS` e `FINISHED` — sem `FAILED`, `ABANDONED`, `UNAVAILABLE` | Alto |
| 2 | **Nenhum rastreamento de progresso** — ex: "5/10 morcegos mortos" não é armazenado | Alto |
| 3 | Sem **timestamp** de início ou conclusão da missão | Baixo |
| 4 | Sem **referência ao ID** da quest original — dificulta rastreamento e debug | Médio |
| 5 | Sem suporte a **múltiplos objetivos** com progresso individual por objetivo | Alto |

---

### 🪟 `[VS] Window_Quest.rb` — Janela Principal (Lista)

Janela principal do sistema de quests, exibindo a lista de missões do jogador dividida em abas.

#### ✅ O que faz bem

- **`Tab_Control` funcional** com abas "Em Progresso" e "Concluídas"
- **Ícones de status** distintos para missão em progresso vs. concluída
- **Integração com `$windows[:quest_info]`** ao clicar em uma missão da lista

#### ❌ Limitações Identificadas

| # | Limitação | Impacto |
|---|---|---|
| 1 | Janela muito **pequena (235×212)** para padrões MMORPG | Alto |
| 2 | **Posições hardcoded** `(173, 170)` sem bloco de `CONFIGS` | Alto |
| 3 | Sem exibição de **progresso na lista** — ex: `"Morcegos (5/10)"` | Alto |
| 4 | Sem **contador total** de missões ativas na aba | Médio |
| 5 | Sem **filtro ou busca** de missões por nome ou categoria | Baixo |
| 6 | Sem **categoria ou dificuldade** visível na lista | Médio |
| 7 | Sem **scroll adequado** para muitas missões simultâneas | Médio |
| 8 | Sem **destaque visual** para missões prontas para entregar | Alto |
| 9 | Sem `line_height` configurável via bloco de `CONFIGS` | Médio |

---

### 📄 `[VS] Window_QuestInfo.rb` — Janela de Detalhes

Janela secundária que exibe os detalhes completos da missão selecionada na lista principal.

#### ✅ O que faz bem

- **`word_wrap`** na descrição — texto longo não transborda horizontalmente
- **Exibe exp, gold e item** de recompensa com ícones visuais
- **Título "Recompensas"** em cor diferente — boa hierarquia visual

#### ❌ Limitações Identificadas

| # | Limitação | Impacto |
|---|---|---|
| 1 | Posições de texto **absolutamente hardcoded** (`y: 115, 139, 162, 152`) — frágil a qualquer mudança de layout | Alto |
| 2 | Sem exibição de **progresso atual** dos objetivos | Alto |
| 3 | Sem exibição de **categoria/dificuldade** da quest | Médio |
| 4 | Sem **NPC de entrega** identificado — jogador não sabe com quem entregar | Médio |
| 5 | Sem **botão "Abandonar Missão"** | Alto |
| 6 | Sem suporte a **múltiplos objetivos** com checkmarks individuais | Alto |
| 7 | Janela **pequena (245×231)** — pouco espaço para descrições longas | Médio |
| 8 | Sem **scrollbar** para descrições extensas | Médio |

---

### 💬 `[VS] Window_QuestDialogue.rb` — Diálogo de NPC

Janela exibida quando um NPC oferece uma missão ao jogador, com opção de aceitar.

#### ✅ O que faz bem

- **Botão "Aceitar"** funcional e integrado ao sistema de eventos
- **Exibe ícones de recompensa** (exp, gold, item) de forma visual
- **`draw_justified_texts`** para a descrição — texto alinhado e legível

#### ❌ Limitações Identificadas

| # | Limitação | Impacto |
|---|---|---|
| 1 | **Extração do ID da quest via regex frágil**: `$game_message.texts.first[/QT(.*):/,1].to_i - 1` — quebra facilmente com mudanças no formato da mensagem | Alto |
| 2 | **Sem botão "Recusar"** — o jogador é forçado a fechar a janela sem recusar formalmente | Alto |
| 3 | `hide_window` envia `send_choice(1)` automaticamente ao fechar — **comportamento inesperado e silencioso** | Alto |
| 4 | Sem **animação ou transição visual** ao abrir/fechar | Baixo |
| 5 | Sem exibição de **pré-requisitos** da quest | Médio |
| 6 | Sem indicação se a quest é **repetível** | Baixo |

---

## 🎮 Comparativo com MMORPGs de Referência

A tabela abaixo compara as funcionalidades do sistema atual com os jogos que servem de inspiração para o **Fields Online**.

| Funcionalidade | Fields Online | Tibia | Ragnarok | WoW | MU Online | Saga Diablo |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| Progresso de objetivo na lista | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Múltiplos objetivos por quest | ❌ | ✅ | ✅ | ✅ | ❌ | ✅ |
| Categorias de quest | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ |
| Botão "Recusar" quest | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Botão "Abandonar" quest | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ |
| NPC de entrega visível | ❌ | ✅ | ✅ | ✅ | ❌ | ✅ |
| Dificuldade colorida | ❌ | ❌ | ✅ | ✅ | ❌ | ✅ |
| Múltiplas recompensas de item | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Quest chains / pré-requisitos | ❌ | ✅ | ✅ | ✅ | ❌ | ✅ |
| Highlight "pronto para entregar" | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Bloco de CONFIGS centralizado | ❌ | — | — | — | — | — |

---

### 🏰 Tibia Online

- Lista de missões com **progresso detalhado** — ex: `"0/10 coletados"`
- Missões em **cadeia** com tracking de etapas sequenciais
- **Log de quest** com histórico completo de quests concluídas
- Interface compacta e funcional, muito próxima do estilo 2D do RPG Maker

> 💡 **Referência direta para Fields Online:** O estilo compacto e o log de histórico são perfeitamente adaptáveis ao VXA-OS.

---

### ⚔️ Ragnarok Online

- **Categorias de quests** claramente separadas: Main, Side, Daily
- **NPC de origem e destino** visíveis no log de missão
- **Timer visual** para quests diárias e semanais
- Ícones de categoria distintos na lista

> 💡 **Referência direta para Fields Online:** O sistema de categorias com abas e o timer de quests diárias são funcionalidades de alto valor para o projeto.

---

### 🌍 World of Warcraft

- **Múltiplos objetivos simultâneos** por quest com progresso individual
- **Barra de progresso** por objetivo — ex: `"Kill 5/10"`, `"Collect 3/5"`
- **Mapa com marcadores** de quest (NPC, área alvo)
- **Botão "Abandonar Quest"** com janela de confirmação
- **Dificuldade colorida** — normal, élite, raro, lendário
- **Recompensas múltiplas** com seleção de item pelo jogador

> 💡 **Referência direta para Fields Online:** O botão "Abandonar" com confirmação e o progresso por objetivo são as funcionalidades mais críticas a implementar.

---

### 🔮 MU Online

- Interface **compacta** mas com **progresso de kill count** visível
- **Quests de guilda** com contribuição coletiva entre membros
- Sistema de missões integrado ao sistema de ranking

> 💡 **Referência direta para Fields Online:** O modelo de quests de guilda é uma expansão futura interessante para o projeto.

---

### 🔥 Saga Diablo

- Quests com **lore e texto narrativo** mais rico e imersivo
- Quests com **múltiplas escolhas** — aceitar, recusar ou negociar
- Recompensas variáveis baseadas na escolha do jogador

> 💡 **Referência direta para Fields Online:** O sistema de múltiplas escolhas no diálogo de NPC (aceitar/recusar/negociar) elevaria muito a imersão do jogo.

---

## 🛠️ Sugestões de Melhoria por Prioridade

---

### 🔴 Alta Prioridade — Impacto Direto na Experiência do Jogador

#### 1. Rastreamento de Progresso por Objetivo

Adicionar `@progress = {}` no `Game_Quest` para rastrear kills, itens coletados e outros objetivos em tempo real.

```ruby
# Em Game_Quest.rb
@progress = {}  # { objetivo_id => quantidade_atual }

def update_progress(objective_id, amount)
  @progress[objective_id] ||= 0
  @progress[objective_id] += amount
end

def objective_complete?(objective_id)
  target = data[:objectives][objective_id][:amount]
  (@progress[objective_id] || 0) >= target
end
```

**Resultado visual esperado na lista:**
```
⚔️ Morcegos Malditos        [5/10] →
```
Com cor diferente (ex: dourado) quando o objetivo estiver completo.

---

#### 2. Botão "Abandonar Missão" no `Window_QuestInfo`

Inspirado diretamente no World of Warcraft, com janela de confirmação para evitar clique acidental.

```
┌─────────────────────────────┐
│  Abandonar esta missão?     │
│  Esta ação não pode ser     │
│  desfeita.                  │
│                             │
│   [Confirmar]  [Cancelar]   │
└─────────────────────────────┘
```

**Estados afetados:** Adicionar estado `ABANDONED` ao `Game_Quest`.

---

#### 3. Botão "Recusar" no `Window_QuestDialogue`

Ao lado do botão "Aceitar", com disparo direto de `send_choice(1)` de forma **explícita e intencional** — eliminando o comportamento silencioso atual do `hide_window`.

```
┌──────────────────────────────────┐
│  [Nome da Quest]                 │
│  Descrição da missão...          │
│                                  │
│  Recompensas: 20 EXP | 20 Gold  │
│                                  │
│    [✅ Aceitar]  [❌ Recusar]    │
└──────────────────────────────────┘
```

---

#### 4. Bloco de CONFIGS no Topo dos Scripts

Centralizar **todas** as posições x/y, tamanhos de janela, fontes e tamanho de linha em um único bloco de configuração — seguindo o padrão já estabelecido em outros scripts do projeto (estilo `VS_COORDENADAS`).

```ruby
#==============================================================================
# ■ CONFIGS — Window_Quest
#==============================================================================
module VS_QuestConfig

  # Posição e tamanho da janela principal
  WINDOW_X      = 173
  WINDOW_Y      = 170
  WINDOW_WIDTH  = 300
  WINDOW_HEIGHT = 280

  # Fonte e tamanho de texto
  FONT_NAME     = 'Arial'
  FONT_SIZE     = 16
  LINE_HEIGHT   = 24

  # Cores de status
  COLOR_PROGRESS  = Color.new(255, 255, 100)  # Amarelo — em progresso
  COLOR_COMPLETE  = Color.new(100, 255, 100)  # Verde — pronto para entregar
  COLOR_FINISHED  = Color.new(150, 150, 150)  # Cinza — concluída

end
```

---

### 🟡 Média Prioridade — Enriquecimento do Sistema

#### 5. Suporte a Múltiplos Objetivos por Quest

Refatorar `Quests::DATA` para ter `:objectives => [...]`, onde cada objetivo possui tipo, alvo e quantidade independentes.

```ruby
:objectives => [
  { :type => :enemy, :id => 2, :amount => 10 },
  { :type => :item,  :id => 3, :kind => 1, :amount => 5 }
]
```

Exibir **checkmarks individuais** por objetivo no `Window_QuestInfo`:
```
☑ Matar 10 Morcegos Malditos     [10/10] ✅
☐ Coletar 5 Asas de Morcego      [2/5]  ⏳
```

---

#### 6. Categorias de Quest

Adicionar campo `:category` com suporte a `:main`, `:side`, `:daily` e `:guild`.

- Adicionar **terceira aba "Diárias"** no `Window_Quest`
- Exibir **ícone de categoria** na lista de missões
- Filtrar automaticamente quests diárias com reset por timer

```
[ Em Progresso (3) ] [ Concluídas (12) ] [ Diárias (2) ]
```

> 💡 Padrão diretamente inspirado em Ragnarok Online e World of Warcraft.

---

#### 7. Highlight de Quest "Pronta para Entregar"

Aplicar cor dourada e ícone especial para missões cujos objetivos já foram todos cumpridos, mas que ainda não foram entregues ao NPC.

```
🌟 Morcegos Malditos    [PRONTA PARA ENTREGAR]
```

- Cor: `Color.new(255, 215, 0)` — dourado
- Ícone: `:rew_ready` ou estrela pulsante
- Ordenar estas missões **no topo da lista** automaticamente

---

#### 8. Múltiplas Recompensas de Item

Mudar `:rew_item_id` para array `:rew_items => [{id, kind, amount}, ...]`, permitindo que uma quest recompense múltiplos itens simultaneamente.

```ruby
:rewards => {
  :exp   => 20,
  :gold  => 20,
  :items => [
    { :id => 2, :kind => 2, :amount => 1 },
    { :id => 5, :kind => 1, :amount => 3 }
  ]
}
```

---

### 🟢 Baixa Prioridade — Polish e Quality of Life

#### 9. Scrollbar no `Window_QuestInfo`
Para descrições longas que ultrapassem o espaço disponível da janela.

#### 10. Animação de Abertura/Fechamento
Transição suave (fade in/out ou slide) ao abrir e fechar as janelas de quest.

#### 11. Pré-requisitos Visíveis
Exibir no `Window_QuestInfo` e no `Window_QuestDialogue` os requisitos para aceitar a missão:
```
⚠️ Requer: Nível 10 | Quest "Introdução" concluída
```

#### 12. NPC de Entrega Identificado
Exibir no `Window_QuestInfo` o nome do NPC para quem a missão deve ser entregue:
```
📍 Entregar para: Ancião da Vila
```

#### 13. Contador no Título da Aba
Padrão WoW/Ragnarok — exibir quantidade de missões em cada aba:
```
[ Em Progresso (3) ]  [ Concluídas (12) ]
```

#### 14. Sons Distintos por Ação
- 🔔 **Aceitar quest** — som de fanfarra leve
- 🏆 **Concluir quest** — som de recompensa
- ❌ **Abandonar quest** — som de cancelamento

---

## 📐 Sugestão de Estrutura de Dados Modernizada

### `[VS] Quests.rb` — Formato Proposto

```ruby
#==============================================================================
# ■ [VS] Quests — Estrutura de Dados Modernizada
# Fields Online | Versão 2.0
#==============================================================================
module Quests

  DATA = []

  #----------------------------------------------------------------------------
  # Exemplo: Quest com múltiplos objetivos e múltiplas recompensas
  #----------------------------------------------------------------------------
  DATA << {
    :name          => 'Morcegos Malditos',
    :desc          => 'Os morcegos da Caverna Sombria estão aterrorizando ' \
                      'os aldeões. Elimine-os e colete suas asas como prova.',

    # Classificação
    :category      => :side,       # :main, :side, :daily, :guild
    :difficulty    => :normal,     # :easy, :normal, :hard, :elite

    # Requisitos
    :min_level     => 1,
    :required_quests => [],        # IDs de quests que devem estar concluídas

    # NPCs envolvidos
    :npc_give      => 'Ancião da Vila',
    :npc_receive   => 'Ancião da Vila',

    # Configurações
    :repeat        => false,
    :time_limit    => nil,         # nil = sem limite | valor em segundos

    # Múltiplos objetivos
    :objectives    => [
      { :type => :enemy, :id => 2, :amount => 10, :desc => 'Matar Morcegos Malditos' },
      { :type => :item,  :id => 3, :kind => 1, :amount => 5, :desc => 'Coletar Asas de Morcego' }
    ],

    # Recompensas múltiplas
    :rewards       => {
      :exp   => 20,
      :gold  => 20,
      :items => [
        { :id => 2, :kind => 2, :amount => 1 }
      ]
    }
  }

end
```

### Comparativo: Estrutura Atual vs. Proposta

| Campo | Atual | Proposto |
|---|---|---|
| Objetivo | `:rew_type` (único) | `:objectives => [...]` (múltiplos) |
| Recompensa item | `:rew_item_id` (único) | `:rewards => { :items => [...] }` (múltiplos) |
| Categoria | ❌ ausente | `:category => :side` |
| Dificuldade | ❌ ausente | `:difficulty => :normal` |
| Nível mínimo | ❌ ausente | `:min_level => 1` |
| NPC envolvido | ❌ ausente | `:npc_give`, `:npc_receive` |
| Pré-requisitos | ❌ ausente | `:required_quests => [...]` |
| Tempo limite | ❌ ausente | `:time_limit => nil` |

---

## ✅ Resumo Executivo

### 📊 Avaliação por Componente

| Componente | Estado Atual | Principais Problemas | Nota |
|---|---|---|:---:|
| `Quests.rb` (dados) | Funcional, mas limitado | Objetivo único, sem categoria/dificuldade | ⭐⭐⭐ |
| `Game_Quest.rb` (objeto) | Mínimo funcional | Sem progresso, apenas 2 estados | ⭐⭐ |
| `Window_Quest.rb` (lista) | Funcional, pequena | Sem progresso, posições hardcoded | ⭐⭐⭐ |
| `Window_QuestInfo.rb` (detalhes) | Funcional, básico | Hardcoded, sem abandonar, sem progresso | ⭐⭐ |
| `Window_QuestDialogue.rb` (NPC) | Funcional | Regex frágil, sem recusar, hide silencioso | ⭐⭐⭐ |

### 🎯 As 4 Melhorias Mais Críticas

```
┌─────────────────────────────────────────────────────────────────┐
│  1. 📊 Rastreamento de progresso por objetivo                   │
│     → Adicionar @progress = {} no Game_Quest                    │
│                                                                 │
│  2. ❌ Botão "Recusar" no Window_QuestDialogue                  │
│     → Eliminar o comportamento silencioso do hide_window        │
│                                                                 │
│  3. 🗑️ Botão "Abandonar" no Window_QuestInfo                   │
│     → Com janela de confirmação (padrão WoW)                    │
│                                                                 │
│  4. ⚙️ Bloco de CONFIGS centralizado em todos os scripts        │
│     → Seguindo o padrão VS_COORDENADAS já existente no projeto  │
└─────────────────────────────────────────────────────────────────┘
```

### 📌 Conclusão

O sistema de Quests do **Fields Online** é **funcional para um MVP**, mas está abaixo dos padrões esperados para um MMORPG inspirado em Tibia Online, World of Warcraft e Ragnarok Online. A ausência de rastreamento de progresso é a limitação mais crítica, pois impacta diretamente a experiência do jogador em todas as missões do jogo.

A implementação das melhorias deve seguir a abordagem **incremental e iterativa** — começando pelo bloco de `CONFIGS` (menor risco, maior impacto na manutenibilidade), seguido pelo rastreamento de progresso, e então os botões de recusar e abandonar.

> **Próximo passo sugerido:** Iniciar pela refatoração do `[VS] Quests.rb` para a estrutura modernizada, garantindo retrocompatibilidade com as quests já existentes no projeto antes de modificar as janelas de interface.

---

*📁 Documento de análise técnica — Fields Online / VXA-OS*
*🗓️ Versão 1.0 — 31/03/2026*