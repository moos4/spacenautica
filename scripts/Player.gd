extends CharacterBody3D
# nodes
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var interact_ray = $Head/Camera3D/RayCast3D
@onready var progress_oxygen_bar = $"Head/Camera3D/over/Control/player oxygen tank 1"
@onready var progress_health_bar = $"Head/Camera3D/over/Control/player health bar"

# life variables
 #oxygen
var max_oxygen = 3600.0
var current_oxygen = 3600.0
 #player health
var player_max_health = 100.0
var player_current_health = 100.0

# movement variables
var speed
const WALK_SPEED = 4.0
const SPRINT_SPEED = 6.0
const JUMP_VELOCITY = 2.5
const SENSITIVITY = 0.004
const BOOST_VELOCITY = 3.5 # 1.5
const BOOST_Y_VELOCITY = 2.5

#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5
# gravity variables
var inside : bool = false
const outside_gravity : float = 1.625 #9.8
var inside_gravity : float = 9.81

# different functions
func oxygen_handling(delta):
	progress_oxygen_bar.value = current_oxygen
	if current_oxygen > 0.0:
		current_oxygen -= delta
	else:
		get_tree().quit()
		print("you ran out of oxygen")

func player_take_damage(damage):
	if player_current_health <= damage:
		get_tree().quit()
		print("you died")
	player_current_health -= damage

# physics functions
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	progress_oxygen_bar.max_value = max_oxygen
	progress_health_bar.max_value = player_max_health

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	if Input.is_action_just_pressed("interact"): # Make sure to add "interact" in Input Map (e.g., 'E')
		if check_interaction() == true:
			var collider = interact_ray.get_collider()
			collider.collect()

func _physics_process(delta):
	progress_health_bar.value = player_current_health
	# goes to oxygen
	oxygen_handling(delta)
	# interaction visual
	check_interaction()
	# Add the gravity.
	if not is_on_floor():
		if inside:
			velocity.y -= inside_gravity * delta
		else:
			velocity.y -= outside_gravity * delta
		
	if Input.is_action_just_pressed("quit"):
		if $Head/Camera3D/menu.visible == true:
			$Head/Camera3D/menu.hide()
			$Head/Camera3D/over.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			$Head/Camera3D/menu.show()
			$Head/Camera3D/over.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED	
	# handles air boost
	
	

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if inside:
		if direction: 
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, (direction.x / 2) * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, (direction.z / 2) * speed, delta * 7.0)
	else: 
		if is_on_floor():
			if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = lerp(velocity.x, (direction.x / 2) * speed, delta * 7.0)
				velocity.z = lerp(velocity.z, (direction.z / 2) * speed, delta * 7.0)
		# air control system (potential bug)
		elif Input.is_action_pressed("use_oxygen_boost"):
			current_oxygen -= 100 * delta
			velocity.x += direction.x * BOOST_VELOCITY * delta * 2.0
			velocity.z += direction.z * BOOST_VELOCITY * delta * 2.0
			velocity.x = clamp(velocity.x, -5, 5)
			velocity.z = clamp(velocity.z, -5, 5)
			if Input.is_action_pressed("jump"):
				velocity.y += BOOST_Y_VELOCITY * delta * 2.0
				velocity.y = clamp(velocity.y, -7.5, 7.5)
		velocity.x += direction.x * BOOST_VELOCITY * delta * 1
		velocity.z += direction.z * BOOST_VELOCITY * delta * 1.0
		
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
func check_interaction():
	var collider = interact_ray.get_collider()
	if collider is Interactable and interact_ray.is_colliding():
		$Head/Camera3D/over/CenterContainer/TextureRect.texture = load("res://assets/textures/crosshair_o.png")
		return true
	else:
		$Head/Camera3D/over/CenterContainer/TextureRect.texture = load("res://assets/textures/crosshair_x.png")
		return false
		
# menu buttons


func _on_back_pressed() -> void:
	$Head/Camera3D/menu.hide()
	$Head/Camera3D/over.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_settings_pressed() -> void:
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()
#comment because git is acting gay
