class_name Shop
extends Node2D

const HERO_SCENE := preload("res://heroes/components/hero.tscn")
const ITEM_SCENE := preload("res://items/components/item.tscn")

@onready var reroll_button: Button = $RerollButton
@onready var item_container: Node = $ItemContainer
@onready var hero_container: Node = $HeroContainer

@export var hero_pool : Array[HeroStats]
@export var item_pool : WeightedRandomList
@export var hero_offset : Vector2
@export var item_offset : Vector2
var heroes : Array[Hero] = [null, null, null, null]
var items : Array[Item] = [null, null, null]
var hero_positions : Array[Vector2] = []
var item_positions : Array[Vector2] = []
var dist_between_heroes : int = 180
var dist_between_items : int = 100


func _ready() -> void:
	for i in range(heroes.size()):
		hero_positions.append(Vector2(i * dist_between_heroes, 0) + hero_offset)
	for i in range(items.size()):
		item_positions.append(Vector2(i * dist_between_items, 0) + item_offset)
	
	reroll_button.pressed.connect(reroll_shop)
	reroll_shop()


func reroll_shop() -> void:
	heroes.fill(null)
	for hero in hero_container.get_children():
		hero.queue_free()
	
	items.fill(null)
	for item in item_container.get_children():
		item.queue_free()
	
	add_heroes()
	add_items()


func add_heroes() -> void:
	var stat_list : Array[HeroStats] = []
	for i in range(heroes.size()):
		stat_list.append(hero_pool[int(randf_range(0, hero_pool.size()))])
	
	if not stat_list:
			push_error("stat_list is not valid for HeroLine: ", hero_line_info())
	var i : int = 0
	for stat: HeroStats in stat_list:
		if not is_instance_valid(stat):
			continue
		if i >= heroes.size():
			push_error("Was given too many HeroStats for the HeroLine: ", hero_line_info(), " stat_list: ", stat_list)
			break
		heroes[i] = _create_hero(stat, i)
		heroes[i].change_position(global_position + hero_positions[i], i)
		i += 1


func _create_hero(stats: HeroStats, i: int) -> Hero:
	var new_hero : Hero = HERO_SCENE.instantiate()
	hero_container.add_child(new_hero)
	new_hero.global_position = global_position + hero_positions[i]
	new_hero.stats = stats

	heroes[i] = new_hero
	return new_hero


func hero_line_info() -> String:
	var rtn := name
	for h: Hero in heroes:
		rtn += (str(h) + " ")
	return rtn


func add_items() -> void:
	for i in range(items.size()):
		items[i] = create_item(item_pool.get_random(), i)
		items[i].global_position = global_position + item_positions[i]


func create_item(data: ItemData, i: int) -> Item:
	var new_item : Item = ITEM_SCENE.instantiate()
	item_container.add_child(new_item)
	new_item.global_position = global_position + item_positions[i]
	new_item.get_node("ItemTexture").texture = data.model
	
	items[i] = new_item
	return new_item
