# 📋 Plano de Implementação — Sistema de Quests v2.0
### Fields Online — RPG Maker VX Ace (VXA-OS)
**Autor:** Caio Juan De Lima Silva | **Data:** 31/03/2026 | **Versão do Plano:** 1.0.0

---

## 🎯 Objetivo Geral

Modernizar o sistema de quests para o padrão de MMORPGs de referência **(Tibia, WoW, Ragnarok, MU Online, Diablo)**, mantendo compatibilidade total com o servidor VXA-OS e seguindo o estilo **modular, bem comentado e configurável** já existente no projeto Fields Online.

---

## 🗂️ Visão Geral das Fases

| # | Fase | Nome | Arquivos Afetados | Prioridade | Status |
|---|------|------|-------------------|------------|--------|
| 1 | 📦 | Bloco de CONFIGS + Reorganização | `Window_Quest.rb` | 🔴 Alta | ⬜ Pendente |
| 2 | 📊 | Rastreamento de Progresso | `Game_Quest.rb` + `Window_Quest.rb` | 🔴 Alta | ⬜ Pendente |
| 3 | ❌ | Botão Recusar + Correção do Dialogue | `Window_Quest.rb` | 🔴 Alta | ⬜ Pendente |
| 4 | 🎯 | Múltiplos Objetivos | `Quests.rb` + `Game_Quest.rb` + `Window_Quest.rb` | 🟡 Média | ⬜ Pendente |
| 5 | 🗂️ | Categorias + Abas Extras | `Quests.rb` + `Window_Quest.rb` | 🟡 Média | ⬜ Pendente |
| 6 | 🎁 | Múltiplas Recompensas de Item | `Quests.rb` + `Game_Quest.rb` + `Window_Quest.rb` | 🟡 Média | ⬜ Pendente |
| 7 | ✨ | Highlight "Pronta para Entregar" | `Window_Quest.rb` | 🟢 Baixa | ⬜ Pendente |
| 8 | 🪄 | Polish Final (NPC, sons, contadores) | `Window_Quest.rb` | 🟢 Baixa | ⬜ Pendente |

> 🔁 **Metodologia:** Cada fase é **independente e testável**. Avance para a próxima somente após validar todos os checkpoints da fase atual.

---

## 🔢 Ordem de Execução Recomendada

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌──────────────┐
│ FASE 1  │ →  │ FASE 2  │ →  │ FASE 3  │ →  │ VALIDAR BASE │
│ CONFIGS │    │PROGRESSO│    │ RECUSAR │    │   ✅ ✅ ✅   │
└─────────┘    └─────────┘    └─────────┘    └──────┬───────┘
                                                     │
     ┌───────────────────────────────────────────────┘
     ▼
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ FASE 4  │ →  │ FASE 5  │ →  │ FASE 6  │ →  │ FASE 7  │ →  │ FASE 8  │
│MÚLT.OBJ │    │CATEGORIAS    │MÚLT.RECOMP   │HIGHLIGHT│    │ POLISH  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
```

---

## 📁 Arquivos que Serão Modificados

| Arquivo | Fases Envolvidas | Tipo de Modificação |
|---------|-----------------|---------------------|
| `[VS] Window_Quest.rb` | 1, 2, 3, 4, 5, 6, 7, 8 | Principal — UI, layout, lógica de exibição |
| `[VS] Game_Quest.rb` | 2, 4, 6 | Dados — estrutura de progresso e recompensas |
| `[VS] Quests.rb` | 4, 5, 6 | Dados — definição de quests e estrutura |

> 💾 **Regra de Backup:** Ao término de cada fase, salve uma cópia com sufixo de versão.
> Exemplo: `Window_Quest_v2.1.rb`, `Window_Quest_v2.2.rb`, etc.

---

---

## 📦 FASE 1 — Bloco de CONFIGS + Reorganização

> **Meta:** Centralizar **todas** as configurações do sistema de quests em um único bloco no topo do script, eliminando valores hardcoded espalhados pelo código.
>
> **Arquivo principal:** `[VS] Window_Quest.rb`
>
> **Complexidade:** 🟡 Média | **Risco:** 🟢 Baixo

---

### 📋 Etapa 1.1 — Mapear todos os valores hardcoded existentes

> Antes de criar o bloco de CONFIGS, é necessário **identificar e catalogar** todos os valores fixos espalhados pelo script atual.

#### 🔍 Valores a serem mapeados:

| Categoria | Valor Atual | Localização no Código | Constante Proposta |
|-----------|-------------|----------------------|-------------------|
| Posição da lista | `x: 173, y: 170` | `Window_Quest#initialize` | `QUEST_WINDOW_X / Y` |
| Tamanho da lista | `w: 235, h: 212` | `Window_Quest#initialize` | `QUEST_WINDOW_W / H` |
| Posição dos detalhes | `x: 415, y: 151` | `Window_QuestInfo#initialize` | `QUEST_INFO_X / Y` |
| Tamanho dos detalhes | `w: 245, h: 231` | `Window_QuestInfo#initialize` | `QUEST_INFO_W / H` |
| Tamanho do diálogo | calculado via `adjust_x/y` | `Window_QuestDialogue` | `QUEST_DIALOGUE_W / H` |
| Altura de linha | `line_height = 20` | Múltiplos métodos | `QUEST_LINE_HEIGHT` |
| Posições Y absolutas | `y: -2, 21, 115, 139, 162, 152` | `Window_QuestInfo#refresh` | Calculadas via `line_height` |
| Tamanho da fonte geral | hardcoded | `Window_Quest` | `QUEST_FONT_SIZE` |
| Tamanho da fonte título | hardcoded | `Window_QuestInfo` | `QUEST_TITLE_FONT_SIZE` |
| Tamanho da fonte recompensa | hardcoded | `Window_QuestInfo` | `QUEST_REWARD_FONT_SIZE` |
| Ícone quest em progresso | `QUEST_IN_PROGRESS_ICON` | `Configs` (já existe) | Manter referência |
| Ícone quest concluída | `QUEST_FINISHED_ICON` | `Configs` (já existe) | Manter referência |

#### ✅ Checklist da Etapa 1.1:
- [ ] Abrir `Window_Quest.rb` e anotar **todas** as ocorrências de números mágicos
- [ ] Abrir `Window_QuestInfo` e mapear posições Y absolutas no `refresh`
- [ ] Abrir `Window_QuestDialogue` e mapear cálculos de `adjust_x` / `adjust_y`
- [ ] Verificar se já existe algum bloco `module Configs` com constantes de quest
- [ ] Documentar cada valor encontrado na tabela acima antes de prosseguir

---

### 📋 Etapa 1.2 — Criar o bloco de configuração no topo do script

> Criar (ou expandir) o `module Configs` com todas as constantes identificadas na etapa anterior. O bloco deve ser **bem comentado**, seguindo o estilo do script `VS_COORDENADAS`.

#### 📝 Estrutura esperada do bloco CONFIGS:

