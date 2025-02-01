extends LimboState

func _enter():
    agent.is_dead = true

func _update(_delta: float):
    if agent.is_on_floor():
        agent.emit_signal("state_changed", "dead", agent.velocity)
