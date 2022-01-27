extends Control

signal lost()

var bet_red = false
var roll_red = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Chips.set_stake(1)
	$Panel/ChipsCountLabel.set_text("Chips 1")
	$BallChipsAnimation.play("reset_bet")
	$table/CircleRotation/ballRotation/ball.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BlackBtn_pressed():
	bet_red = false
	bet()


func _on_RedBtn_pressed():
	bet_red = true
	bet()


func bet():
	if bet_red:
		$BallChipsAnimation.play("bet_red")
	else:
		$BallChipsAnimation.play("bet_black")
	$table/CircleRotation/ballRotation/ball.hide()
	$Buttons.hide()
	

func roll():
	$table/CircleRotation.rotate(randi()%8*(2*PI/8.0))
	roll_red = (randi() % 2 == 0)
	$CircleAnimation.play("rotate")
	if roll_red:
		$BallChipsAnimation.play("red")
	else:
		$BallChipsAnimation.play("black")


func won():
	var new_stake = $Chips.get_stake() * 2
	$Chips.set_stake(new_stake)
	$Panel/ChipsCountLabel.set_text("Chips %d" % new_stake)
	$BallChipsAnimation.play("reset_bet")
	$Buttons.show()


func lost():
	emit_signal("lost")


func _end_bet():
	roll()

func _end_roll():
	if bet_red == roll_red:
		won()
	else:
		lost()
