#minimalism results in reasonable and attainable goals
#conceptual clarity and integrity in the development process
#ingenious ideas are simple, ingenious software is simple
extends Node3D
@onready var player = $player
@onready var camera = $player/springarm/camera
@onready var springarm = $player/springarm
@onready var model = $player/model
@onready var raycast = $player/springarm/camera/raycast
@onready var muzzle = $player/muzzle
@onready var animation_tree = $player/animation_tree
@onready var lobby = get_node("/root/lobby/")
@onready var zip_curve1 = $ziplines/zip1/path.get_curve()
@onready var zip_curve2 = $ziplines/zip2/path.get_curve()
@onready var zip_curve3 = $ziplines/zip3/path.get_curve()
@onready var zip_curve4 = $ziplines/zip4/path.get_curve()
@onready var zip1 = $ziplines/zip1/path/follow
@onready var zip2 = $ziplines/zip2/path/follow
@onready var zip3 = $ziplines/zip3/path/follow
@onready var zip4 = $ziplines/zip4/path/follow
const arrow = preload("res://scenes/arrow.tscn")
var speed = 20
var jump_velocity = 46
var walljump_vector = Vector3.ZERO
var walljump_speed = 60
var walljump_timer = 80
var gravity = 100
var accel = 1
var wall_normal = Vector3.ZERO
var is_sliding = false
var slide_direction = Vector3.ZERO
var input_dir
var direction
var sens = 1
var just_landed = false
var is_zipping = false
var zip_boost = Vector3.ZERO
var zip_id
var recoil = 0
var flipped = false
var in_menu = false
var in_network = false
# Set up some global Steam variables
var IS_OWNED: bool = false
var IS_ONLINE: bool = false
var STEAM_ID: int = 0
var STEAM_USERNAME: String

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.set_as_top_level(true)
	camera.fov = 90
	camera.h_offset = 1.4
	raycast.transform.origin.x = 1.4
	$menu/main.visible = false
	$menu/network.visible = false
#	_initialize_Steam()
#	# Set up some signals
#	_connect_Steam_Signals("lobby_created", "_on_Lobby_Created")
#	_connect_Steam_Signals("lobby_match_list", "_on_Lobby_Match_List")
#	_connect_Steam_Signals("lobby_joined", "_on_Lobby_Joined")
#	_connect_Steam_Signals("lobby_chat_update", "_on_Lobby_Chat_Update")
#	_connect_Steam_Signals("lobby_message", "_on_Lobby_Message")
#	_connect_Steam_Signals("lobby_data_update", "_on_Lobby_Data_Update")
#	_connect_Steam_Signals("lobby_invite", "_on_Lobby_Invite")
#	_connect_Steam_Signals("join_requested", "_on_Lobby_Join_Requested")
#	_connect_Steam_Signals("persona_state_change", "_on_Persona_Change")
#	_connect_Steam_Signals("p2p_session_request", "_on_P2P_Session_Request")
#	_connect_Steam_Signals("p2p_session_connect_fail", "_on_P2P_Session_Connect_Fail")
#	# Check for command line arguments
#	#_check_Command_Line()

func _physics_process(delta):
	if in_menu == true:
		_menu()
		player.velocity.y -= gravity * delta
	else:
		_controls()
		_movement(delta)
		_abilities(delta)
		_menu()
	player.move_and_slide()

# Process all Steamworks callbacks
#func _process(_delta: float) -> void:
#	Steam.run_callbacks()
	# Get packets if lobby is joined
#	if LOBBY_ID > 0:
#		_read_P2P_Packet()

func _controls():
	input_dir = Input.get_vector("left", "right", "forward", "back")
	direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized().rotated(Vector3.UP,springarm.rotation.y)
	if Input.is_action_pressed("shoot"):
		model.look_at(player.transform.origin - Vector3.FORWARD.rotated(Vector3.UP,springarm.rotation.y))
	else:
		if input_dir.length() > 0:
			model.look_at(player.transform.origin - Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP,springarm.rotation.y))
		
func _input(event):
	if event is InputEventMouseMotion:
		if in_menu == true:
			pass
		else:
			springarm.rotation.x -= event.relative.y * sens / 2000
			springarm.rotation.x = clamp(springarm.rotation.x, -1.5708, 1.5708)
			springarm.rotation.y -= event.relative.x * sens / 2000
			
func _movement(delta):
#walljump
	if player.is_on_wall():
		if Input.is_action_just_released("jump"):
			walljump_vector.x = player.get_wall_normal().x * walljump_speed
			walljump_vector.z = player.get_wall_normal().z * walljump_speed
			player.velocity.y = jump_velocity
			animation_tree["parameters/jump/active"] = true
	if walljump_vector.x > 0:
		walljump_vector.x -= delta * walljump_timer
	else:
		walljump_vector.x += delta * walljump_timer
	if walljump_vector.z > 0:
		walljump_vector.z -= delta * walljump_timer
	else:
		walljump_vector.z += delta * walljump_timer
