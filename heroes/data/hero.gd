@tool
class_name Hero
extends Node2D

signal died

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

	for effect: Effect in stats.effects:
		effect.effect_owner = self
		effect.owner_line_position = line_position

	sprite.texture = stats.model
	hero_name = stats.hero_name

	_on_stats_changed()


func take_damage(dmg: int) -> void:
	if dmg <= 0:
		return

	for effect: Effect in stats.effects:
		if Effect.TriggerType.DAMAGE_TAKEN in effect.triggers:
			EffectQueue.push_back(effect, 2)

	stats.current_hp = stats.current_hp - dmg
	if stats.current_hp <= 0:
		_died()
	_on_stats_changed()


func take_aoe_damage(dmg: int) -> void:
	take_damage(dmg)
	

func get_buffed(health_buff: int, damage_buff: int) -> void:
	stats.max_hp += health_buff
	stats.current_hp += health_buff
	stats.damage += damage_buff
	_on_stats_changed()


func change_position(pos: Vector2, line_pos: int) -> void:
	line_position = line_pos
	for effect: Effect in stats.effects:
		effect.position = pos
		effect.owner_line_position = line_pos


func before_attack() -> void:
	for effect: Effect in stats.effects:
		if Effect.TriggerType.BEFORE_ATTACK in effect.triggers:
			EffectQueue.push_back(effect, 2)


func _died() -> void:
	if dying:
		return
	died.emit(self)
	health_label.text = str(stats.current_hp)
	dying = true
	for effect: Effect in stats.effects:
		if Effect.TriggerType.DEATH in effect.triggers:
			EffectQueue.push_back(effect, 2)


func _on_stats_changed() -> void:
	attack_label.text = str(stats.damage)
	health_label.text = str(stats.current_hp)
