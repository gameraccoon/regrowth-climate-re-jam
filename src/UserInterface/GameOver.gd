extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_values(lost, damage):
	$Panel/LostAmount.set_text("%d000$" % lost)
	$Panel/DamageAmount.set_text("%d000$" % damage)
	$Panel/LossAmount.set_text("%d000$" % (damage + lost))
