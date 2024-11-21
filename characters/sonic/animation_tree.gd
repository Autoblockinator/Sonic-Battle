@tool
extends AnimationTree


@export_category("Conditions")
## Is the character attempting to affect it's velocity?
@export var input_active := false
## Is the character moving at any considerable speed?
@export var moving := false
## Is the character moving at a high speed?
@export var running := false
## Is the character sprite flipping?
@export var flipping := false
## Is the character jumping?
@export var jumping := false
## Is the character currently on the ground?
@export var grounded := true
## Is the character attacking?
@export var attacking := false

# References
@onready var character: Character = owner
@onready var sprite: Sprite3D = %Sprite
@onready var floor_scan: RayCast3D = %FloorScanRay

var face_left := false
var input_active_off_delay := -1:
	set(value):
		if value < 0: Game.cancel_delay(input_active_off_delay)
		input_active_off_delay = value
		return


func _ready():
	character.connect("jump_start", func(): jumping = true)
	character.connect("left_ground", func(): grounded = false)
	character.connect("landed", func(): grounded = true)
	character.connect("is_attacking", func(): attacking = true)
	return


func _process(delta):
	if Engine.is_editor_hint(): return

	if character.target_velocity.length() >= 0.01:
		input_active = true
		if input_active_off_delay >= 0: input_active_off_delay = -1
		input_active_off_delay = Game.delay(
			func(): input_active = false; input_active_off_delay = -1,
			0.1
		).key
	
	moving = character.velocity.length() >= 1.0
	running = character.velocity.length() >= 3.0

	if grounded:
		if flipping: sprite.flip_h = face_left
		
		if abs(character.target_velocity.x) >= 0.01:
			face_left = character.target_velocity.x < 0.0
			if face_left != sprite.flip_h: flipping = true
		set("parameters/Grounded/Moving/BlendTree/Run Speed/scale", (character.velocity.length()/10) + 0.3)

	else:
		if abs(character.target_velocity.x) >= 0.01:
			face_left = character.target_velocity.x < 0.0
		
		flipping = false
		sprite.flip_h = face_left

	if attacking:
		print("pow")
		attacking = false

	return
