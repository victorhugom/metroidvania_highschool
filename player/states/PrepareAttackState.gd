extends LimboState

func _enter():
    agent.strong_attack_time = 0

func _update(delta: float):
    agent.strong_attack_time += delta
    if agent.strong_attack_time > agent.strong_attack_threshold:
        agent.emit_signal("state_changed", "holding_attack", agent.velocity)