#zipline
	if Input.is_action_just_pressed("use") and raycast.is_colliding() == true and is_zipping == false:
		if is_sliding:
			is_sliding = false
		just_landed = false
		accel = 1.6
		zip_id = raycast.get_collider()
		if zip_id == $ziplines/zip1/area3d:
			var temp_pos = (player.position.y - 12) / 112
			player.position = Vector3.ZERO
			player.velocity = Vector3.ZERO
			lobby.remove_child(player)
			player.set_as_top_level(false)
			zip1.add_child(player)
			is_zipping = true
			zip1.set_progress_ratio(temp_pos)
		if zip_id == $ziplines/zip2/area3d:
			var temp_pos = (player.position.y - 12) / 112
			player.position = Vector3.ZERO
			player.velocity = Vector3.ZERO
			lobby.remove_child(player)
			player.set_as_top_level(false)
			zip2.add_child(player)
			is_zipping = true
			zip2.set_progress_ratio(temp_pos)
		if zip_id == $ziplines/zip3/area3d:
			var temp_pos = (player.position.y - 12) / 112
			player.position = Vector3.ZERO
			player.velocity = Vector3.ZERO
			lobby.remove_child(player)
			player.set_as_top_level(false)
			zip3.add_child(player)
			is_zipping = true
			zip3.set_progress_ratio(temp_pos)
		if zip_id == $ziplines/zip4/area3d:
			var temp_pos = (player.position.y - 12) / 112
			player.position = Vector3.ZERO
			player.velocity = Vector3.ZERO
			lobby.remove_child(player)
			player.set_as_top_level(false)
			zip4.add_child(player)
			is_zipping = true
			zip4.set_progress_ratio(temp_pos)
	if is_zipping == true:
		model.rotation.y = springarm.rotation.y + 3.14159
		animation_tree["parameters/run/active"] = false
		animation_tree["parameters/jump/active"] = false
		animation_tree["parameters/fall/active"] = false
		if zip_id == $ziplines/zip1/area3d:
			zip1.set_progress_ratio(zip1.get_progress_ratio() + delta / 3)
			player.global_position.x = -184
			player.global_position.z = -56
			if Input.is_action_just_released("jump") or zip1.get_progress_ratio() >= 1:
				var temp_pos = (zip1.get_progress_ratio() * 96) + 12
				var temp_dir = springarm.rotation
				if zip1.get_child_count() > 0:
					zip1.remove_child(player)
					lobby.add_child(player)
				is_zipping = false
				player.set_as_top_level(true)
				player.position.y = temp_pos
				player.position.x = -184
				player.position.z = -56
				player.velocity.y = jump_velocity
				springarm.rotation = temp_dir
		if zip_id == $ziplines/zip2/area3d:
			zip2.set_progress_ratio(zip2.get_progress_ratio() + delta / 3)
			player.global_position.x = 184
			player.global_position.z = -56
			if Input.is_action_just_released("jump") or zip2.get_progress_ratio() >= 1:
				var temp_pos = (zip2.get_progress_ratio() * 96) + 12
				var temp_dir = springarm.rotation
				if zip2.get_child_count() > 0:
					zip2.remove_child(player)
					lobby.add_child(player)
				is_zipping = false
				player.set_as_top_level(true)
				player.position.y = temp_pos
				player.position.x = 184
				player.position.z = -56
				player.velocity.y = jump_velocity
				springarm.rotation = temp_dir
		if zip_id == $ziplines/zip3/area3d:
			zip3.set_progress_ratio(zip3.get_progress_ratio() + delta / 3)
			player.global_position.x = -184
			player.global_position.z = 56
			if Input.is_action_just_released("jump") or zip3.get_progress_ratio() >= 1:
				var temp_pos = (zip3.get_progress_ratio() * 96) + 12
				var temp_dir = springarm.rotation
				if zip3.get_child_count() > 0:
					zip3.remove_child(player)
					lobby.add_child(player)
				is_zipping = false
				player.set_as_top_level(true)
				player.position.y = temp_pos
				player.position.x = -184
				player.position.z = 56
				player.velocity.y = jump_velocity
				springarm.rotation = temp_dir
		if zip_id == $ziplines/zip4/area3d:
			zip4.set_progress_ratio(zip4.get_progress_ratio() + delta / 3)
			player.global_position.x = 184
			player.global_position.z = 56
			print(zip4.get_progress_ratio())
			if Input.is_action_just_released("jump") or zip4.get_progress_ratio() >= 1:
				var temp_pos = (zip4.get_progress_ratio() * 96) + 12
				var temp_dir = springarm.rotation
				if zip4.get_child_count() > 0:
					zip4.remove_child(player)
					lobby.add_child(player)
				is_zipping = false
				player.set_as_top_level(true)
				player.position.y = temp_pos
				player.position.x = 184
				player.position.z = 56
				player.velocity.y = jump_velocity
				springarm.rotation = temp_dir
