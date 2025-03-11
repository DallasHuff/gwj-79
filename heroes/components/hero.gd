class_name Hero
extends Node2D

signal died(hero: Hero)

@export var stats : HeroStats : set = _set_stats
var hero_name := "empty hero name"
var friendly := true
var dying := false
var summon := false
var line_position : int = 0

@onready var sprite : TextureRect = %HeroTexture
@onready var health_label : Label = %HealthLabel
@onready var attack_label : Label = %AttackLabel


func _set_stats(value: HeroStats) -> void:
	if not is_node_ready():
		await ready

	if value == null:
		push_error("HeroStats null for hero: ", name)

	stats = value.custom_duplicate()
	stats.changed.connect(_on_stats_changed)

	sprite.texture = stats.model
	hero_name = stats.hero_name

	_on_stats_changed()


func take_damage(dmg: int) -> void:
	if dmg <= 0:
		return

	for effect: Effect in stats.effects:
		if Effect.TriggerType.DAMAGE_TAKEN in effect.triggers:
			effect.context = ContextBuilder.build_default(self)
			EffectQueue.push_back(effect, 2)

	stats.current_hp = stats.current_hp - dmg
	if stats.current_hp <= 0:
		_died()
	_on_stats_changed()


func take_aoe_damage(dmg: int) -> void:
	take_damage(dmg)
	

func get_buffed(health_buff: int, damage_buff: int) -> void:
	for effect: Effect in stats.effects:
		if Effect.TriggerType.SELF_BUFFED in effect.triggers:
			effect.context = ContextBuilder.build_default(self)
			EffectQueue.push_back(effect, 2)

	stats.max_hp += health_buff
	stats.current_hp += health_buff
	stats.damage += damage_buff
	_on_stats_changed()

	EventsBus.hero_buffed.emit(self)


func battle_start() -> void:
	for effect: Effect in stats.effects:
		if Effect.TriggerType.START_OF_BATTLE in effect.triggers:
			effect.context = ContextBuilder.build_default(self)
			EffectQueue.push_back(effect, 2)


func before_attack() -> void:
	for effect: Effect in stats.effects:
		if Effect.TriggerType.BEFORE_ATTACK in effect.triggers:
			effect.context = ContextBuilder.build_default(self)
			EffectQueue.push_back(effect, 2)


func on_hero_summoned(summoned_hero: Hero) -> void:
	for effect: Effect in stats.effects:
		if Effect.TriggerType.SUMMONED in effect.triggers:
			effect.context = ContextBuilder.build_trigger(self, summoned_hero)
			EffectQueue.push_back(effect, 2)


func on_hero_buffed(hero: Hero) -> void:
	if hero == self:
		return
	if hero.friendly == friendly:
		for effect: Effect in stats.effects:
			if Effect.TriggerType.FRIENDLY_BUFFED in effect.triggers:
				effect.context = ContextBuilder.build_trigger(self, hero)
				EffectQueue.push_back(effect, 2)
	else:
		for effect: Effect in stats.effects:
			if Effect.TriggerType.ENEMY_BUFFED in effect.triggers:
				effect.context = ContextBuilder.build_trigger(self, hero)
				EffectQueue.push_back(effect, 2)


func on_hero_death(hero: Hero) -> void:
	if hero == self:
		return
	for effect: Effect in stats.effects:
		if Effect.TriggerType.ANY_OTHER_DEATH in effect.triggers:
			effect.context = ContextBuilder.build_trigger(self, hero)
			EffectQueue.push_back(effect, 2)

	if hero.friendly == friendly:
		for effect: Effect in stats.effects:
			if Effect.TriggerType.FRIENDLY_DEATH in effect.triggers:
				effect.context = ContextBuilder.build_trigger(self, hero)
				EffectQueue.push_back(effect, 2)
	else:
		for effect: Effect in stats.effects:
			if Effect.TriggerType.ENEMY_DEATH in effect.triggers:
				effect.context = ContextBuilder.build_trigger(self, hero)
				EffectQueue.push_back(effect, 2)


func on_any_attack() -> void:
	for effect: Effect in stats.effects:
		if Effect.TriggerType.AFTER_ANY_ATTACK in effect.triggers:
			effect.context = ContextBuilder.build_default(self)
			EffectQueue.push_back(effect, 2)


func on_shop_start() -> void:
	for effect: Effect in stats.effects:
		if Effect.TriggerType.START_OF_SHOP in effect.triggers:
			effect.context = ContextBuilder.build_default(self)
			EffectQueue.push_back(effect, 2)


func on_shop_ended() -> void:
	for effect: Effect in stats.effects:
		if Effect.TriggerType.END_OF_SHOP in effect.triggers:
			effect.context = ContextBuilder.build_default(self)
			EffectQueue.push_back(effect, 2)


func _died() -> void:
	if dying:
		return
	died.emit(self)
	health_label.text = str(stats.current_hp)
	dying = true
	for effect: Effect in stats.effects:
		if Effect.TriggerType.SELF_DEATH in effect.triggers:
			effect.context = ContextBuilder.build_default(self)
			EffectQueue.push_back(effect, 2)


func _on_stats_changed() -> void:
	attack_label.text = str(stats.damage)
	health_label.text = str(stats.current_hp)
