# encoding: utf-8
#==============================================================================
# [FO] Diagonal_Movement
#==============================================================================
# Nome        : [FO] Diagonal_Movement
# Versão      : 1.0.0
# Autor       : Caio Juan De Lima Silva
# Projeto     : Fields Online
# Plataforma  : RPG Maker VX Ace + VXA-OS 2022 (GitHub)
#------------------------------------------------------------------------------
# Descrição Técnica:
#   Implementa movimentação diagonal completa para o jogador, mantendo total
#   compatibilidade com sprites de 4 direções. Ao pressionar simultaneamente
#   uma tecla horizontal (esquerda/direita) e uma vertical (cima/baixo), o
#   personagem se move na diagonal correspondente.
#
#   O sistema realiza quatro verificações de passabilidade para garantir que
#   o movimento diagonal seja fisicamente correto, evitando que o personagem
#   atravesse cantos de paredes. Quando a diagonal está bloqueada, o sistema
#   de Wall Slide tenta deslizar pelo eixo livre, proporcionando uma
#   experiência de movimentação fluida similar a MMORPGs clássicos como
#   Tibia Online, MU Online e Ragnarok Online.
#
#   A integração com [FO] Smooth_Movement é automática: o script define
#   @real_x e @real_y com a posição anterior antes de atualizar @x/@y,
#   exatamente como o VX Ace nativo faz em move_straight. O lerp do
#   Smooth_Movement acompanha real_x/real_y normalmente, garantindo
#   animação suave também nos movimentos diagonais.
#
#------------------------------------------------------------------------------
# Dependências:
#   - [FO] Smooth_Movement (deve estar ACIMA deste script na lista)
#
#------------------------------------------------------------------------------
# Ordem de Inserção:
#   Este script deve ser posicionado APÓS [FO] Smooth_Movement na lista de
#   scripts do RPG Maker VX Ace. O lerp do Smooth_Movement funciona
#   automaticamente com o movimento diagonal pois smooth_x/smooth_y seguem
#   real_x/real_y, que são atualizados corretamente por este script antes
#   de cada passo diagonal.
#
#------------------------------------------------------------------------------
# Notas:
#   - Compatível com sprites de 4 direções (não requer spritesheet diagonal).
#   - O Wall Slide evita que o personagem "trave" em cantos de paredes.
#   - Totalmente configurável pelo módulo FO::DiagonalMovement abaixo.
#   - Não interfere com NPCs, MOBs ou Eventos — apenas o Game_Player é
#     sobrescrito para captura de input diagonal.
#==============================================================================

#==============================================================================
# MÓDULO DE CONFIGURAÇÕES
#==============================================================================
# Todas as opções do sistema de movimento diagonal estão centralizadas aqui.
# Altere os valores conforme necessário sem precisar modificar o código abaixo.
#==============================================================================
module FO
  module DiagonalMovement

    #--------------------------------------------------------------------------
    # ENABLED
    # Ativa ou desativa o sistema de movimento diagonal por completo.
    # Quando false, o comportamento de movimento retorna ao padrão de 4
    # direções do VX Ace/VXA-OS, sem qualquer interferência deste script.
    #   true  = movimento diagonal habilitado
    #   false = apenas movimento de 4 direções (padrão)
    #--------------------------------------------------------------------------
    ENABLED = true

    #--------------------------------------------------------------------------
    # SHOW_HORIZONTAL_WHEN_DIAGONAL
    # Define qual direção do sprite é exibida durante o movimento diagonal.
    # Como o projeto Fields Online utiliza sprites de 4 direções (sem sprites
    # diagonais), é necessário escolher entre mostrar o sprite horizontal ou
    # o sprite vertical ao mover na diagonal.
    #   true  = exibe o sprite da direção horizontal (esquerda/direita)
    #           Recomendado para a maioria dos MMORPGs 2D (ex: Tibia, MU)
    #   false = exibe o sprite da direção vertical (cima/baixo)
    #--------------------------------------------------------------------------
    SHOW_HORIZONTAL_WHEN_DIAGONAL = true

    #--------------------------------------------------------------------------
    # WALL_SLIDE
    # Ativa o sistema de deslizamento de parede (Wall Slide).
    # Quando o movimento diagonal está bloqueado (ex: canto de parede), o
    # sistema tenta mover o personagem pelo eixo que ainda está livre,
    # evitando que o personagem "trave" ao encostar em paredes diagonalmente.
    # Isso proporciona uma movimentação mais fluida, similar à encontrada em
    # MMORPGs clássicos como Ragnarok Online e Tibia Online.
    #   true  = deslizamento de parede habilitado (recomendado)
    #   false = ao bloquear diagonal, o personagem para completamente
    #--------------------------------------------------------------------------
    WALL_SLIDE = true

  end # DiagonalMovement
end # FO

