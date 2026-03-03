class_name EldritchGame extends Game

## amount gained from perfect chomp
const GOOD_EAT_AMOUNT : float = 15
## amount gained from imperfect chomp
const BAD_EAT_AMOUNT : float = 7

const MOUSE_CURSOR = preload("uid://bog33u2o2xq6k")

var time : float = 20.0
var max_time : float
var round_started : bool = false

@onready var monsta: Monsta = $Monsta
@onready var hunger_bar: TextureProgressBar = $HungerBar
@onready var eldritch_adaptive_music: EldritchAdaptiveMusic = $EldritchAdaptiveMusic
@onready var particle_pathing: EldritchParticlePathing = $ParticlePathing
@onready var timer: Timer = $Timer as Timer
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var time_left_notifier: ControlNodeEffectSequencer = $TextureProgressBar/TimeLeftNotifier as ControlNodeEffectSequencer
@onready var planet_switcher: PlanetSwitcher = $PlanetSwitcher as PlanetSwitcher


@warning_ignore("unused_signal") signal switch_to_new_scene
@warning_ignore("unused_signal") signal reload_scene

var planets_to_eat : int = 0

func _ready() -> void:
	Input.set_custom_mouse_cursor(MOUSE_CURSOR)
	_start_game()
	await eldritch_adaptive_music.intro.finished
	planet_switcher.spawn_in_new_path()
	round_started = true
	max_time = time * 100 * 2
	texture_progress_bar.max_value = max_time
	timer.start(time)


func _process(_delta: float) -> void:
	if round_started:
		texture_progress_bar.value = timer.time_left * 100 * 2
		if (
			int(texture_progress_bar.value) % int(max_time / 4) >= -10 and 
			int(texture_progress_bar.value) % int(max_time / 4) <= 10
			):
			if time_left_notifier.is_running:
				return
			time_left_notifier.do_effect_sequence()


func _start_game():
	monsta.bad_planet_eaten.connect(_on_bad_planet_eaten)
	monsta.good_planet_eaten.connect(_on_good_planet_eaten)

func win_game():
	particle_pathing.should_be_moving = false
	eldritch_adaptive_music.win()
	await eldritch_adaptive_music.win_outro.finished
	#end_game.emit(true)
	get_tree().quit()

func lose_game():
	particle_pathing.should_be_moving = false
	eldritch_adaptive_music.lose()
	await eldritch_adaptive_music.lose_outro.finished
	end_game.emit(false)
	get_tree().quit()

func _on_good_planet_eaten(hit_was_good : bool):
	planets_to_eat -= 1
	
	var value_to_add : float
	if hit_was_good:
		value_to_add = GOOD_EAT_AMOUNT
	else:
		value_to_add = BAD_EAT_AMOUNT
	print('print(value_to_add) ', value_to_add)
	tween_hunger_bar_to_value(value_to_add)
	
	if planets_to_eat <= 0:
		planet_switcher.switch_out_old_planets(get_tree().get_first_node_in_group("ParticlePathing"))
	
	if hunger_bar.value + value_to_add >= hunger_bar.max_value:
		win_game()
		return

func _on_bad_planet_eaten():
	tween_hunger_bar_to_value( - (GOOD_EAT_AMOUNT * 1.2) )

func tween_hunger_bar_to_value(value : float):
	print(hunger_bar.value, ' tweeining to: ', hunger_bar.value + value)
	get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK).tween_property(hunger_bar, "value", hunger_bar.value + value, 0.3)
