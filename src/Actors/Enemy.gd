class_name Enemy
extends Actor


enum State {
	WALKING,
	ATTACKING,
	DEAD,
}

var _state = State.WALKING

onready var platform_detector = $PlatformDetector
onready var floor_detector_left = $FloorDetectorLeft
onready var floor_detector_right = $FloorDetectorRight
onready var sprite = $SpriteScaler/Sprite
onready var animation_player = $AnimationPlayer

var _pointing_right = 1

var reach_distance = 20.0
var target = null

# This function is called when the scene enters the scene tree.
# We can initialize variables here.
func _ready():
	_velocity.x = speed.x * _pointing_right

# Physics process is a built-in loop in Godot.
# If you define _physics_process on a node, Godot will call it every frame.

# At a glance, you can see that the physics process loop:
# 1. Calculates the move velocity.
# 2. Moves the character.
# 3. Updates the sprite direction.
# 4. Updates the animation.

# Splitting the physics process logic into functions not only makes it
# easier to read, it help to change or improve the code later on:
# - If you need to change a calculation, you can use Go To -> Function
#   (Ctrl Alt F) to quickly jump to the corresponding function.
# - If you split the character into a state machine or more advanced pattern,
#   you can easily move individual functions.
func _physics_process(_delta):
	# If the enemy encounters a wall or an edge, the horizontal velocity is flipped.

	if target != null and _state == State.WALKING:
		var targetX = target.position.x
		var posX = position.x
		if abs(targetX - posX) < reach_distance:
			_state = State.ATTACKING

	if _state == State.WALKING:
		# We only update the y value of _velocity as we want to handle the horizontal movement ourselves.
		position.x += _velocity.x * _delta

		# We flip the Sprite depending on which way the enemy is moving.
		if _velocity.x > 0:
			sprite.scale.x = 1
		else:
			sprite.scale.x = -1

	var animation = get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)


func destroy():
	_state = State.DEAD
	_velocity = Vector2.ZERO


func get_new_animation():
	var animation_new = ""
	if _state == State.WALKING:
		animation_new = "walk"
	elif _state == State.DEAD:
		animation_new = "destroy"
	elif _state == State.ATTACKING:
		animation_new = "attack"
	return animation_new


func reverse():
	_pointing_right *= -1

func is_dead():
	return _state == State.DEAD
