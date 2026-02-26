class_name EldritchGame extends Game

## amount gained from perfect chomp
const GOOD_EAT_AMOUNT : float = 20
## amount gained from imperfect chomp
const BAD_EAT_AMOUNT : float = 5

@onready var planets_switcher: PlanetSwitcher = $PlanetsSwitcher
@onready var monsta: Monsta = $Monsta
@onready var hunger_bar: TextureProgressBar = $HungerBar
@onready var eldritch_adaptive_music: EldritchAdaptiveMusic = $EldritchAdaptiveMusic
#@onready var particle_pathing: EldritchParticlePathing = $ParticlePathing

var good_planets_left : int = 0

@warning_ignore("unused_signal") signal switch_to_new_scene
@warning_ignore("unused_signal") signal reload_scene

func _ready() -> void:
	_start_game()

func _start_game():
	planets_switcher.switch_out_old_planets(get_tree().get_first_node_in_group("ParticlePathing"))
	monsta.bad_planet_eaten.connect(_on_bad_planet_eaten)
	monsta.good_planet_eaten.connect(_on_good_planet_eaten)
	eldritch_adaptive_music.start()

func win_game():
	var particle_pathing : EldritchParticlePathing = get_tree().get_first_node_in_group("ParticlePathing") as EldritchParticlePathing
	particle_pathing.should_be_moving = false
	eldritch_adaptive_music.win()
	await eldritch_adaptive_music.current_bar
	planets_switcher.kill_old_path(particle_pathing)
	await eldritch_adaptive_music.win_outro.finished
	await get_tree().create_timer(0.3).timeout
	end_game.emit(true)
	get_tree().quit()

func lose_game():
	var particle_pathing : EldritchParticlePathing = get_tree().get_first_node_in_group("ParticlePathing") as EldritchParticlePathing
	particle_pathing.should_be_moving = false
	eldritch_adaptive_music.lose()
	await eldritch_adaptive_music.current_bar
	planets_switcher.kill_old_path(particle_pathing)
	await eldritch_adaptive_music.lose_outro.finished
	await get_tree().create_timer(0.3).timeout
	end_game.emit(false)
	get_tree().quit()

func _on_good_planet_eaten(hit_was_good : bool):
	good_planets_left -= 1
	if good_planets_left <= 0:
		planets_switcher.switch_out_old_planets(get_tree().get_first_node_in_group("ParticlePathing"))
	var value_to_add : float
	if hit_was_good:
		value_to_add = GOOD_EAT_AMOUNT
	else:
		value_to_add = BAD_EAT_AMOUNT
	
	tween_hunger_bar_to_value(hunger_bar.value + value_to_add)
	
	if hunger_bar.value + value_to_add >= hunger_bar.max_value:
		win_game()
		return

func _on_bad_planet_eaten():
	tween_hunger_bar_to_value(hunger_bar.value - (GOOD_EAT_AMOUNT * 1.2) )

func tween_hunger_bar_to_value(value : float):
	get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK).tween_property(hunger_bar, "value", value, 0.3)
