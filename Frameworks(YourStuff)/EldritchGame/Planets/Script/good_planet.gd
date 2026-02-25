class_name GoodPlanet extends Planet

@onready var node_2d_effect: Node2DEffect = %Node2DEffect


func die() -> void:
	node_2d_effect.do_tween()
	await node_2d_effect.tween.finished
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is EatingZone:
		z_index += 1
		(area as EatingZone).planet_suck.emit(self)
		die()
