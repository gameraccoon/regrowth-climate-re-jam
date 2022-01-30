extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal game_started

var texts = ["it was an unusual night\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\nyou went to the casino\t\t\t\t\t\t\t\t\t\t\t\t again\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\nyou felt so good today\t\t\t\t\t, so happy\n\t\t\t\t\t\t\t\t\tyou didn't want to stop playing\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\n",
			"you lost everything today\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\ne\t\tv\t\te\t\tr\t\ty\t\tt\t\th\t\ti\t\tn\t\tg\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t",
			"stunned\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t, you slowly started walking away from\nthe roulette table\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t when you saw a chip\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t lying \t\t\t\t\t\t\t\ton\nthe floor\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tYou took it and returned to the table\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tYou need to get your money back\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tYou need to\t\t\t\t\t\t\t\t\t\t\t\t Rregrow your stakesE \t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t"]
var text = ""
var text_index = 0
var currentLetter = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if Autoload.skip_intro:
		emit_signal("game_started")
		$TextFillTimer.stop()
	text = texts[0]
	$StartButton.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextFillTimer_timeout():
	if currentLetter < len(text):
		var nextLetter = text[currentLetter]
		if nextLetter == 'R':
			$Text.push_color(Color("#ff0000"))
		elif nextLetter == 'E':
			$Text.pop()
		elif nextLetter != '\t':
			$Text.add_text(nextLetter)
		currentLetter += 1
	else:
		_next_step()


func _next_step():
	if text_index < len(texts) - 1:
		text_index += 1
		text = texts[text_index]
		currentLetter = 0
		$Text.clear()
	else:
		$TextFillTimer.stop()
		$StartButton.show()


func _on_StartButton_pressed():
	emit_signal("game_started")


func _on_WaitToStartTimer_timeout():
	$TextFillTimer.start()
