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
	$Panel/LostAmount.set_text("%d$" % (lost * 1000))
	$Panel/DamageAmount.set_text("%d$" % (damage * 1000))
	$Panel/LossAmount.set_text("%d$" % ((damage + lost) * 1000))


func open():
	show()
	$ShowButtonTimer.start()


func _on_Button_pressed():
	Autoload.skip_intro = true
	get_tree().reload_current_scene()


func _on_ShowButtonTimer_timeout():
	$Button.show()