#==============================================================================
# GAME_CHARACTERBASE
#==============================================================================
# Adiciona o método move_diagonal à classe base de todos os personagens.
# Embora apenas o Game_Player utilize este método via input, ele é definido
# em Game_CharacterBase para permitir uso futuro em NPCs ou eventos via
# script calls, mantendo a arquitetura consistente com o VX Ace nativo.
#==============================================================================
class Game_CharacterBase

  #----------------------------------------------------------------------------
  # move_diagonal(horz, vert)
  #----------------------------------------------------------------------------
  # Realiza um passo diagonal combinando uma direção horizontal e uma vertical.
  #
  # Parâmetros:
  #   horz : Direção horizontal — 4 (esquerda) ou 6 (direita)
  #   vert : Direção vertical   — 2 (baixo)    ou 8 (cima)
  #
  # Lógica de passabilidade:
  #   Para que o movimento diagonal seja válido, TODOS os quatro checks abaixo
  #   devem ser verdadeiros. Isso evita que o personagem atravesse cantos:
  #     1. passable?(@x, @y,    horz) → pode sair da tile atual na horizontal
  #     2. passable?(@x, new_y, horz) → pode entrar na tile destino pela horiz
  #     3. passable?(@x, @y,    vert) → pode sair da tile atual na vertical
  #     4. passable?(new_x, @y, vert) → pode entrar na tile destino pela vert
  #
  # Integração com Smooth_Movement:
  #   Antes de atualizar @x/@y, salvamos a posição atual em prev_x/prev_y e
  #   definimos @real_x = prev_x.to_f e @real_y = prev_y.to_f. Isso replica
  #   exatamente o comportamento do move_straight nativo do VX Ace, permitindo
  #   que o lerp do [FO] Smooth_Movement funcione sem nenhuma modificação.
  #----------------------------------------------------------------------------
  def move_diagonal(horz, vert)
    # Atualiza a direção do sprite conforme a configuração do projeto.
    # Como usamos sprites de 4 direções, escolhemos entre horizontal ou vertical.
    if FO::DiagonalMovement::SHOW_HORIZONTAL_WHEN_DIAGONAL
      # Exibe o sprite horizontal (esquerda/direita) durante o movimento diagonal.
      # Recomendado para o estilo visual de Fields Online.
      set_direction(horz)
    else
      # Exibe o sprite vertical (cima/baixo) durante o movimento diagonal.
      set_direction(vert)
    end

    # Calcula as coordenadas de destino para cada eixo individualmente.
    # round_x_with_direction e round_y_with_direction respeitam o loop do mapa.
    new_x = $game_map.round_x_with_direction(@x, horz)
    new_y = $game_map.round_y_with_direction(@y, vert)

    # Verifica se o movimento diagonal completo é passável.
    # Os quatro checks garantem que nenhum canto de parede seja atravessado.
    diagonal_passable = passable?(@x, @y,    horz) &&
                        passable?(@x, new_y, horz) &&
                        passable?(@x, @y,    vert) &&
                        passable?(new_x, @y, vert)

    if diagonal_passable
      # -----------------------------------------------------------------------
      # MOVIMENTO DIAGONAL LIVRE
      # -----------------------------------------------------------------------
      # Salva a posição atual antes de mover para que o Smooth_Movement possa
      # interpolar (lerp) a posição visual do sprite corretamente.
      prev_x = @x
      prev_y = @y

      # Atualiza a posição lógica do personagem no mapa.
      @x = new_x
      @y = new_y

      # Define real_x/real_y como a posição anterior (em float).
      # O [FO] Smooth_Movement lerp de real_x/real_y até @x/@y a cada frame,
      # produzindo a animação suave de deslocamento.
      @real_x = prev_x.to_f
      @real_y = prev_y.to_f

      # Incrementa o contador de passos (necessário para animação de walking,
      # contagem de passos para encontros aleatórios, etc.).
      increase_steps

    elsif FO::DiagonalMovement::WALL_SLIDE
      # -----------------------------------------------------------------------
      # WALL SLIDE — DESLIZAMENTO DE PAREDE
      # -----------------------------------------------------------------------
      # A diagonal está bloqueada. Verificamos cada eixo individualmente para
      # tentar deslizar pelo eixo que ainda está livre.
      # Isso evita que o personagem "trave" ao encostar em paredes diagonalmente,
      # proporcionando movimentação fluida como em Tibia Online e Ragnarok Online.

      # Verifica se o eixo horizontal está bloqueado.
      # O eixo horizontal está bloqueado se NÃO é possível sair da tile atual
      # na direção horizontal OU NÃO é possível entrar na tile destino pela horiz.
      h_blocked = !passable?(@x, @y,    horz) ||
                  !passable?(@x, new_y, horz)

      # Verifica se o eixo vertical está bloqueado.
      # O eixo vertical está bloqueado se NÃO é possível sair da tile atual
      # na direção vertical OU NÃO é possível entrar na tile destino pela vert.
      v_blocked = !passable?(@x, @y,    vert) ||
                  !passable?(new_x, @y, vert)

      if h_blocked && !v_blocked
        # Apenas o eixo horizontal está bloqueado.
        # Desliza verticalmente (move apenas para cima ou para baixo).
        move_straight(vert)

      elsif v_blocked && !h_blocked
        # Apenas o eixo vertical está bloqueado.
        # Desliza horizontalmente (move apenas para esquerda ou direita).
        move_straight(horz)

      end
      # Se ambos os eixos estiverem bloqueados, o personagem para completamente.
      # Nenhuma ação adicional é necessária neste caso.
    end
  end

