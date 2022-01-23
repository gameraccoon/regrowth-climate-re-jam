extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Chips.set_stake(1)
	$Panel/ChipsCountLabel.set_text("Chips 1")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BlackBtn_pressed():
	if randi() % 2 == 0:
		won()
	else:
		lost()


func _on_RedBtn_pressed():
	if randi() % 2 == 0:
		won()
	else:
		lost()


func won():
	var new_stake = $Chips.get_stake() * 2
	$Chips.set_stake(new_stake)
	$Panel/ChipsCountLabel.set_text("Chips %d" % new_stake)


func lost():
	$"../..".start_fight()
