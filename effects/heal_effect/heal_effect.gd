class_name HealEffect
extends Effect

const HEAL_SPRITE := preload("res://effects/heal_effect/heal_sprite.tscn")

@export_category("targets")
@export var aoe_target_type := AoETargetType.NONE
@export var single_target_types: Array[TargetType] = []
@export var include_self := false
@export_category("values")
@export var heal: int = 1
@export var use_effect_owner_damage_as_heal := false
@export var use_effect_owner_current_health_as_heal := false
@export var use_effect_owner_max_health_as_heal := false


func execute() -> void:
	if not check_default_context():
		call_deferred("finish")
		return

	flight_time = flight_time / Settings.battle_speed

	var effect_owner: Hero = context[ContextBuilder.ContextKey.EFFECT_OWNER]
	var position := _get_owner_position()

	if use_effect_owner_damage_as_heal:
		heal = effect_owner.stats.damage
	elif use_effect_owner_current_health_as_heal:
		heal = effect_owner.stats.current_hp
	elif use_effect_owner_max_health_as_heal:
		heal = effect_owner.stats.max_hp

	var targets: Array[Hero] = _get_aoe_target(aoe_target_type)
	for target_type: TargetType in single_target_types:
		targets.append(_get_target(target_type))
	targets = _clean_targets_array(targets)

	for target: Hero in targets:
		if not is_instance_valid(target):
			continue
		if not include_self and target == effect_owner:
			continue
		if target.dying:
			continue
		print("Doing ", heal, " healing to target: ", target.name)
		var heal_sprite: Node2D = HEAL_SPRITE.instantiate()
		effect_owner.add_child(heal_sprite)
		heal_sprite.global_position = position + Vector2(0, HEIGHT_ABOVE_HERO)

		var tween := effect_owner.get_tree().create_tween()
		tween.tween_property(heal_sprite, "global_position:x", target.global_position.x, flight_time)
		var y_tween := effect_owner.get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		y_tween.tween_property(heal_sprite, "global_position:y", target.global_position.y + HEIGHT_ABOVE_HERO + ARC_HEIGHT, flight_time / 2).set_ease(Tween.EASE_OUT)
		y_tween.tween_property(heal_sprite, "global_position:y", target.global_position.y + HEIGHT_ABOVE_HERO, flight_time / 2).set_ease(Tween.EASE_IN)
		tween.tween_callback(heal_sprite.queue_free).set_delay(flight_time / 2)
		tween.tween_callback(target.get_healed.bind(effect_owner).bind(heal))
	
	finish()


func get_effect_name() -> String:
	return "HealEffect"
