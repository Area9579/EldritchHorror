class_name EldritchGame extends Node2D

var planet_count : int = 0

@warning_ignore("unused_signal") signal switch_to_new_scene
@warning_ignore("unused_signal") signal reload_scene

func _ready() -> void:
	add_all_bubble_signals()

func add_all_bubble_signals() -> void:
	for child in get_children():
		if child is EldritchParticlePathing:
			(child as EldritchParticlePathing).planet_got_eaten.connect(decrease_planet_count)
			(child as EldritchParticlePathing).bad_planet_eaten.connect(_on_bad_planet_eatens)


func increase_planet_count():
	planet_count += 1


func decrease_planet_count():
	planet_count -= 1
	check_for_game_completion()
	print(planet_count)


func _on_bad_planet_eatens():
	reload_scene.emit()

func check_for_game_completion() -> void:
	if planet_count == 0:
		switch_to_new_scene.emit()