```ruby
#==============================================================================
# ** CONFIGS — Sistema de Quests
#------------------------------------------------------------------------------
# Centralize aqui todas as configurações visuais e de layout do sistema.
# Altere os valores abaixo para personalizar posição, tamanho e fontes.
#==============================================================================
module Configs

  #----------------------------------------------------------------------------
  # JANELA DE LISTA DE QUESTS (Window_Quest)
  #----------------------------------------------------------------------------
  QUEST_WINDOW_X = 173      # Posição X da janela de lista
  QUEST_WINDOW_Y = 170      # Posição Y da janela de lista
  QUEST_WINDOW_W = 235      # Largura da janela de lista
  QUEST_WINDOW_H = 212      # Altura da janela de lista

  #----------------------------------------------------------------------------
  # JANELA DE DETALHES DA QUEST (Window_QuestInfo)
  #----------------------------------------------------------------------------
  QUEST_INFO_X   = 415      # Posição X da janela de detalhes
  QUEST_INFO_Y   = 151      # Posição Y da janela de detalhes
  QUEST_INFO_W   = 245      # Largura da janela de detalhes
  QUEST_INFO_H   = 231      # Altura da janela de detalhes

  #----------------------------------------------------------------------------
  # JANELA DE DIÁLOGO DO NPC (Window_QuestDialogue)
  #----------------------------------------------------------------------------
  QUEST_DIALOGUE_W = 400    # Largura da janela de diálogo
  QUEST_DIALOGUE_H = 180    # Altura da janela de diálogo

  #----------------------------------------------------------------------------
  # TIPOGRAFIA
  #----------------------------------------------------------------------------
  QUEST_LINE_HEIGHT      = 20   # Altura de cada linha de texto
  QUEST_FONT_SIZE        = 16   # Tamanho da fonte geral
  QUEST_TITLE_FONT_SIZE  = 18   # Tamanho da fonte do título da quest
  QUEST_REWARD_FONT_SIZE = 14   # Tamanho da fonte da seção de recompensas

end
```

#### ✅ Checklist da Etapa 1.2:
- [ ] Bloco `module Configs` criado no topo do arquivo
- [ ] Todas as constantes da tabela da Etapa 1.1 estão presentes
- [ ] Cada constante possui comentário explicativo na mesma linha
- [ ] Seções separadas por categoria com cabeçalhos comentados
- [ ] Estilo visual do bloco segue o padrão do projeto (linhas `#===`, `#---`)

---

### 📋 Etapa 1.3 — Substituir hardcodes nas 3 janelas

> Com o bloco CONFIGS criado, substituir **um arquivo por vez** os valores hardcoded pelas constantes.

#### 🔧 Substituições em `Window_Quest`:

| Antes | Depois |
|-------|--------|
| `Window_Quest.new(173, 170, 235, 212)` | `Window_Quest.new(Configs::QUEST_WINDOW_X, Configs::QUEST_WINDOW_Y, Configs::QUEST_WINDOW_W, Configs::QUEST_WINDOW_H)` |
| `line_height = 20` | `line_height = Configs::QUEST_LINE_HEIGHT` |
| `font.size = 16` | `font.size = Configs::QUEST_FONT_SIZE` |

#### 🔧 Substituições em `Window_QuestInfo`:

| Antes | Depois |
|-------|--------|
| `Window_QuestInfo.new(415, 151, 245, 231)` | `Window_QuestInfo.new(Configs::QUEST_INFO_X, Configs::QUEST_INFO_Y, Configs::QUEST_INFO_W, Configs::QUEST_INFO_H)` |
| `draw_text(x, -2, ...)` | `draw_text(x, 0, ...)` *(posição Y calculada via `line_height`)* |
| `draw_text(x, 21, ...)` | `draw_text(x, Configs::QUEST_LINE_HEIGHT, ...)` |
| `draw_text(x, 115, ...)` | `draw_text(x, Configs::QUEST_LINE_HEIGHT * 5, ...)` |
| `font.size = 18` | `font.size = Configs::QUEST_TITLE_FONT_SIZE` |
| `font.size = 14` | `font.size = Configs::QUEST_REWARD_FONT_SIZE` |

#### 🔧 Substituições em `Window_QuestDialogue`:

| Antes | Depois |
|-------|--------|
| Cálculo manual de `adjust_x` | Usar `Configs::QUEST_DIALOGUE_W` |
| Cálculo manual de `adjust_y` | Usar `Configs::QUEST_DIALOGUE_H` |

> ⚠️ **Atenção:** Faça as substituições **uma janela por vez** e teste após cada uma antes de passar para a próxima.

#### ✅ Checklist da Etapa 1.3:
- [ ] `Window_Quest` — todos os hardcodes substituídos por constantes
- [ ] `Window_QuestInfo` — todos os hardcodes substituídos por constantes
- [ ] `Window_QuestInfo` — posições Y absolutas recalculadas via `line_height`
- [ ] `Window_QuestDialogue` — `adjust_x` e `adjust_y` usando constantes
- [ ] Nenhum número mágico restante nas 3 janelas (exceto `0` e `1` lógicos)

---

### 📋 Etapa 1.4 — Teste e Validação da Fase 1

> Testar **cada janela individualmente** e depois o fluxo completo.

#### 🧪 Testes a realizar:

| # | Teste | Resultado Esperado | ✅ |
|---|-------|-------------------|---|
| 1 | Abrir o menu de quests | Janela de lista abre na posição `(173, 170)` | ⬜ |
| 2 | Selecionar uma quest | Janela de detalhes abre na posição `(415, 151)` | ⬜ |
| 3 | Falar com NPC de quest | Diálogo centralizado na tela corretamente | ⬜ |
| 4 | Alterar `QUEST_WINDOW_X` para `200` | Janela de lista move para X=200 | ⬜ |
| 5 | Alterar `QUEST_LINE_HEIGHT` para `24` | Espaçamento de linhas aumenta proporcionalmente | ⬜ |
| 6 | Alterar `QUEST_FONT_SIZE` para `14` | Fonte da lista diminui corretamente | ⬜ |
| 7 | Restaurar todos os valores originais | Tudo volta ao estado inicial sem erros | ⬜ |

> 💾 **Backup:** Salvar `Window_Quest_v2.1.rb` após validação completa.

---

---

## 📊 FASE 2 — Rastreamento de Progresso

> **Meta:** Exibir o progresso real dos objetivos da quest em tempo real — ex: `"5/10 Morcegos Malditos"` — tanto na lista quanto na janela de detalhes.
>
> **Arquivos:** `[VS] Game_Quest.rb` + `[VS] Window_Quest.rb`
>
> **Complexidade:** 🔴 Alta | **Risco:** 🟡 Médio

---

### 📋 Etapa 2.1 — Adicionar campo de progresso no `Game_Quest`

> Modificar a classe `Game_Quest` para armazenar e gerenciar o progresso numérico do objetivo.

#### 🔧 Modificações em `Game_Quest`:

| Elemento | Tipo | Valor Inicial | Descrição |
|----------|------|---------------|-----------|
| `attr_accessor :progress` | `Integer` | `0` | Progresso atual do objetivo |
| `progress_text` | Método | `"#{@progress}/#{@data[:amount]}"` | Texto formatado do progresso |
| `objective_complete?` | Método | `@progress >= @data[:amount]` | Verifica se objetivo foi cumprido |
| `progress_percent` | Método | `(@progress.to_f / @data[:amount] * 100).to_i` | Percentual de conclusão (0–100) |

