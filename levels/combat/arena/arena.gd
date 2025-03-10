class_name Arena
extends Node2D

signal combat_finished(hero_line: HeroLine)

const MOVE_BACK_AMOUNT := Vector2(40, 0)

@export var test_friendly_hero_list : Array[HeroStats]
@export var test_enemy_hero_list : Array[HeroStats]

@export var friendly_line : HeroLine
@export var enemy_line : HeroLine


func _ready() -> void:
	friendly_line.setup(test_friendly_hero_list)
	enemy_line.setup(test_enemy_hero_list)

	await get_tree().create_timer(2).timeout

	do_attack()


func do_attack() -> void:
	var friendly: Hero = friendly_line.front()
	var enemy: Hero = enemy_line.front()

	# Add attack and pre-attack effects to the queue
	var attack_effect := AttackEffect.new()
	attack_effect.h1 = friendly
	attack_effect.h2 = enemy
	EffectQueue.push_back(attack_effect, 1)
	enemy.before_attack()
	friendly.before_attack()

	# Move Heroes to prep for attack
	var tween := friendly.get_tree().create_tween()
	tween.tween_property(friendly, "global_position", friendly.global_position - MOVE_BACK_AMOUNT, 0.2)
	tween.parallel().tween_property(enemy, "global_position", enemy.global_position + MOVE_BACK_AMOUNT, 0.2)
	await get_tree().create_timer(0.5).timeout

	# Run effect queue
	while not EffectQueue.is_empty():
		var effect: Effect = EffectQueue.front()
		var context: Dictionary[Effect.ContextKey, Variant] = _build_context(effect)
		EffectQueue.execute_next(context)
		await effect.finished
		await get_tree().create_timer(1).timeout

	await get_tree().create_timer(0.3).timeout

	friendly_line.update_hero_positions()
	enemy_line.update_hero_positions()

	await get_tree().create_timer(0.3).timeout

	var winner_line: HeroLine = _check_winner()
	if is_instance_valid(winner_line):
		combat_finished.emit(winner_line)
		print("combat finished. winner: ", winner_line.line_info())
	else:
		do_attack()


func _build_context(effect: Effect) -> Dictionary[Effect.ContextKey, Variant]:
	var context : Dictionary[Effect.ContextKey, Variant] = {}

	if effect is AttackEffect:
		return context

	var hero: Hero = effect.effect_owner
	if not is_instance_valid(hero):
		print("Hero doesn't exist so we are not building context")
		return context
	context[Effect.ContextKey.SAME_SIDE_HERO_LINE] = friendly_line if hero.friendly else enemy_line
	context[Effect.ContextKey.OTHER_SIDE_HERO_LINE] = friendly_line if not hero.friendly else enemy_line

	return context


func _check_winner() -> HeroLine:
	if not _check_combat_finished():
		return null
	# Ties have the friendly line winning so there is always a winner
	if enemy_line.has_alive_hero():
		return enemy_line
	else:
		return friendly_line


func _check_combat_finished() -> bool:
	return not friendly_line.has_alive_hero() or not enemy_line.has_alive_hero()
