class_name Shop
extends Node2D

signal next_round_requested

const HERO_SCENE := preload("res://heroes/components/hero.tscn")
const ITEM_SCENE := preload("res://items/components/item.tscn")
const HERO_LOCATION_SCENE := preload("res://shop/hero_location.tscn")

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
var in_sell_portal := false
var hero_sell_spot_dic: Dictionary[Hero, int] = {}
var buy_spots: Dictionary[HeroLocation, int] = {}
var buy_spots_hovered: Dictionary[HeroLocation, bool] = {}
var hero_buy_spot_dic: Dictionary[Hero, int]

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
@onready var income_label: Label = %IncomeLabel
@onready var canvas: CanvasLayer = %CanvasLayer


func _ready() -> void:
	EventsBus.hero_summoned.connect(_on_hero_summoned)
	EventsBus.hero_buffed.connect(_on_hero_buffed)
	EventsBus.hero_died.connect(_on_hero_died)
	EventsBus.hero_healed.connect(_on_hero_healed)

	for i in range(heroes.size()):
		hero_positions.append(Vector2(i * dist_between_heroes, 0) + hero_offset)
	for i in range(items.size()):
		item_positions.append(Vector2(i * dist_between_items, 0) + item_offset)
	
	round_counter.text = "Round: " + str(player_stats.round_number)
	income_label.text = "Income: " + str(player_stats.income)

	# Set up buyable hero locations
	for i in range(hero_positions.size()):
		var hero_location: HeroLocation = HERO_LOCATION_SCENE.instantiate()
		canvas.add_child(hero_location)
		hero_location.global_position = global_position + hero_positions[i] + Vector2(0, 60)

	# Set up party hero locations
	for i in range(player_party.hero_list.size()):
		var hero_location: HeroLocation = HERO_LOCATION_SCENE.instantiate()
		canvas.add_child(hero_location)
		hero_location.global_position = player_party.global_position + player_party.positions[i] + Vector2(0, 60)
		hero_location.hovered.connect(_player_party_hovered)
		hero_location.not_hovered.connect(_player_party_not_hovered)
		buy_spots[hero_location] = i


	_on_reroll_button_pressed()
	# Have to subtract one here because the initial shop entry will add 1 reroll even though the player didn't press the button
	player_stats.times_rerolled -= 1
	# Add one since initial reroll subtracts 2
	player_stats.money += 2

	player_party.setup(player_stats.heroes)
	for i in range(player_party.hero_list.size()):
		var hero: Hero = player_party.hero_list[i]
		if is_instance_valid(hero):
			hero_sell_spot_dic[hero] = i
			hero.drag_drop.dropped.connect(_on_hero_dropped)

	_on_shop_entered()
	_update_money(0)



func add_heroes() -> void:
	var stat_list : Array[HeroStats] = []
	for i in range(heroes.size()):
		var random_hero: HeroStats = hero_pool[randi_range(0, hero_pool.size()-1)]
		# Don't add heroes that the player hasn't unlocked yet
		while random_hero.rarity > player_stats.level:
			random_hero = hero_pool[randi_range(0, hero_pool.size()-1)]
		stat_list.append(random_hero)
	
	var i: int = 0
	for stat: HeroStats in stat_list:
		if not is_instance_valid(stat):
			continue
		if i >= heroes.size():
			push_error("Was given too many HeroStats for the HeroLine: ", _heroes_info(), " stat_list: ", stat_list)
			break
		heroes[i] = _create_hero(stat, i)
		heroes[i].position = global_position + hero_positions[i]
		heroes[i].drag_drop.dropped.connect(_on_hero_dropped)
		hero_buy_spot_dic[heroes[i]] = i
		i += 1


func buy_hero(shop_slot: int, party_slot: int) -> void:
	if not is_instance_valid(heroes[shop_slot]):
		print("Trying to buy hero that was already bought")
		return
	if player_stats.money < hero_cost[heroes[shop_slot].stats.rarity]:
		print("Trying to buy hero without enough money")
		return
	if player_party.is_line_full():
		print("Player party is full")
		return
	print("Buying hero from shop slot ", shop_slot)

	var new_hero: Hero = player_party.buy_hero(party_slot, heroes[shop_slot].stats)
	new_hero.drag_drop.dropped.connect(_on_hero_dropped)
	hero_sell_spot_dic[new_hero] = player_party.find_hero_position(new_hero)
	heroes[shop_slot].queue_free()
	_update_money(-hero_cost[heroes[shop_slot].stats.rarity])


