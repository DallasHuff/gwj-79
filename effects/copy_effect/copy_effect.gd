class_name CopyEffect
extends Effect

const COPY_EFFECT_SPRITE: PackedScene = preload("res://effects/copy_effect/copy_effect_sprite.tscn")

@export_category("target")
@export var single_target_type := TargetType.ONE_AHEAD


func execute() -> void:
	if not check_default_context():
		call_deferred("finish")
		return

	flight_time = flight_time / Settings.battle_speed

	var effect_owner: Hero = context[ContextBuilder.ContextKey.EFFECT_OWNER]
	var target: Hero = _get_target(single_target_type)

	if not is_instance_valid(target):
		call_deferred("finish")
		return
	if target.dying or effect_owner.dying:
		call_deferred("finish")
		return
	for effect: Effect in target.stats.effects:
		effect_owner.stats.effects.append(effect.duplicate())

	var target_line: HeroLine = context[ContextBuilder.ContextKey.SAME_SIDE_HERO_LINE] \
		if effect_owner.friendly == target.friendly else context[ContextBuilder.ContextKey.OTHER_SIDE_HERO_LINE]

	var copy_sprite: Node2D = COPY_EFFECT_SPRITE.instantiate()
	effect_owner.get_tree().root.add_child(copy_sprite)
	copy_sprite.global_position = target_line.get_global_from_line_pos(target.line_position) + Vector2(0, HEIGHT_ABOVE_HERO)


	var tween := effect_owner.get_tree().create_tween()
	tween.tween_property(copy_sprite, "global_position:x", effect_owner.global_position.x, flight_time)
	var y_tween := effect_owner.get_tree().create_tween()
	y_tween.tween_property(copy_sprite, "global_position:y", target.global_position.y + HEIGHT_ABOVE_HERO + ARC_HEIGHT, flight_time / 2).set_ease(Tween.EASE_OUT)
	y_tween.tween_property(copy_sprite, "global_position:y", target.global_position.y + HEIGHT_ABOVE_HERO, flight_time / 2).set_ease(Tween.EASE_IN)
	tween.tween_callback(copy_sprite.queue_free).set_delay(flight_time)
	tween.tween_callback(finish)


func get_effect_name() -> String:
	return "CopyEffect"