end # Game_CharacterBase

#==============================================================================
# GAME_PLAYER
#==============================================================================
# Sobrescreve move_by_input para detectar input diagonal e chamar move_diagonal.
# O comportamento original de 4 direções é preservado via alias e chamado
# sempre que o movimento diagonal não se aplica (tecla única ou sistema
# desabilitado).
#==============================================================================
class Game_Player < Game_Character

  #----------------------------------------------------------------------------
  # Alias do método original move_by_input
  #----------------------------------------------------------------------------
  # Preservamos o comportamento original de movimentação de 4 direções do
  # VXA-OS/VX Ace. O alias é chamado em todos os casos onde o movimento
  # diagonal não se aplica, garantindo compatibilidade total com o sistema base.
  #----------------------------------------------------------------------------
  alias fo_diag_move_by_input move_by_input

  #----------------------------------------------------------------------------
  # move_by_input (sobrescrito)
  #----------------------------------------------------------------------------
  # Detecta se o jogador está pressionando simultaneamente uma tecla horizontal
  # e uma tecla vertical. Se sim, e se as condições de movimento forem
  # satisfeitas, executa o movimento diagonal. Caso contrário, delega ao
  # comportamento original de 4 direções.
  #
  # Condições para movimento diagonal:
  #   1. FO::DiagonalMovement::ENABLED deve ser true
  #   2. Uma tecla horizontal (LEFT ou RIGHT) deve estar pressionada
  #   3. Uma tecla vertical (UP ou DOWN) deve estar pressionada
  #   4. O personagem não deve estar em movimento (!moving?)
  #   5. O personagem deve poder se mover (movable?)
  #   6. A cena atual deve ser Scene_Map
  #----------------------------------------------------------------------------
  def move_by_input
    # Verifica se o sistema de movimento diagonal está habilitado.
    # Se não estiver, chama o comportamento original sem interferência.
    unless FO::DiagonalMovement::ENABLED
      fo_diag_move_by_input
      return
    end

    # Detecta a direção horizontal pressionada.
    # Retorna 4 (esquerda), 6 (direita) ou nil se nenhuma tecla horizontal
    # estiver pressionada no momento.
    horz = if Input.press?(:LEFT)
             4  # Esquerda
           elsif Input.press?(:RIGHT)
             6  # Direita
           else
             nil
           end

    # Detecta a direção vertical pressionada.
    # Retorna 8 (cima), 2 (baixo) ou nil se nenhuma tecla vertical
    # estiver pressionada no momento.
    vert = if Input.press?(:UP)
             8  # Cima
           elsif Input.press?(:DOWN)
             2  # Baixo
           else
             nil
           end

    # Verifica se AMBAS as direções (horizontal e vertical) estão presentes,
    # caracterizando um input diagonal genuíno.
    diagonal_input = !horz.nil? && !vert.nil?

    # Verifica se todas as condições para executar o movimento diagonal
    # estão satisfeitas simultaneamente.
    if diagonal_input &&
       !moving? &&
       movable? &&
       SceneManager.scene.is_a?(Scene_Map)

      # -----------------------------------------------------------------------
      # EXECUTA MOVIMENTO DIAGONAL
      # -----------------------------------------------------------------------
      # Todas as condições foram satisfeitas. Chama move_diagonal com as
      # direções detectadas. O método em Game_CharacterBase cuidará da
      # passabilidade, Wall Slide e integração com Smooth_Movement.
      move_diagonal(horz, vert)

    else
      # -----------------------------------------------------------------------
      # COMPORTAMENTO ORIGINAL DE 4 DIREÇÕES
      # -----------------------------------------------------------------------
      # Apenas uma direção está pressionada (ou nenhuma), ou as condições de
      # movimento não foram satisfeitas. Delega ao comportamento original do
      # VXA-OS/VX Ace para manter compatibilidade total.
      fo_diag_move_by_input

    end
  end

end # Game_Player

#==============================================================================
# FIM DO SCRIPT [FO] Diagonal_Movement v1.0.0
#==============================================================================