#### 📝 Pseudocódigo esperado:

```ruby
class Game_Quest
  attr_accessor :progress

  def initialize(id)
    # ... código existente ...
    @progress = 0   # Inicializar progresso zerado
  end

  # Retorna texto formatado: "5/10"
  def progress_text
    "#{@progress}/#{@data[:amount]}"
  end

  # Retorna true se o objetivo foi completamente cumprido
  def objective_complete?
    @progress >= @data[:amount]
  end

  # Retorna percentual de conclusão (0 a 100)
  def progress_percent
    return 100 if @data[:amount].to_i <= 0
    [(@progress.to_f / @data[:amount] * 100).to_i, 100].min
  end
end
```

#### ✅ Checklist da Etapa 2.1:
- [ ] `attr_accessor :progress` adicionado à classe
- [ ] `@progress = 0` no `initialize`
- [ ] Método `progress_text` implementado e retorna string formatada
- [ ] Método `objective_complete?` implementado e retorna booleano
- [ ] Método `progress_percent` implementado e retorna inteiro 0–100
- [ ] Testar no console: criar quest, incrementar progresso, verificar retornos

---

### 📋 Etapa 2.2 — Exibir progresso na `Window_Quest` (lista)

> Modificar o `draw_item` da lista para exibir o progresso abaixo do nome da quest, com cores diferenciadas por estado.

#### 🎨 Lógica de cores por estado:

| Estado | Condição | Cor do Texto |
|--------|----------|-------------|
| Pronta para entregar | `objective_complete?` | 🟡 Dourado — `text_color(14)` |
| Em progresso | `in_progress? && !objective_complete?` | ⚪ Normal — `normal_color` |
| Concluída | `finished?` | 🟢 Verde — `text_color(3)` |

#### 📝 Comportamento esperado no `draw_item`:

```
┌─────────────────────────────────┐
│ 🗡️ Caçada aos Morcegos          │
│    (5/10) ████████░░            │  ← progresso em cor diferente
├─────────────────────────────────┤
│ ✅ Missão da Espada Sagrada     │
│    (Concluída)                  │
└─────────────────────────────────┘
```

#### ✅ Checklist da Etapa 2.2:
- [ ] `draw_item` modificado para exibir linha de progresso abaixo do nome
- [ ] Cor dourada aplicada quando `objective_complete?` retorna `true`
- [ ] Cor normal aplicada quando quest está em progresso
- [ ] Cor verde aplicada para quests concluídas
- [ ] Texto de progresso usa `progress_text` do `Game_Quest`
- [ ] Layout não quebra quando o nome da quest é longo

---

### 📋 Etapa 2.3 — Exibir progresso na `Window_QuestInfo` (detalhes)

> Adicionar uma seção "Objetivo" com barra de progresso visual na janela de detalhes.

#### 🎨 Lógica de cores da barra de progresso:

| Percentual | Cor da Barra |
|------------|-------------|
| 0% – 49% | ⬜ Cinza — `text_color(7)` |
| 50% – 74% | 🟡 Amarelo — `text_color(14)` |
| 75% – 99% | 🟠 Laranja — `text_color(2)` |
| 100% | 🟢 Verde — `text_color(3)` |

#### 📝 Layout esperado na `Window_QuestInfo`:

```
┌──────────────────────────────────────────┐
│ 🗡️ Caçada aos Morcegos                   │  ← título (fonte maior)
│ ─────────────────────────────────────── │
│ Descrição: Elimine os morcegos que       │
│ infestam as cavernas ao norte da cidade. │
│                                          │
│ Objetivo:                                │
│   Morcegos Malditos: 5/10               │
│   [████████░░░░░░░░░░] 50%              │  ← barra de progresso
│                                          │
│ Recompensa:                              │
│   💰 500 Gold   ⭐ 200 EXP   🗡️ x1     │
└──────────────────────────────────────────┘
```

#### 🔧 Método de barra de progresso a implementar:

```ruby
# Desenha barra de progresso simples via Bitmap
# x, y    → posição
# width   → largura total da barra
# percent → valor de 0 a 100
def draw_progress_bar(x, y, width, percent)
  # Fundo da barra (cinza escuro)
  # Preenchimento proporcional ao percent
  # Cor varia conforme o percentual (ver tabela acima)
end
```

#### ✅ Checklist da Etapa 2.3:
- [ ] Seção "Objetivo:" adicionada ao `refresh` da `Window_QuestInfo`
- [ ] Texto do objetivo exibe `progress_text` corretamente
- [ ] Método `draw_progress_bar` implementado
- [ ] Barra de progresso desenhada abaixo do texto do objetivo
- [ ] Cor da barra muda conforme o percentual (4 faixas de cor)
- [ ] Barra não ultrapassa os limites da janela
- [ ] Posições Y calculadas via `Configs::QUEST_LINE_HEIGHT` (sem hardcode)

---

### 📋 Etapa 2.4 — Teste e Validação da Fase 2

| # | Teste | Resultado Esperado | ✅ |
|---|-------|-------------------|---|
| 1 | Quest com progresso 0/10 | Lista exibe `(0/10)`, barra vazia cinza | ⬜ |
| 2 | Quest com progresso 5/10 | Lista exibe `(5/10)`, barra 50% amarela | ⬜ |
| 3 | Quest com progresso 8/10 | Lista exibe `(8/10)`, barra 80% laranja | ⬜ |
| 4 | Quest com progresso 10/10 | Lista exibe dourado, barra 100% verde | ⬜ |
| 5 | Selecionar quest na lista | Detalhes exibem seção "Objetivo:" com barra | ⬜ |
| 6 | Quest concluída (finished) | Exibe "Concluída" em verde, sem barra | ⬜ |
| 7 | `Game_Quest` salva progresso | Progresso persiste após fechar e reabrir menu | ⬜ |

> 💾 **Backup:** Salvar `Window_Quest_v2.2.rb` e `Game_Quest_v2.2.rb` após validação.

---

---

## ❌ FASE 3 — Botão Recusar + Correção do Dialogue

> **Meta:** Dar ao jogador a opção formal de **recusar** uma quest, e corrigir o comportamento inesperado do `hide_window` que disparava `send_choice(1)` automaticamente.
>
> **Arquivo principal:** `[VS] Window_Quest.rb`
>
> **Complexidade:** 🟡 Média | **Risco:** 🟡 Médio

---

### 📋 Etapa 3.1 — Adicionar botão "Recusar" no `Window_QuestDialogue`

> Criar um segundo botão ao lado do "Aceitar" existente, seguindo o padrão visual de WoW e Ragnarok (Aceitar à esquerda, Recusar à direita).

#### 🎨 Layout esperado do diálogo:

```
┌──────────────────────────────────────────────────┐
│                                                  │
│  🗡️ [Nome do NPC]                               │
│  ─────────────────────────────────────────────  │
│  "Aventureiro, preciso da sua ajuda! Os          │
│   morcegos estão infestando as cavernas          │
│   ao norte. Você pode eliminá-los?"              │
│                                                  │
│  ┌──────────────┐        ┌──────────────┐        │
│  │   ✅ Aceitar │        │  ❌ Recusar  │        │
│  └──────────────┘        └──────────────┘        │
└──────────────────────────────────────────────────┘
```

