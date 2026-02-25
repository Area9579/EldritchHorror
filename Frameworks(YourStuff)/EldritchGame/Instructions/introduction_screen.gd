class_name EldritchInstructionScreen extends Node2D
@onready var dissapear: Node2DEffect = $Dissapear


func _ready() -> void:
	get_tree().paused = true
	await get_tree().create_timer(1.5).timeout
	do_introduction()



func do_introduction() -> void:
	dissapear.do_tween()
	await dissapear.tween.finished
	get_tree().paused = false
