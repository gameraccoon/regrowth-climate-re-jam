extends Node2D

export(Array, NodePath) var chips

var stake = 12

func set_stake(amount):
	stake = amount
	var counted = 0
	for chip in chips:
		get_node(chip).set_visible(counted < amount)
		counted += 1
			
func get_stake():
	return stake
