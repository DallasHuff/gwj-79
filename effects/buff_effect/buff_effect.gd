class_name BuffEffect
extends Effect

const BUFF_SPRITE := preload("res://effects/buff_effect/buff_sprite.tscn")

@export_category("targets")
@export var aoe_target_type := AoETargetType.OTHER_SIDE
@export var single_target_types : Array[TargetType] = []
@export var include_self := false
@export_category("values")
@export var health_buff : int = 0
@export var attack_buff : int = 0


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
		var buff_sprite: Node2D = BUFF_SPRITE.instantiate()
		effect_owner.add_child(buff_sprite)
		buff_sprite.global_position = position + HEIGHT_ABOVE_HERO
		
		var tween := effect_owner.get_tree().create_tween()
		tween.tween_property(buff_sprite, "global_position", target.global_position + HEIGHT_ABOVE_HERO, FLIGHT_TIME)
		tween.tween_callback(buff_sprite.queue_free).set_delay(FLIGHT_TIME)
		tween.tween_callback(target.get_buffed.bind(attack_buff).bind(health_buff)).set_delay(FLIGHT_TIME)

	await effect_owner.get_tree().create_timer(FLIGHT_TIME, false).timeout
	finish()

func get_effect_name() -> String:
	return "BuffEffect"