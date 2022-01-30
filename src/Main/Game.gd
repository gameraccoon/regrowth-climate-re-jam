extends Node
# This class contains controls that should always be accessible, like pausing
# the game or toggling the window full-screen.

enum State {
	ROULETTE,
	WAIT_FIGHT,
	FIGHT,
	GAME_OVER
}

var _state = State.ROULETTE

var _hit_time_left = [192, 576, 960, 1344, 1728, 2112, 2496, 2880, 3264, 3648, 4032, 4416, 4800, 5184, 5568, 5952, 6528, 6720, 7296, 7488, 8064, 8256, 8832, 9024, 9600, 9792, 10368, 10560, 11136, 11328, 11904, 12240, 12576, 12960, 13152, 13320, 13824, 14208, 15232, 15328, 15648, 16032, 16224, 16392, 16896, 17280, 17616, 17856, 18432, 18816, 19200, 19392, 19536, 20256, 20688, 21408, 21504, 21888, 22272, 22464, 22608, 23328, 23760, 24000, 24864, 25056, 25248, 25632, 25776, 25968, 26400, 26496, 26784, 27072, 27936, 28128, 28320, 28704, 28800, 28944, 29136, 29472, 29568, 29760, 29904, 31008, 31104, 31296, 31440, 31776, 32112, 32160, 32544, 32640, 32832, 32976, 33312, 33696, 34176, 34368, 34896, 35040, 35184, 35568, 35664, 36000, 36336, 36432, 38400, 38544, 38688, 38880, 38928, 39024, 39168, 39312, 39456, 39648, 39696, 39792, 40704, 40848, 40992, 41184, 41232, 41328, 42768, 42864, 43008, 43152, 43296, 43488, 43536, 43632, 44304, 44400, 45312, 45456, 45600, 45792, 45840, 45936, 47616, 47760, 47904, 48096, 48144, 48240, 49152, 49488, 49824, 49920, 50304, 50688, 50992, 51072, 51408, 52128, 52160, 52512, 52608, 52752, 52944, 53280, 53376, 53520, 53760, 54000, 54240, 54288, 54528, 54816, 55296, 55632, 55968, 56064, 56448, 56832, 57136, 57216, 57552, 58272, 58304, 58656, 58752, 58896, 59088, 59424, 59520, 59664, 59904, 60144, 60384, 60432, 60672, 61008]
var _hit_time_right = [0, 384, 768, 1152, 1536, 1920, 2304, 2688, 3072, 3456, 3840, 4224, 4608, 4992, 5376, 5760, 6144, 6336, 6912, 7104, 7680, 7872, 8448, 8640, 9216, 9408, 9984, 10176, 10752, 10944, 11520, 11712, 12192, 12288, 12672, 13056, 13248, 13392, 14112, 14592, 15264, 15360, 15744, 16128, 16320, 16464, 17184, 17568, 17664, 17952, 18720, 19104, 19296, 19464, 19968, 20352, 21360, 21456, 21792, 22176, 22368, 22536, 23040, 23424, 23712, 23808, 24096, 24288, 24480, 24960, 25152, 25344, 25680, 25872, 26064, 26448, 26592, 26688, 26832, 27168, 28032, 28224, 28368, 28752, 28848, 29040, 29520, 29664, 29856, 31056, 31200, 31392, 31680, 31968, 32144, 32592, 32736, 32928, 33216, 33504, 34080, 34272, 34464, 34512, 34848, 34944, 35088, 35232, 35616, 35952, 36048, 36384, 36864, 37008, 37152, 37344, 37392, 37488, 37632, 37776, 37920, 38112, 38160, 38256, 39936, 40080, 40224, 40416, 40464, 40560, 41472, 41616, 41760, 41952, 42000, 42096, 42240, 42384, 42528, 42720, 43776, 43920, 44064, 44256, 44544, 44688, 44832, 45024, 45072, 45168, 46080, 46224, 46368, 46560, 46608, 46704, 46848, 46992, 47136, 47328, 47376, 47472, 48384, 48528, 48672, 49440, 49536, 49872, 50112, 50496, 50976, 51008, 51264, 52144, 52224, 52560, 52656, 52848, 53232, 53328, 53424, 53616, 53952, 54144, 54384, 54720, 54864, 55584, 55680, 56016, 56256, 56640, 57120, 57152, 57408, 58288, 58368, 58704, 58800, 58992, 59376, 59472, 59568, 59760, 60096, 60288, 60528, 60960]
var _time_passed = 0
var _next_enemy_idx_left = 0
var _next_enemy_idx_right = 0

