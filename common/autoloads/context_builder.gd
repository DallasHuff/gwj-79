extends Node

enum ContextKey {
	EFFECT_OWNER,
	SAME_SIDE_HERO_LINE,
	OTHER_SIDE_HERO_LINE,
	TRIGGER_HERO,
	PLAYER_STATS,
}

@onready var player_stats : PlayerStats = load("res://player/player_stats.tres")


func build_default(effect_owner: Hero) -> Dictionary[ContextKey, Variant]:
	var context: Dictionary[ContextKey, Variant] = {}

	if not is_instance_valid(effect_owner):
		push_warning("Hero doesn't exist so we are not building context")
		return context

	var arena: Arena = Global.main.arena
	var friendly_line: HeroLine = arena.friendly_line
	var enemy_line: HeroLine = arena.enemy_line

	context[ContextKey.EFFECT_OWNER] = effect_owner
	context[ContextKey.SAME_SIDE_HERO_LINE] = friendly_line if effect_owner.friendly else enemy_line
	context[ContextKey.OTHER_SIDE_HERO_LINE] = friendly_line if not effect_owner.friendly else enemy_line
	context[ContextKey.PLAYER_STATS] = player_stats

	return context


func build_trigger(effect_owner: Hero, trigger: Hero) -> Dictionary[ContextKey, Variant]:
	var context := build_default(effect_owner)
	context[ContextKey.TRIGGER_HERO] = trigger
	return context


func build_from_shop(effect_owner: Hero, player_party: HeroLine) -> Dictionary[ContextKey, Variant]:
	var context: Dictionary[ContextKey, Variant] = {}

	context[ContextKey.EFFECT_OWNER] = effect_owner
	context[ContextKey.SAME_SIDE_HERO_LINE] = player_party
	context[ContextKey.OTHER_SIDE_HERO_LINE] = player_party
	context[ContextKey.PLAYER_STATS] = player_stats

	return context