#### 🔧 Lógica dos botões:

| Botão | Ação | Método chamado |
|-------|------|----------------|
| ✅ Aceitar | Aceita a quest e fecha a janela | `send_choice(0)` → `hide` |
| ❌ Recusar | Recusa a quest e fecha a janela | `send_choice(1)` → `hide` |

#### ✅ Checklist da Etapa 3.1:
- [ ] `Button.new` para "Recusar" criado no `initialize` do `Window_QuestDialogue`
- [ ] Botão "Recusar" posicionado à direita do "Aceitar"
- [ ] Clique em "Recusar" chama `send_choice(1)` e fecha a janela
- [ ] Clique em "Aceitar" chama `send_choice(0)` e fecha a janela
- [ ] Posições dos botões definidas via constantes do CONFIGS

---

### 📋 Etapa 3.2 — Corrigir comportamento do `hide_window`

> **Problema atual:** O método `hide_window` dispara `send_choice(1)` automaticamente ao fechar a janela, causando recusa involuntária da quest quando o jogador fecha pelo botão X ou por outro evento.

#### 🔧 Correção:

| Comportamento | Antes (Incorreto) | Depois (Correto) |
|---------------|-------------------|-----------------|
| Fechar pelo botão X | `send_choice(1)` + `hide` | Apenas `hide` (sem efeito colateral) |
| Clicar "Aceitar" | `send_choice(0)` + `hide` | `send_choice(0)` + `hide` ✅ |
| Clicar "Recusar" | N/A (não existia) | `send_choice(1)` + `hide` ✅ |
| Timeout / outro evento | `send_choice(1)` + `hide` | Apenas `hide` (sem efeito colateral) |

#### 📝 Pseudocódigo da correção:

```ruby
# ANTES (incorreto):
def hide_window
  send_choice(1)   # ← REMOVER esta linha
  hide
end

# DEPOIS (correto):
def hide_window
  hide   # Apenas fecha visualmente, sem disparar escolha
end
```

#### ✅ Checklist da Etapa 3.2:
- [ ] `send_choice(1)` removido do método `hide_window`
- [ ] `hide_window` apenas fecha a janela visualmente
- [ ] Toda comunicação de escolha passa exclusivamente pelos botões
- [ ] Verificar se há outros lugares no código que dependiam do comportamento antigo

---

### 📋 Etapa 3.3 — Ajustar layout do diálogo

> Garantir que o layout dos botões e do texto do diálogo esteja correto após as modificações.

#### 🔧 Ajustes de layout:

| Elemento | Configuração |
|----------|-------------|
| Posição botão "Aceitar" | `x: QUEST_DIALOGUE_W / 4`, centralizado à esquerda |
| Posição botão "Recusar" | `x: QUEST_DIALOGUE_W * 3 / 4`, centralizado à direita |
| Espaçamento entre botões | Mínimo de `20px` de separação |
| Posição Y dos botões | `QUEST_DIALOGUE_H - 40` (rodapé da janela) |
| Largura de cada botão | `QUEST_DIALOGUE_W / 3` |

#### ✅ Checklist da Etapa 3.3:
- [ ] Botão "Aceitar" posicionado à esquerda com espaçamento correto
- [ ] Botão "Recusar" posicionado à direita com espaçamento correto
- [ ] Botões não se sobrepõem ao texto do diálogo
- [ ] Botões não ultrapassam os limites da janela
- [ ] Posições dos botões definidas via constantes do CONFIGS (sem hardcode)
- [ ] Layout testado com textos de diálogo curtos e longos

---

### 📋 Etapa 3.4 — Teste e Validação da Fase 3

| # | Teste | Resultado Esperado | ✅ |
|---|-------|-------------------|---|
| 1 | Falar com NPC de quest | Diálogo exibe botões "Aceitar" e "Recusar" | ⬜ |
| 2 | Clicar "Aceitar" | Quest adicionada ao log, janela fecha | ⬜ |
| 3 | Clicar "Recusar" | Quest não adicionada, janela fecha | ⬜ |
| 4 | Fechar janela pelo X | Janela fecha sem aceitar nem recusar | ⬜ |
| 5 | Fechar janela pelo X e falar com NPC novamente | Diálogo reabre normalmente | ⬜ |
| 6 | Layout com texto longo | Botões não sobrepõem o texto | ⬜ |
| 7 | Layout com texto curto | Botões posicionados corretamente no rodapé | ⬜ |

> 💾 **Backup:** Salvar `Window_Quest_v2.3.rb` após validação.

> 🏁 **Marco:** Após validar as Fases 1, 2 e 3, a **base do sistema está estável**. Faça um backup completo de todos os arquivos antes de prosseguir para as fases de média prioridade.

---

---

## 🎯 FASE 4 — Múltiplos Objetivos

> **Meta:** Permitir que uma quest tenha **mais de um objetivo simultâneo** — ex: matar 10 morcegos E coletar 5 asas — com progresso independente por objetivo.
>
> **Arquivos:** `[VS] Quests.rb` + `[VS] Game_Quest.rb` + `[VS] Window_Quest.rb`
>
> **Complexidade:** 🔴 Alta | **Risco:** 🔴 Alto

---

### 📋 Etapa 4.1 — Refatorar estrutura de dados em `Quests.rb`

> Substituir os campos simples `:enemy_id` e `:amount` por um array de objetivos estruturado.

#### 🔧 Estrutura de dados — Antes vs Depois:

**Antes (estrutura simples):**
```ruby
{
  :name     => "Caçada aos Morcegos",
  :enemy_id => 15,
  :amount   => 10,
  :desc     => "Elimine os morcegos das cavernas."
}
```

**Depois (estrutura com múltiplos objetivos):**
```ruby
{
  :name => "Caçada aos Morcegos",
  :desc => "Elimine os morcegos e colete suas asas.",
  :objectives => [
    { :type => :kill,    :id => 15, :amount => 10, :label => "Morcegos Malditos" },
    { :type => :collect, :id => 42, :amount => 5,  :label => "Asas de Morcego"   }
  ]
}
```

#### 📋 Tipos de objetivo suportados:

| Tipo | Símbolo | Descrição |
|------|---------|-----------|
| Matar inimigo | `:kill` | Eliminar X unidades de um inimigo |
| Coletar item | `:collect` | Obter X unidades de um item |
| Falar com NPC | `:talk` | Interagir com um NPC específico |
| Chegar a local | `:reach` | Entrar em um mapa específico |

#### 🔧 Compatibilidade retroativa:

> ⚠️ **Importante:** Quests antigas que usam `:enemy_id` e `:amount` devem continuar funcionando sem modificação.

```ruby
# Método de compatibilidade em Game_Quest:
def objectives
  if @data[:objectives]
    @data[:objectives]   # Novo formato
  else
    # Converter formato antigo para novo automaticamente
    [{ :type => :kill, :id => @data[:enemy_id], :amount => @data[:amount], :label => "Inimigos" }]
  end
end
```

#### ✅ Checklist da Etapa 4.1:
- [ ] Pelo menos 2 quests em `Quests.rb` atualizadas para o novo formato com `:objectives`
- [ ] Quests antigas com `:enemy_id` mantidas sem modificação (teste de retrocompatibilidade)
- [ ] Método `objectives` de compatibilidade implementado em `Game_Quest`
- [ ] Documentação do novo formato adicionada como comentário em `Quests.rb`

