class_name BaseEnemy extends CharacterBody2D

const DESTROYABLE_OBJECT_CONTAINER = preload("res://_starter_content/destroyable_object/destroyable_object_container.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_being_hit: AnimationPlayer = $AnimationPlayerBeingHit
@onready var health: Health = $Health
@onready var hurt_box: HurtBox = $HurtBox
@onready var destroyable_object_container: DestroyableObjectContainer = $DestroyableObjectContainer
@onready var money_dropper: MoneyDropper = $MoneyDropper
@onready var attack_box: AttackBox = $AttackBox

@onready var ray_cast_2d_eyes: RayCast2D = $RayCast2DEyes
@onready var ray_cast_2d_left: RayCast2D = $RayCast2DLeft
@onready var ray_cast_2d_right: RayCast2D = $RayCast2DRight
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var speed = 64
@export var dash_speed = 400
@export var dodge_distance = 128

var origin_position = Vector2.ZERO
var has_floor = true
var direction = "right"
var player_in_sight: CharacterBody2D
var sight_time = 4
var loose_sight_timeout = 0
var is_attacking = false
var is_combo_attack = false
var is_being_attacked = false
var damager_position = null
var is_dying = null
var is_being_hit = false
var is_being_parried = false


func _ready():
	origin_position = global_position
	
	animation_player.animation_finished.connect(_on_animation_finished)
	animation_player_being_hit.animation_finished.connect(_on_animation_player_being_hit_animation_finished)
	hurt_box.damaged.connect(_on_hurt_box_damaged)
	health.health_empty.connect(_on_health_empty)
	attack_box.parried.connect(_on_attack_parried)

func _physics_process(delta: float) -> void:
	
	loose_sight_timeout-= delta
	
	if is_dying || LevelsVars.SLEEPING == false:
		if animation_player.is_playing():
			animation_player.stop()
		return
	
	is_being_attacked = Input.is_action_just_pressed("player_attack")
	
	if is_attacking or is_being_parried:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if velocity.x > 0:
		direction = "right"
		sprite_2d.flip_h = false
		animation_player.play("walk")
		ray_cast_2d_eyes.target_position = abs(ray_cast_2d_eyes.target_position)
	elif velocity.x < 0:
		direction = "left"
		sprite_2d.flip_h = true
		animation_player.play("walk")
		ray_cast_2d_eyes.target_position = -abs(ray_cast_2d_eyes.target_position)
	else:
		animation_player.play("idle")

	if velocity.x < 0 and not ray_cast_2d_left.is_colliding():
		has_floor = false
		stop()
	elif velocity.x > 0 and not ray_cast_2d_right.is_colliding():
		has_floor = false
		stop()
	else:
		has_floor = true
	
	if has_floor == true and is_on_wall() == false:
		move_and_slide()
		
	if velocity.x != 0:
		animation_player.play("walk")
	else:
		animation_player.play("idle")
		
func move(target_position) -> void:
	
	var move_direction = (target_position - global_position).normalized()
	if move_direction.x > 0:
		velocity = Vector2(1, 0) * speed
	else:
		velocity = Vector2(-1, 0) * speed
		
func swing_bat():
	animation_player.play("attack_01_%s" %direction)
	is_attacking = true
	
func combo_attack(attack = 1):
	animation_player.play("attack_0%s_%s" %[attack, direction])
	is_attacking = true
	is_combo_attack = true
	
func stop() -> void:
	velocity = Vector2.ZERO

func dodge() -> void:
	if direction == "left":
		velocity = Vector2(1, 0) * dash_speed
	else:
		velocity = Vector2(-1, 0) * -dash_speed
	
func check_for_player():
	if ray_cast_2d_eyes.is_colliding():
		loose_sight_timeout = sight_time
		player_in_sight = ray_cast_2d_eyes.get_collider()
	else:
		if player_in_sight != null and loose_sight_timeout <= 0:
			player_in_sight = null	
		
func _on_animation_finished(anim_name:String):
	if anim_name.begins_with("attack_01"):
		if is_combo_attack:
			combo_attack(2)
		else:
			is_attacking = false	
	if anim_name.begins_with("attack_02"):
		combo_attack(3)
	if anim_name.begins_with("attack_03"):
		is_attacking = false

func parried():
	
	animation_player.play("dash")
	is_attacking = false
	
	#push back
	if direction == "right" and ray_cast_2d_left.is_colliding():
		velocity = Vector2(1, 0)
		global_position.x -= 5
	elif ray_cast_2d_right.is_colliding():
		global_position.x += 5
		velocity = Vector2(-1, 0)
	
	var tween = create_tween()
	tween.tween_callback(func():
		is_being_parried = false
		animation_player.play("idle")
	).set_delay(.2) 

func _on_attack_parried(character: CharacterBody2D):
	is_being_parried = true
		
func _on_animation_player_being_hit_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hit":
		is_being_hit = false

func _on_health_empty():
	
	set_as_is_dying()
	drop_money()
	queue_free()

func set_as_is_dying():
	visible = false
	is_dying = true
	
func drop_money():
	money_dropper.drop()

func _on_hurt_box_damaged(damage: int, area: Area2D):
	
	is_being_hit = true
	
	health.decrease_health(damage)
	
	damager_position = area.global_position
	var move_direction = (damager_position - global_position).normalized()
	
	if move_direction.x > 0 and ray_cast_2d_left.is_colliding():
		velocity = Vector2(1, 0)
		global_position.x -= 10
	elif ray_cast_2d_right.is_colliding():
		global_position.x += 10
		velocity = Vector2(-1, 0)
	
	player_in_sight = area.get_parent()
	loose_sight_timeout = sight_time
	
	animation_player_being_hit.play("hit")
	
func _exit_tree() -> void:
	destroyable_object_container.visible = true
	
	remove_child(destroyable_object_container)
	get_tree().root.add_child(destroyable_object_container)

	destroyable_object_container.global_position = global_position
	destroyable_object_container.destroy(damager_position)