const enemy_speed = 200.0
const distance = 250.0
const time_to_reach = distance / enemy_speed
const start_delay = -3
const bit_resolution_mult = 1.0 / ((60.0/130.0)/192.0)

# The "_" prefix is a convention to indicate that variables are private,
# that is to say, another node or script should not access them.
onready var _pause_menu = $InterfaceLayer/PauseMenu
onready var _roulette_window = $InterfaceLayer/Roulette

onready var enemyScene = preload("res://src/Actors/Enemy.tscn")


func _init():
	OS.min_window_size = OS.window_size
	OS.max_window_size = OS.get_screen_size()
	randomize()


func _notification(what):
	if what == NOTIFICATION_WM_QUIT_REQUEST:
		# We need to clean up a little bit first to avoid Viewport errors.
		if name == "Splitscreen":
			$Black/SplitContainer/ViewportContainer1.free()
			$Black.queue_free()


func _unhandled_input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		get_tree().set_input_as_handled()
	# The GlobalControls node, in the Stage scene, is set to process even
	# when the game is paused, so this code keeps running.
	# To see that, select GlobalControls, and scroll down to the Pause category
	# in the inspector.
	elif event.is_action_pressed("toggle_pause"):
		var tree = get_tree()
		tree.paused = not tree.paused
		if tree.paused:
			_pause_menu.open()
		else:
			_pause_menu.close()
		get_tree().set_input_as_handled()


func spawn_random(dir_left):
	var enemy = enemyScene.instance()
	if dir_left:
		enemy.set_position($LeftSpawner.position)
	else:
		enemy.set_position($RightSpawner.position)
		enemy.reverse()
	enemy.target = $Level/Player
	enemy.speed.x = enemy_speed
	#enemy.speed.x = enemy.speed.x + randf() * 100
	$Enemies.add_child(enemy)


func _on_SpawnTimer_timeout():
	spawn_random(randi() % 2 == 0)


func _process(delta):
	if get_tree().is_paused():
		return

	if _state == State.FIGHT:
		_time_passed += delta
		var new_time_hit = _time_passed * bit_resolution_mult
		while _next_enemy_idx_left < len(_hit_time_left) and new_time_hit > _hit_time_left[_next_enemy_idx_left]:
			spawn_random(true)
			#$DebugSound.play()
			_next_enemy_idx_left += 1
		while _next_enemy_idx_right < len(_hit_time_right) and new_time_hit > _hit_time_right[_next_enemy_idx_right]:
			spawn_random(false)
			#$DebugSound.play()
			_next_enemy_idx_right += 1


func start_fight():
	_state = State.WAIT_FIGHT
	$InterfaceLayer/Roulette.set_visible(false)
	$Level/CasinoAmbient.stop()


func is_ready_to_fight():
	return _state == State.FIGHT or _state == State.WAIT_FIGHT


func _on_Player_died():
	_state = State.GAME_OVER
	$SpawnTimer.stop()
	for child in $Enemies.get_children():
		child.queue_free()

	$InterfaceLayer/GameOver.open()
	$InterfaceLayer/GameOver.set_values($InterfaceLayer/Roulette/Chips.get_stake(), $InterfaceLayer/PauseMenu/ColorRect/CoinsCounter.coins_collected)


func _on_Player_finished_stretching():
	$Tutorial.visible = true

	if Autoload.skip_intro:
		_on_Player_passed_tutorial()


func _on_Intro_game_started():
	$InterfaceLayer/Intro.hide()


func _on_Roulette_lost(amount):
	start_fight()


func _on_Player_passed_tutorial():
	if $Tutorial.visible:
		$StartMusicTimer.start(time_to_reach+start_delay)
		#_time_passed = -(time_to_reach+start_delay)+0.05
		$Tutorial.visible = false
		_state = State.FIGHT
		#$SpawnTimer.start()
		#$DifficultyTimer.start()


func _on_DifficultyTimer_timeout():
	$SpawnTimer.wait_time *= 0.8


func _on_StartMusicTimer_timeout():
	$Level/Music.play()
