class_name Shop
extends Node2D

signal next_round_requested

const HERO_SCENE := preload("res://heroes/components/hero.tscn")
const ITEM_SCENE := preload("res://items/components/item.tscn")

@export var hero_pool: Array[HeroStats]
@export var item_pool: WeightedRandomList
@export var hero_offset: Vector2
@export var item_offset: Vector2
var heroes: Array[Hero] = [null, null, null, null]
var items: Array[Item] = [null, null, null]
var hero_positions: Array[Vector2] = []
var item_positions: Array[Vector2] = []
var dist_between_heroes: int = 180
var dist_between_items: int = 100
var player_stats: PlayerStats
var round_number: int = 0

var hero_cost: Dictionary[HeroStats.Rarity, int] = {
	HeroStats.Rarity.COMMON: 1,
	HeroStats.Rarity.UNCOMMON: 2,
	HeroStats.Rarity.RARE: 3,
	HeroStats.Rarity.LEGENDARY: 5
}

@onready var reroll_button: Button = %RerollButton
@onready var next_round_button: Button = %NextRoundButton
@onready var item_container: Node = %ItemContainer
@onready var hero_container: Node = %HeroContainer
@onready var player_party: HeroLine = %PlayerParty
@onready var money_display: RichTextLabel = %MoneyDisplay
@onready var round_counter: RichTextLabel = %RoundCounter

#TEMPORARY - TO BE REPLACED BY DRAG AND DROP
@onready var bt_buy_hero_1: Button = %BtBuyHero1
@onready var bt_buy_hero_2: Button = %BtBuyHero2
@onready var bt_buy_hero_3: Button = %BtBuyHero3
@onready var bt_buy_hero_4: Button = %BtBuyHero4
@onready var bt_buy_item_1: Button = %BtBuyItem1
@onready var bt_buy_item_2: Button = %BtBuyItem2
@onready var bt_buy_item_3: Button = %BtBuyItem3
@onready var bt_sell_hero_1: Button = %BtSellHero1
@onready var bt_sell_hero_2: Button = %BtSellHero2
@onready var bt_sell_hero_3: Button = %BtSellHero3
@onready var bt_sell_hero_4: Button = %BtSellHero4
@onready var bt_sell_hero_5: Button = %BtSellHero5

func _connect_temp_buttons() -> void:
	bt_buy_hero_1.pressed.connect(func() -> void: buy_hero(0))
	bt_buy_hero_2.pressed.connect(func() -> void: buy_hero(1))
	bt_buy_hero_3.pressed.connect(func() -> void: buy_hero(2))
	bt_buy_hero_4.pressed.connect(func() -> void: buy_hero(3))
	bt_buy_item_1.pressed.connect(func() -> void: buy_item(0))
	bt_buy_item_2.pressed.connect(func() -> void: buy_item(1))
	bt_buy_item_3.pressed.connect(func() -> void: buy_item(2))
	bt_sell_hero_1.pressed.connect(func() -> void: sell_hero(0))
	bt_sell_hero_2.pressed.connect(func() -> void: sell_hero(1))
	bt_sell_hero_3.pressed.connect(func() -> void: sell_hero(2))
	bt_sell_hero_4.pressed.connect(func() -> void: sell_hero(3))
	bt_sell_hero_5.pressed.connect(func() -> void: sell_hero(4))
#TEMPORARY - TO BE REPLACED BY DRAG AND DROP


func _ready() -> void:
	for i in range(heroes.size()):
		hero_positions.append(Vector2(i * dist_between_heroes, 0) + hero_offset)
	for i in range(items.size()):
		item_positions.append(Vector2(i * dist_between_items, 0) + item_offset)
	
	round_counter.text = "Round: " + str(round_number)

	reroll_button.pressed.connect(reroll_shop)
	reroll_shop()
	_update_money(0)
	_connect_temp_buttons()
	player_party.setup(player_stats.heroes)

	# TODO: give this money an animation or something so players can see their income adding to the money
	player_stats.money += player_stats.income


func reroll_shop() -> void:
	heroes.fill(null) # Adjust later if the option to lock a selection is added
	for hero in hero_container.get_children():
		hero.queue_free()
	
	items.fill(null) # Adjust later if the option to lock a selection is added
	for item in item_container.get_children():
		item.queue_free()
	
	add_heroes()
	add_items()
	_update_money(-2)


func add_heroes() -> void:
	var stat_list : Array[HeroStats] = []
	for i in range(heroes.size()):
		stat_list.append(hero_pool[randi_range(0, hero_pool.size()-1)])
	
	var i: int = 0
	for stat: HeroStats in stat_list:
		if not is_instance_valid(stat):
			continue
		if i >= heroes.size():
			push_error("Was given too many HeroStats for the HeroLine: ", _heroes_info(), " stat_list: ", stat_list)
			break
		heroes[i] = _create_hero(stat, i)
		heroes[i].position = global_position + hero_positions[i]
		i += 1


func buy_hero(shop_slot: int) -> Hero:
	if not is_instance_valid(heroes[shop_slot]):
		print("Trying to buy hero that was already bought")
		return
	print("Buying hero from shop slot ", shop_slot)
	var rtn: Hero
	# Get next available position in party (probably not necessary when drag and drop is implemented)
	var i: int = 0
	for hero in player_party.hero_list:
		if hero == null:
			break
		i += 1

	if i >= player_party.hero_list.size(): # Throw error if there are no open slots
		print("Tried to buy a hero when there are no open party slots.")
	else: # Proceed with purchase
		rtn = player_party._create_hero(heroes[shop_slot].stats, i)
		heroes[shop_slot].queue_free()
		_update_money(-hero_cost[heroes[shop_slot].stats.rarity])
	return rtn


func sell_hero(party_slot: int) -> void:
	if not is_instance_valid(player_party.hero_list[party_slot]):
		print("No hero to sell at slot: ", party_slot, " in line: ", player_party.line_info())
		return
	print("Selling hero from party slot ", party_slot)
	_update_money(hero_cost[player_party.hero_list[party_slot].stats.rarity])
	player_party.hero_list[party_slot].queue_free()
	player_party.hero_list[party_slot] = null
	player_party.update_hero_positions()


func buy_item(shop_slot: int) -> Item:
	print("Buying hero from shop slot ", shop_slot)
	return null


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


func _create_hero(stats: HeroStats, i: int) -> Hero:
	var new_hero : Hero = HERO_SCENE.instantiate()
	hero_container.add_child(new_hero)
	new_hero.global_position = global_position + hero_positions[i]
	new_hero.stats = stats

	heroes[i] = new_hero
	return new_hero


func _update_money(delta: int) -> void:
	player_stats.money += delta
	money_display.text = str(player_stats.money)


func _on_next_round_button_pressed() -> void:
	if not player_party.has_alive_hero():
		return
	var hero_array := HeroArray.new()
	print(player_party.line_info())
	for i in range(player_party.hero_list.size()):
		if not is_instance_valid(player_party.hero_list[i]):
			continue
		hero_array.heroes[i] = player_party.hero_list[i].stats
	player_stats.heroes = hero_array
	next_round_requested.emit()


func _heroes_info() -> String:
	var rtn := name
	for h: Hero in heroes:
		rtn += (str(h) + " ")
	return rtn