#slide
	if player.is_on_floor():
		if just_landed == false:
			if Input.is_action_pressed("slide") and player.get_real_velocity().y < 2:
				slide_direction.x = player.velocity.x
				slide_direction.z = player.velocity.z
				animation_tree["parameters/slide/active"] = true
				is_sliding = true
				just_landed = true
		if Input.is_action_just_pressed("slide") and player.get_real_velocity().y < 2:
			slide_direction.x = player.velocity.x
			slide_direction.z = player.velocity.z
			accel += 0.5 / pow((player.get_floor_normal().dot(Vector3.UP)),2)
			is_sliding = true
		if Input.is_action_pressed("slide") and is_sliding == true:
			animation_tree["parameters/slide/active"] = true
			camera.position.y = -1
			if accel <= 1:
				animation_tree["parameters/run/active"] = true
				is_sliding = false
		else:
			accel = 1
			camera.position.y = 0
			is_sliding = false
			if input_dir.length() > 0:
				animation_tree["parameters/run/active"] = true
			else:
				animation_tree["parameters/run/active"] = false
#jump
		if Input.is_action_just_released("jump"):
			animation_tree["parameters/slide/active"] = false
			animation_tree["parameters/jump/active"] = true
			player.velocity.y = jump_velocity
			is_sliding = false
			just_landed = false
	if !player.is_on_floor() and !player.is_on_wall() and player.velocity.y < 0:
		is_sliding = false
		animation_tree["parameters/fall/active"] = true
		animation_tree["parameters/jump/active"] = false
	else:
		animation_tree["parameters/fall/active"] = false
#base
	if is_sliding == true and player.get_real_velocity().y < 2:
		player.velocity.x = slide_direction.x * accel
		player.velocity.z = slide_direction.z * accel
		player.velocity.y -= gravity * delta
	if is_sliding == false and is_zipping == false:
		player.velocity.x = direction.x * speed * accel + walljump_vector.x
		player.velocity.z = direction.z * speed * accel + walljump_vector.z
		player.velocity.y -= gravity * delta
	if input_dir.length() == 0 and is_sliding == false:
		player.velocity.x = 0
		player.velocity.z = 0
	model.rotation.x = 0
	model.rotation.z = 0
#accel
	if accel > 1:
		accel -= delta * pow((player.get_floor_normal().dot(Vector3.UP)),32)

func _abilities(delta):
#bow
	if Input.is_action_pressed("shoot"):
		speed = 16
		if Globals.charge < 1:
			Globals.charge += delta
			camera.fov -= delta * 20
		if not is_sliding:
			animation_tree["parameters/aim/active"] = true
	if Input.is_action_just_released("shoot"):
		speed = 24
		camera.fov = 80
		muzzle.rotation = springarm.rotation
		muzzle.rotation.x += 0.026
		muzzle.add_child(arrow.instantiate())
		recoil += 0.06 * Globals.charge
		var recoil_fix = 0.06 * Globals.charge
		springarm.rotation.x += recoil_fix
		Globals.charge = 0
		animation_tree["parameters/recoil/active"] = true
	if recoil > 0:
		recoil -= delta * 0.2
		springarm.rotation.x -= delta * 0.2
	if Input.is_action_just_pressed("cam_swap"):
		camera.h_offset *= -1
		raycast.transform.origin.x *= -1

func _menu():
	if Input.is_action_just_pressed("menu"):
		if in_network == true:
			$menu/network.visible = false
			$menu/main.visible = true
			in_menu = true
			in_network = false
		else:
			if $menu/main.visible == false:
				in_menu = true
				$menu/main.visible = true
				$player/springarm/camera/crosshair.visible = false
				Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
				player.velocity.x = 0
				player.velocity.z = 0
			else:
				in_menu = false
				$menu/main.visible = false
				$player/springarm/camera/crosshair.visible = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#func _initialize_Steam() -> void:
#	var INIT: Dictionary = Steam.steamInit()
#	print("Did Steam initialize?: "+str(INIT))
##	if INIT['status'] != 1:
##		print("Failed to initialize Steam. "+str(INIT['verbal'])+" Shutting down...")
##		get_tree().quit()
#	IS_ONLINE = Steam.loggedOn()
#	STEAM_ID = Steam.getSteamID()
#	IS_OWNED = Steam.isSubscribed()
#	STEAM_USERNAME = Steam.getPersonaName()
#
## Connect a Steam signal and show the success code
#func _connect_Steam_Signals(this_signal: String, this_function: String) -> void:
#	var SIGNAL_CONNECT: int = Steam.this_signal.connect(self.this_function)
#	print("[STEAM] Connecting "+str(this_signal)+" to "+str(this_function)+" successful: "+str(SIGNAL_CONNECT))

func _on_network_pressed():
	in_network = true
	$menu/main.visible = false
	$menu/network.visible = true
