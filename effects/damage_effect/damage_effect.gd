class_name DamageEffect
extends Effect


const DAMAGE_SPRITE := preload("res://effects/damage_effect/damage_sprite.tscn")

@export_category("targets")
@export var aoe_target_type := AoETargetType.OTHER_SIDE
@export var single_target_types : Array[TargetType] = []
@export var include_self := false
@export_category("values")
@export var damage : int = 1


func execute() -> void:
	if not check_default_context():
		call_deferred("finish")
		return

	var effect_owner: Hero = context[ContextBuilder.ContextKey.EFFECT_OWNER]
	var position := _get_owner_position()

	var targets: Array[Hero] = _get_aoe_target(aoe_target_type)
	for target_type: TargetType in single_target_types:
		targets.append(_get_target(target_type))

	for target: Hero in targets:
		if not is_instance_valid(target):
			continue
		if not include_self and target == effect_owner:
			continue
		var dmg_sprite: Node2D = DAMAGE_SPRITE.instantiate()
		effect_owner.get_tree().root.add_child(dmg_sprite)
		dmg_sprite.global_position = position + HEIGHT_ABOVE_HERO

		var tween := effect_owner.get_tree().create_tween()
		tween.tween_property(dmg_sprite, "global_position", target.global_position + HEIGHT_ABOVE_HERO, FLIGHT_TIME)
		tween.tween_callback(dmg_sprite.queue_free).set_delay(FLIGHT_TIME)
		tween.tween_callback(target.take_damage.bind(damage)).set_delay(FLIGHT_TIME)
	
	await effect_owner.get_tree().create_timer(FLIGHT_TIME, false).timeout
	finish()


func get_effect_name() -> String:
	return "SingleDamageEffect"