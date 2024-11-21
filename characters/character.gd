## A base class for all characters.
extends CharacterBody3D
class_name Character


signal jump_start
signal left_ground
signal landed
signal is_attacking


@export var max_speed := 8.0
@export var acceleration := 4.0
@export var deceleration := 5.0
@export var turning_boost := 3.0
@export var jump_strength := 17.0
@export var air_control := 0.4
@export var jump_gravity := Vector3.DOWN * 9.81 * 5.0
@export var fall_gravity := Vector3.DOWN * 9.81 * 3.0


var gravity := fall_gravity

var isAttack := false

#@onready var floor_scan: RayCast3D = %FloorScanRay

@onready var floor_scan: Area3D = %FloorScanArea
@onready var floor_scan_collision: CollisionShape3D = %FlrScnArCol

@onready var floor_shad_scan: RayCast3D = %FloorShadScan
@onready var floor_shad: MeshInstance3D = %FloorShad

## Set the grounded variable, and emit related signals.
var grounded := true:
	set(value):
		if value == grounded: return
		grounded = value
		# If wasn't grounded, but now is, emit "landed".
		if grounded: 
			if velocity.y <= 0: emit_signal("landed")
		# Else, emit, "left_ground"
		else: emit_signal("left_ground")
		return
## Set the target velocity variable.
var target_velocity := Vector2.ZERO:
	set(val): target_velocity = val.limit_length(1.0)

## Character jump function.
func jump():
	if !grounded: return
	velocity.y = jump_strength
	#floor_scan.enabled = false
	floor_scan_collision.disabled = true

	# Disables the floor scan for 1 frame.
	Game.delay(func():
		#floor_scan.enabled = true
		floor_scan_collision.disabled = false)
	grounded = false
	emit_signal("jump_start")
	return

## Character attack function.
func attack():
	if grounded:
		emit_signal("is_attacking")
		isAttack = true
	return


func _ready():
	if is_on_floor():
		grounded = true
	else:
		grounded = false


## Non-physics related code.
func _process(delta):
	# Sets the drop shadow to the floor, or disables it if there is no nearby floor.
	if floor_shad_scan.is_colliding():
		floor_shad.global_position.y = floor_shad_scan.get_collision_point().y
		floor_shad.visible = true
		floor_shad.scale = Vector3(
		# Sets the drop shadow's size based on it's distance.
		clamp(-1 * clamp(self.global_position.y - floor_shad_scan.get_collision_point().y, 0, 5)/ 7 + 1, 0.3, 1), 1,
		clamp(-1 * clamp(self.global_position.y - floor_shad_scan.get_collision_point().y, 0, 5)/ 7 + 1, 0.3, 1)
		)
	else:
		floor_shad.global_position.y = self.position.y
		floor_shad.visible = false


## Physics related code.
func _physics_process(delta: float):
	## Checks whether the player is on the ground usng the raycast.
#	if floor_scan.enabled: grounded = floor_scan.is_colliding()


	# Turns the target velocity (Vector2) into Vector3.
	var corrected_target_velocity := Vector3(
		target_velocity.x,
		0.0,
		-target_velocity.y
	)
	corrected_target_velocity *= max_speed

	var weight := delta

	# Sets the accelerations based on the if the character has a target velocity.
	if corrected_target_velocity.length() <= 0.01: weight *= deceleration
	else:
		weight *= acceleration
		weight *= lerp(turning_boost, 1.0,
			(velocity.normalized().dot(
				corrected_target_velocity.normalized()
			) + 1) / 2
		)

	# Changes the weight if in the air.
	if !grounded: weight *= air_control

	# Adds gravity, based on if the character is moving up or falling.
	if !grounded:
		if velocity.y <= 0: gravity = fall_gravity
		if velocity.y > 0: gravity = jump_gravity
		velocity += gravity * delta

	if grounded:
		if isAttack:
			corrected_target_velocity = Vector3.ZERO
			Game.delay(func(): isAttack = false, 15)


	# The target velocity Y is set to the actual velocity Y, so it can plug into the velocity without problems.
	corrected_target_velocity.y = velocity.y
	velocity = velocity.lerp(corrected_target_velocity, min(weight, 1.0))
	# Sets the velocity to zero if it's low enough.
	if velocity.length() <= 0.1: velocity = Vector3.ZERO

	move_and_slide()


## Checks whether the player is on the ground usng the area.
func _on_floor_scan_area_body_entered(body):
	grounded = true

func _on_floor_scan_area_body_exited(body):
	if !is_on_floor():
		grounded = false

func _get_camera_basis() -> float:
	return get_viewport().get_camera_3d().basis.get_euler().y
