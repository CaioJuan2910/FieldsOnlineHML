# ==============================================================================
# [FO] Diagonal_Movement
# Versão  : 1.0.0
# Autor   : Caio Juan De Lima Silva
# Projeto : Fields Online
# ------------------------------------------------------------------------------
# Compatibilidade : RPG Maker VX Ace + VXA-OS 2022 (GitHub)
# Dependências    : [VS] Game_Player (VXA-OS) — obrigatório
#                   [FO] Smooth_Movement       — opcional, mas recomendado
# Posição na lista: APÓS [VS] Game_Player
# ------------------------------------------------------------------------------
# DESCRIÇÃO TÉCNICA
# -----------------
# O VXA-OS utiliza arquitetura server-authoritative para movimentação:
#   1. O cliente detecta a tecla pressionada
#   2. Chama send_movement(d), que move o personagem localmente (previsão)
#      E envia a direção ao servidor via $network.send_player_movement(d)
#   3. O servidor valida e confirma (ou corrige) a posição
#
# O método original move_by_input do [VS] Game_Player usa Input.dir4, que
# retorna apenas os valores cardinais: 2 (baixo), 4 (esquerda), 6 (direita),
# 8 (cima). Valores diagonais (1, 3, 7, 9) nunca são retornados por dir4.
#
# Este script intercepta move_by_input via alias e substitui a detecção de
# input por uma leitura simultânea de teclas horizontais e verticais.
# Quando ambas estão pressionadas ao mesmo tempo, calcula a direção diagonal
# no formato numpad (1, 3, 7, 9) e passa ao send_movement(), que já possui
# suporte nativo a diagonais no [VS] Game_Player do VXA-OS.
#
# IMPORTANTE: Este script NÃO sobrescreve move_diagonal. Ele apenas corrige
# a detecção de input para reconhecer 8 direções em vez de 4.
# O send_movement() do [VS] Game_Player já trata os valores 1, 3, 7, 9
# internamente com um case/when que chama move_diagonal(horz, vert).
# ==============================================================================

# ==============================================================================
# MÓDULO DE CONFIGURAÇÕES
# ==============================================================================
module FO
  module DiagonalMovement

    # --------------------------------------------------------------------------
    # ENABLED
    # Ativa ou desativa o sistema de movimento diagonal.
    # true  = movimento diagonal habilitado (padrão)
    # false = comportamento original do VXA-OS (apenas 4 direções)
    # --------------------------------------------------------------------------
    ENABLED = true

    # --------------------------------------------------------------------------
    # HORIZONTAL_PRIORITY
    # Define para qual direção o sprite do personagem vira ao se mover
    # diagonalmente. Isso afeta apenas a aparência visual do sprite.
    #
    # true  = o sprite vira para a direção horizontal (esquerda ou direita)
    #         Comportamento comum em MMORPGs como Tibia e MU Online
    # false = o sprite vira para a direção vertical (cima ou baixo)
    # --------------------------------------------------------------------------
    HORIZONTAL_PRIORITY = true

  end # DiagonalMovement
end # FO

