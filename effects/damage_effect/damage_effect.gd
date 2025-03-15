class_name DamageEffect
extends Effect

const DAMAGE_SPRITE := preload("res://effects/damage_effect/damage_sprite.tscn")

@export_category("targets")
@export var aoe_target_type := AoETargetType.NONE
@export var single_target_types: Array[TargetType] = []
@export var include_self := false
@export_category("values")
@export var damage: int = 1
@export var use_effect_owner_damage := false


func execute() -> void:
	if not check_default_context():
		call_deferred("finish")
		return

	flight_time = flight_time / Settings.battle_speed

	var effect_owner: Hero = context[ContextBuilder.ContextKey.EFFECT_OWNER]
	var position := _get_owner_position()

	if use_effect_owner_damage:
		damage = effect_owner.stats.damage

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
		print("Damaging target: ", target.name)
		var dmg_sprite: Node2D = DAMAGE_SPRITE.instantiate()
		effect_owner.get_tree().root.add_child(dmg_sprite)
		dmg_sprite.global_position = position + Vector2(0, HEIGHT_ABOVE_HERO)

		var tween := effect_owner.get_tree().create_tween()
		tween.tween_property(dmg_sprite, "global_position:x", target.global_position.x, flight_time)
		var y_tween := effect_owner.get_tree().create_tween()
		y_tween.tween_property(dmg_sprite, "global_position:y", target.global_position.y + HEIGHT_ABOVE_HERO + ARC_HEIGHT, flight_time / 2).set_ease(Tween.EASE_OUT)
		y_tween.tween_property(dmg_sprite, "global_position:y", target.global_position.y + HEIGHT_ABOVE_HERO, flight_time / 2).set_ease(Tween.EASE_IN)
		tween.tween_callback(dmg_sprite.queue_free).set_delay(flight_time)
		tween.tween_callback(target.take_damage.bind(effect_owner).bind(damage)).set_delay(flight_time)
	
	await effect_owner.get_tree().create_timer(flight_time, false).timeout
	finish()


func get_effect_name() -> String:
	return "DamageEffect"
