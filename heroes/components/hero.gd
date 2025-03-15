class_name Hero
extends Node2D

signal died(hero: Hero)
signal hero_purchased(hero: Hero)

@export var stats: HeroStats : set = _set_stats
var hero_name := "empty hero name"
var friendly := true
var dying := false
var summon := false
var line_position: int = 0

@onready var sprite: TextureRect = %HeroTexture
@onready var health_label: Label = %HealthLabel
@onready var attack_label: Label = %AttackLabel
@onready var tooltip_component: TooltipComponent = %TooltipComponent


func _set_stats(value: HeroStats) -> void:
	if not is_node_ready():
		await ready

	if value == null:
		push_error("HeroStats null for hero: ", name)

	stats = value.custom_duplicate()
	stats.changed.connect(_on_stats_changed)

	sprite.texture = stats.model
	hero_name = stats.hero_name

	tooltip_component.set_tooltip(stats.tooltip)

	_on_stats_changed()


func take_damage(dmg: int, hero: Hero = null) -> void:
	if dmg <= 0:
		return

	_check_effects_for_trigger(Effect.TriggerType.DAMAGE_TAKEN, hero)

	stats.current_hp = stats.current_hp - dmg
	if stats.current_hp <= 0:
		_died()
	_on_stats_changed()


func take_aoe_damage(dmg: int) -> void:
	take_damage(dmg)
	

func get_buffed(health_buff: int, damage_buff: int, hero: Hero = null) -> void:
	_check_effects_for_trigger(Effect.TriggerType.SELF_BUFFED, hero)

	stats.max_hp += health_buff
	stats.current_hp += health_buff
	stats.damage += damage_buff
	_on_stats_changed()

	EventsBus.hero_buffed.emit(self)


func get_healed(heal: int, hero: Hero = null) -> void:
	_check_effects_for_trigger(Effect.TriggerType.SELF_HEALED, hero)

	stats.current_hp = clampi(stats.current_hp + heal, 0, stats.max_hp)
	_on_stats_changed()

	EventsBus.hero_healed.emit(self)


func battle_start() -> void:
	_check_effects_for_trigger(Effect.TriggerType.START_OF_BATTLE)


func before_attack() -> void:
	_check_effects_for_trigger(Effect.TriggerType.BEFORE_ATTACK)


func on_hero_summoned(summoned_hero: Hero) -> void:
	_check_effects_for_trigger(Effect.TriggerType.SUMMONED, summoned_hero)


func on_hero_buffed(hero: Hero) -> void:
	if hero == self:
		return
	if hero.friendly == friendly:
		_check_effects_for_trigger(Effect.TriggerType.FRIENDLY_BUFFED, hero)
	else:
		_check_effects_for_trigger(Effect.TriggerType.ENEMY_BUFFED, hero)


func on_hero_healed(hero: Hero) -> void:
	if hero == self:
		return
	if hero.friendly == friendly:
		_check_effects_for_trigger(Effect.TriggerType.FRIENDLY_HEALED)
	else:
		_check_effects_for_trigger(Effect.TriggerType.ENEMY_HEALED)
	_check_effects_for_trigger(Effect.TriggerType.ANY_HEALED)


func on_hero_death(hero: Hero) -> void:
	if hero == self:
		return
	_check_effects_for_trigger(Effect.TriggerType.ANY_OTHER_DEATH, hero)

	if hero.friendly == friendly:
		_check_effects_for_trigger(Effect.TriggerType.FRIENDLY_DEATH, hero)
	else:
		_check_effects_for_trigger(Effect.TriggerType.ENEMY_DEATH, hero)


func on_any_attack() -> void:
	_check_effects_for_trigger(Effect.TriggerType.AFTER_ANY_ATTACK)


func on_shop_start() -> void:
	_check_effects_for_trigger(Effect.TriggerType.START_OF_SHOP)


func on_shop_ended() -> void:
	_check_effects_for_trigger(Effect.TriggerType.END_OF_SHOP)


func _check_effects_for_trigger(trigger_type: Effect.TriggerType, trigger_hero: Hero = null) -> void:
	for effect: Effect in stats.effects:
		if trigger_type in effect.triggers:
			if is_instance_valid(trigger_hero):
				effect.context = ContextBuilder.build_trigger(self, trigger_hero)
			else:
				effect.context = ContextBuilder.build_default(self)
			EffectQueue.push_back(effect, 2)

	for item: ItemData in stats.item_list:
		if is_instance_valid(item.effect) and trigger_type in item.effect.triggers:
			if is_instance_valid(trigger_hero):
				item.effect.context = ContextBuilder.build_trigger(self, trigger_hero)
			else:
				item.effect.context = ContextBuilder.build_default(self)
			EffectQueue.push_back(item.effect, 2)



func _died() -> void:
	if dying:
		return
	died.emit(self)
	health_label.text = str(stats.current_hp)
	dying = true
	_check_effects_for_trigger(Effect.TriggerType.SELF_DEATH)


func _on_stats_changed() -> void:
	attack_label.text = str(stats.damage)
	health_label.text = str(stats.current_hp)