# ==============================================================================
# CLASSE Game_Player
# Reaberta para sobrescrever move_by_input com suporte a 8 direções.
# O alias garante que a versão original do [VS] Game_Player (VXA-OS) seja
# preservada e possa ser chamada como fallback quando o módulo estiver
# desativado ou quando nenhuma tecla diagonal for detectada.
# ==============================================================================
class Game_Player < Game_Character

  # ----------------------------------------------------------------------------
  # Alias sobre o move_by_input do [VS] Game_Player (VXA-OS).
  # É fundamental que o alias seja feito APÓS o [VS] Game_Player na lista de
  # scripts, pois precisamos capturar a versão já modificada pelo VXA-OS
  # (que inclui as guards de $typing, $wait_player_move, etc.) e não a versão
  # vanilla do RPG Maker VX Ace.
  # ----------------------------------------------------------------------------
  alias fo_diag_original_move_by_input move_by_input

  # ----------------------------------------------------------------------------
  # move_by_input
  # Sobrescreve o método original para detectar teclas diagonais.
  # Mantém todas as guards de segurança do VXA-OS antes de processar o input.
  # ----------------------------------------------------------------------------
  def move_by_input
    # --------------------------------------------------------------------------
    # Guards de segurança — replicadas do [VS] Game_Player para garantir
    # compatibilidade total com a arquitetura do VXA-OS.
    #
    # movable?                         → personagem pode se mover agora?
    # $game_map.interpreter.running?   → nenhum evento em execução
    # $windows[:quest_dialogue].visible → janela de diálogo de quest fechada
    # $typing                          → jogador não está digitando no chat
    # $wait_player_move                → não está aguardando resposta do servidor
    # --------------------------------------------------------------------------
    return if !movable?
    return if $game_map.interpreter.running?
    return if $windows[:quest_dialogue] && $windows[:quest_dialogue].visible
    return if $typing
    return if $wait_player_move

    # --------------------------------------------------------------------------
    # Se o módulo estiver desativado nas configurações, delega ao método
    # original do [VS] Game_Player sem nenhuma modificação.
    # --------------------------------------------------------------------------
    unless FO::DiagonalMovement::ENABLED
      fo_diag_original_move_by_input
      return
    end

    # --------------------------------------------------------------------------
    # Detecção simultânea de teclas horizontal e vertical.
    #
    # Input.press? verifica se a tecla está sendo mantida pressionada neste
    # frame, ao contrário de Input.trigger? (que só detecta o primeiro frame).
    # Isso é necessário para movimento contínuo enquanto a tecla está segurada.
    #
    # horz → 6 se RIGHT pressionado, 4 se LEFT pressionado, nil se nenhum
    # vert → 2 se DOWN pressionado,  8 se UP pressionado,   nil se nenhum
    # --------------------------------------------------------------------------
    horz = if Input.press?(:RIGHT)
             6  # direita
           elsif Input.press?(:LEFT)
             4  # esquerda
           end

    vert = if Input.press?(:DOWN)
             2  # baixo
           elsif Input.press?(:UP)
             8  # cima
           end

    if horz && vert
      # ------------------------------------------------------------------------
      # Ambas as teclas (horizontal + vertical) estão pressionadas ao mesmo
      # tempo: calculamos a direção diagonal no formato numpad.
      #
      # Mapeamento numpad para referência:
      #   7  8  9
      #   4  5  6
      #   1  2  3
      #
      # Fórmula de conversão:
      #   vert == 2 (baixo) → diagonal = horz - 3
      #     LEFT(4)  + DOWN(2) = 4 - 3 = 1  → sudoeste (↙)
      #     RIGHT(6) + DOWN(2) = 6 - 3 = 3  → sudeste  (↘)
      #
      #   vert == 8 (cima)  → diagonal = horz + 3
      #     LEFT(4)  + UP(8) = 4 + 3 = 7   → noroeste (↖)
      #     RIGHT(6) + UP(8) = 6 + 3 = 9   → nordeste (↗)
      #
      # A fórmula funciona porque no layout numpad a linha de baixo (1,2,3)
      # é exatamente 3 unidades abaixo da linha do meio (4,5,6), e a linha
      # de cima (7,8,9) é exatamente 3 unidades acima.
      # ------------------------------------------------------------------------
      diagonal = (vert == 2) ? (horz - 3) : (horz + 3)

      # ------------------------------------------------------------------------
      # Ajuste visual do sprite conforme a prioridade configurada.
      #
      # O send_movement() do [VS] Game_Player chama move_diagonal(horz, vert)
      # internamente. O move_diagonal do RPG Maker VX Ace aceita um terceiro
      # parâmetro implícito de direção do sprite. Aqui forçamos a direção
      # do sprite antes de enviar o movimento para garantir que a animação
      # do personagem reflita a prioridade configurada em HORIZONTAL_PRIORITY.
      # ------------------------------------------------------------------------
      if FO::DiagonalMovement::HORIZONTAL_PRIORITY
        # Sprite vira para a direção horizontal (esquerda ou direita)
        set_direction(horz)
      else
        # Sprite vira para a direção vertical (cima ou baixo)
        set_direction(vert)
      end

      # ------------------------------------------------------------------------
      # Envia o movimento diagonal ao sistema do VXA-OS via send_movement().
      #
      # IMPORTANTE: Chamamos send_movement() e NÃO move_diagonal() diretamente,
      # pois o VXA-OS usa arquitetura server-authoritative. O send_movement()
      # do [VS] Game_Player já possui um case/when que trata os valores
      # diagonais (1, 3, 7, 9) da seguinte forma:
      #   1. Chama move_diagonal(horz, vert) localmente (previsão de movimento)
      #   2. Envia a direção ao servidor via $network.send_player_movement(d)
      #
      # Chamar move_diagonal() diretamente ignoraria o servidor, causando
      # dessincronização de posição entre cliente e servidor.
      # ------------------------------------------------------------------------
      send_movement(diagonal)

    elsif horz
      # ------------------------------------------------------------------------
      # Apenas tecla horizontal pressionada: movimento cardinal normal.
      # Delega ao send_movement() com a direção horizontal detectada.
      # ------------------------------------------------------------------------
      send_movement(horz)

    elsif vert
      # ------------------------------------------------------------------------
      # Apenas tecla vertical pressionada: movimento cardinal normal.
      # Delega ao send_movement() com a direção vertical detectada.
      # ------------------------------------------------------------------------
      send_movement(vert)

    end
    # Nenhuma tecla pressionada: nenhuma ação necessária (personagem parado).
  end

end # Game_Player

# ==============================================================================
# FIM DO SCRIPT [FO] Diagonal_Movement v1.0.0
# ==============================================================================