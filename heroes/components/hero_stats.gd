class_name HeroStats
extends Resource

enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}

const RARITY_COLORS := {
	Rarity.COMMON: Color("124a2e"),
	Rarity.UNCOMMON: Color("1c527c"),
	Rarity.RARE: Color("ab0979"),
	Rarity.LEGENDARY: Color("ea940b"),
}

@export_category("Combat Stats")
@export var max_hp : int = 1 : set = _set_max_hp
@export var current_hp : int = max_hp
@export var damage : int = 1
@export_category("Effects")
@export var effects : Array[Effect]
@export var item_list : Array[ItemData]
@export_category("Visuals")
@export var hero_name : String
@export var model : Texture


func _set_max_hp(value: int) -> void:
	max_hp = clampi(value, 1, 100)
	changed.emit()


func _set_current_hp(value: int) -> void:
	current_hp = clampi(value, -1000, max_hp)
	changed.emit()


func _set_damage(value: int) -> void:
	damage = clampi(value, 1, 100)
	changed.emit()


## Duplicate should be done with this due to Godot issue with 
## recursively duplicating resources
func custom_duplicate() -> HeroStats:
	var new_stats: HeroStats = duplicate(true)

	var new_effects: Array[Effect] = []
	for effect: Effect in effects:
		new_effects.append(effect.duplicate(true))
	new_stats.effects = new_effects

	var new_items: Array[ItemData] = []
	for item_data: ItemData in item_list:
		new_items.append(item_data.duplicate(true))
	new_stats.item_list = new_items
	
	return new_stats
