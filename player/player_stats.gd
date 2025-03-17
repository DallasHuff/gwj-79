class_name PlayerStats
extends Resource

@export var level: int = 1
@export var money: int = 100
@export var income: int = 5
@export var health: int = 3
@export var heroes: HeroArray

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
	heroes = HeroArray.new()
