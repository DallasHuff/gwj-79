class_name Shop
extends Node2D

signal request_friendly_hero_list()

const HERO_SCENE := preload("res://heroes/components/hero.tscn")
const ITEM_SCENE := preload("res://items/components/item.tscn")
const HERO_STATS := preload("res://heroes/components/hero_stats.gd")

@onready var reroll_button: Button = %RerollButton
@onready var next_round_button: Button = %NextRoundButton
@onready var item_container: Node = $ItemContainer
@onready var hero_container: Node = $HeroContainer
@onready var player_party: HeroLine = %PlayerParty
@onready var money_display: RichTextLabel = %MoneyDisplay

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
var money : int

var hero_costs : Dictionary = {
	HERO_STATS.Rarity.COMMON: 1,
	HERO_STATS.Rarity.UNCOMMON: 2,
	HERO_STATS.Rarity.RARE: 3,
	HERO_STATS.Rarity.LEGENDARY: 5
}


func _ready() -> void:
	for i in range(heroes.size()):
		hero_positions.append(Vector2(i * dist_between_heroes, 0) + hero_offset)
	for i in range(items.size()):
		item_positions.append(Vector2(i * dist_between_items, 0) + item_offset)
	
	reroll_button.pressed.connect(reroll_shop)
	reroll_shop()
	_update_money_display()
	request_friendly_hero_list.emit()


func reroll_shop() -> void:
	heroes.fill(null) # Adjust later if the option to lock a selection is added
	for hero in hero_container.get_children():
		hero.queue_free()
	
	items.fill(null) # Adjust later if the option to lock a selection is added
	for item in item_container.get_children():
		item.queue_free()
	
	add_heroes()
	add_items()


func add_heroes() -> void:
	var stat_list : Array[HeroStats] = []
	for i in range(heroes.size()):
		stat_list.append(hero_pool[int(randf_range(0, hero_pool.size()))])
	
	if not stat_list:
			push_error("stat_list is not valid for HeroLine: ", _heroes_info())
	var i : int = 0
	for stat: HeroStats in stat_list:
		if not is_instance_valid(stat):
			continue
		if i >= heroes.size():
			push_error("Was given too many HeroStats for the HeroLine: ", _heroes_info(), " stat_list: ", stat_list)
			break
		heroes[i] = _create_hero(stat, i)
		set_hero_position(heroes[i], global_position + hero_positions[i])
		i += 1


func _create_hero(stats: HeroStats, i: int) -> Hero:
	var new_hero : Hero = HERO_SCENE.instantiate()
	hero_container.add_child(new_hero)
	new_hero.global_position = global_position + hero_positions[i]
	new_hero.stats = stats

	heroes[i] = new_hero
	return new_hero


func set_hero_position(hero: Hero, destination: Vector2) -> void:
	hero.position = destination


func _heroes_info() -> String:
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


func purchase_hero(hero: Hero, dest_pos: int) -> void:
	# Takes a hero (supplied by drag and drop?)
	# Subtract money from the player
	# Hide hero from the shop and make it unclickable? Or queue free, if that doesn't mess up adding the hero to the player's party
	# Return the purchased hero so drag and drop can pass the hero to hero line
	
	
	# Replace this hero's spot in heroes[] with null
	# Send hero_purchased signal? (Adds to player's party
	pass


func purchase_item() -> Item:
	return null


func _update_money_display() -> void:
	money_display.text = "$" + str(money)


# Called from main after the request_friendly_hero_list signal is sent
func import_player_party(friendly_hero_list: HeroArray) -> void:
	player_party.setup(friendly_hero_list)


func export_player_party() -> HeroArray:
	# Needs to construct a new HeroArray from shop.hero_line, return it, main.gd sets main.friendly_hero_list equal to the returned value
	return null
