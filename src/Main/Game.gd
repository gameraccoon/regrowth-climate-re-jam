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

var _hit_time = [188, 620, 1053, 1504, 1954, 2422, 2888, 3322, 3807, 4257, 4757, 5190, 5657, 6108, 6591, 7025, 7493, 7960, 8460, 8911, 9377, 9811, 10261, 10728, 11196, 11646, 12113, 12531, 12997, 13448, 13931, 14381, 14849, 15316, 15800, 16250, 16717, 17167, 17668, 18102, 18585, 19003, 19486, 19953, 20420, 20854, 21306, 21772, 22238, 22689, 23189, 23623, 24090, 24525, 25008, 25475, 25960, 26427, 26876, 27343, 27811, 28227, 28697, 29145, 29395, 29496, 29612, 30212, 30480, 31146, 31430, 31730, 31947, 32214, 32281, 33265, 33966, 34249, 34983, 36618, 36735, 36851, 37018, 37702, 37953, 38620, 38853, 39137, 39370, 39587, 39704, 40755, 41456, 41672, 42306, 42456, 42556, 42974, 43274, 44375, 45075, 45342, 46043, 46310, 46543, 46762, 46977, 47110, 48112, 48762, 49012, 49779, 51448, 51548, 51651, 51765, 51848, 52449, 52666, 53416, 53633, 53900, 54133, 54367, 54500, 55486, 56135, 56419, 57086, 57169, 57303, 57720, 58003, 58437, 58971, 59889, 60105, 60372, 60623, 60873, 61089, 61623, 61857, 62107, 62341, 62574, 62791, 63508, 63625, 63742, 64042, 64276, 64509, 64659, 65184, 65443, 67312, 67512, 67729, 67979, 68212, 68346, 69046, 69163, 69283, 69547, 69697, 69914, 70149, 70915, 71015, 71132, 71265, 71499, 71682, 71882, 72033, 74602, 74701, 74818, 74968, 75168, 75369, 75586, 75703, 76261, 76486, 76921, 77404, 78321, 78438, 78539, 78807, 79055, 79289, 79387, 79933, 80206, 80657, 81124, 81958, 82241, 82508, 82743, 82992, 83092, 83743, 83826, 83960, 84093, 84343, 84427, 84644, 84727, 85528, 85645, 85761, 85878, 86462, 86579, 86697, 86929, 87480, 87563, 87696, 87797, 88764, 89081, 89448, 89865, 90215, 90549, 90916, 91266, 91717, 92050, 92417, 92734, 93101, 93552, 93902, 94236, 94569, 94919, 95370, 95720, 96104, 96437, 96805, 97288, 97606, 97956, 98272, 98639, 99107, 99457, 99824, 100157, 100491, 100958, 101292, 101642, 101959, 102326, 102793, 103127, 103477, 103828, 104194, 104628, 104978, 105345, 105696, 106013, 106463, 106813, 107164, 107514, 107898, 108348, 108665, 109015, 109349, 109716, 110149, 110517, 110884, 111217, 111567, 112018, 112335, 112685, 113019, 113386, 113836, 114187, 114553, 114870, 115287, 115704, 116055, 116372, 116739, 117122, 117506, 118224, 118841, 118991, 119074, 119775, 119875, 119992, 120475, 120943, 121394, 121877, 122594, 122694, 122778, 122894, 123278, 123644, 125396, 125513, 125647, 126247, 126314, 126431, 126548, 126613, 126880, 127147, 127414, 128114, 128198, 128281, 128365, 128514, 128748, 128982, 129232, 129749, 129883, 130133, 130483, 130633, 130900, 131134, 131501, 131734, 131868, 132185, 133135, 133703, 133803, 133919, 134003, 134587, 134703, 134837, 135237, 135721, 136188, 136638, 137322, 137439, 137523, 137723, 138073, 138457, 140108, 140208, 140275, 140376, 140425, 140542, 141176, 141293, 141409, 141676, 141926, 142160, 142794, 142894, 143011, 143094, 143177, 143461, 143761, 144045, 144529, 144679, 144879, 145313, 145430, 145696, 145763, 146347, 146631, 146731]
var _time_passed = 0
var _next_enemy_idx = 0
var _last_dir_left = false

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


func spawn_random():
	var enemy = enemyScene.instance()
	if _last_dir_left:
		enemy.set_position($LeftSpawner.position)
	else:
		enemy.set_position($RightSpawner.position)
		enemy.reverse()
	_last_dir_left = !_last_dir_left
	enemy.target = $Level/Player
	#enemy.speed.x = enemy.speed.x + randf() * 100
	$Enemies.add_child(enemy)


func _on_SpawnTimer_timeout():
	spawn_random()


func _process(delta):
	if _state == State.FIGHT:
		_time_passed += delta
		var new_time_ms = _time_passed * 1000
		while _next_enemy_idx < len(_hit_time) and new_time_ms > _hit_time[_next_enemy_idx]:
			#spawn_random()
			$DebugSound.play()
			_next_enemy_idx += 1


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
		$StartMusicTimer.start(250/150.0+1.2)
		_time_passed = -(250/150.0+1.2)+0.12
		$Tutorial.visible = false
		_state = State.FIGHT
		#$SpawnTimer.start()
		#$DifficultyTimer.start()


func _on_DifficultyTimer_timeout():
	$SpawnTimer.wait_time *= 0.8


func _on_StartMusicTimer_timeout():
	$Level/Music.play()