func sell_hero(hero: Hero) -> void:
	if not is_instance_valid(hero):
		return
	_update_money(hero_cost[hero.stats.rarity])
	player_party.remove_hero(hero)


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


func _on_reroll_button_pressed() -> void:
	if player_stats.money < 2:
		print("Tried to reroll without enough money")
		return
	player_stats.times_rerolled += 1
	heroes.fill(null) # Adjust later if the option to lock a selection is added
	for hero in hero_container.get_children():
		hero.queue_free()
	
	items.fill(null) # Adjust later if the option to lock a selection is added
	for item in item_container.get_children():
		item.queue_free()
	
	add_heroes()
	add_items()
	_update_money(-2)


func _on_hero_dropped(hero: Hero, starting_position: Vector2) -> void:
	# player party heroes
	print("hero dropped")
	if player_party.has_hero(hero):
		# Sell hero
		if in_sell_portal:
			sell_hero(hero)
			return
		for key: HeroLocation in buy_spots_hovered.keys():
			if buy_spots_hovered[key]:
				var other_hero: Hero = player_party.get_hero_at(buy_spots[key])
				if not is_instance_valid(other_hero):
					hero.global_position = starting_position
					return
				player_party.swap_heroes(hero, other_hero)
				return
		hero.global_position = starting_position
		return
	# Buy hero
	else:
		# Player party is full
		if player_party.is_line_full():
			hero.global_position = starting_position
			return
		# Find spot
		for key: HeroLocation in buy_spots_hovered.keys():
			if buy_spots_hovered[key]:
				buy_hero(hero_buy_spot_dic[hero], buy_spots[key])
				return
	hero.global_position = starting_position


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
	
	for hero: Hero in player_party.hero_list:
		if is_instance_valid(hero):
			hero.on_shop_ended(player_party)

	# Run effect queue for shop-ended effects
	while not EffectQueue.is_empty():
		var effect: Effect = EffectQueue.front()
		print("Executing effect: ", effect.get_effect_name())
		EffectQueue.execute_next()
		await effect.finished
		await get_tree().create_timer(0.5 / Settings.battle_speed, false).timeout

	var hero_array := HeroArray.new()
	print(player_party.line_info())
	for i in range(player_party.hero_list.size()):
		if not is_instance_valid(player_party.hero_list[i]):
			continue
		hero_array.heroes[i] = player_party.hero_list[i].stats
	player_stats.heroes = hero_array
	next_round_requested.emit()


func _on_shop_entered() -> void:
	for hero: Hero in player_party.hero_list:
		if is_instance_valid(hero):
			hero.on_shop_start(player_party)
	
	# Run effect queue for shop-entered effects
	while not EffectQueue.is_empty():
		var effect: Effect = EffectQueue.front()
		print("Executing effect: ", effect.get_effect_name())
		EffectQueue.execute_next()
		await effect.finished
		await get_tree().create_timer(0.5 / Settings.battle_speed, false).timeout


func _on_hero_healed(healed_hero: Hero) -> void:
	for hero: Hero in player_party.hero_list:
		if is_instance_valid(hero):
			hero.on_hero_healed(healed_hero)


func _on_hero_summoned(summon: Hero) -> void:
	for hero: Hero in player_party.hero_list:
		if is_instance_valid(hero):
			hero.on_hero_summoned(summon)


func _on_hero_buffed(buffed_hero: Hero) -> void:
	for hero: Hero in player_party.hero_list:
		if is_instance_valid(hero):
			hero.on_hero_buffed(buffed_hero)


func _on_hero_died(died_hero: Hero) -> void:
	for hero: Hero in player_party.hero_list:
		if is_instance_valid(hero):
			hero.on_hero_death(died_hero)


func _heroes_info() -> String:
	var rtn := name
	for h: Hero in heroes:
		rtn += (str(h) + " ")
	return rtn


func _on_sell_portal_area_mouse_exited() -> void:
	in_sell_portal = false
	print("sell portal no")


func _on_sell_portal_area_mouse_entered() -> void:
	in_sell_portal = true
	print("sell portal yes")


func _player_party_hovered(hl: HeroLocation) -> void:
	buy_spots_hovered[hl] = true


func _player_party_not_hovered(hl:HeroLocation) -> void:
	buy_spots_hovered[hl] = false
