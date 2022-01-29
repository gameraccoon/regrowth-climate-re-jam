extends Node
# This class contains controls that should always be accessible, like pausing
# the game or toggling the window full-screen.

enum State {
	ROULETTE,
	FIGHT,
	GAME_OVER
}

var _state = State.ROULETTE

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
	var i = randi() % 2
	if i == 0:
		enemy.set_position($LeftSpawner.position)
	else:
		enemy.set_position($RightSpawner.position)
		enemy.reverse()
	enemy.target = $Level/Player
	$Enemies.add_child(enemy)


func _on_SpawnTimer_timeout():
	spawn_random()


func start_fight():
	_state = State.FIGHT
	$InterfaceLayer/Roulette.set_visible(false)
	$Level/CasinoAmbient.stop()


func is_fight():
	return _state == State.FIGHT


func _on_Player_died():
	_state = State.GAME_OVER
	$SpawnTimer.stop()
	for child in $Enemies.get_children():
		child.queue_free()

	$InterfaceLayer/GameOver.open()
	$InterfaceLayer/GameOver.set_values($InterfaceLayer/Roulette/Chips.get_stake(), $InterfaceLayer/PauseMenu/ColorRect/CoinsCounter.coins_collected)


func _on_Player_finished_stretching():
	$Tutorial.visible = true
	$Level/Music.play()
	
	if Autoload.skip_intro:
		_on_Player_passed_tutorial()


func _on_Intro_game_started():
	$InterfaceLayer/Intro.hide()


func _on_Roulette_lost(amount):
	start_fight()


func _on_Player_passed_tutorial():
	if $Tutorial.visible:
		$Tutorial.visible = false
		$SpawnTimer.start()
		$DifficultyTimer.start()


func _on_DifficultyTimer_timeout():
	$SpawnTimer.wait_time *= 0.8
