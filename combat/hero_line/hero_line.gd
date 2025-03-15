class_name HeroLine
extends Node2D

const HERO_SCENE := preload("res://heroes/components/hero.tscn")

@export var friendly := true
var hero_list : Array[Hero] = [null, null, null, null, null]
var positions : Array[Vector2] = []
var dist_between_heroes : int = 180


func _ready() -> void:
	if friendly:
		dist_between_heroes *= -1
	for i in range(hero_list.size()):
		positions.append(Vector2(i * dist_between_heroes, 0))


func setup(stat_list: HeroArray) -> void:
	if not stat_list:
		push_error("stat_list is not valid for HeroLine: ", line_info())
	
	var i : int = 0
	for stat: HeroStats in stat_list.heroes:
		if not is_instance_valid(stat):
			continue
		if i >= hero_list.size():
			push_error("Was given too many HeroStats for the HeroLine: ", line_info(), " stat_list: ", stat_list)
			break
		hero_list[i] = _create_hero(stat, i)
		hero_list[i].line_position = i
		i += 1
	
	update_hero_positions()
	

func _create_hero(stats: HeroStats, i: int) -> Hero:
	var new_hero : Hero = HERO_SCENE.instantiate()
	add_child(new_hero)
	new_hero.global_position = global_position + positions[i]

	new_hero.stats = stats.custom_duplicate()
	if friendly: 
		new_hero.sprite.flip_h = true
	new_hero.friendly = friendly

	new_hero.died.connect(_on_hero_death)
	hero_list[i] = new_hero
	new_hero.name = "hero" + str(i) + ("friendly" if friendly else "enemy")
	return new_hero


func update_hero_positions() -> void:
	for i in range(hero_list.size()):
		if is_instance_valid(hero_list[i]):
			var tweeny := get_tree().create_tween()
			tweeny.tween_property(hero_list[i], "global_position", global_position + positions[i], 0.2)
			continue
		for j in range(i, hero_list.size()):
			if is_instance_valid(hero_list[j]):
				hero_list[i] = hero_list[j]
				hero_list[j] = null
				hero_list[i].line_position = i
				var tween := get_tree().create_tween()
				tween.tween_property(hero_list[i], "global_position", global_position + positions[i], 0.2)
				break


func make_heroes_run() -> void:
	var height_diff: float = 50
	for hero: Hero in hero_list:
		if not is_instance_valid(hero):
			continue
		var random_time_offset := randf_range(0, 0.1)

		var tween := get_tree().create_tween()
		tween.tween_property(hero, "global_position:y", self.global_position.y + height_diff, (0.3 + random_time_offset) / Settings.battle_speed)
		tween.tween_property(hero, "global_position:y", self.global_position.y - height_diff, (0.3 + random_time_offset) / Settings.battle_speed)
		tween.set_loops(4)
		tween.tween_property(hero, "global_position:y", self.global_position.y, 0.15 / Settings.battle_speed)
		tween.tween_property(hero, "rotation", 0, 0.15 / Settings.battle_speed)


func summon(pos: int, stats: HeroStats) -> void:
	var i := hero_list.size() - 1
	if pos < 0 or pos > i:
		push_warning("Tried to summon with invalid position: ", pos)
		return
	if is_instance_valid(hero_list[i]):
		print("Can't summon another hero - hero_list is full ", line_info())
		return

	# Move heroes back from the summon position
	while i > pos:
		hero_list[i] = hero_list[i-1]
		hero_list[i-1] = null
		i -= 1
	# Move i up to be the front-most available position
	while i-1 >= 0 and not is_instance_valid(hero_list[i-1]):
		i -= 1

	var new_hero: Hero = _create_hero(stats, i)
	EventsBus.hero_summoned.emit(new_hero)
	update_hero_positions()


func find_hero_position(hero: Hero) -> int:
	var hero_position : int = -1

	if not is_instance_valid(hero):
		push_error("Tried to find position of a hero that isn't valid: ", hero, " in list: ", hero_list)
		return hero_position

	for i in range(hero_list.size()):
		if hero_list[i] == hero:
			hero_position = i

	if hero_position == -1:
		push_error("Couldn't find Hero: ", hero.stats.hero_name, " in HeroList: ", to_string())

	return hero_position


func has_hero(hero: Hero) -> bool:
	for h : Hero in hero_list:
		if h == hero:
			return true
	return false


func front() -> Hero:
	var hero : Hero = hero_list[0]
	
	var i := 1
	while not is_instance_valid(hero) or hero.dying:
		if i >= hero_list.size():
			print("Searching from front, couldn't find an alive Hero in HeroList: ", line_info())
			return null
		hero = hero_list[i]
		i += 1
	return hero


func back() -> Hero:
	var hero : Hero = hero_list[hero_list.size()-1]
	
	var i := hero_list.size() - 1
	while not is_instance_valid(hero) or hero.dying:
		if i < 0:
			push_warning("Searching from back, couldn't find a Hero in HeroList: ", line_info())
			return null
		hero = hero_list[i]
		i -= 1

	return hero


func get_random_hero() -> Hero:
	var attempts : int = 0
	
	var hero : Hero = null
	while not is_instance_valid(hero):
		if attempts > 100:
			push_error("Random search couldn't find a hero in HeroList. Searching front of list:  ", line_info())
			return front()
		hero = hero_list[randi() % hero_list.size()]
		attempts += 1

	return hero


func get_one_behind(hero: Hero) -> Hero:
	for i in range(hero_list.size()):
		if hero == hero_list[i]:
			if (i + 1 < hero_list.size()) and is_instance_valid(hero_list[i+1]):
				return hero_list[i+1]
	return null


func get_hero_at(pos: int) -> Hero:
	if pos < 0 or pos >= hero_list.size():
		print("Position requested: ", pos, " not within HeroList: ", line_info())
	var hero : Hero = hero_list[pos]
	if not is_instance_valid(hero):
		print("Didn't find hero at position: ", pos, " within HeroList: ", line_info())
	return hero


func has_alive_hero() -> bool:
	for hero: Hero in hero_list:
		if is_instance_valid(hero):
			return true
	return false


func damage_all(damage: int) -> void:
	for i in range(hero_list.size()):
		if is_instance_valid(hero_list[i]):
			hero_list[i].take_aoe_damage(damage)


func get_global_from_line_pos(i: int) -> Vector2:
	return global_position + positions[i]


func get_back_pos() -> int:
	var i := hero_list.size()-1
	var hero: Hero = hero_list[i]
	while not is_instance_valid(hero) and i >= 0:
		i -= 1
		hero = hero_list[i]
	return i+1


func is_line_full() -> bool:
	for i in range(hero_list.size()):
		if not is_instance_valid(hero_list[i]):
			return false
	return true


func _on_hero_death(hero: Hero) -> void:
	for i in range(hero_list.size()):
		if hero_list[i] == hero:
			hero_list[i] = null

	var death_position : Vector2 = Vector2(0, -200) if friendly else Vector2(2000, -200)
	var tween := get_tree().create_tween()
	tween.tween_property(hero, "global_position", death_position, 0.4)

	update_hero_positions()


func line_info() -> String:
	var rtn := name
	rtn += " friendly " if friendly else " enemy "
	for h: Hero in hero_list:
		rtn += (str(h) + " ")
	return rtn
