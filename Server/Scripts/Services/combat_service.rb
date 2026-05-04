class CombatService

  def process_attack(attacker, target, skill)
    damage = calculate_damage(attacker, target, skill)

    apply_damage(target, damage)

    send_damage(attacker, target, damage)
  end

  private

  def calculate_damage(attacker, target, skill)
    atk = attacker.atk
    defense = target.def

    base = atk - defense
    base = 1 if base < 1

    base
  end

def apply_damage(target, damage)
  # ainda não aplica dano (fase de integração)
end

  def send_damage(attacker, target, damage)
    attacker.send_attack(damage, 0, false, attacker.id, Enums::Target::PLAYER, 0, 0, false)
  end

end