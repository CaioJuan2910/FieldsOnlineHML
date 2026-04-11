# Fields Online — Plano de Desenvolvimento MMORPG 2D

> **Versão do Documento:** 1.0.0 | **Data:** 08 de Abril de 2026 | **Autor:** Caio Juan De Lima Silva
> **Repositório:** https://github.com/CaioJuan2910/FieldsOnlineHML

---

## Índice

- [1. Visão Geral do Projeto](#1-visão-geral-do-projeto)
  - [1.1 Conceito](#11-conceito)
  - [1.2 Diferencial Competitivo](#12-diferencial-competitivo)
  - [1.3 Pilares do Design](#13-pilares-do-design)
- [2. Análise Técnica](#2-análise-técnica)
  - [2.1 Stack Tecnológico](#21-stack-tecnológico)
  - [2.2 Arquitetura Client-Server](#22-arquitetura-client-server)
  - [2.3 Módulos do Server já Implementados](#23-módulos-do-server-já-implementados)
  - [2.4 Scripts do Client já Implementados](#24-scripts-do-client-já-implementados)
  - [2.5 Limitações e Potencialidades](#25-limitações-e-potencialidades)
- [3. Sistemas Core do Jogo](#3-sistemas-core-do-jogo)
  - [3.1 Sistema de Combate](#31-sistema-de-combate)
  - [3.2 Sistema de Classes/Jobs](#32-sistema-de-classesjobs)
  - [3.3 Sistema de Itens e Inventário](#33-sistema-de-itens-e-inventário)
  - [3.4 Sistema de Party](#34-sistema-de-party)
  - [3.5 Sistema de Guild](#35-sistema-de-guild)
  - [3.6 Sistema de PvP](#36-sistema-de-pvp)
  - [3.7 Sistema de Quests](#37-sistema-de-quests)
  - [3.8 Sistema de Economia](#38-sistema-de-economia)
  - [3.9 Sistema de Chat e Social](#39-sistema-de-chat-e-social)
  - [3.10 Sistema de Progressão](#310-sistema-de-progressão)
- [4. Plano de Desenvolvimento por Fases](#4-plano-de-desenvolvimento-por-fases)
  - [Fase 1 — Fundação](#fase-1--fundação-semanas-18)
  - [Fase 2 — Expansão](#fase-2--expansão-semanas-920)
  - [Fase 3 — Polimento](#fase-3--polimento-semanas-2132)
  - [Fase 4 — Beta e Lançamento](#fase-4--beta-e-lançamento-semanas-3340)
- [5. Roadmap Técnico](#5-roadmap-técnico)
  - [5.1 Estrutura de Pastas Recomendada](#51-estrutura-de-pastas-recomendada)
  - [5.2 Scripts/Plugins Prioritários](#52-scriptsplugins-prioritários-a-desenvolver)
  - [5.3 Convenções de Código Ruby/RGSS3](#53-convenções-de-código-rubyrgss3)
  - [5.4 Integração Client-Server](#54-integração-client-server)
  - [5.5 Database e Persistência](#55-database-e-persistência)
- [6. Cronograma Estimado](#6-cronograma-estimado)
  - [6.1 Timeline Visual (Gantt ASCII)](#61-timeline-visual-gantt-ascii)
  - [6.2 Milestones Principais](#62-milestones-principais)
  - [6.3 Recursos Necessários](#63-recursos-necessários)
- [7. Considerações e Riscos](#7-considerações-e-riscos)
  - [7.1 Desafios Técnicos](#71-desafios-técnicos)
  - [7.2 Boas Práticas Recomendadas](#72-boas-práticas-recomendadas)
  - [7.3 Referências e Recursos](#73-referências-e-recursos)
- [Apêndice A — Inventário Completo de Scripts](#apêndice-a--inventário-completo-de-scripts)
- [Apêndice B — Glossário Técnico](#apêndice-b--glossário-técnico)

---

## 1. Visão Geral do Projeto

### 1.1 Conceito

| Campo         | Detalhe                                                                 |
|---------------|-------------------------------------------------------------------------|
| **Nome**      | Fields Online                                                           |
| **Gênero**    | MMORPG 2D Top-Down                                                      |
| **Engine**    | RPG Maker VX Ace + VXA-OS v2.1.6                                        |
| **Plataforma**| PC (Windows)                                                            |
| **Tagline**   | *"Explore os campos, forje sua lenda, domine o mundo."*                 |

**Pitch:**

Fields Online é um MMORPG 2D de perspectiva top-down que resgata a essência dos grandes clássicos do gênero — Tibia, Ragnarok Online, MU Online, Diablo e World of Warcraft — e os reinterpreta em um mundo persistente, vivo e repleto de possibilidades. O jogador começa como um aventureiro anônimo em um vasto mundo de campos, florestas, masmorras e cidades, onde cada decisão molda sua trajetória: a classe escolhida, os itens coletados, as alianças formadas e os inimigos derrotados constroem uma identidade única e irreplicável.

O coração do jogo é seu sistema de progressão multicamada: classes com especializações profundas, itens com atributos aleatórios e sistema de upgrade até +15, dungeons desafiadoras com mecânicas de MVP, e um ecossistema econômico robusto sustentado por comércio entre jogadores, leilões e profissões. O combate em tempo real, processado inteiramente no servidor para garantir integridade e anti-cheat, oferece uma experiência fluida e justa, onde habilidade e estratégia são tão importantes quanto o nível do personagem.

A comunidade é o pilar central de Fields Online. Sistemas de Party, Guild, PvP aberto com karma, Guild Wars e eventos mundiais garantem que o jogo seja uma experiência social rica. O mundo é dinâmico: eventos sazonais, drops raros disputados, rankings públicos e conquistas exclusivas mantêm os jogadores engajados a longo prazo. Fields Online não é apenas um jogo — é um mundo para se viver.

**Público-alvo:**

| Critério       | Detalhe                                                                 |
|----------------|-------------------------------------------------------------------------|
| Faixa etária   | 16 a 35 anos                                                            |
| Perfil         | Jogadores nostálgicos de MMORPGs clássicos, fãs de RPG 2D, comunidade RPG Maker |
| Plataforma     | PC Windows (desktop)                                                    |
| Experiência    | Casual a hardcore — progressão acessível, profundidade para veteranos   |

---

### 1.2 Diferencial Competitivo

| Mecânica                          | Tibia | MU Online | Ragnarok | Diablo | WoW | Fields Online |
|-----------------------------------|:-----:|:---------:|:--------:|:------:|:---:|:-------------:|
| Visão top-down 2D                 | ✅    | ❌        | ✅       | ✅     | ❌  | ✅            |
| PvP aberto com karma              | ✅    | ✅        | ❌       | ❌     | ❌  | ✅            |
| Sistema de upgrade de itens (+N)  | ❌    | ✅        | ✅       | ❌     | ❌  | ✅            |
| Job system multicamada            | ❌    | ✅        | ✅       | ❌     | ✅  | ✅            |
| Loot aleatório com afixos         | ❌    | ❌        | ❌       | ✅     | ✅  | ✅            |
| Quest chains estruturadas         | ❌    | ❌        | ❌       | ❌     | ✅  | ✅            |
| Guild Wars                        | ❌    | ✅        | ✅       | ❌     | ✅  | ✅            |
| MVP/Boss system                   | ❌    | ✅        | ✅       | ✅     | ✅  | ✅            |
| Economia player-driven            | ✅    | ❌        | ✅       | ❌     | ✅  | ✅            |
| Projéteis e skills visuais        | ✅    | ✅        | ✅       | ✅     | ✅  | ✅            |
| Engine acessível (RPG Maker)      | ❌    | ❌        | ❌       | ❌     | ❌  | ✅            |

> 📌 **Fields Online é o único MMORPG 2D top-down que combina TODAS essas mecânicas em uma engine acessível e customizável via Ruby/RGSS3.**

---

### 1.3 Pilares do Design

#### 🗺️ Exploração
O mundo de Fields Online é vasto e recompensador. Mapas interconectados, dungeons secretas, áreas de alto risco/alta recompensa e eventos de mundo incentivam o jogador a sempre ir além do horizonte. Cada área tem sua identidade visual, fauna de monstros e loot exclusivo.

#### ⚔️ Combate
Combate em tempo real, fluido e estratégico. Posicionamento importa, skills têm cooldowns e custos de mana, projéteis podem ser esquivados, e debuffs mudam o rumo de batalhas. O servidor processa toda a lógica de combate, garantindo fairness e anti-cheat.

#### 💎 Progressão
Múltiplas camadas de progressão mantêm o jogador sempre com objetivos: level up, evolução de classe, upgrade de equipamentos, desbloqueio de skills, conquistas, títulos e rankings. Não existe "fim de jogo" — sempre há algo a melhorar.

#### 🏰 Comunidade
Party, Guild, amizades, comércio entre jogadores, eventos coletivos e Guild Wars criam laços sociais duradouros. O jogo é projetado para ser melhor com outros jogadores do que sozinho.

#### 💰 Economia
Um ecossistema econômico saudável e player-driven: lojas de NPC para itens básicos, comércio direto entre jogadores (Trade), casa de leilões, banco seguro e sistema monetário em camadas (Cobre → Prata → Ouro → Platina). Profissões como Ferreiro e Alquimista alimentam a economia com itens craftados.

---

## 2. Análise Técnica

### 2.1 Stack Tecnológico

| Componente       | Tecnologia                  | Versão        | Responsabilidade                                      |
|------------------|-----------------------------|---------------|-------------------------------------------------------|
| Engine           | RPG Maker VX Ace            | 1.02a         | Renderização, eventos, mapas, assets                  |
| Framework MMO    | VXA-OS (Valentine90)        | v2.1.6        | Camada de rede, sistemas MMO, scripts customizados    |
| Linguagem Client | Ruby / RGSS3                | Ruby 1.9.x    | Lógica do cliente, UI, scripts de jogo                |
| Linguagem Server | Ruby puro                   | Ruby 2.x+     | Lógica de servidor, processamento de pacotes          |
| Rede             | EventMachine                | ~1.2.x        | I/O assíncrono, gerenciamento de conexões TCP         |
| Protocolo        | TCP Sockets customizados    | —             | Comunicação bidirecional client-server                |
| Banco de Dados   | MySQL / SQLite              | MySQL 5.7+    | Persistência de dados de jogadores, itens, guilds     |
| Serialização     | Buffer customizado (VXA-OS) | —             | Empacotamento/desempacotamento de dados de rede       |
| Assets           | PNG, OGG, MIDI              | —             | Gráficos, sons, músicas do jogo                       |
| Controle Versão  | Git / GitHub                | —             | Versionamento do código e assets                      |

---

### 2.2 Arquitetura Client-Server

```
┌─────────────────────────────────────────────────────────────────────┐
│                         FIELDS ONLINE                               │
│                    Arquitetura Client-Server                        │
└─────────────────────────────────────────────────────────────────────┘

  ┌──────────────────────────────────┐
  │           CLIENT (PC)            │
  │  ┌────────────────────────────┐  │
  │  │  RPG Maker VX Ace (RGSS3)  │  │
  │  │  ┌──────────┐ ┌─────────┐  │  │
  │  │  │ Scene_Map│ │Sprite_  │  │  │
  │  │  │ Scene_   │ │HUD/Drop │  │  │
  │  │  │ Login    │ │Minimap  │  │  │
  │  │  └──────────┘ └─────────┘  │  │
  │  │  ┌──────────┐ ┌─────────┐  │  │
  │  │  │  Mouse   │ │ Input   │  │  │
  │  │  │  Cursor  │ │ Control │  │  │
  │  │  └──────────┘ └─────────┘  │  │
  │  └────────────┬───────────────┘  │
  │               │                  │
  │  ┌────────────▼───────────────┐  │
  │  │     [VS] Network Layer     │  │
  │  │  Send_Data ◄──► Handle_Data│  │
  │  │  Socket ◄──────► Buffer    │  │
  │  └────────────┬───────────────┘  │
  └───────────────┼──────────────────┘
                  │ TCP Socket
                  │ (EventMachine)
  ┌───────────────▼──────────────────┐
  │           SERVER (Ruby)          │
  │  ┌────────────────────────────┐  │
  │  │    Kernel (EventMachine)   │  │
  │  │  ┌──────────┐ ┌─────────┐  │  │
  │  │  │ Network  │ │ Client  │  │  │
  │  │  │ Protocol │ │ Handler │  │  │
  │  │  └──────────┘ └─────────┘  │  │
  │  └────────────────────────────┘  │
  │  ┌────────────────────────────┐  │
  │  │      Game Logic Layer      │  │
  │  │  ┌────────┐ ┌───────────┐  │  │
  │  │  │ Combat │ │   Map     │  │  │
  │  │  │ Battle │ │ Manager   │  │  │
  │  │  └────────┘ └───────────┘  │  │
  │  │  ┌────────┐ ┌───────────┐  │  │
  │  │  │ Guild  │ │  Party    │  │  │
  │  │  └────────┘ └───────────┘  │  │
  │  │  ┌────────┐ ┌───────────┐  │  │
  │  │  │ Trade  │ │  Quest    │  │  │
  │  │  └────────┘ └───────────┘  │  │
  │  └────────────────────────────┘  │
  │  ┌────────────────────────────┐  │
  │  │     Database Layer         │  │
  │  │  MySQL / SQLite            │  │
  │  │  Database.sql schema       │  │
  │  └────────────────────────────┘  │
  └──────────────────────────────────┘
```

**Fluxo de Dados — Exemplo: Jogador Ataca Inimigo**

```
[CLIENT]                          [SERVER]
   │                                  │
   │── Input: clique no inimigo ──►   │
   │   Mouse.rb detecta alvo          │
   │   Game_Player verifica range     │
   │                                  │
   │── Send_Data(:attack, target_id)─►│
   │   Buffer.write_byte(opcode)      │
   │   Socket.send(packet)            │
   │                                  │
   │                    ◄─ Network.rb recebe pacote
   │                       Handle_Data processa
   │                       game_battle.rb calcula dano
   │                       game_enemy.rb atualiza HP
   │                                  │
   │◄─ Handle_Data(:damage, data) ───│
   │   Sprite_HUD atualiza HP bar     │
   │   Sprite_Character anima hit     │
   │   Sprite_Drop cria loot (se morreu)
   │                                  │
   │◄─ Broadcast para todos na área ─│
      (todos os clientes no mapa atualizam)
```

**Módulos de Rede — Responsabilidades:**

| Módulo        | Arquivo           | Responsabilidade                                              |
|---------------|-------------------|---------------------------------------------------------------|
| `Send_Data`   | Send_Data.rb      | Empacota e envia dados do cliente para o servidor             |
| `Handle_Data` | Handle_Data.rb    | Recebe e processa pacotes vindos do servidor                  |
| `Network`     | Network.rb        | Gerencia a conexão TCP, reconexão e estado da sessão          |
| `Socket`      | Socket.rb         | Abstração de baixo nível do socket TCP                        |
| `Buffer`      | Buffer.rb         | Serialização/deserialização de dados binários (read/write)    |

---

### 2.3 Módulos do Server já Implementados

| Módulo       | Pasta          | Arquivo(s) Principal(is)                    | Responsabilidade                                              |
|--------------|----------------|---------------------------------------------|---------------------------------------------------------------|
| Kernel       | `Kernel/`      | `main.rb`, EventMachine core                | Loop principal do servidor, gerenciamento de conexões         |
| Network      | `Network/`     | Protocolo TCP                               | Recepção e envio de pacotes, broadcast para clientes          |
| Client       | `Client/`      | Handlers de conexão                         | Autenticação, sessão de jogador, entrada/saída de mapas       |
| Combat       | `Combat/`      | `game_battle.rb`, `game_client.rb`, `game_enemy.rb` | Cálculo de dano, batalha em tempo real, IA de inimigos |
| Database     | `Database/`    | SQL/MySQL scripts                           | CRUD de jogadores, itens, guilds, quests, banco               |
| Guild        | `Guild/`       | guild.rb (inferido)                         | Criação, gerenciamento, hierarquia e guerra de guildas        |
| Party        | `Party/`       | party.rb (inferido)                         | Formação de grupos, compartilhamento de XP e loot             |
| Trade        | `Trade/`       | trade.rb (inferido)                         | Comércio seguro entre dois jogadores                          |
| Map          | `Map/`         | map_manager.rb (inferido)                   | Instâncias de mapa, eventos de mapa, spawn de inimigos        |
| Entrypoints  | `Server/`      | `main.rb`, `editor.rb`                      | Inicialização do servidor e do editor de conta                |
| Config       | `Server/`      | `configs.ini`, `vocab.ini`, `motd.txt`      | Configurações globais, vocabulário, mensagem do dia           |

---

### 2.4 Scripts do Client já Implementados

#### Scripts Base RPG Maker — Prefixo `[RM]`

| Script                  | Responsabilidade                                                    |
|-------------------------|---------------------------------------------------------------------|
| `Cache`                 | Cache de bitmaps e recursos gráficos                                |
| `DataManager`           | Carregamento e salvamento de dados do jogo                          |
| `Game_Action`           | Ações de batalha (ataque, skill, item)                              |
| `Game_ActionResult`     | Resultado de ações de batalha (dano, cura, status)                  |
| `Game_Actor`            | Dados e lógica do ator (personagem do jogador)                      |
| `Game_Actors`           | Coleção de atores                                                   |
| `Game_BaseItem`         | Classe base para itens, armas e armaduras                           |
| `Game_Battler`          | Lógica de combatente (HP, MP, stats, estados)                       |
| `Game_BattlerBase`      | Base de combatente (atributos fundamentais)                         |
| `Game_Character`        | Movimento e comportamento de personagens no mapa                    |
| `Game_CharacterBase`    | Base de personagem (posição, direção, velocidade)                   |
| `Game_Enemy`            | Dados e lógica de inimigos                                          |
| `Game_Event`            | Eventos do mapa (NPCs, triggers, scripts de evento)                 |
| `Game_Interpreter`      | Interpretador de comandos de evento                                 |
| `Game_Map`              | Gerenciamento do mapa atual (tiles, eventos, scroll)                |
| `Game_Message`          | Sistema de mensagens e diálogos                                     |
| `Game_Party`            | Grupo do jogador (membros, inventário, ouro)                        |
| `Game_Picture`          | Imagens de tela (pictures)                                          |
| `Game_Pictures`         | Coleção de pictures                                                 |
| `Game_Player`           | Personagem controlado pelo jogador                                  |
| `Game_Screen`           | Efeitos de tela (fade, flash, shake, tone)                          |
| `Game_SelfSwitches`     | Switches locais de eventos                                          |
| `Game_Switches`         | Switches globais do jogo                                            |
| `Game_System`           | Configurações do sistema em tempo de execução                       |
| `Game_Temp`             | Dados temporários (não persistidos)                                 |
| `Game_Timer`            | Timer global do jogo                                                |
| `Game_Unit`             | Unidade de batalha (grupo de combatentes)                           |
| `Game_Variables`        | Variáveis globais do jogo                                           |
| `Game_Vehicle`          | Veículos (barco, navio, aeronave)                                   |
| `Main`                  | Loop principal do RPG Maker                                         |
| `SceneManager`          | Gerenciamento de cenas (transições)                                 |
| `Scene_Base`            | Classe base para todas as cenas                                     |
| `Scene_Map`             | Cena principal do mapa de jogo                                      |
| `Sound`                 | Reprodução de sons e músicas                                        |
| `Sprite_Base`           | Classe base para sprites                                            |
| `Sprite_Character`      | Sprite de personagem no mapa                                        |
| `Sprite_Picture`        | Sprite de picture                                                   |
| `Sprite_Timer`          | Sprite do timer                                                     |
| `Spriteset_Map`         | Conjunto de sprites do mapa                                         |
| `Spriteset_Weather`     | Efeitos climáticos (chuva, neve, tempestade)                        |
| `Vocab`                 | Vocabulário padrão do RPG Maker                                     |
| `Window_Base`           | Classe base para janelas                                            |
| `Window_ChoiceList`     | Janela de escolha de opções                                         |
| `Window_Command`        | Janela de comandos                                                  |
| `Window_Gold`           | Janela de exibição de ouro                                          |
| `Window_ItemList`       | Lista de itens                                                      |
| `Window_KeyItem`        | Seleção de item chave                                               |
| `Window_Message`        | Janela de mensagem/diálogo                                          |
| `Window_NumberInput`    | Entrada numérica                                                    |
| `Window_ScrollText`     | Texto com scroll                                                    |
| `Window_Selectable`     | Janela selecionável base                                            |

#### Scripts VXA-OS Customizados — Prefixo `[VS]`

| Script              | Responsabilidade                                                         | Prioridade MMO |
|---------------------|--------------------------------------------------------------------------|:--------------:|
| `Audio`             | Sistema de áudio customizado para MMO                                    | 🟡 Média       |
| `Buffer`            | Serialização binária de pacotes de rede                                  | 🔴 Alta        |
| `Button`            | Componente de botão para UI                                              | 🟡 Média       |
| `Check_Box`         | Componente checkbox para UI                                              | 🟢 Baixa       |
| `Combo_Box`         | Componente combobox para UI                                              | 🟢 Baixa       |
| **`Configs`**       | Configurações centrais do VXA-OS (IP, porta, resolução, features)        | 🔴 Alta        |
| `Control`           | Controles de UI base                                                     | 🟡 Média       |
| `DataManager`       | Override do DataManager para MMO (carregamento de dados de rede)         | 🔴 Alta        |
| `Enums`             | Enumerações de opcodes e constantes de rede                              | 🔴 Alta        |
| `Game_ActionResult` | Override do resultado de ação para combate MMO                           | 🔴 Alta        |
| `Game_Actor`        | Override do ator para dados de personagem MMO                            | 🔴 Alta        |
| **`Game_Bank`**     | Sistema de banco (depósito/saque de itens e ouro)                        | 🔴 Alta        |
| `Game_Character`    | Override de personagem para movimento em rede                            | 🔴 Alta        |
| **`Game_Drop`**     | Sistema de drops no chão (loot de inimigos)                              | 🔴 Alta        |
| `Game_Event`        | Override de eventos para sincronização em rede                           | 🔴 Alta        |
| `Game_Map`          | Override do mapa para gerenciamento MMO                                  | 🔴 Alta        |
| **`Game_NetPlayer`**| Dados e lógica de outros jogadores visíveis no mapa                      | 🔴 Alta        |
| `Game_Party`        | Override de party para MMO                                               | 🔴 Alta        |
| `Game_Player`       | Override do jogador para controle em rede                                | 🔴 Alta        |
| **`Game_Projectile`**| Sistema de projéteis (flechas, magias, etc.)                            | 🔴 Alta        |
| **`Game_Quest`**    | Dados e lógica de quests do jogador                                      | 🔴 Alta        |
| **`Game_Trade`**    | Sistema de comércio entre jogadores                                      | 🔴 Alta        |
| `Handle_Data`       | Processamento de pacotes recebidos do servidor                           | 🔴 Alta        |
| `Icon`              | Renderização de ícones de itens/skills                                   | 🟡 Média       |
| `Image_Button`      | Botão com imagem para UI                                                 | 🟡 Média       |
| `Input`             | Override do sistema de input para MMO                                    | 🔴 Alta        |
| `Input_Slider`      | Componente slider para UI                                                | 🟢 Baixa       |
| `Kernel`            | Extensões do Kernel Ruby para o cliente                                  | 🔴 Alta        |
| **`Mouse`**         | Sistema de input de mouse customizado                                    | 🔴 Alta        |
| **`Network`**       | Gerenciamento da conexão de rede do cliente                              | 🔴 Alta        |
| `Progress_Bar`      | Barra de progresso para UI (HP, MP, XP)                                  | 🟡 Média       |
| **`Quests`**        | Configuração e definição de quests do jogo                               | 🔴 Alta        |
| `Radio_Button`      | Componente radio button para UI                                          | 🟢 Baixa       |
| `Scene_Base`        | Override da cena base para MMO                                           | 🔴 Alta        |
| **`Scene_Character`**| Cena de criação/seleção de personagem                                   | 🔴 Alta        |
| **`Scene_Login`**   | Cena de login (tela inicial)                                             | 🔴 Alta        |
| `Scene_Map`         | Override da cena de mapa para MMO                                        | 🔴 Alta        |
| `Scroll_Bar`        | Barra de scroll para UI                                                  | 🟡 Média       |
| `Send_Data`         | Envio de pacotes para o servidor                                         | 🔴 Alta        |
| `Settings_File`     | Leitura/escrita de arquivo de configurações locais                       | 🟡 Média       |
| **`Socket`**        | Abstração do socket TCP                                                  | 🔴 Alta        |
| **`Sprite2`**       | Sistema de sprites estendido para MMO (paperdolls, efeitos)              | 🔴 Alta        |
| `Sprite_Character`  | Override do sprite de personagem para MMO                                | 🔴 Alta        |
| **`Sprite_Cursor`** | Cursor customizado do mouse                                              | 🟡 Média       |
| **`Sprite_Desc`**   | Tooltip/descrição de itens e skills                                      | 🟡 Média       |
| **`Sprite_Drop`**   | Renderização visual de drops no chão                                     | 🔴 Alta        |
| **`Sprite_HUD`**    | HUD principal (HP, MP, XP, skills, minimap)                              | 🔴 Alta        |

---

### 2.5 Limitações e Potencialidades

#### ⚠️ Limitações

| Limitação                          | Impacto                                      | Solução / Workaround                                              |
|------------------------------------|----------------------------------------------|-------------------------------------------------------------------|
| Tile size fixo 32x32px             | Resolução visual limitada                    | Assets de alta qualidade 32x32, uso de overlays e efeitos        |
| Mapa máximo 500x500 tiles          | Mundo limitado em tamanho                    | Múltiplos mapas interconectados, instâncias de dungeon            |
| ~200-300 eventos por mapa          | Poucos NPCs/inimigos simultâneos             | Scripts anti-lag, spawn dinâmico via servidor, pooling de eventos |
| Single-thread RGSS3                | Sem paralelismo no cliente                   | Operações assíncronas via Fiber, processamento no servidor        |
| Sem suporte mobile                 | Apenas PC                                    | Foco em PC, possível port futuro via Wine/emulação                |
| Resolução padrão 544x416           | Tela pequena                                 | Script de resolução customizada (ex: 800x600, 1024x768)           |
| Ruby 1.9.x (RGSS3)                 | Sintaxe e gems limitadas                     | Usar apenas stdlib compatível, evitar gems externas               |
| Sem shaders avançados              | Efeitos visuais limitados                    | Efeitos via Bitmap, Tone, Flash, animações de sprite              |

#### 🟢 Potencialidades

| Potencialidade                     | Como Explorar                                                     |
|------------------------------------|-------------------------------------------------------------------|
| VXA-OS já tem 20+ sistemas MMO     | Focar em customização e polimento ao invés de reescrever do zero  |
| EventMachine no servidor           | I/O assíncrono eficiente para centenas de conexões simultâneas    |
| Ruby altamente expressivo          | Scripts concisos, legíveis e fáceis de manter                     |
| RPG Maker tem editor visual        | Criação rápida de mapas, eventos e NPCs sem código                |
| Sistema de eventos do RM           | 99% dos comandos de evento funcionam no servidor (VXA-OS)         |
| Comunidade RPG Maker ativa         | Scripts públicos, tutoriais, assets gratuitos disponíveis         |
| MySQL integrado                    | Persistência robusta, queries complexas, escalabilidade           |
| Game_Projectile já existe          | Sistema de projéteis pronto para skills de longa distância        |
| Mouse customizado já existe        | Interação rica com o mundo (coletar drops, atacar, navegar)       |

---

## 3. Sistemas Core do Jogo

### 3.1 Sistema de Combate

> 🗡️ **Inspirações:** Tibia (top-down real-time, posicionamento), Diablo (combate dinâmico, loot ao morrer), Ragnarok (MVP system, skills visuais)

**Mecânicas Planejadas:**

- **Ataque básico:** clique no inimigo, personagem se move até o range e ataca automaticamente
- **Skills ativas:** barra de hotkeys (F1-F12 ou slots clicáveis), cada skill com cooldown e custo de mana
- **Projéteis:** arqueiros e magos disparam projéteis visuais (Game_Projectile.rb já existe)
- **Debuffs/Buffs:** veneno, paralisia, lentidão, bênção, haste — exibidos via Sprite_States
- **Knockback:** habilidades especiais empurram inimigos/jogadores
- **MVP System:** bosses com HP elevado, mecânicas especiais, drops raros exclusivos
- **Combate servidor-side:** toda lógica de dano, hit/miss e morte processada no servidor

**Checklist de Implementação:**

- [x] Combate básico em tempo real (VXA-OS já implementa)
- [x] Sistema de projéteis (Game_Projectile.rb existe)
- [ ] Sistema de cooldown de skills no cliente (UI visual)
- [ ] Barra de hotkeys de skills clicável (Sprite_HUD)
- [ ] Sistema de debuffs com duração e ícones (Sprite_States)
- [ ] Knockback visual e lógico
- [ ] MVP/Boss system com mecânicas especiais
- [ ] Animações de hit, miss e crítico
- [ ] Indicador de dano flutuante (damage popup)
- [ ] Sistema de aggro/ameaça para grupos
- [ ] Área de efeito (AoE) para skills
- [ ] Sistema de combo/encadeamento de ataques
- [ ] Resistências elementais (fogo, água, terra, vento)
- [ ] Indicador de range de ataque visual

**Snippet Ruby — Sistema de Skill com Cooldown:**

```ruby
#==============================================================================
# [FO] Skill Cooldown System
# Fields Online — Sistema de Cooldown de Skills
# Autor: Caio Juan De Lima Silva
# Versão: 1.0.0
#==============================================================================

module FO
  module SkillConfig
    # Cooldowns em frames (60 frames = 1 segundo)
    SKILL_COOLDOWNS = {
      1  => 120,  # Skill ID 1: 2 segundos
      2  => 180,  # Skill ID 2: 3 segundos
      3  => 300,  # Skill ID 3: 5 segundos
      4  => 600,  # Skill ID 4: 10 segundos
    }
    DEFAULT_COOLDOWN = 60 # 1 segundo padrão
  end
end

#==============================================================================
# Game_Actor — Extensão para Cooldowns
#==============================================================================
class Game_Actor < Game_Battler
  alias fo_cooldown_initialize initialize
  def initialize(actor_id)
    fo_cooldown_initialize(actor_id)
    @skill_cooldowns = {} # { skill_id => frames_restantes }
  end

  # Verifica se a skill está disponível (sem cooldown)
  def skill_ready?(skill_id)
    return true unless @skill_cooldowns[skill_id]
    @skill_cooldowns[skill_id] <= 0
  end

  # Usa a skill e inicia o cooldown
  def use_skill_cooldown(skill_id)
    cd = FO::SkillConfig::SKILL_COOLDOWNS[skill_id] ||
         FO::SkillConfig::DEFAULT_COOLDOWN
    @skill_cooldowns[skill_id] = cd
  end

  # Atualiza cooldowns a cada frame
  def update_cooldowns
    @skill_cooldowns.each do |id, frames|
      @skill_cooldowns[id] = [frames - 1, 0].max
    end
  end

  # Retorna progresso do cooldown (0.0 a 1.0) para a UI
  def cooldown_progress(skill_id)
    return 1.0 unless @skill_cooldowns[skill_id]
    max = FO::SkillConfig::SKILL_COOLDOWNS[skill_id] ||
          FO::SkillConfig::DEFAULT_COOLDOWN
    return 1.0 if max == 0
    remaining = @skill_cooldowns[skill_id].to_f
    1.0 - (remaining / max)
  end
end
```

---

### 3.2 Sistema de Classes/Jobs

> ⚔️ **Inspirações:** Ragnarok Online (job system multicamada), MU Online (classes com wings), WoW (specs/especializações)

**Árvore de Classes:**

```
                    ┌─────────────┐
                    │   NOVATO    │
                    │  (Lv 1-10)  │
                    └──────┬──────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
   ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐
   │  GUERREIRO  │  │    MAGO     │  │  ARQUEIRO   │
   │  (Lv 10+)  │  │  (Lv 10+)  │  │  (Lv 10+)  │
   └──────┬──────┘  └──────┬──────┘  └──────┬──────┘
          │                │                │
    ┌─────┴─────┐    ┌─────┴─────┐    ┌─────┴─────┐
    │           │    │           │    │           │
┌───▼───┐ ┌───▼───┐ ┌───▼───┐ ┌───▼───┐ ┌───▼───┐ ┌───▼───┐
│PALADIN│ │BERSER-│ │FEITICEI│ │CLERIC │ │HUNTER │ │BARD   │
│(Lv30+)│ │KER    │ │RO     │ │(Lv30+)│ │(Lv30+)│ │(Lv30+)│
│       │ │(Lv30+)│ │(Lv30+)│ │       │ │       │ │       │
└───────┘ └───────┘ └───────┘ └───────┘ └───────┘ └───────┘
    │           │         │         │         │         │
  [Wings]    [Wings]   [Wings]   [Wings]   [Wings]   [Wings]
  Lv 80+     Lv 80+    Lv 80+    Lv 80+    Lv 80+    Lv 80+
```

**Tabela de Classes:**

| Classe      | Stat Principal | Habilidade Única                        | Estilo de Jogo                          |
|-------------|----------------|-----------------------------------------|-----------------------------------------|
| Novato      | Balanceado     | Nenhuma                                 | Tutorial, aprendizado                   |
| Guerreiro   | STR / VIT      | Grito de Guerra (buff de grupo)         | Tanque, dano corpo-a-corpo              |
| Mago        | INT / MP       | Teleporte de curta distância            | Dano mágico massivo, frágil             |
| Arqueiro    | DEX / AGI      | Disparo múltiplo (3 projéteis)          | Dano à distância, mobilidade            |
| Paladino    | STR / VIT / INT| Aura Sagrada (cura passiva de grupo)    | Tanque suporte, PvP defensivo           |
| Berserker   | STR / AGI      | Fúria (dano +50%, defesa -30%)          | DPS extremo, alto risco                 |
| Feiticeiro  | INT / MP       | Invocação de familiar                   | Controle de área, debuffs               |
| Cleric      | INT / VIT      | Ressurreição (revive aliado)            | Suporte, cura, buffs                    |
| Hunter      | DEX / AGI      | Armadilha (imobiliza inimigo)           | Controle, dano sustentado               |
| Bard        | DEX / INT      | Música de Batalha (buff de área)        | Suporte ofensivo, buffs de grupo        |

**Checklist de Implementação:**

- [x] Sistema base de classes (RPG Maker Actors/Classes)
- [ ] Árvore de evolução de classes (script de job change)
- [ ] Sistema de Wings (equipamento especial Lv 80+)
- [ ] Skills exclusivas por classe
- [ ] Restrição de equipamentos por classe
- [ ] Interface de seleção de classe na criação de personagem
- [ ] Bônus de stats por classe ao evoluir
- [ ] Sistema de Skill Points para distribuição manual
- [ ] Preview de classe na Scene_Character

---

### 3.3 Sistema de Itens e Inventário

> 💎 **Inspirações:** Diablo (afixos aleatórios, raridades), MU Online (upgrade +1~+15), Tibia (loot no chão, peso)

**Raridades de Itens:**

| Raridade  | Cor (Hex)  | Cor Nome     | Drop Rate | Exemplo                    |
|-----------|------------|--------------|-----------|----------------------------|
| Comum     | `#FFFFFF`  | Branco       | 60%       | Espada de Ferro            |
| Incomum   | `#1EFF00`  | Verde        | 25%       | Espada Afiada              |
| Raro      | `#0070DD`  | Azul         | 10%       | Espada do Cavaleiro        |
| Épico     | `#A335EE`  | Roxo         | 4%        | Espada do Campeão          |
| Lendário  | `#FF8000`  | Laranja      | 1%        | Espada do Herói Lendário   |
| Único     | `#E6CC80`  | Dourado      | 0.1%      | Espada de Campos           |

**Sistema de Upgrade (+1 a +15):**

```
+0  → +5  : Taxa de sucesso alta (80-95%), sem risco de quebra
+6  → +10 : Taxa de sucesso média (40-70%), falha = sem upgrade
+11 → +13 : Taxa de sucesso baixa (20-35%), falha = item desce 1 nível
+14 → +15 : Taxa de sucesso muito baixa (5-10%), falha = item quebra
```

**Sistema de Afixos Aleatórios (inspirado em Diablo):**

| Afixo          | Tipo    | Efeito                              |
|----------------|---------|-------------------------------------|
| `of Strength`  | Sufixo  | +5 a +15 STR                        |
| `of the Bear`  | Sufixo  | +50 a +150 HP máximo                |
| `Flaming`      | Prefixo | +10 a +30 dano de fogo              |
| `Blessed`      | Prefixo | +5% a +15% de cura recebida         |
| `Swift`        | Prefixo | +5% a +20% de velocidade de ataque  |
| `Vampiric`     | Prefixo | +2% a +8% de life steal             |

**Checklist de Implementação:**

- [x] Sistema de drop no chão (Game_Drop.rb, Sprite_Drop.rb)
- [x] Banco de itens (Game_Bank.rb)
- [ ] Sistema de raridades com cores no nome
- [ ] Sistema de upgrade +1 a +15 com taxas de sucesso
- [ ] Sistema de afixos aleatórios no drop
- [ ] Tooltip detalhado de item (Sprite_Desc melhorado)
- [ ] Sistema de peso/capacidade de inventário
- [ ] Comparação de item equipado vs. item no chão
- [ ] Proteção de drop temporária para o dono (2 tiles de range para coletar)
- [ ] Filtro de loot (mostrar apenas itens de certa raridade)
- [ ] Sistema de identificação de itens (itens não identificados)
- [ ] Durabilidade de equipamentos

---

### 3.4 Sistema de Party

> 🏰 **Inspirações:** Tibia (party com shared XP), WoW (roles: tank/healer/DPS)

**Regras de Party:**

| Regra                    | Detalhe                                                          |
|--------------------------|------------------------------------------------------------------|
| Tamanho máximo           | 6 jogadores                                                      |
| Compartilhamento de XP   | XP dividido igualmente entre membros no mesmo mapa              |
| Bônus de XP em party     | +10% por membro adicional (máx +50% com 6 membros)              |
| Loot sharing             | Round-robin, livre ou para o líder (configurável)               |
| Distância de XP shared   | Membros devem estar no mesmo mapa                               |
| Convite                  | Líder convida, membro aceita/recusa                             |
| Expulsão                 | Apenas o líder pode expulsar membros                            |
| Transferência de liderança| Líder pode transferir para outro membro                        |

**Checklist de Implementação:**

- [x] Sistema de party base (VXA-OS Party/)
- [ ] UI de party (frames com HP/MP de cada membro na HUD)
- [ ] Bônus de XP em party
- [ ] Sistema de loot sharing configurável
- [ ] Indicador visual de membros de party no mapa (cor diferente)
- [ ] Chat de party (/p)
- [ ] Roles visuais (ícone de tank/healer/DPS)
- [ ] Notificação de morte de membro de party

---

### 3.5 Sistema de Guild

> 🏰 **Inspirações:** Ragnarok Online (guild wars, emblema), WoW (guild bank, raids)

**Hierarquia de Cargos:**

```
[Grão-Mestre] — Fundador, controle total
      │
[Oficiais] — Gerenciam membros, acesso ao banco
      │
[Veteranos] — Membros antigos, permissões extras
      │
[Membros] — Membros regulares
      │
[Recrutas] — Novos membros, permissões limitadas
```

**Funcionalidades:**

| Feature          | Descrição                                                        |
|------------------|------------------------------------------------------------------|
| Guild Bank       | Banco compartilhado com abas e permissões por cargo             |
| Guild Chat       | Canal de chat exclusivo da guilda (/g)                          |
| Guild Wars       | Declaração de guerra entre guildas, PvP autorizado              |
| Emblema          | Imagem customizada da guilda exibida sobre o personagem         |
| Guild Hall       | Mapa exclusivo da guilda (sede)                                 |
| Guild Log        | Histórico de ações (depósitos, saques, guerras)                 |
| Ranking          | Ranking público de guildas por poder/conquistas                 |

**Checklist de Implementação:**

- [x] Sistema de guild base (VXA-OS Guild/)
- [ ] Interface de gerenciamento de guild
- [ ] Guild Bank com permissões por cargo
- [ ] Sistema de Guild Wars
- [ ] Emblema de guild sobre o personagem
- [ ] Guild Hall (mapa exclusivo)
- [ ] Guild Log de atividades
- [ ] Ranking de guildas
- [ ] Sistema de recrutamento (anúncio público)
- [ ] Missões de guild (Guild Quests)

---

### 3.6 Sistema de PvP

> ⚔️ **Inspirações:** Tibia (PvP aberto com karma/skull system), MU Online (arena PvP, Blood Castle)

**Modos de PvP:**

| Modo          | Descrição                                                        | Karma |
|---------------|------------------------------------------------------------------|:-----:|
| Open PvP      | PvP em zonas específicas do mapa (campos abertos)               | Sim   |
| Arena         | Zona PvP dedicada, sem penalidade de karma                      | Não   |
| Guild War     | PvP entre guildas em guerra declarada                           | Não   |
| Duelo         | PvP consensual entre dois jogadores (/duel)                     | Não   |
| Safe Zone     | Cidades e áreas protegidas, PvP bloqueado                       | N/A   |

**Sistema de Karma (inspirado no Skull System do Tibia):**

```
KARMA POSITIVO (Herói)
  ★★★★★ Lendário  — Bônus de XP +10%, título especial
  ★★★★☆ Honrado   — Sem penalidades
  ★★★☆☆ Neutro    — Estado padrão

KARMA NEGATIVO (Criminoso)
  💀 Caveira Branca — Matou 1 jogador inocente (24h)
  💀 Caveira Amarela — Matou 3+ jogadores (48h)
  💀 Caveira Vermelha — Matou 10+ jogadores (72h)
  → Penalidades: drop de itens ao morrer, banido de cidades
```

**Checklist de Implementação:**

- [x] PvP base (VXA-OS PvP)
- [ ] Sistema de karma/skull com ícones
- [ ] Zonas de PvP e Safe Zones no mapa
- [ ] Arena PvP dedicada
- [ ] Sistema de duelo (/duel)
- [ ] Penalidades de morte em PvP (drop de itens)
- [ ] Ranking de PvP (kills/deaths)
- [ ] Notificação de morte de jogador no chat global
- [ ] Sistema de bounty (recompensa por cabeça)

---

### 3.7 Sistema de Quests

> 🗺️ **Inspirações:** WoW (quest chains estruturadas, recompensas), VXA-OS (Game_Quest.rb já existe)

**Tipos de Quest:**

| Tipo       | Descrição                                          | Recompensa Típica              |
|------------|----------------------------------------------------|--------------------------------|
| Principal  | Narrativa central do jogo, sequencial              | XP alto, itens únicos, lore    |
| Secundária | Quests opcionais de NPCs                           | XP médio, ouro, itens comuns   |
| Diária     | Reset a cada 24h, repetível                        | Ouro, materiais de craft       |
| Dungeon    | Completar dungeon específica                       | Itens raros, XP alto           |
| Guild      | Missões coletivas para a guilda                    | Pontos de guilda, itens épicos |
| Evento     | Quests temporárias de eventos sazonais             | Itens exclusivos de evento     |

**Estrutura de Dados de uma Quest (Ruby):**

```ruby
#==============================================================================
# [FO] Quest Data Structure
# Fields Online — Estrutura de Dados de Quest
#==============================================================================

module FO
  module QuestData
    # Exemplo de definição de quest
    QUESTS = {
      1 => {
        name:        "O Primeiro Passo",
        type:        :main,           # :main, :side, :daily, :dungeon, :guild
        description: "Fale com o Guarda da Entrada para iniciar sua jornada.",
        level_req:   1,
        objectives:  [
          { type: :talk,  npc_id: 5,  count: 1, desc: "Falar com o Guarda" },
          { type: :kill,  enemy_id: 3, count: 10, desc: "Matar 10 Slimes" },
          { type: :item,  item_id: 12, count: 1,  desc: "Entregar Espada Enferrujada" }
        ],
        rewards: {
          exp:   500,
          gold:  100,
          items: [{ id: 15, amount: 1 }],  # Item ID 15, quantidade 1
          title: nil                         # Título desbloqueado (nil = nenhum)
        },
        chain_next:  2,    # ID da próxima quest na cadeia (nil = fim)
        repeatable:  false,
        daily:       false,
        icon_id:     1     # Ícone da quest no log
      },

      2 => {
        name:        "Ameaça nas Planícies",
        type:        :main,
        description: "Os Slimes estão se multiplicando. Elimine o Rei Slime.",
        level_req:   5,
        objectives:  [
          { type: :kill, enemy_id: 10, count: 1, desc: "Derrotar o Rei Slime" }
        ],
        rewards: {
          exp:   1500,
          gold:  300,
          items: [{ id: 20, amount: 1 }],
          title: "Caçador de Slimes"
        },
        chain_next:  3,
        repeatable:  false,
        daily:       false,
        icon_id:     2
      }
    }
  end
end
```

**Checklist de Implementação:**

- [x] Sistema de quest base (Game_Quest.rb, Quests.rb)
- [x] Log de quests (Window_Quest.rb)
- [ ] Quest chains (sequência de quests encadeadas)
- [ ] Quests diárias com reset automático
- [ ] Objetivos múltiplos por quest (matar, coletar, falar)
- [ ] Rastreamento de progresso em tempo real
- [ ] Marcadores de quest no minimap
- [ ] Notificação visual de quest disponível (ícone sobre NPC)
- [ ] Recompensa de título por quest
- [ ] Quests de dungeon com instâncias
- [ ] Sistema de quest de guild

---

### 3.8 Sistema de Economia

> 💰 **Inspirações:** WoW (Auction House), Tibia (NPC shops, gold coins), Ragnarok (Merchant class)

**Sistema Monetário em Camadas:**

```
💰 Cobre  (C)  — Moeda básica, drop comum de monstros
💰 Prata  (S)  — 100 Cobres = 1 Prata
💰 Ouro   (G)  — 100 Pratas = 1 Ouro (= 10.000 Cobres)
💰 Platina (P) — 100 Ouros = 1 Platina (= 1.000.000 Cobres)
```

**Componentes da Economia:**

| Componente       | Sistema Base         | Status    | Descrição                                      |
|------------------|----------------------|-----------|------------------------------------------------|
| Loja NPC         | RPG Maker Shop       | ✅ Existe | Compra/venda de itens básicos com NPCs         |
| Player Trade     | Game_Trade.rb        | ✅ Existe | Comércio direto e seguro entre 2 jogadores     |
| Banco            | Game_Bank.rb         | ✅ Existe | Depósito seguro de itens e ouro                |
| Casa de Leilões  | —                    | ❌ Novo   | Leilão de itens entre jogadores (assíncrono)   |
| Merchant Class   | —                    | ❌ Novo   | Jogador abre loja própria no mapa              |
| Profissões       | —                    | ❌ Novo   | Ferreiro, Alquimista, Cozinheiro, Minerador    |
| Impostos         | —                    | ❌ Novo   | Taxa sobre transações (sink de ouro)           |

**Checklist de Implementação:**

- [x] Loja NPC (RPG Maker nativo)
- [x] Player Trade (Game_Trade.rb)
- [x] Banco (Game_Bank.rb)
- [ ] Sistema monetário em camadas (Cobre/Prata/Ouro/Platina)
- [ ] Casa de Leilões (Auction House)
- [ ] Sistema de profissões (Ferreiro, Alquimista)
- [ ] Loja de jogador (Merchant mode)
- [ ] Histórico de transações
- [ ] Imposto sobre transações (sink econômico)
- [ ] Preços dinâmicos de NPC baseados em oferta/demanda

---

### 3.9 Sistema de Chat e Social

> 💬 **Inspirações:** WoW (canais de chat), Tibia (chat local/global)

**Canais de Chat:**

| Canal    | Comando | Cor       | Alcance                          |
|----------|---------|-----------|----------------------------------|
| Global   | `/g`    | `#FFFF00` | Todos os jogadores online        |
| Local    | `/l`    | `#FFFFFF` | Jogadores no mesmo mapa          |
| Party    | `/p`    | `#00FF7F` | Membros do grupo                 |
| Guild    | `/gu`   | `#00BFFF` | Membros da guilda                |
| Privado  | `/w`    | `#FF69B4` | Jogador específico               |
| Trade    | `/t`    | `#FFA500` | Canal de comércio global         |
| Sistema  | —       | `#FF4444` | Mensagens do servidor            |

**Comandos de Chat:**

```
/w [nome] [mensagem]  — Mensagem privada
/p [mensagem]         — Chat de party
/gu [mensagem]        — Chat de guild
/t [mensagem]         — Canal de trade
/duel [nome]          — Desafiar para duelo
/invite [nome]        — Convidar para party
/kick [nome]          — Expulsar da party
/trade [nome]         — Solicitar troca
/friend [nome]        — Adicionar amigo
/ignore [nome]        — Ignorar jogador
/who                  — Listar jogadores online
/help                 — Lista de comandos
```

**Checklist de Implementação:**

- [x] Sistema de chat base (Window_Chat.rb)
- [x] Sistema de amizade (VXA-OS Friend)
- [ ] Múltiplos canais de chat com cores
- [ ] Comandos de chat (/w, /p, /gu, /t)
- [ ] Histórico de mensagens privadas
- [ ] Sistema de ignorar jogador
- [ ] Notificação de mensagem privada (som + flash)
- [ ] Filtro de palavrões
- [ ] Chat de trade dedicado
- [ ] Emojis/emoticons no chat

---

### 3.10 Sistema de Progressão

> 📈 **Inspirações:** Ragnarok (base level + job level), WoW (talent trees), MU Online (reset system)

**Camadas de Progressão:**

| Camada              | Descrição                                                        |
|---------------------|------------------------------------------------------------------|
| Base Level (1-100)  | Nível principal, ganho por XP de monstros e quests              |
| Job Level (1-50)    | Nível de classe, ganho por uso de skills e quests de classe      |
| Attribute Points    | Pontos distribuídos manualmente em STR/DEX/INT/VIT/AGI/LUK      |
| Skill Points        | Pontos para desbloquear e melhorar skills da árvore              |
| Equipment Score     | Poder calculado pelo equipamento (+upgrades, raridade, afixos)   |
| Achievement Points  | Pontos de conquistas, desbloqueiam títulos e cosméticos          |
| Prestige/Reset      | Sistema de reset de nível com bônus permanentes (inspirado MU)   |

**Checklist de Implementação:**

- [x] Sistema de level e XP (RPG Maker nativo)
- [ ] Job Level separado do Base Level
- [ ] Distribuição manual de Attribute Points
- [ ] Árvore de Skill Points
- [ ] Equipment Score calculado
- [ ] Sistema de conquistas (Achievements)
- [ ] Sistema de títulos desbloqueáveis
- [ ] Ranking de jogadores (level, poder, PvP)
- [ ] Sistema de Prestige/Reset
- [ ] Barra de XP visual na HUD

---

## 4. Plano de Desenvolvimento por Fases

### Fase 1 — Fundação (Semanas 1–8)

> 🎯 **Objetivo:** Personagem se move, ataca, morre e ressurge no servidor. Sistemas base funcionando de forma estável.

**Prioridades:**

1. Estabilizar e documentar o ambiente de desenvolvimento
2. Mapear e comentar todos os scripts [VS] existentes
3. Melhorar a HUD principal (Sprite_HUD)
4. Implementar sistema de cooldown de skills
5. Melhorar o Minimap (quadrado, frame via Bitmap)
6. Melhorar o sistema de drops (proteção de dono, range 2 tiles)
7. Implementar damage popup flutuante
8. Configurar banco de dados MySQL com schema completo

**Checklist Fase 1:**

- [ ] Configurar ambiente de desenvolvimento (Ruby, MySQL, RPG Maker VX Ace)
- [ ] Documentar e comentar todos os scripts [VS] existentes
- [ ] Criar estrutura de pastas organizada (ver seção 5.1)
- [ ] Implementar resolução customizada (800x600 ou 1024x768)
- [ ] Melhorar Sprite_HUD (barras de HP/MP/XP, skills hotkeys)
- [ ] Implementar Minimap quadrado com frame via Bitmap
- [ ] Implementar sistema de cooldown de skills (UI visual)
- [ ] Melhorar Sprite_Drop (proteção de dono, range 2 tiles para coletar)
- [ ] Implementar damage popup flutuante
- [ ] Implementar Sprite_States com ícones de debuff/buff
- [ ] Configurar schema MySQL completo (players, items, guilds, quests)
- [ ] Criar mapa de teste (Map001) com inimigos e drops
- [ ] Testar ciclo completo: login → mover → atacar → matar → lotar → logout
- [ ] Implementar sistema de karma básico (skull system)
- [ ] Documentar todos os opcodes de rede existentes
- [ ] Criar script [FO] Configs com todas as configurações do Fields Online
- [ ] Implementar cursor customizado com efeito de rotação
- [ ] Testar estabilidade do servidor com 5-10 conexões simultâneas

---

### Fase 2 — Expansão (Semanas 9–20)

> 🎯 **Objetivo:** Todos os sistemas core funcionando. Jogo jogável do início ao fim com conteúdo básico.

**Checklist Fase 2:**

- [ ] Implementar árvore de classes (Novato → 3 classes base)
- [ ] Implementar sistema de raridades de itens com cores
- [ ] Implementar sistema de upgrade de itens (+1 a +10)
- [ ] Implementar afixos aleatórios em drops
- [ ] Implementar quest chains (cadeia de quests principais)
- [ ] Implementar quests diárias com reset automático
- [ ] Implementar marcadores de quest no minimap
- [ ] Implementar sistema monetário em camadas (Cobre/Prata/Ouro)
- [ ] Implementar Casa de Leilões (Auction House)
- [ ] Implementar múltiplos canais de chat com cores
- [ ] Implementar comandos de chat (/w, /p, /gu, /t, /duel)
- [ ] Implementar UI de party (HP/MP de membros na HUD)
- [ ] Implementar bônus de XP em party
- [ ] Implementar interface de gerenciamento de guild
- [ ] Implementar Guild Bank
- [ ] Implementar sistema de PvP com zonas e karma
- [ ] Implementar Arena PvP
- [ ] Implementar sistema de duelo (/duel)
- [ ] Criar 3 dungeons com mecânicas distintas
- [ ] Implementar MVP/Boss system com drops raros
- [ ] Implementar sistema de conquistas (Achievements)
- [ ] Criar 20+ quests principais e 30+ quests secundárias
- [ ] Implementar sistema de profissões (Ferreiro, Alquimista)
- [ ] Criar 5 mapas de mundo interconectados
- [ ] Testar estabilidade com 20-30 conexões simultâneas

---

### Fase 3 — Polimento (Semanas 21–32)

> 🎯 **Objetivo:** Jogo polido, balanceado e com UI profissional. Pronto para beta fechado.

**Checklist Fase 3:**

- [ ] Refinar e balancear todas as classes e skills
- [ ] Balancear drop rates e economia
- [ ] Implementar especializações de classe (Lv 30+)
- [ ] Implementar sistema de Wings (Lv 80+)
- [ ] Implementar upgrade de itens +11 a +15
- [ ] Implementar sistema de identificação de itens
- [ ] Implementar durabilidade de equipamentos
- [ ] Implementar sistema de Prestige/Reset
- [ ] Implementar ranking de jogadores (level, PvP, guild)
- [ ] Implementar eventos sazonais (Natal, Halloween, etc.)
- [ ] Implementar sistema de títulos e cosméticos
- [ ] Refinar toda a UI (HUD, menus, tooltips, chat)
- [ ] Implementar efeitos sonoros e músicas para todas as áreas
- [ ] Implementar efeitos visuais de skills (animações)
- [ ] Implementar sistema de clima dinâmico (chuva, neve)
- [ ] Implementar Guild Wars com sistema de pontuação
- [ ] Implementar Guild Hall (mapa exclusivo)
- [ ] Criar sistema de tutorial interativo para novatos
- [ ] Implementar sistema de notificações (conquistas, level up, etc.)
- [ ] Otimizar performance do cliente (reduzir lag em mapas cheios)
- [ ] Otimizar queries do banco de dados
- [ ] Implementar sistema anti-cheat básico
- [ ] Criar documentação de jogador (wiki básica)
- [ ] Testar estabilidade com 50+ conexões simultâneas

---

### Fase 4 — Beta e Lançamento (Semanas 33–40)

> 🎯 **Objetivo:** Lançamento do beta aberto, coleta de feedback, correção de bugs críticos e lançamento oficial.

**Checklist Fase 4:**

- [ ] Lançar beta fechado (20-50 jogadores selecionados)
- [ ] Coletar e priorizar feedback do beta fechado
- [ ] Corrigir todos os bugs críticos (crash, perda de dados, exploits)
- [ ] Lançar beta aberto (público geral)
- [ ] Monitorar logs de servidor em tempo real
- [ ] Implementar sistema de report de bugs in-game
- [ ] Balancear economia baseado em dados reais do beta
- [ ] Balancear PvP baseado em feedback dos jogadores
- [ ] Criar sistema de backup automático do banco de dados
- [ ] Implementar sistema de ban/mute de jogadores
- [ ] Criar painel de administração (GM commands)
- [ ] Testar estabilidade com 100+ conexões simultâneas
- [ ] Configurar servidor de produção (VPS/dedicado)
- [ ] Criar site oficial do jogo
- [ ] Criar Discord oficial da comunidade
- [ ] Preparar material de divulgação (trailer, screenshots)
- [ ] Lançamento oficial v1.0

---

## 5. Roadmap Técnico

### 5.1 Estrutura de Pastas Recomendada

```
FieldsOnlineHML/
├── Client/
│   ├── Game.exe
│   ├── Game.rvproj2
│   ├── Data/
│   │   ├── Actors.rvdata2
│   │   ├── Animations.rvdata2
│   │   ├── Armors.rvdata2
│   │   ├── Classes.rvdata2
│   │   ├── CommonEvents.rvdata2
│   │   ├── Enemies.rvdata2
│   │   ├── Items.rvdata2
│   │   ├── Map001.rvdata2
│   │   ├── Map002.rvdata2
│   │   ├── Skills.rvdata2
│   │   ├── States.rvdata2
│   │   ├── System.rvdata2
│   │   ├── Tilesets.rvdata2
│   │   ├── Troops.rvdata2
│   │   └── Weapons.rvdata2
│   ├── Graphics/
│   │   ├── Animations/
│   │   ├── Battlebacks1/
│   │   ├── Battlebacks2/
│   │   ├── Battlers/
│   │   ├── Characters/       ← Spritesheets de personagens
│   │   ├── Faces/
│   │   ├── Icons/            ← Ícones de itens, skills, status
│   │   ├── Parallaxes/
│   │   ├── Pictures/
│   │   │   ├── HUD/          ← Assets da HUD (frames, barras)
│   │   │   ├── Login/        ← Assets da tela de login
│   │   │   └── UI/           ← Assets gerais de UI
│   │   ├── System/
│   │   │   ├── Cursors/      ← Cursores customizados
│   │   │   └── Fonts/        ← Fontes customizadas
│   │   ├── Tilesets/
│   │   └── Titles1/
│   ├── Scripts/              ← Gerenciado pelo RPG Maker
│   │   ├── [RM] Scripts Base (não modificar)
│   │   ├── [VS] Scripts VXA-OS (base)
│   │   └── [FO] Scripts Fields Online (customizações)
│   ├── Audio/
│   │   ├── BGM/              ← Músicas de fundo por área
│   │   ├── BGS/              ← Sons de ambiente
│   │   ├── ME/               ← Efeitos musicais (level up, etc.)
│   │   └── SE/               ← Efeitos sonoros
│   └── System/
│       └── settings.ini      ← Configurações locais do cliente
│
├── Server/
│   ├── main.rb               ← Entrypoint do servidor
│   ├── editor.rb             ← Entrypoint do editor
│   ├── Server.bat            ← Launcher Windows
│   ├── Editor.bat            ← Launcher do editor
│   ├── configs.ini           ← Configurações do servidor
│   ├── vocab.ini             ← Vocabulário/textos
│   ├── motd.txt              ← Mensagem do dia
│   ├── Database.sql          ← Schema do banco de dados
│   ├── Data/
│   │   ├── Accounts/         ← Dados de contas (se file-based)
│   │   ├── Logs/             ← Logs do servidor
│   │   │   ├── server.log
│   │   │   ├── error.log
│   │   │   └── pvp.log
│   │   └── Backups/          ← Backups automáticos do DB
│   └── Scripts/
│       ├── Client/           ← Handlers de conexão
│       ├── Combat/
│       │   ├── game_battle.rb
│       │   ├── game_client.rb
│       │   └── game_enemy.rb
│       ├── Database/         ← Persistência SQL/MySQL
│       ├── Guild/            ← Sistema de guildas
│       ├── Kernel/           ← Núcleo EventMachine
│       ├── Map/              ← Gerenciamento de mapas
│       ├── Network/          ← Protocolo de rede
│       ├── Party/            ← Sistema de grupos
│       └── Trade/            ← Sistema de comércio
│
├── Docs/                     ← Documentação do projeto
│   ├── README.md
│   ├── CHANGELOG.md
│   ├── DEVELOPMENT_PLAN.md   ← Este documento
│   ├── API/
│   │   ├── opcodes.md        ← Documentação de opcodes de rede
│   │   └── database.md       ← Documentação do schema
│   └── Design/
│       ├── classes.md        ← Design de classes e skills
│       ├── economy.md        ← Design da economia
│       └── quests.md         ← Design de quests
│
└── Tools/                    ← Ferramentas auxiliares
    ├── item_editor/          ← Editor de itens customizado
    └── map_converter/        ← Conversor de mapas
```

---

### 5.2 Scripts/Plugins Prioritários a Desenvolver

| Script                        | Tipo      | Fase | Dependências                    | Prioridade |
|-------------------------------|-----------|------|---------------------------------|:----------:|
| `[FO] Configs`                | Novo      | 1    | Nenhuma                         | 🔴 Crítica |
| `[FO] Sprite_HUD Melhorado`   | Melhoria  | 1    | Sprite_HUD, Progress_Bar        | 🔴 Crítica |
| `[FO] Minimap Quadrado`       | Melhoria  | 1    | Game_Map, Sprite_HUD            | 🔴 Crítica |
| `[FO] Skill Cooldown`         | Novo      | 1    | Game_Actor, Sprite_HUD          | 🔴 Crítica |
| `[FO] Damage Popup`           | Novo      | 1    | Sprite_Base, Game_Battler       | 🔴 Crítica |
| `[FO] Sprite_Drop Melhorado`  | Melhoria  | 1    | Sprite_Drop, Game_Drop, Mouse   | 🔴 Crítica |
| `[FO] Sprite_States Melhorado`| Melhoria  | 1    | Sprite_States, Game_Battler     | 🔴 Crítica |
| `[FO] Mouse Melhorado`        | Melhoria  | 1    | Mouse, Sprite_Cursor            | 🔴 Crítica |
| `[FO] Resolução Customizada`  | Novo      | 1    | Scene_Base, Spriteset_Map       | 🟡 Alta    |
| `[FO] Cursor Rotativo`        | Melhoria  | 1    | Sprite_Cursor                   | 🟡 Alta    |
| `[FO] Job System`             | Novo      | 2    | Game_Actor, Scene_Character     | 🔴 Crítica |
| `[FO] Item Raridade`          | Novo      | 2    | Game_Drop, Sprite_Drop, Sprite_Desc | 🔴 Crítica |
| `[FO] Item Upgrade`           | Novo      | 2    | Game_Actor, Window_Base         | 🔴 Crítica |
| `[FO] Item Afixos`            | Novo      | 2    | Game_Drop, Game_BaseItem        | 🔴 Crítica |
| `[FO] Quest Chains`           | Melhoria  | 2    | Game_Quest, Quests, Window_Quest| 🔴 Crítica |
| `[FO] Auction House`          | Novo      | 2    | Game_Bank, Network, Database    | 🟡 Alta    |
| `[FO] Chat Multicanal`        | Melhoria  | 2    | Window_Chat, Network            | 🟡 Alta    |
| `[FO] Party HUD`              | Novo      | 2    | Sprite_HUD, Game_Party          | 🟡 Alta    |
| `[FO] Guild Interface`        | Melhoria  | 2    | Guild (Server), Window_Base     | 🟡 Alta    |
| `[FO] PvP Karma System`       | Novo      | 2    | Game_NetPlayer, Network         | 🟡 Alta    |
| `[FO] MVP Boss System`        | Novo      | 2    | game_enemy.rb (Server), Game_Drop | 🟡 Alta  |
| `[FO] Achievement System`     | Novo      | 3    | Game_Actor, Network, Database   | 🟢 Média   |
| `[FO] Weather System`         | Melhoria  | 3    | Spriteset_Weather, Network      | 🟢 Média   |
| `[FO] Prestige System`        | Novo      | 3    | Game_Actor, Network, Database   | 🟢 Média   |

---

### 5.3 Convenções de Código Ruby/RGSS3

**Padrão de Nomenclatura para Scripts `[FO]`:**

```
[FO] NomeDoScript
```

- Prefixo `[FO]` para todos os scripts Fields Online
- PascalCase para nomes de módulos e classes
- snake_case para métodos e variáveis
- SCREAMING_SNAKE_CASE para constantes
- Aliases com prefixo `fo_` para evitar conflitos

**Estrutura Modelo de um Script VXA-OS/Fields Online:**

```ruby
#==============================================================================
# [FO] Nome do Script
# Fields Online — Descrição breve do script
#------------------------------------------------------------------------------
# Autor    : Caio Juan De Lima Silva
# Versão   : 1.0.0
# Data     : 2026-04-08
# Requer   : VXA-OS v2.1.6, [VS] Configs, [VS] Sprite_HUD
#------------------------------------------------------------------------------
# DESCRIÇÃO:
#   Descrição detalhada do que este script faz, como funciona e
#   quais sistemas ele afeta.
#
# INSTRUÇÕES DE USO:
#   1. Instale abaixo de [VS] Sprite_HUD
#   2. Configure as opções no módulo FO::NomeConfig abaixo
#   3. Reinicie o jogo
#
# CHANGELOG:
#   v1.0.0 (2026-04-08) — Versão inicial
#==============================================================================

#==============================================================================
# CONFIGURAÇÕES — Edite aqui para personalizar o script
#==============================================================================
module FO
  module NomeConfig
    #--------------------------------------------------------------------------
    # Configurações Gerais
    #--------------------------------------------------------------------------
    ATIVO         = true      # Ativar/desativar o script
    FONTE         = "Arial"   # Nome da fonte
    TAMANHO_FONTE = 16        # Tamanho da fonte em pixels
    NEGRITO       = false     # Texto em negrito?
    ITALICO       = false     # Texto em itálico?

    #--------------------------------------------------------------------------
    # Configurações de Posição
    #--------------------------------------------------------------------------
    POS_X         = 10        # Posição X na tela
    POS_Y         = 10        # Posição Y na tela
    LARGURA       = 200       # Largura do elemento
    ALTURA        = 30        # Altura do elemento

    #--------------------------------------------------------------------------
    # Configurações Visuais
    #--------------------------------------------------------------------------
    COR_TEXTO     = Color.new(255, 255, 255, 255)  # Branco
    COR_FUNDO     = Color.new(0, 0, 0, 180)        # Preto semi-transparente
    MOSTRAR_FUNDO = true      # Exibir fundo?
  end
end

#==============================================================================
# Extensão de Classe Existente (exemplo: Game_Actor)
#==============================================================================
class Game_Actor < Game_Battler
  # Alias para preservar comportamento original
  alias fo_nome_initialize initialize
  def initialize(actor_id)
    fo_nome_initialize(actor_id)
    # Inicializações adicionais do Fields Online
    @fo_dado_extra = nil
  end

  # Novo método Fields Online
  def fo_metodo_novo
    # Implementação
  end
end

#==============================================================================
# Novo Sprite (exemplo de sprite customizado)
#==============================================================================
class Sprite_FoNome < Sprite_Base
  def initialize(viewport = nil)
    super(viewport)
    create_bitmap
    refresh
  end

  def create_bitmap
    self.bitmap = Bitmap.new(
      FO::NomeConfig::LARGURA,
      FO::NomeConfig::ALTURA
    )
    self.x = FO::NomeConfig::POS_X
    self.y = FO::NomeConfig::POS_Y
    self.z = 200  # Z-order (acima do mapa, abaixo da HUD principal)
  end

  def refresh
    return unless FO::NomeConfig::ATIVO
    self.bitmap.clear

    # Desenhar fundo
    if FO::NomeConfig::MOSTRAR_FUNDO
      self.bitmap.fill_rect(
        0, 0,
        FO::NomeConfig::LARGURA,
        FO::NomeConfig::ALTURA,
        FO::NomeConfig::COR_FUNDO
      )
    end

    # Configurar fonte
    self.bitmap.font.name  = FO::NomeConfig::FONTE
    self.bitmap.font.size  = FO::NomeConfig::TAMANHO_FONTE
    self.bitmap.font.bold  = FO::NomeConfig::NEGRITO
    self.bitmap.font.italic = FO::NomeConfig::ITALICO
    self.bitmap.font.color = FO::NomeConfig::COR_TEXTO

    # Desenhar conteúdo
    self.bitmap.draw_text(
      4, 0,
      FO::NomeConfig::LARGURA - 8,
      FO::NomeConfig::ALTURA,
      "Conteúdo aqui"
    )
  end

  def update
    super
    refresh if needs_refresh?
  end

  def needs_refresh?
    # Lógica para determinar se precisa redesenhar
    false
  end

  def dispose
    self.bitmap.dispose if self.bitmap
    super
  end
end
```

---

### 5.4 Integração Client-Server

**Diagrama de Fluxo de Pacote — Jogador Ataca:**

```
┌─────────────────────────────────────────────────────────────────────┐
│  FLUXO COMPLETO: Jogador A ataca Inimigo → Todos os clientes veem  │
└─────────────────────────────────────────────────────────────────────┘

[CLIENT A]              [SERVIDOR]              [CLIENT B] [CLIENT C]
    │                       │                       │           │
    │ 1. Clique no inimigo  │                       │           │
    │ Mouse.rb detecta alvo │                       │           │
    │ Game_Player verifica  │                       │           │
    │   range (2 tiles)     │                       │           │
    │                       │                       │           │
    │──2. Send_Data(:atk)──►│                       │           │
    │   opcode: 0x10        │                       │           │
    │   data: [target_id,   │                       │           │
    │          skill_id]    │                       │           │
    │                       │                       │           │
    │                       │ 3. Handle_Data recebe │           │
    │                       │ game_battle.rb calcula│           │
    │                       │   dano, hit/miss      │           │
    │                       │ game_enemy.rb atualiza│           │
    │                       │   HP do inimigo       │           │
    │                       │                       │           │
    │◄──4. Resposta dano ───│                       │           │
    │   opcode: 0x11        │                       │           │
    │   data: [damage,      │──5. Broadcast ───────►│──────────►│
    │          new_hp,      │   para todos no mapa  │           │
    │          is_dead]     │                       │           │
    │                       │                       │           │
    │ 6. Handle_Data processa                       │           │
    │ Sprite_HUD: atualiza HP bar                   │           │
    │ Damage popup: mostra dano                     │           │
    │ Sprite_Character: anima hit                   │           │
    │                       │                       │           │
    │ (se inimigo morreu)   │                       │           │
    │◄──7. Drop data ───────│                       │           │
    │   Game_Drop cria loot │                       │           │
    │   Sprite_Drop exibe   │                       │           │
    │   (protegido 30s)     │                       │           │
```

**Tabela de Opcodes de Rede:**

| Opcode (hex) | Nome              | Direção        | Dados                                    | Status    |
|:------------:|-------------------|----------------|------------------------------------------|-----------|
| `0x01`       | Login             | Client → Server| username, password                       | ✅ Existe |
| `0x02`       | Login Response    | Server → Client| success, player_data                     | ✅ Existe |
| `0x03`       | Move              | Client → Server| direction, x, y                          | ✅ Existe |
| `0x04`       | Player Move       | Server → Client| player_id, x, y, direction               | ✅ Existe |
| `0x05`       | Chat Message      | Bidirecional   | channel, sender, message                 | ✅ Existe |
| `0x10`       | Attack            | Client → Server| target_id, skill_id                      | ✅ Existe |
| `0x11`       | Damage            | Server → Client| attacker_id, target_id, damage, new_hp   | ✅ Existe |
| `0x12`       | Enemy Death       | Server → Client| enemy_id, drop_data                      | ✅ Existe |
| `0x13`       | Player Death      | Server → Client| player_id, killer_id                     | ✅ Existe |
| `0x20`       | Drop Item         | Server → Client| drop_id, item_id, x, y, owner_id         | ✅ Existe |
| `0x21`       | Collect Drop      | Client → Server| drop_id                                  | ✅ Existe |
| `0x22`       | Drop Collected    | Server → Client| drop_id, player_id                       | ✅ Existe |
| `0x30`       | Trade Request     | Client → Server| target_player_id                         | ✅ Existe |
| `0x31`       | Trade Data        | Bidirecional   | items, gold                              | ✅ Existe |
| `0x40`       | Quest Update      | Server → Client| quest_id, objective_progress             | ✅ Existe |
| `0x41`       | Quest Complete    | Server → Client| quest_id, rewards                        | ✅ Existe |
| `0x50`       | Skill Use         | Client → Server| skill_id, target_id, target_x, target_y  | ❌ Novo   |
| `0x51`       | Skill Effect      | Server → Client| skill_id, caster_id, targets[], effects[]| ❌ Novo   |
| `0x60`       | Karma Update      | Server → Client| player_id, karma_level, skull_type       | ❌ Novo   |
| `0x70`       | Auction List      | Client → Server| filter_params                            | ❌ Novo   |
| `0x71`       | Auction Data      | Server → Client| auction_list[]                           | ❌ Novo   |
| `0x80`       | Achievement       | Server → Client| achievement_id, player_id                | ❌ Novo   |
| `0x90`       | Guild War Start   | Server → Client| guild_a_id, guild_b_id                   | ❌ Novo   |

**Exemplo de Send_Data e Handle_Data em Ruby:**

```ruby
#==============================================================================
# [FO] Exemplo de Send_Data — Usar Skill
#==============================================================================
module Send_Data
  # Envia pacote de uso de skill para o servidor
  # skill_id: ID da skill usada
  # target_id: ID do alvo (0 se sem alvo)
  # target_x, target_y: posição do alvo (para skills de área)
  def self.use_skill(skill_id, target_id = 0, target_x = 0, target_y = 0)
    return unless $network.connected?
    buffer = Buffer.new
    buffer.write_byte(0x50)       # Opcode: USE_SKILL
    buffer.write_short(skill_id)  # ID da skill (2 bytes)
    buffer.write_int(target_id)   # ID do alvo (4 bytes)
    buffer.write_short(target_x)  # X do alvo (2 bytes)
    buffer.write_short(target_y)  # Y do alvo (2 bytes)
    $network.send(buffer.to_s)
  end
end

#==============================================================================
# [FO] Exemplo de Handle_Data — Receber Efeito de Skill
#==============================================================================
module Handle_Data
  # Processa pacote de efeito de skill recebido do servidor
  # Opcode 0x51: SKILL_EFFECT
  def self.handle_skill_effect(buffer)
    skill_id  = buffer.read_short  # ID da skill
    caster_id = buffer.read_int    # ID do conjurador
    target_count = buffer.read_byte # Número de alvos

    targets = []
    target_count.times do
      target_id = buffer.read_int
      damage    = buffer.read_int
      new_hp    = buffer.read_int
      is_dead   = buffer.read_bool
      targets << { id: target_id, damage: damage, hp: new_hp, dead: is_dead }
    end

    # Aplicar efeitos visuais para cada alvo
    targets.each do |t|
      # Mostrar damage popup
      $game_map.fo_add_damage_popup(t[:id], t[:damage])
      # Atualizar HP do alvo
      $game_map.fo_update_entity_hp(t[:id], t[:hp])
      # Processar morte se necessário
      $game_map.fo_process_death(t[:id]) if t[:dead]
    end

    # Reproduzir animação da skill
    $game_map.fo_play_skill_animation(skill_id, caster_id)
  end
end
```

---

### 5.5 Database e Persistência

**Schema SQL Principal:**

```sql
-- ============================================================
-- Fields Online — Database Schema v1.0
-- ============================================================

-- Tabela de Contas
CREATE TABLE accounts (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(20) NOT NULL UNIQUE,
    password    VARCHAR(64) NOT NULL,  -- SHA-256 hash
    email       VARCHAR(100),
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login  DATETIME,
    is_banned   TINYINT(1) DEFAULT 0,
    ban_reason  VARCHAR(255),
    is_vip      TINYINT(1) DEFAULT 0,
    vip_expires DATETIME
);

-- Tabela de Personagens
CREATE TABLE players (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    account_id  INT NOT NULL,
    name        VARCHAR(20) NOT NULL UNIQUE,
    class_id    INT DEFAULT 1,
    job_id      INT DEFAULT 0,
    level       INT DEFAULT 1,
    job_level   INT DEFAULT 1,
    exp         BIGINT DEFAULT 0,
    hp          INT DEFAULT 100,
    mp          INT DEFAULT 50,
    max_hp      INT DEFAULT 100,
    max_mp      INT DEFAULT 50,
    str         INT DEFAULT 10,
    dex         INT DEFAULT 10,
    int_stat    INT DEFAULT 10,
    vit         INT DEFAULT 10,
    agi         INT DEFAULT 10,
    luk         INT DEFAULT 10,
    attr_points INT DEFAULT 0,
    skill_points INT DEFAULT 0,
    gold        BIGINT DEFAULT 0,
    map_id      INT DEFAULT 1,
    map_x       INT DEFAULT 5,
    map_y       INT DEFAULT 5,
    direction   INT DEFAULT 2,
    karma       INT DEFAULT 0,
    pvp_kills   INT DEFAULT 0,
    pvp_deaths  INT DEFAULT 0,
    guild_id    INT DEFAULT 0,
    guild_rank  INT DEFAULT 0,
    prestige    INT DEFAULT 0,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_seen   DATETIME,
    FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
);

-- Tabela de Inventário
CREATE TABLE inventory (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    player_id   INT NOT NULL,
    slot        INT NOT NULL,           -- Slot no inventário (0-N)
    item_type   TINYINT NOT NULL,       -- 0=item, 1=weapon, 2=armor
    item_id     INT NOT NULL,
    amount      INT DEFAULT 1,
    upgrade     INT DEFAULT 0,          -- Nível de upgrade (+0 a +15)
    rarity      TINYINT DEFAULT 0,      -- 0=comum, 1=incomum, 2=raro, 3=épico, 4=lendário
    affix_data  TEXT,                   -- JSON com afixos aleatórios
    is_equipped TINYINT(1) DEFAULT 0,
    equip_slot  INT DEFAULT -1,         -- Slot de equipamento (-1 = não equipado)
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE KEY unique_slot (player_id, slot)
);

-- Tabela de Banco (Bank)
CREATE TABLE bank (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    player_id   INT NOT NULL,
    slot        INT NOT NULL,
    item_type   TINYINT NOT NULL,
    item_id     INT NOT NULL,
    amount      INT DEFAULT 1,
    upgrade     INT DEFAULT 0,
    rarity      TINYINT DEFAULT 0,
    affix_data  TEXT,
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

-- Tabela de Guildas
CREATE TABLE guilds (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(30) NOT NULL UNIQUE,
    leader_id   INT NOT NULL,
    description TEXT,
    emblem      VARCHAR(100),           -- Path do emblema
    level       INT DEFAULT 1,
    exp         BIGINT DEFAULT 0,
    gold        BIGINT DEFAULT 0,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (leader_id) REFERENCES players(id)
);

-- Tabela de Quests dos Jogadores
CREATE TABLE player_quests (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    player_id   INT NOT NULL,
    quest_id    INT NOT NULL,
    status      TINYINT DEFAULT 0,     -- 0=disponível, 1=ativa, 2=completa, 3=falhou
    progress    TEXT,                  -- JSON com progresso de cada objetivo
    started_at  DATETIME,
    completed_at DATETIME,
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE KEY unique_quest (player_id, quest_id)
);

-- Tabela de Skills dos Jogadores
CREATE TABLE player_skills (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    player_id   INT NOT NULL,
    skill_id    INT NOT NULL,
    skill_level INT DEFAULT 1,
    hotkey_slot INT DEFAULT -1,        -- Slot na barra de hotkeys (-1 = não atribuído)
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE KEY unique_skill (player_id, skill_id)
);

-- Tabela de Conquistas
CREATE TABLE player_achievements (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    player_id       INT NOT NULL,
    achievement_id  INT NOT NULL,
    unlocked_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE KEY unique_achievement (player_id, achievement_id)
);

-- Tabela de Casa de Leilões
CREATE TABLE auction_house (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    seller_id   INT NOT NULL,
    item_type   TINYINT NOT NULL,
    item_id     INT NOT NULL,
    amount      INT DEFAULT 1,
    upgrade     INT DEFAULT 0,
    rarity      TINYINT DEFAULT 0,
    affix_data  TEXT,
    start_price BIGINT NOT NULL,
    buyout_price BIGINT,               -- Preço de compra imediata (NULL = sem buyout)
    current_bid BIGINT DEFAULT 0,
    bidder_id   INT DEFAULT 0,
    expires_at  DATETIME NOT NULL,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES players(id)
);

-- Índices para performance
CREATE INDEX idx_players_account ON players(account_id);
CREATE INDEX idx_inventory_player ON inventory(player_id);
CREATE INDEX idx_quests_player ON player_quests(player_id);
CREATE INDEX idx_auction_expires ON auction_house(expires_at);
CREATE INDEX idx_players_map ON players(map_id);
```

**Estratégias de Backup e Sincronização:**

| Estratégia          | Frequência    | Método                                          |
|---------------------|---------------|-------------------------------------------------|
| Backup completo     | Diário (3h AM)| `mysqldump` para arquivo comprimido             |
| Backup incremental  | A cada 6h     | Binary log do MySQL                             |
| Sync de personagem  | A cada 5 min  | Auto-save de dados do jogador no servidor       |
| Sync ao logout      | Imediato      | Salvar todos os dados ao desconectar            |
| Retenção de backups | 30 dias       | Rotação automática de arquivos antigos          |

---

## 6. Cronograma Estimado

### 6.1 Timeline Visual (Gantt ASCII)

```
FIELDS ONLINE — CRONOGRAMA DE DESENVOLVIMENTO (40 Semanas)
═══════════════════════════════════════════════════════════════════════════════

Semana:  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20
         │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │
FASE 1   ████████████████████████████████
Ambiente ████████
HUD/UI      ████████████
Minimap         ████████
Combate             ████████████
Database                ████████████████
─────────────────────────────────────────────────────────────────────────────
FASE 2                                   ████████████████████████████████████
Classes                                  ████████████
Itens/Drop                                   ████████████
Quests                                           ████████████
Economia                                             ████████████
PvP/Guild                                                ████████████████████
─────────────────────────────────────────────────────────────────────────────

Semana: 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40
         │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │
FASE 3   ████████████████████████████████
Polimento████████████████
Balanceam        ████████████
UI Final                 ████████████
Otimização                       ████████████
─────────────────────────────────────────────────────────────────────────────
FASE 4                                   ████████████████████████████████████
Beta Fech                                ████████
Bug Fix                                      ████████
Beta Aber                                        ████████████
Lançamento                                               ████████████████████
═══════════════════════════════════════════════════════════════════════════════
LEGENDA: ████ = Período ativo de desenvolvimento
```

---

### 6.2 Milestones Principais

| Milestone                          | Fase   | Semana Alvo | Critério de Conclusão                                              |
|------------------------------------|--------|:-----------:|--------------------------------------------------------------------|
| 🟢 Ambiente Configurado            | Fase 1 | Semana 1    | Dev pode rodar cliente e servidor localmente sem erros             |
| 🟢 HUD Modernizada                 | Fase 1 | Semana 3    | HP/MP/XP bars, hotkeys de skill e minimap quadrado funcionando     |
| 🟢 Ciclo de Combate Completo       | Fase 1 | Semana 6    | Jogador ataca, mata inimigo, loot cai, jogador coleta              |
| 🟢 Database Schema Completo        | Fase 1 | Semana 8    | Todas as tabelas criadas, dados persistem entre sessões            |
| 🟡 Sistema de Classes Funcional    | Fase 2 | Semana 11   | 3 classes base com skills únicas e evolução implementada           |
| 🟡 Sistema de Itens Completo       | Fase 2 | Semana 14   | Raridades, upgrades e afixos funcionando                           |
| 🟡 Quest System Completo           | Fase 2 | Semana 16   | 10 quests principais encadeadas funcionando                        |
| 🟡 Economia Funcional              | Fase 2 | Semana 18   | Trade, banco e leilão funcionando entre jogadores                  |
| 🟡 PvP e Guild Completos           | Fase 2 | Semana 20   | PvP com karma, arena e guild wars funcionando                      |
| 🔴 Jogo Polido                     | Fase 3 | Semana 28   | UI profissional, sem bugs visuais, balanceamento inicial           |
| 🔴 Otimização Completa             | Fase 3 | Semana 32   | 50+ jogadores simultâneos sem lag perceptível                      |
| 🔴 Beta Fechado                    | Fase 4 | Semana 33   | 20-50 jogadores testando, sistema de report funcionando            |
| 🔴 Beta Aberto                     | Fase 4 | Semana 37   | Público geral pode criar conta e jogar                             |
| 🔴 **Lançamento Oficial v1.0**     | Fase 4 | Semana 40   | Servidor estável, sem bugs críticos, comunidade ativa              |

---

### 6.3 Recursos Necessários

| Recurso                        | Tipo    | Estimativa de Horas | Prioridade |
|--------------------------------|---------|:-------------------:|:----------:|
| Desenvolvimento de scripts Ruby| Dev     | 400h                | 🔴 Crítica |
| Design e criação de mapas      | Design  | 150h                | 🔴 Crítica |
| Criação de assets gráficos     | Art     | 200h                | 🔴 Crítica |
| Balanceamento de gameplay      | Design  | 80h                 | 🟡 Alta    |
| Criação de conteúdo (quests)   | Design  | 100h                | 🟡 Alta    |
| Testes e QA                    | Dev/QA  | 120h                | 🔴 Crítica |
| Configuração de servidor       | Dev/Ops | 40h                 | 🔴 Crítica |
| Documentação técnica           | Dev     | 60h                 | 🟡 Alta    |
| Criação de músicas/sons        | Art     | 80h                 | 🟡 Alta    |
| Criação de animações de skill  | Art     | 100h                | 🟡 Alta    |
| Administração da comunidade    | Social  | 50h                 | 🟢 Média   |
| Marketing e divulgação         | Social  | 40h                 | 🟢 Média   |
| **TOTAL ESTIMADO**             | —       | **~1.420h**         | —          |

---

## 7. Considerações e Riscos

### 7.1 Desafios Técnicos

| Desafio                                    | Probabilidade | Impacto | Estratégia de Mitigação                                              |
|--------------------------------------------|:-------------:|:-------:|----------------------------------------------------------------------|
| Lag em mapas com muitos jogadores          | 🔴 Alta       | 🔴 Alto | Scripts anti-lag, limite de jogadores por mapa, otimização de sprites|
| Dessincronização client-server             | 🟡 Média      | 🔴 Alto | Validação server-side de todas as ações, reconciliação periódica     |
| Memory leaks em sprites não dispostos      | 🟡 Média      | 🟡 Médio| Auditoria de dispose(), uso de object pooling para sprites           |
| Exploits de duplication de itens           | 🟡 Média      | 🔴 Alto | Transações atômicas no DB, validação dupla no servidor               |
| Crash do servidor sob alta carga           | 🟡 Média      | 🔴 Alto | Testes de stress, watchdog para reinício automático, logs detalhados |
| Incompatibilidade de scripts [RM] e [VS]   | 🟡 Média      | 🟡 Médio| Aliases cuidadosos, testes de regressão após cada script novo        |
| Limitação de 200-300 eventos por mapa      | 🔴 Alta       | 🟡 Médio| Spawn dinâmico via servidor, pooling de eventos, mapas menores       |
| Ruby 1.9.x sem gems modernas               | 🟡 Média      | 🟡 Médio| Implementar funcionalidades necessárias manualmente em Ruby puro     |
| Perda de dados por crash do servidor       | 🟢 Baixa      | 🔴 Alto | Auto-save a cada 5 min, backup diário, transações MySQL              |
| Cheating/hacking de clientes               | 🟡 Média      | 🔴 Alto | Toda lógica crítica no servidor, validação de pacotes, anti-cheat    |

---

### 7.2 Boas Práticas Recomendadas

1. **📌 Sempre use aliases ao sobrescrever métodos do RPG Maker ou VXA-OS.** Nunca sobrescreva diretamente sem alias — isso quebra a cadeia de herança e causa bugs difíceis de rastrear.

2. **📌 Toda lógica de jogo crítica (dano, drop, XP) deve ser processada exclusivamente no servidor.** O cliente apenas exibe resultados — nunca confie em dados enviados pelo cliente para cálculos de gameplay.

3. **📌 Sempre chame `dispose()` em bitmaps e sprites quando não forem mais necessários.** Memory leaks são a principal causa de degradação de performance no RGSS3.

4. **📌 Use o módulo `FO::Configs` como ponto central de configuração.** Nunca hardcode valores como posições, cores ou tamanhos diretamente no código — sempre referencie uma constante configurável.

5. **📌 Documente todos os opcodes de rede em `Docs/API/opcodes.md`.** Manter a documentação de protocolo atualizada é essencial para debugging e expansão futura.

6. **📌 Faça commits pequenos e frequentes no GitHub com mensagens descritivas.** Use o padrão: `[FASE] tipo: descrição breve` (ex: `[F1] feat: implementa minimap quadrado com frame bitmap`).

7. **📌 Teste cada script isoladamente antes de integrá-lo ao projeto principal.** Crie um projeto RPG Maker de teste separado para validar scripts novos.

8. **📌 Use transações MySQL para operações críticas de banco de dados** (transferência de itens, compra/venda, upgrade). Nunca faça operações de múltiplos passos sem transação — risco de inconsistência de dados.

9. **📌 Implemente logging detalhado no servidor** (ações de jogadores, erros, transações). Logs são essenciais para debugging, detecção de exploits e análise de comportamento.

10. **📌 Mantenha separação clara entre scripts `[RM]`, `[VS]` e `[FO]`.** Scripts `[RM]` nunca devem ser modificados diretamente. Scripts `[VS]` só devem ser modificados se absolutamente necessário. Toda customização Fields Online vai em scripts `[FO]`.

11. **📌 Implemente rate limiting no servidor** para pacotes de rede. Limite a frequência de ações por jogador (ex: máximo 10 ataques por segundo) para prevenir spam e exploits.

12. **📌 Use `$game_temp` para dados temporários** que não precisam ser persistidos. Evite poluir `$game_system` ou `$game_variables` com dados temporários.

13. **📌 Valide sempre o range de ação no servidor** antes de processar qualquer ação (ataque, coleta de drop, interação com NPC). O cliente pode enviar coordenadas falsas.

14. **📌 Mantenha um CHANGELOG.md atualizado** com todas as mudanças por versão. Isso facilita debugging, comunicação com a comunidade e rollback se necessário.

---

### 7.3 Referências e Recursos

| Recurso                              | URL / Localização                                                    |
|--------------------------------------|----------------------------------------------------------------------|
| Repositório VXA-OS Oficial           | https://github.com/Valentine90/vxa-os                               |
| Repositório Fields Online (HML)      | https://github.com/CaioJuan2910/FieldsOnlineHML                     |
| Documentação RGSS3 (RPG Maker VX Ace)| https://www.rpgmakerweb.com/support/products/rpg-maker-vx-ace       |
| Fórum RPG Maker (RMW)                | https://forums.rpgmakerweb.com/                                     |
| Fórum RPG Maker Brasil               | https://www.condadobraveheart.com/                                  |
| EventMachine Documentação            | https://www.rubydoc.info/gems/eventmachine                          |
| Ruby 1.9 Reference                   | https://ruby-doc.org/core-1.9.3/                                    |
| MySQL 5.7 Documentation              | https://dev.mysql.com/doc/refman/5.7/en/                            |
| Tibia Wiki (referência de mecânicas) | https://tibia.fandom.com/wiki/Tibia_Wiki                            |
| Ragnarok Wiki (referência de sistemas)| https://ragnarok.fandom.com/wiki/Ragnarok_Wiki                     |
| Git/GitHub Guides                    | https://guides.github.com/                                          |

---

## Apêndice A — Inventário Completo de Scripts

### Scripts Base RPG Maker — Prefixo `[RM]`

| # | Script                  | Categoria      | Descrição Funcional                                                        |
|---|-------------------------|----------------|----------------------------------------------------------------------------|
| 1 | `Cache`                 | Sistema        | Gerencia cache de bitmaps para evitar recarregamento desnecessário de assets |
| 2 | `DataManager`           | Sistema        | Carrega, salva e gerencia todos os dados do jogo (.rvdata2)                |
| 3 | `Game_Action`           | Batalha        | Representa uma ação de batalha (atacar, usar skill, usar item, defender)   |
| 4 | `Game_ActionResult`     | Batalha        | Armazena o resultado de uma ação (dano causado, HP curado, status aplicado)|
| 5 | `Game_Actor`            | Personagem     | Dados completos de um ator: stats, equipamentos, skills, level             |
| 6 | `Game_Actors`           | Personagem     | Coleção de todos os atores do jogo, acessível por ID                       |
| 7 | `Game_BaseItem`         | Item           | Classe base para itens, armas e armaduras (dados comuns)                   |
| 8 | `Game_Battler`          | Batalha        | Lógica de combatente: HP/MP, aplicar dano, estados, regeneração            |
| 9 | `Game_BattlerBase`      | Batalha        | Atributos fundamentais de combatente: parâmetros base, features            |
|10 | `Game_Character`        | Mapa           | Movimento de personagem no mapa: velocidade, direção, colisão              |
|11 | `Game_CharacterBase`    | Mapa           | Base de personagem: posição (x,y), direção, sprite, passabilidade          |
|12 | `Game_Enemy`            | Batalha        | Dados de inimigo: stats, drops, ações de batalha                           |
|13 | `Game_Event`            | Mapa           | Evento do mapa: páginas, condições, comandos, triggers                     |
|14 | `Game_Interpreter`      | Sistema        | Interpreta e executa comandos de evento (move, show message, etc.)         |
|15 | `Game_Map`              | Mapa           | Gerencia o mapa atual: tiles, eventos, scroll, passabilidade               |
|16 | `Game_Message`          | UI             | Sistema de mensagens: texto, escolhas, input numérico                      |
|17 | `Game_Party`            | Personagem     | Grupo do jogador: membros, inventário, ouro, itens chave                   |
|18 | `Game_Picture`          | UI             | Imagem de tela (picture): posição, escala, opacidade, blend                |
|19 | `Game_Pictures`         | UI             | Coleção de pictures (1-100)                                                |
|20 | `Game_Player`           | Personagem     | Personagem controlado pelo jogador: input, movimento, interação            |
|21 | `Game_Screen`           | UI             | Efeitos de tela: fade, flash, shake, tone, weather                         |
|22 | `Game_SelfSwitches`     | Sistema        | Switches locais de eventos (A, B, C, D por evento/mapa)                    |
|23 | `Game_Switches`         | Sistema        | Switches globais do jogo (1-5000)                                          |
|24 | `Game_System`           | Sistema        | Configurações em runtime: BGM, batalha, save, veículos                     |
|25 | `Game_Temp`             | Sistema        | Dados temporários não persistidos: destino de teleporte, batalha comum     |
|26 | `Game_Timer`            | Sistema        | Timer global: contagem regressiva, eventos ao zerar                        |
|27 | `Game_Unit`             | Batalha        | Unidade de batalha (grupo de combatentes): party ou tropa de inimigos      |
|28 | `Game_Variables`        | Sistema        | Variáveis globais do jogo (1-5000), armazenam valores numéricos            |
|29 | `Game_Vehicle`          | Mapa           | Veículos: barco, navio, aeronave — movimento e embarque                    |
|30 | `Main`                  | Sistema        | Loop principal do RPG Maker: inicializa e executa o SceneManager           |
|31 | `SceneManager`          | Sistema        | Gerencia transições entre cenas (goto, call, return)                       |
|32 | `Scene_Base`            | Cena           | Classe base para todas as cenas: create, update, terminate                 |
|33 | `Scene_Map`             | Cena           | Cena principal do jogo: mapa, eventos, HUD, input do jogador               |
|34 | `Sound`                 | Áudio          | Reprodução de BGM, BGS, ME e SE com parâmetros de volume/pitch             |
|35 | `Sprite_Base`           | Sprite         | Classe base para sprites: animação, flash, efeitos                         |
|36 | `Sprite_Character`      | Sprite         | Sprite de personagem no mapa: spritesheet, direção, animação de movimento  |
|37 | `Sprite_Picture`        | Sprite         | Sprite de picture: carrega e exibe imagens de tela                         |
|38 | `Sprite_Timer`          | Sprite         | Sprite do timer: exibe contagem regressiva na tela                         |
|39 | `Spriteset_Map`         | Sprite         | Conjunto de todos os sprites do mapa: tiles, personagens, weather          |
|40 | `Spriteset_Weather`     | Sprite         | Efeitos climáticos visuais: chuva, neve, tempestade de areia               |
|41 | `Vocab`                 | Sistema        | Vocabulário padrão: nomes de stats, comandos de batalha, mensagens         |
|42 | `Window_Base`           | UI             | Classe base para janelas: desenho de texto, ícones, gauges                 |
|43 | `Window_ChoiceList`     | UI             | Janela de lista de escolhas (ramificação de diálogo)                       |
|44 | `Window_Command`        | UI             | Janela de comandos: lista de opções selecionáveis                          |
|45 | `Window_Gold`           | UI             | Janela de exibição de ouro do jogador                                      |
|46 | `Window_ItemList`       | UI             | Lista de itens do inventário com filtros                                   |
|47 | `Window_KeyItem`        | UI             | Seleção de item chave para uso em eventos                                  |
|48 | `Window_Message`        | UI             | Janela de mensagem/diálogo: texto, faces, escolhas, input                  |
|49 | `Window_NumberInput`    | UI             | Janela de entrada numérica (ex: quantidade de itens)                       |
|50 | `Window_ScrollText`     | UI             | Janela de texto com scroll (créditos, textos longos)                       |
|51 | `Window_Selectable`     | UI             | Janela selecionável base: cursor, scroll, input de seleção                 |

### Scripts VXA-OS Customizados — Prefixo `[VS]`

| # | Script              | Categoria  | Descrição Funcional                                                              |
|---|---------------------|------------|----------------------------------------------------------------------------------|
| 1 | `Audio`             | Sistema    | Sistema de áudio customizado para MMO: BGM por mapa, sons de rede               |
| 2 | `Buffer`            | Rede       | Serialização/deserialização binária de pacotes: read/write de tipos primitivos   |
| 3 | `Button`            | UI         | Componente de botão clicável para interfaces customizadas                        |
| 4 | `Check_Box`         | UI         | Componente checkbox para configurações e formulários de UI                       |
| 5 | `Combo_Box`         | UI         | Componente combobox (dropdown) para seleção de opções                            |
| 6 | `Configs`           | Sistema    | Configurações centrais do VXA-OS: IP, porta, resolução, features on/off         |
| 7 | `Control`           | UI         | Classe base para controles de UI interativos                                     |
| 8 | `DataManager`       | Sistema    | Override do DataManager para MMO: carrega dados de rede ao invés de arquivo     |
| 9 | `Enums`             | Sistema    | Enumerações de opcodes de rede e constantes do sistema MMO                       |
|10 | `Game_ActionResult` | Batalha    | Override do resultado de ação para combate MMO server-side                       |
|11 | `Game_Actor`        | Personagem | Override do ator para dados de personagem MMO (stats de rede, equipamentos)     |
|12 | `Game_Bank`         | Economia   | Sistema de banco: depósito/saque de itens e ouro, sincronização com servidor    |
|13 | `Game_Character`    | Mapa       | Override de personagem para movimento sincronizado em rede                       |
|14 | `Game_Drop`         | Loot       | Sistema de drops: criação, propriedade, expiração, coleta de itens no chão      |
|15 | `Game_Event`        | Mapa       | Override de eventos para sincronização de estado em rede (switches, variáveis)  |
|16 | `Game_Map`          | Mapa       | Override do mapa para gerenciamento MMO: jogadores, drops, projéteis            |
|17 | `Game_NetPlayer`    | Personagem | Dados e lógica de outros jogadores visíveis no mapa (não controlados localmente)|
|18 | `Game_Party`        | Personagem | Override de party para MMO: membros de rede, compartilhamento de XP             |
|19 | `Game_Player`       | Personagem | Override do jogador para controle em rede: envio de movimento, ações            |
|20 | `Game_Projectile`   | Combate    | Sistema de projéteis: criação, movimento, colisão, efeito ao atingir            |
|21 | `Game_Quest`        | Quest      | Dados e lógica de quests do jogador: objetivos, progresso, recompensas          |
|22 | `Game_Trade`        | Economia   | Sistema de comércio entre jogadores: oferta, confirmação, troca segura          |
|23 | `Handle_Data`       | Rede       | Processamento de todos os pacotes recebidos do servidor (dispatcher)            |
|24 | `Icon`              | UI         | Renderização de ícones de itens, skills e status a partir do iconset            |
|25 | `Image_Button`      | UI         | Botão com imagem customizada (PNG) para interfaces visuais                      |
|26 | `Input`             | Sistema    | Override do sistema de input para MMO: teclado + mouse integrados               |
|27 | `Input_Slider`      | UI         | Componente slider para ajuste de valores (volume, brilho, etc.)                 |
|28 | `Kernel`            | Sistema    | Extensões do Kernel Ruby para o cliente: utilitários, helpers globais           |
|29 | `Mouse`             | Input      | Sistema de input de mouse: posição, cliques, hover, detecção de alvos           |
|30 | `Network`           | Rede       | Gerenciamento da conexão TCP: conectar, desconectar, reconectar, estado         |
|31 | `Progress_Bar`      | UI         | Barra de progresso customizável: HP, MP, XP, cooldown                           |
|32 | `Quests`            | Quest      | Configuração e definição de todas as quests do jogo (dados estáticos)           |
|33 | `Radio_Button`      | UI         | Componente radio button para seleção exclusiva entre opções                     |
|34 | `Scene_Base`        | Cena       | Override da cena base para MMO: update de rede, tratamento de desconexão        |
|35 | `Scene_Character`   | Cena       | Cena de criação e seleção de personagem: lista de chars, criação, deleção       |
|36 | `Scene_Login`       | Cena       | Cena de login: campos de usuário/senha, botão de login, registro               |
|37 | `Scene_Map`         | Cena       | Override da cena de mapa para MMO: update de rede, outros jogadores, HUD       |
|38 | `Scroll_Bar`        | UI         | Barra de scroll para listas e janelas com conteúdo extenso                      |
|39 | `Send_Data`         | Rede       | Empacotamento e envio de todos os tipos de pacotes para o servidor              |
|40 | `Settings_File`     | Sistema    | Leitura e escrita de arquivo de configurações locais (settings.ini)             |
|41 | `Socket`            | Rede       | Abstração de baixo nível do socket TCP: conexão, envio, recepção de dados       |
|42 | `Sprite2`           | Sprite     | Sistema de sprites estendido: paperdolls, camadas de equipamento, efeitos       |
|43 | `Sprite_Character`  | Sprite     | Override do sprite de personagem para MMO: paperdoll, nome, guild tag           |
|44 | `Sprite_Cursor`     | UI         | Cursor customizado do mouse: imagem, animação, estados (normal, hover, attack)  |
|45 | `Sprite_Desc`       | UI         | Tooltip/descrição de itens e skills: stats, afixos, comparação de equipamento  |
|46 | `Sprite_Drop`       | Loot       | Renderização visual de drops no chão: ícone, nome, brilho, proteção de dono    |
|47 | `Sprite_HUD`        | UI         | HUD principal: barras de HP/MP/XP, hotkeys de skill, minimap, status           |

---

## Apêndice B — Glossário Técnico

| Termo              | Definição                                                                                                    |
|--------------------|--------------------------------------------------------------------------------------------------------------|
| **RGSS3**          | Ruby Game Scripting System 3 — ambiente de scripting do RPG Maker VX Ace, baseado em Ruby 1.9.x             |
| **VXA-OS**         | Framework MMORPG para RPG Maker VX Ace desenvolvido por Valentine90, adiciona camada de rede e sistemas MMO |
| **EventMachine**   | Biblioteca Ruby para I/O assíncrono baseado em eventos, usada no servidor do VXA-OS                         |
| **Opcode**         | Código numérico que identifica o tipo de pacote de rede (ex: 0x10 = ataque)                                 |
| **Buffer**         | Estrutura de dados para serialização/deserialização de pacotes binários de rede                              |
| **Paperdoll**      | Sistema de visualização de equipamentos sobrepostos ao sprite do personagem                                  |
| **Sprite**         | Objeto gráfico 2D renderizado na tela, pode ser animado e posicionado                                       |
| **Bitmap**         | Objeto de imagem em memória no RGSS3, usado para desenhar pixels, texto e formas                            |
| **Alias**          | Técnica Ruby para criar um apelido de método antes de sobrescrevê-lo, preservando o comportamento original  |
| **Tile**           | Unidade básica de mapa no RPG Maker, 32x32 pixels                                                           |
| **Tileset**        | Conjunto de tiles usados para construir mapas                                                                |
| **rvdata2**        | Formato de arquivo binário do RPG Maker VX Ace para dados do jogo (mapas, atores, itens, etc.)              |
| **Scene**          | Tela/estado do jogo no RPG Maker (Scene_Map, Scene_Login, etc.)                                             |
| **Spriteset**      | Conjunto de sprites que compõem uma cena (ex: Spriteset_Map contém todos os sprites do mapa)               |
| **Game_NetPlayer** | Representação no cliente de outro jogador conectado ao servidor                                              |
| **Handle_Data**    | Módulo responsável por processar pacotes recebidos do servidor e atualizar o estado do cliente              |
| **Send_Data**      | Módulo responsável por empacotar e enviar dados do cliente para o servidor                                  |
| **MVP**            | Most Valuable Player — boss especial de alto nível com drops raros e mecânicas únicas (termo do Ragnarok)   |
| **Afixo**          | Atributo aleatório adicional em um item (ex: "+10 STR", "+5% de velocidade de ataque")                      |
| **Karma**          | Sistema de reputação PvP que penaliza jogadores que matam outros sem justificativa                           |
| **Skull System**   | Sistema de caveiras do Tibia Online que marca visualmente jogadores com karma negativo                       |
| **Job Level**      | Nível de classe separado do nível base, ganho por uso de skills (inspirado em Ragnarok Online)              |
| **Wings**          | Equipamento especial de alto nível em MU Online que concede bônus significativos e visual único             |
| **Prestige**       | Sistema de reset de nível com bônus permanentes, aumentando a replayability (inspirado em MU Online)        |
| **Aggro**          | Ameaça gerada por um jogador em relação a um inimigo, determina quem o inimigo ataca                        |
| **AoE**            | Area of Effect — habilidade que afeta múltiplos alvos em uma área                                           |
| **DPS**            | Damage Per Second — métrica de dano por segundo, também usado para descrever classes focadas em dano        |
| **Tank**           | Classe/papel focado em absorver dano e proteger aliados                                                      |
| **Healer**         | Classe/papel focado em curar e suportar aliados                                                              |
| **Sink econômico** | Mecanismo que remove moeda/itens do jogo para evitar inflação (ex: impostos, custos de upgrade)             |
| **Rate limiting**  | Limitação da frequência de ações por jogador para prevenir spam e exploits                                   |
| **Broadcast**      | Envio de um pacote do servidor para múltiplos clientes simultaneamente                                       |
| **GM**             | Game Master — administrador do jogo com poderes especiais de moderação                                       |
| **HUD**            | Heads-Up Display — interface sobreposta ao jogo exibindo informações do jogador (HP, MP, minimap, etc.)     |
| **Hotkey**         | Tecla de atalho para uso rápido de skills ou itens                                                           |
| **Drop rate**      | Probabilidade de um item ser dropado por um inimigo ao morrer                                                |
| **Instance**       | Instância privada de dungeon criada exclusivamente para um grupo de jogadores                                |
| **Tooltip**        | Janela de informação exibida ao passar o mouse sobre um item, skill ou elemento de UI                       |
| **[FO]**           | Prefixo de scripts customizados do Fields Online, diferenciando de scripts [RM] e [VS]                      |
| **[RM]**           | Prefixo de scripts base do RPG Maker VX Ace (não devem ser modificados diretamente)                         |
| **[VS]**           | Prefixo de scripts do VXA-OS (Valentine90), base do sistema MMO                                             |

---

> 📌 **Documento gerado em:** 08 de Abril de 2026
> 📌 **Próxima revisão planejada:** Início da Fase 2 (Semana 9)
> 📌 **Repositório:** https://github.com/CaioJuan2910/FieldsOnlineHML
> 📌 **Versão VXA-OS:** v2.1.6 (Jan 2022)