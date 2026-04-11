# ==============================================================================
# [FO] Diagonal_Movement
# Versão  : 1.0.1
# Autor   : Caio Juan De Lima Silva
# Projeto : Fields Online
# ------------------------------------------------------------------------------
# Compatibilidade : RPG Maker VX Ace + VXA-OS 2022 (GitHub)
# Dependências    : [VS] Game_Player (VXA-OS) — obrigatório
#                   [FO] Smooth_Movement       — opcional, mas recomendado
# Posição na lista: APÓS [VS] Game_Player
# ------------------------------------------------------------------------------
# CHANGELOG v1.0.1:
#   - Corrigido: detecção de input agora inclui WASD além das setas.
#     Na v1.0.0, apenas as teclas de seta eram verificadas, fazendo com que
#     WASD não gerasse movimento algum. Agora ambos os métodos funcionam.
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
# ==============================================================================
class Game_Player < Game_Character

  alias fo_diag_original_move_by_input move_by_input

  def move_by_input
    # Guards de segurança — replicadas do [VS] Game_Player
    return if !movable?
    return if $game_map.interpreter.running?
    return if $windows[:quest_dialogue] && $windows[:quest_dialogue].visible
    return if $typing
    return if $wait_player_move

    # Se o módulo estiver desativado, delega ao método original
    unless FO::DiagonalMovement::ENABLED
      fo_diag_original_move_by_input
      return
    end

    # --------------------------------------------------------------------------
    # Detecção simultânea de teclas — suporta SETAS e WASD.
    #
    # horz → 6 se RIGHT/D, 4 se LEFT/A, nil se nenhum
    # vert → 2 se DOWN/S,  8 se UP/W,   nil se nenhum
    #
    # CORREÇÃO v1.0.1: adicionado suporte a WASD (:LETTER_W/A/S/D).
    #   Na v1.0.0 apenas as teclas de seta eram verificadas, causando falha
    #   total de movimento ao usar WASD.
    # --------------------------------------------------------------------------
    horz = if Input.press?(:RIGHT) || Input.press?(:LETTER_D)
               6  # direita
             elsif Input.press?(:LEFT) || Input.press?(:LETTER_A)
               4  # esquerda
             end

    vert = if Input.press?(:DOWN) || Input.press?(:LETTER_S)
               2  # baixo
             elsif Input.press?(:UP) || Input.press?(:LETTER_W)
               8  # cima
             end

    if horz && vert
      # ------------------------------------------------------------------------
      # Ambas as teclas pressionadas: calcula direção diagonal no formato numpad.
      #
      # Mapeamento:
      #   LEFT(4)  + DOWN(2) → 4 - 3 = 1  → sudoeste (↙)
      #   RIGHT(6) + DOWN(2) → 6 - 3 = 3  → sudeste  (↘)
      #   LEFT(4)  + UP(8)   → 4 + 3 = 7  → noroeste (↖)
      #   RIGHT(6) + UP(8)   → 6 + 3 = 9  → nordeste (↗)
      # ------------------------------------------------------------------------
      diagonal = (vert == 2) ? (horz - 3) : (horz + 3)

      # Ajusta o sprite conforme a prioridade configurada
      if FO::DiagonalMovement::HORIZONTAL_PRIORITY
        set_direction(horz)
      else
        set_direction(vert)
      end

      # Envia o movimento via send_movement() para manter sincronismo com
      # o servidor (arquitetura server-authoritative do VXA-OS)
      send_movement(diagonal)

    elsif horz
      # Apenas horizontal: movimento cardinal
      send_movement(horz)

    elsif vert
      # Apenas vertical: movimento cardinal
      send_movement(vert)

    end
    # Nenhuma tecla: personagem parado.
  end

end # Game_Player

# ==============================================================================
# FIM DO SCRIPT [FO] Diagonal_Movement v1.0.1
# ==============================================================================