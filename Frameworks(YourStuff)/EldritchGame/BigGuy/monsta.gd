extends Sprite2D

@onready var eating_zone: EatingZone = $EatingZone
@onready var marker_2d: Marker2D = $Marker2D


func _ready() -> void:
	eating_zone.planet_suck.connect(move_planet_to_marker)


func move_planet_to_marker(planet : Planet) -> void:
	var tween : Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(planet, 'global_position', marker_2d.global_position, 0.2)
