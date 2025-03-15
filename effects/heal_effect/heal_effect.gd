class_name HealEffect
extends Effect

const HEAL_SPRITE := preload("res://effects/heal_effect/heal_sprite.tscn")

@export_category("targets")
@export var aoe_target_type := AoETargetType.NONE
@export var single_target_types: Array[TargetType] = []
@export var include_self := false
@export_category("values")
@export var heal: int = 1


func execute() -> void:
	if not check_default_context():
		call_deferred("finish")
		return

	flight_time = flight_time / Settings.battle_speed

	var effect_owner: Hero = context[ContextBuilder.ContextKey.EFFECT_OWNER]
	var position := _get_owner_position()

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
		print("Healing target: ", target.name)
		var heal_sprite: Node2D = HEAL_SPRITE.instantiate()
		effect_owner.get_tree().root.add_child(heal_sprite)
		heal_sprite.global_position = position + HEIGHT_ABOVE_HERO

		var tween := effect_owner.get_tree().create_tween()
		tween.tween_property(heal_sprite, "global_position", target.global_position + HEIGHT_ABOVE_HERO, flight_time)
		tween.tween_callback(heal_sprite.queue_free).set_delay(flight_time)
		tween.tween_callback(target.get_healed.bind(effect_owner).bind(heal)).set_delay(flight_time)
	
	await effect_owner.get_tree().create_timer(flight_time, false).timeout
	finish()


func get_effect_name() -> String:
	return "HealEffect"
