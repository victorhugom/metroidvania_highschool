extends LimboState

func _enter():
    agent.is_dashing = true
    agent.emit_signal("state_changed", "dash", agent.velocity)
    agent.dash_timer = agent.dash_duration
    agent.dash_cooldown_timer = agent.dash_cooldown
    if Input.is_action_pressed("player_left"):
        agent.velocity.x = -agent.dash_speed
        agent.last_direction = "left"
    elif Input.is_action_pressed("player_right"):
        agent.velocity.x = agent.dash_speed
        agent.last_direction = "right"

func _update(delta: float):
    agent.emit_signal("state_changed", "dash", agent.velocity)
    if agent.is_dashing:
        agent.dash_timer -= delta
    if agent.dash_timer <= 0:
        agent.main_state_machine.dispatch(agent.to_idle)
        
    agent.current_time_duplication += delta
    if agent.current_time_duplication > agent.duplication_time:
        agent.current_time_duplication = 0
        agent._create_duplication()


func _exit():
    agent.is_dashing = false
    agent.velocity.x = 0 # Stop the dash movement