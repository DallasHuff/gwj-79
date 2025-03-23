class_name PlayerStats
extends Resource

@export var level: int = 0
@export var money: int = 100
@export var income: int = 5
@export var health: int = 3
@export var round_number: int = 1
@export var heroes: HeroArray
var rounds_required_to_win: int = 5
var rounds_won: int = 0
var times_rerolled: int = 0
var units_slain: int = 0
var effects_triggered: int = 0


func get_random_rarity_for_level() -> HeroStats.Rarity:
	# var rng := RandomNumberGenerator.new()
	# var available_rarities : Array = ROLL_RARITIES[level]
	# var weights : PackedFloat32Array = PackedFloat32Array(ROLL_CHANCES[level])

	# return available_rarities[rng.rand_weighted(weights)]
	return HeroStats.Rarity.COMMON


func setup_for_new_game() -> void:
	level = 1
	money = 10
	income = 5
	health = 3
	round_number = 1
	rounds_won = 2
	times_rerolled = 0
	units_slain = 0
	effects_triggered = 0
	heroes = HeroArray.new()