---

### 📋 Etapa 4.2 — Refatorar `Game_Quest` para múltiplos objetivos

> Transformar `@progress` de um `Integer` simples para um `Hash` indexado por objetivo.

#### 🔧 Mudanças na estrutura de `Game_Quest`:

| Elemento | Antes | Depois |
|----------|-------|--------|
| `@progress` | `Integer` (ex: `5`) | `Hash` (ex: `{ 0 => 5, 1 => 2 }`) |
| `progress_text` | `"5/10"` | Array de strings por objetivo |
| `objective_complete?` | Verifica único objetivo | `objective_complete?(index)` — verifica por índice |
| Novo método | N/A | `all_objectives_complete?` — verifica todos |
| `progress_percent` | Único valor | `progress_percent(index)` — por objetivo |

#### 📝 Pseudocódigo esperado:

```ruby
class Game_Quest
  def initialize(id)
    # ... código existente ...
    @progress = {}   # Hash: { índice_objetivo => progresso_atual }
  end

  # Incrementa progresso de um objetivo específico
  def increment_progress(index, amount = 1)
    @progress[index] ||= 0
    @progress[index] += amount
  end

  # Retorna progresso de um objetivo específico
  def get_progress(index)
    @progress[index] || 0
  end

  # Verifica se um objetivo específico foi concluído
  def objective_complete?(index)
    get_progress(index) >= objectives[index][:amount]
  end

  # Verifica se TODOS os objetivos foram concluídos
  def all_objectives_complete?
    objectives.each_index.all? { |i| objective_complete?(i) }
  end
end
```

#### ✅ Checklist da Etapa 4.2:
- [ ] `@progress` inicializado como `Hash` vazio `{}`
- [ ] Método `increment_progress(index, amount)` implementado
- [ ] Método `get_progress(index)` implementado
- [ ] Método `objective_complete?(index)` implementado
- [ ] Método `all_objectives_complete?` implementado
- [ ] Método `progress_percent(index)` atualizado para receber índice
- [ ] Retrocompatibilidade: quests antigas (formato simples) funcionam com índice `0`

---

### 📋 Etapa 4.3 — Exibir múltiplos objetivos no `Window_QuestInfo`

> Modificar o `refresh` da janela de detalhes para iterar sobre todos os objetivos e exibir cada um com seu status individual.

#### 🎨 Layout esperado com múltiplos objetivos:

```
┌──────────────────────────────────────────┐
│ 🗡️ Caçada aos Morcegos                   │
│ ─────────────────────────────────────── │
│ Elimine os morcegos e colete suas asas.  │
│                                          │
│ Objetivos:                               │
│  ✓ Morcegos Malditos:  10/10            │  ← verde (completo)
│    [████████████████████] 100%          │
│  ✗ Asas de Morcego:     2/5             │  ← cinza (incompleto)
│    [████████░░░░░░░░░░░░] 40%           │
│                                          │
│ Recompensa:                              │
│  💰 500 Gold   ⭐ 200 EXP               │
└──────────────────────────────────────────┘
```

#### 🔧 Lógica de exibição por objetivo:

| Estado | Ícone | Cor do texto |
|--------|-------|-------------|
| Completo | `✓` | 🟢 Verde — `text_color(3)` |
| Incompleto | `✗` | ⚪ Normal — `normal_color` |

#### ✅ Checklist da Etapa 4.3:
- [ ] Loop `objectives.each_with_index` implementado no `refresh`
- [ ] Cada objetivo exibe ícone `✓` ou `✗` conforme `objective_complete?(i)`
- [ ] Cada objetivo exibe texto `"Label: progresso/total"`
- [ ] Barra de progresso individual desenhada para cada objetivo
- [ ] Posições Y calculadas dinamicamente (sem hardcode) para acomodar N objetivos
- [ ] Layout não quebra com 1, 2 ou 3 objetivos

---

### 📋 Etapa 4.4 — Teste e Validação da Fase 4

| # | Teste | Resultado Esperado | ✅ |
|---|-------|-------------------|---|
| 1 | Quest com 1 objetivo (formato antigo) | Funciona normalmente, sem erros | ⬜ |
| 2 | Quest com 2 objetivos | Ambos exibidos na janela de detalhes | ⬜ |
| 3 | Completar apenas 1 de 2 objetivos | Quest NÃO marcada como pronta | ⬜ |
| 4 | Completar ambos os objetivos | Quest marcada como pronta para entregar | ⬜ |
| 5 | Progresso independente por objetivo | Incrementar obj.0 não afeta obj.1 | ⬜ |
| 6 | Quest antiga com `:enemy_id` | Retrocompatibilidade funciona sem erros | ⬜ |
| 7 | 3 objetivos na mesma quest | Layout da janela acomoda sem quebrar | ⬜ |

> 💾 **Backup:** Salvar `Window_Quest_v2.4.rb`, `Game_Quest_v2.4.rb` e `Quests_v2.4.rb`.

---

---

## 🗂️ FASE 5 — Categorias + Abas Extras

> **Meta:** Classificar quests por categoria (Principal, Secundária, Diária, Guilda) e adicionar uma aba "Diárias" inspirada em Ragnarok Online e World of Warcraft.
>
> **Arquivos:** `[VS] Quests.rb` + `[VS] Window_Quest.rb`
>
> **Complexidade:** 🟡 Média | **Risco:** 🟡 Médio

---

### 📋 Etapa 5.1 — Adicionar campo `:category` em `Quests.rb`

> Adicionar o campo `:category` a cada quest, com um valor padrão para quests que não o definirem.

#### 📋 Categorias disponíveis:

| Símbolo | Nome Exibido | Cor | Ícone |
|---------|-------------|-----|-------|
| `:main` | Missão Principal | 🟡 Dourado | `⭐` |
| `:side` | Missão Secundária | ⚪ Branco | `📜` |
| `:daily` | Missão Diária | 🔵 Azul | `🔄` |
| `:guild` | Missão de Guilda | 🟣 Roxo | `🛡️` |

#### 🔧 Exemplo de quest com categoria:

```ruby
{
  :name     => "Caçada aos Morcegos",
  :category => :daily,   # ← novo campo
  :desc     => "Missão diária: elimine os morcegos.",
  :objectives => [...]
}
```

#### 🔧 Valor padrão para quests sem `:category`:

```ruby
# Em Game_Quest, método para obter categoria com fallback:
def category
  @data[:category] || :side   # Padrão: missão secundária
end
```

#### ✅ Checklist da Etapa 5.1:
- [ ] Campo `:category` adicionado a pelo menos 1 quest de cada tipo em `Quests.rb`
- [ ] Método `category` com fallback implementado em `Game_Quest`
- [ ] Tabela de categorias documentada como comentário em `Quests.rb`
- [ ] Quests sem `:category` retornam `:side` por padrão (sem erros)

---

### 📋 Etapa 5.2 — Adicionar terceira aba "Diárias" no `Tab_Control`

> Expandir o controle de abas para incluir a aba "Diárias", com filtro automático por categoria.

