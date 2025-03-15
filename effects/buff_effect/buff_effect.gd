class_name BuffEffect
extends Effect

const BUFF_SPRITE := preload("res://effects/buff_effect/buff_sprite.tscn")

@export_category("targets")
@export var aoe_target_type := AoETargetType.NONE
@export var single_target_types: Array[TargetType] = []
@export var include_self := false
@export_category("values")
@export var health_buff: int = 0
@export var attack_buff: int = 0


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
		print("Buffing target: ", target.name)
		var buff_sprite: Node2D = BUFF_SPRITE.instantiate()
		effect_owner.add_child(buff_sprite)
		buff_sprite.global_position = position + Vector2(0, HEIGHT_ABOVE_HERO)
		
		var tween := effect_owner.get_tree().create_tween()
		tween.tween_property(buff_sprite, "global_position:x", target.global_position.x, flight_time)
		var y_tween := effect_owner.get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		y_tween.tween_property(buff_sprite, "global_position:y", target.global_position.y + HEIGHT_ABOVE_HERO + ARC_HEIGHT, flight_time / 2).set_ease(Tween.EASE_OUT)
		y_tween.tween_property(buff_sprite, "global_position:y", target.global_position.y + HEIGHT_ABOVE_HERO, flight_time / 2).set_ease(Tween.EASE_IN)
		tween.tween_callback(buff_sprite.queue_free).set_delay(flight_time)
		tween.tween_callback(target.get_buffed.bind(effect_owner).bind(attack_buff).bind(health_buff)).set_delay(flight_time)

	await effect_owner.get_tree().create_timer(flight_time, false).timeout
	finish()

func get_effect_name() -> String:
	return "BuffEffect"
