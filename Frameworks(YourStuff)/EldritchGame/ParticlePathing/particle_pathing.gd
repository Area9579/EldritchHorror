class_name EldritchParticlePathing extends Path2D

const PathFollow2d = preload('uid://d3xire3t1b2b5')

signal planet_got_eaten
signal bad_planet_eaten

var path_movement_percent : float

var paths_array : Array[EldritchParticleFollow] = []

@export var speed : float = 0.1
var planets : Array[Planet]
func _ready() -> void:
	for planet in get_children():
		if planet is not Planet:
			continue
		planets.append(planet as Planet)
		if planet is GoodPlanet:
			(get_parent() as EldritchGame).increase_planet_count()
			(planet as Planet).planet_eaten.connect(call_planet_decrease)
		elif planet is Planet:
			(planet as Planet).planet_eaten.connect(_on_bad_planet_eaten)
		parent_planet_to_line_follow(planet as Planet)
	space_out_planets()
	path_movement_percent = 1.0 / (get_parent() as EldritchGame).planet_count


func parent_planet_to_line_follow(planet : Planet) -> void:
	var path : EldritchParticleFollow = EldritchParticleFollow.new()
	path.set_script(PathFollow2d)
	#path.speed = speed
	add_child(path)
	planet.reparent(path, false)
	planet.position = Vector2.ZERO
	paths_array.append(path)


func space_out_planets() -> void:
	var progress_amount : float = 0
	for child in get_children():
		if child is not EldritchParticleFollow:
			return
		progress_amount += (1/float(get_child_count()))
		(child as EldritchParticleFollow).progress_ratio = progress_amount

func _on_bad_planet_eaten() -> void:
	for planet in planets:
		if is_instance_valid(planet):
			#TODO: implement the new updated version based on area region
			pass
	bad_planet_eaten.emit()

func call_planet_decrease() -> void:
	planet_got_eaten.emit()


func progress_paths() -> void:
	for path : EldritchParticleFollow in paths_array:
		path.progress_ratio += path_movement_percent
		


func _on_timer_timeout() -> void:
	progress_paths()