#### 🔧 Estrutura das abas:

| Índice | Nome da Aba | Filtro Aplicado |
|--------|------------|----------------|
| `0` | Em Progresso | `in_progress?` (todas as categorias) |
| `1` | Concluídas | `finished?` (todas as categorias) |
| `2` | Diárias | `in_progress? && category == :daily` |

#### 🔧 Modificação no `make_list`:

```ruby
def make_list
  @data = []
  $game_quests.each do |quest|
    case @tab_index
    when 0  # Em Progresso
      @data << quest if quest.in_progress?
    when 1  # Concluídas
      @data << quest if quest.finished?
    when 2  # Diárias
      @data << quest if quest.in_progress? && quest.category == :daily
    end
  end
end
```

#### ✅ Checklist da Etapa 5.2:
- [ ] Terceira aba "Diárias" adicionada ao `Tab_Control`
- [ ] `make_list` atualizado com filtro para aba de diárias
- [ ] Trocar de aba atualiza a lista corretamente
- [ ] Aba "Diárias" vazia exibe mensagem "Nenhuma missão diária ativa"
- [ ] Índice da aba ativa persiste ao fechar e reabrir o menu

---

### 📋 Etapa 5.3 — Exibir categoria na `Window_QuestInfo`

> Adicionar uma linha de categoria nos detalhes da quest, com cor e ícone correspondentes.

#### 🎨 Layout esperado:

```
┌──────────────────────────────────────────┐
│ 🗡️ Caçada aos Morcegos                   │
│ Tipo: 🔄 Missão Diária                   │  ← linha de categoria (azul)
│ ─────────────────────────────────────── │
│ ...                                      │
└──────────────────────────────────────────┘
```

#### ✅ Checklist da Etapa 5.3:
- [ ] Linha "Tipo: [ícone] [nome da categoria]" adicionada ao `refresh`
- [ ] Cor do texto varia conforme a categoria (tabela da Etapa 5.1)
- [ ] Ícone da categoria exibido antes do nome
- [ ] Posição Y calculada via `line_height` (sem hardcode)

---

### 📋 Etapa 5.4 — Teste e Validação da Fase 5

| # | Teste | Resultado Esperado | ✅ |
|---|-------|-------------------|---|
| 1 | Abrir menu de quests | 3 abas visíveis: Em Progresso, Concluídas, Diárias | ⬜ |
| 2 | Clicar na aba "Diárias" | Apenas quests com `:daily` aparecem | ⬜ |
| 3 | Quest sem `:category` | Aparece na aba "Em Progresso" normalmente | ⬜ |
| 4 | Selecionar quest diária | Detalhes exibem "Tipo: 🔄 Missão Diária" em azul | ⬜ |
| 5 | Selecionar quest principal | Detalhes exibem "Tipo: ⭐ Missão Principal" em dourado | ⬜ |
| 6 | Aba "Diárias" sem quests | Exibe mensagem de lista vazia | ⬜ |

> 💾 **Backup:** Salvar `Window_Quest_v2.5.rb` e `Quests_v2.5.rb`.

---

---

## 🎁 FASE 6 — Múltiplas Recompensas de Item

> **Meta:** Suportar **mais de um item** como recompensa de quest, exibindo todos os itens com ícone e quantidade tanto na janela de detalhes quanto no diálogo do NPC.
>
> **Arquivos:** `[VS] Quests.rb` + `[VS] Game_Quest.rb` + `[VS] Window_Quest.rb`
>
> **Complexidade:** 🟡 Média | **Risco:** 🟡 Médio

---

### 📋 Etapa 6.1 — Refatorar estrutura de recompensas em `Quests.rb`

> Substituir o campo simples `:rew_item_id` por uma estrutura de recompensas completa.

#### 🔧 Estrutura — Antes vs Depois:

**Antes:**
```ruby
{
  :rew_exp     => 200,
  :rew_gold    => 500,
  :rew_item_id => 42,
  :rew_item_kind => 1
}
```

**Depois:**
```ruby
{
  :rewards => {
    :exp   => 200,
    :gold  => 500,
    :items => [
      { :id => 42, :kind => 1, :amount => 1 },
      { :id => 15, :kind => 2, :amount => 3 }
    ]
  }
}
```

#### 📋 Tipos de item (`:kind`):

| Valor | Tipo |
|-------|------|
| `1` | Item comum (`$data_items`) |
| `2` | Arma (`$data_weapons`) |
| `3` | Armadura (`$data_armors`) |

#### ✅ Checklist da Etapa 6.1:
- [ ] Pelo menos 2 quests em `Quests.rb` atualizadas com nova estrutura `:rewards`
- [ ] Quests com múltiplos itens de recompensa criadas para teste
- [ ] Documentação do novo formato adicionada como comentário

---

### 📋 Etapa 6.2 — Atualizar `Game_Quest::Reward` para lista de itens

> Atualizar a classe/módulo de recompensas para suportar múltiplos itens com retrocompatibilidade.

#### 🔧 Métodos a implementar/atualizar:

| Método | Retorno | Descrição |
|--------|---------|-----------|
| `reward.items` | `Array` de objetos | Lista de todos os itens de recompensa |
| `reward.item` | Objeto único | Retrocompatibilidade — retorna `items.first` |
| `reward.exp` | `Integer` | EXP de recompensa |
| `reward.gold` | `Integer` | Gold de recompensa |

#### 🔧 Retrocompatibilidade:

```ruby
# Método que lê tanto o formato antigo quanto o novo:
def items
  if @data[:rewards] && @data[:rewards][:items]
    @data[:rewards][:items]   # Novo formato
  elsif @data[:rew_item_id]
    # Converter formato antigo automaticamente
    [{ :id => @data[:rew_item_id], :kind => @data[:rew_item_kind], :amount => 1 }]
  else
    []
  end
end
```

#### ✅ Checklist da Etapa 6.2:
- [ ] Método `items` implementado com retrocompatibilidade
- [ ] Método `item` (singular) mantido para compatibilidade
- [ ] Métodos `exp` e `gold` atualizados para ler novo formato
- [ ] Quest sem recompensa de item retorna array vazio sem erros

---

### 📋 Etapa 6.3 — Atualizar `Window_QuestInfo` para múltiplos ícones

> Modificar a seção de recompensas para exibir todos os itens em loop, lado a lado.

#### 🎨 Layout esperado com múltiplos itens:

```
Recompensa:
  💰 500 Gold   ⭐ 200 EXP
  [🗡️ x1]  [🛡️ x3]  [🧪 x2]   ← ícones lado a lado
```

#### 🔧 Lógica de exibição:

```ruby
# Loop para desenhar ícones de itens lado a lado:
reward.items.each_with_index do |item_data, i|
  icon_x = base_x + (i * (24 + 4))   # 24px ícone + 4px espaçamento
  draw_icon(item_data[:id], icon_x, icon_y)
  draw_text(icon_x, icon_y + 24, "x#{item_data[:amount]}")
end
```

#### ✅ Checklist da Etapa 6.3:
- [ ] Loop `reward.items.each_with_index` implementado no `refresh`
- [ ] Ícone de cada item desenhado com `draw_icon`
- [ ] Quantidade exibida abaixo de cada ícone
- [ ] Ícones posicionados lado a lado sem sobreposição
- [ ] Layout não quebra com 1, 2 ou 3 itens de recompensa
- [ ] Quest sem item de recompensa não exibe seção de ícones

