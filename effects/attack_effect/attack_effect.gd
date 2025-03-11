class_name AttackEffect
extends Effect

const MOVE_UP_AMOUNT := Vector2(80, 0)

## Friendly hero
var h1 : Hero
## Enemy hero
var h2 : Hero


func execute() -> void:
	var tween := h1.get_tree().create_tween()
	tween.tween_property(h1, "global_position", h1.global_position + MOVE_UP_AMOUNT, 0.3)
	tween.parallel().tween_property(h2, "global_position", h2.global_position - MOVE_UP_AMOUNT, 0.3)
	tween.tween_callback(h1.take_damage.bind(h2.stats.damage))
	tween.tween_callback(h2.take_damage.bind(h1.stats.damage))
	tween.tween_callback(finish)


func get_effect_name() -> String:
	return "AttackEffect"