---

### 📋 Etapa 6.4 — Atualizar `Window_QuestDialogue` igualmente

> Replicar a mesma lógica de múltiplos ícones no diálogo do NPC ao oferecer a quest.

#### ✅ Checklist da Etapa 6.4:
- [ ] Seção de recompensas no diálogo atualizada com loop de itens
- [ ] Layout do diálogo acomoda múltiplos ícones sem quebrar
- [ ] Consistência visual entre `Window_QuestInfo` e `Window_QuestDialogue`

---

### 📋 Etapa 6.5 — Teste e Validação da Fase 6

| # | Teste | Resultado Esperado | ✅ |
|---|-------|-------------------|---|
| 1 | Quest com 1 item (formato antigo) | Ícone exibido normalmente | ⬜ |
| 2 | Quest com 2 itens (novo formato) | 2 ícones lado a lado nos detalhes | ⬜ |
| 3 | Quest com 3 itens | 3 ícones lado a lado sem sobreposição | ⬜ |
| 4 | Quest sem item de recompensa | Seção de ícones não aparece | ⬜ |
| 5 | Diálogo do NPC com 2 itens | Ícones exibidos corretamente no diálogo | ⬜ |
| 6 | Aceitar quest com múltiplos itens | Todos os itens entregues ao concluir | ⬜ |

> 💾 **Backup:** Salvar `Window_Quest_v2.6.rb`, `Game_Quest_v2.6.rb` e `Quests_v2.6.rb`.

---

---

## ✨ FASE 7 — Highlight "Pronta para Entregar"

> **Meta:** Destacar visualmente as quests cujos objetivos foram **completamente cumpridos**, com cor dourada e ícone especial, facilitando a identificação pelo jogador — padrão WoW/Ragnarok.
>
> **Arquivo principal:** `[VS] Window_Quest.rb`
>
> **Complexidade:** 🟢 Baixa | **Risco:** 🟢 Baixo

---

### 📋 Etapa 7.1 — Detectar estado "ready to deliver"

> Implementar o estado lógico `ready_to_deliver?` que combina `in_progress?` com `all_objectives_complete?`.

#### 🔧 Hierarquia de estados de uma quest:

```
Quest
 ├── not_started?       → Ainda não foi aceita
 ├── in_progress?
 │    ├── ready_to_deliver?   → Todos objetivos completos, aguardando entrega
 │    └── (em andamento)      → Objetivos ainda não completos
 └── finished?          → Entregue e concluída
```

#### 📝 Implementação em `Game_Quest`:

```ruby
# Retorna true se a quest está em progresso E todos os objetivos foram cumpridos
def ready_to_deliver?
  in_progress? && all_objectives_complete?
end
```

#### ✅ Checklist da Etapa 7.1:
- [ ] Método `ready_to_deliver?` implementado em `Game_Quest`
- [ ] Método retorna `false` para quests não iniciadas
- [ ] Método retorna `false` para quests com objetivos incompletos
- [ ] Método retorna `true` apenas quando `in_progress? && all_objectives_complete?`
- [ ] Método retorna `false` para quests já concluídas (`finished?`)

---

### 📋 Etapa 7.2 — Aplicar highlight na `Window_Quest` (lista)

> Modificar o `draw_item` para aplicar cor dourada e ícone especial às quests prontas para entrega.

#### 🎨 Tabela de estilos por estado:

| Estado | Cor do Nome | Ícone | Cor do Progresso |
|--------|------------|-------|-----------------|
| `ready_to_deliver?` | 🟡 Dourado `text_color(14)` | `QUEST_READY_ICON` | 🟡 Dourado |
| `in_progress?` (normal) | ⚪ Normal | `QUEST_IN_PROGRESS_ICON` | ⚪ Normal |
| `finished?` | 🟢 Verde `text_color(3)` | `QUEST_FINISHED_ICON` | 🟢 Verde |

#### 🔧 Nova constante no CONFIGS:

```ruby
# Em module Configs:
QUEST_READY_ICON = 79   # Ícone para quest pronta para entregar (configurável)
```

#### 📝 Lógica no `draw_item`:

```ruby
def draw_item(index)
  quest = @data[index]
  # Determinar cor e ícone conforme estado
  if quest.ready_to_deliver?
    color = text_color(14)   # Dourado
    icon  = Configs::QUEST_READY_ICON
  elsif quest.finished?
    color = text_color(3)    # Verde
    icon  = Configs::QUEST_FINISHED_ICON
  else
    color = normal_color
    icon  = Configs::QUEST_IN_PROGRESS_ICON
  end
  # Desenhar ícone e nome com a cor determinada
  draw_icon(icon, x, y)
  change_color(color)
  draw_text(x + 26, y, width - 26, line_height, quest.name)
end
```

#### ✅ Checklist da Etapa 7.2:
- [ ] Constante `QUEST_READY_ICON` adicionada ao bloco CONFIGS
- [ ] `draw_item` verifica `ready_to_deliver?` antes de `in_progress?`
- [ ] Cor dourada aplicada ao nome e progresso quando `ready_to_deliver?`
- [ ] Ícone especial `QUEST_READY_ICON` exibido quando `ready_to_deliver?`
- [ ] Estados `in_progress?` e `finished?` mantêm comportamento anterior

---

### 📋 Etapa 7.3 — Teste e Validação da Fase 7

| # | Teste | Resultado Esperado | ✅ |
|---|-------|-------------------|---|
| 1 | Quest com objetivos incompletos | Ícone e cor normais na lista | ⬜ |
| 2 | Completar todos os objetivos | Quest muda para dourado + ícone especial | ⬜ |
| 3 | Quest já concluída (finished) | Exibe verde, NÃO dourado | ⬜ |
| 4 | Alterar `QUEST_READY_ICON` no CONFIGS | Ícone muda corretamente | ⬜ |
| 5 | Múltiplas quests prontas | Todas exibem dourado simultaneamente | ⬜ |

> 💾 **Backup:** Salvar `Window_Quest_v2.7.rb` e `Game_Quest_v2.7.rb`.

---

---

## 🪄 FASE 8 — Polish Final

> **Meta:** Refinamentos de UX que elevam a qualidade percebida do sistema — contadores nas abas, NPC de entrega nos detalhes, e sons de feedback para ações de quest.
>
> **Arquivo principal:** `[VS] Window_Quest.rb`
>
> **Complexidade:** 🟢 Baixa | **Risco:** 🟢 Baixo

---

### 📋 Etapa 8.1 — Contador de quests no título das abas

> Exibir a quantidade de quests em cada aba diretamente no título, como `"Em Progresso (3)"`.

#### 🎨 Formato esperado:

| Aba | Formato | Exemplo |
|-----|---------|---------|
| Em Progresso | `"Em Progresso (N)"` | `"Em Progresso (3)"` |
| Concluídas | `"Concluídas (N)"` | `"Concluídas (12)"` |
| Diárias | `"Diárias (N)"` | `"Diárias (1)"` |

#### 🔧 Lógica de contagem:

```ruby
# Contar quests por aba:
def tab_label(index)
  case index
  when 0
    count = $game_quests.count(&:in_progress?)
    "#{Vocab::InProgress} (#{count})"
  when 1
    count = $game_quests.count(&:finished?)
    "#{Vocab::Completed} (#{count})"
  when 2
    count = $game_quests.count { |q| q.in_progress? && q.category == :daily }
    "#{Vocab::Daily} (#{count})"
  end
end
```

#### ✅ Checklist da Etapa 8.1:
- [ ] Método `tab_label(index)` implementado com contagem dinâmica
- [ ] Títulos das abas atualizados para usar `tab_label`
- [ ] Contador atualiza ao aceitar ou concluir uma quest
- [ ] Contador exibe `(0)` quando a aba está vazia (não omite)

---

### 📋 Etapa 8.2 — NPC de entrega no `Window_QuestInfo`

> Exibir no rodapé da janela de detalhes o nome do NPC para quem a quest deve ser entregue.

#### 🔧 Novo campo em `Quests.rb`:

```ruby
{
  :name         => "Caçada aos Morcegos",
  :npc_receive  => "Capitão Aldric",   # ← novo campo
  # ...
}
```

#### 🎨 Layout esperado no rodapé:

```
┌──────────────────────────────────────────┐
│ ...                                      │
│ ─────────────────────────────────────── │
│ 📍 Entregar para: Capitão Aldric         │  ← rodapé (cor diferenciada)
└──────────────────────────────────────────┘
```

#### ✅ Checklist da Etapa 8.2:
- [ ] Campo `:npc_receive` adicionado a pelo menos 2 quests em `Quests.rb`
- [ ] Linha "Entregar para: [Nome]" exibida no rodapé da `Window_QuestInfo`
- [ ] Linha só aparece quando `:npc_receive` está definido (sem erros se ausente)
- [ ] Cor diferenciada para o nome do NPC (ex: `text_color(6)` — amarelo claro)

---

### 📋 Etapa 8.3 — Sons de quest

> Adicionar feedback sonoro para as principais ações do sistema de quests.

#### 🔊 Tabela de sons:

| Ação | Método | Som Sugerido |
|------|--------|-------------|
| Aceitar quest | `Sound.play_quest_accept` | `"Decision"` ou som customizado |
| Concluir quest | `Sound.play_quest_complete` | `"Chime"` ou som customizado |
| Recusar quest | `Sound.play_cancel` | `"Cancel"` (já existente) |
| Abrir menu de quests | `Sound.play_open_quest` | `"Book"` ou som customizado |

#### 🔧 Implementação no módulo `Sound`:

```ruby
module Sound
  # Som ao aceitar uma quest
  def self.play_quest_accept
    Audio.se_play("Audio/SE/Decision", 80, 100)
  end

  # Som ao concluir uma quest
  def self.play_quest_complete
    Audio.se_play("Audio/SE/Chime", 100, 100)
  end

  # Som ao abrir o menu de quests
  def self.play_open_quest
    Audio.se_play("Audio/SE/Book", 80, 100)
  end
end
```

#### 🔧 Constantes de som no CONFIGS:

```ruby
# Em module Configs — Sons do sistema de quests:
QUEST_SOUND_ACCEPT   = "Decision"   # Nome do arquivo SE (sem extensão)
QUEST_SOUND_COMPLETE = "Chime"      # Nome do arquivo SE (sem extensão)
QUEST_SOUND_OPEN     = "Book"       # Nome do arquivo SE (sem extensão)
```

#### ✅ Checklist da Etapa 8.3:
- [ ] Constantes de som adicionadas ao bloco CONFIGS
- [ ] Métodos `Sound.play_quest_accept` e `play_quest_complete` implementados
- [ ] Som de aceitar disparado ao clicar "Aceitar" no diálogo
- [ ] Som de concluir disparado ao entregar a quest ao NPC
- [ ] Som de recusar usa `Sound.play_cancel` existente
- [ ] Sons configuráveis via CONFIGS (nome do arquivo SE)
- [ ] Testar com arquivos SE ausentes — não deve causar crash

---

### 📋 Etapa 8.4 — Teste e Validação da Fase 8

| # | Teste | Resultado Esperado | ✅ |
|---|-------|-------------------|---|
| 1 | Abrir menu com 3 quests em progresso | Aba exibe "Em Progresso (3)" | ⬜ |
| 2 | Aceitar nova quest | Contador da aba incrementa para `(4)` | ⬜ |
| 3 | Concluir uma quest | Contador "Em Progresso" decrementa, "Concluídas" incrementa | ⬜ |
| 4 | Quest com `:npc_receive` definido | Rodapé exibe "Entregar para: [Nome]" | ⬜ |
| 5 | Quest sem `:npc_receive` | Rodapé não exibe linha de NPC (sem erros) | ⬜ |
| 6 | Aceitar quest | Som de aceitar toca | ⬜ |
| 7 | Concluir quest | Som de conclusão toca | ⬜ |
| 8 | Recusar quest | Som de cancelar toca | ⬜ |
| 9 | Alterar `QUEST_SOUND_ACCEPT` no CONFIGS | Som muda corretamente | ⬜ |

> 💾 **Backup:** Salvar versão final `Window_Quest_v2.8.rb` — **versão de release**.

---

---

## 🏁 Checklist Geral de Conclusão

> Use esta tabela para acompanhar o progresso geral do plano de implementação.

| Fase | Nome | Concluída | Backup Salvo | Versão |
|------|------|-----------|-------------|--------|
| 1 | 📦 CONFIGS + Reorganização | ⬜ | ⬜ | `v2.1` |
| 2 | 📊 Rastreamento de Progresso | ⬜ | ⬜ | `v2.2` |
| 3 | ❌ Botão Recusar + Dialogue | ⬜ | ⬜ | `v2.3` |
| 4 | 🎯 Múltiplos Objetivos | ⬜ | ⬜ | `v2.4` |
| 5 | 🗂️ Categorias + Abas | ⬜ | ⬜ | `v2.5` |
| 6 | 🎁 Múltiplas Recompensas | ⬜ | ⬜ | `v2.6` |
| 7 | ✨ Highlight "Pronta" | ⬜ | ⬜ | `v2.7` |
| 8 | 🪄 Polish Final | ⬜ | ⬜ | `v2.8` |

---

## 💡 Dicas Gerais

> - 🔁 **Uma mudança por vez:** Nunca implemente duas etapas simultaneamente. Teste cada uma antes de avançar.
> - 💾 **Backup por fase:** Salve uma cópia versionada ao final de cada fase validada.
> - 🧪 **Teste de regressão:** Ao concluir cada fase, re-execute os testes das fases anteriores para garantir que nada foi quebrado.
> - 📝 **Comentários no código:** Cada novo método deve ter um comentário de cabeçalho explicando seu propósito, parâmetros e retorno.
> - ⚠️ **Retrocompatibilidade:** Quests existentes no servidor não devem ser afetadas pelas mudanças de estrutura de dados — sempre implemente fallbacks.
> - 🎮 **Teste em jogo real:** Além dos testes unitários, sempre teste o fluxo completo em jogo (falar com NPC → aceitar → progredir → entregar).