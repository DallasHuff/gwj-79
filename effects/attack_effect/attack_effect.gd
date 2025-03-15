class_name AttackEffect
extends Effect

const MOVE_UP_AMOUNT := Vector2(80, 0)

## Friendly hero
var h1 : Hero
## Enemy hero
var h2 : Hero


func execute() -> void:
	flight_time = flight_time / Settings.battle_speed
	
	var friendly_line: HeroLine = context[ContextBuilder.ContextKey.SAME_SIDE_HERO_LINE]
	var enemy_line: HeroLine = context[ContextBuilder.ContextKey.OTHER_SIDE_HERO_LINE]

	var tween := h1.get_tree().create_tween()
	tween.tween_property(h1, "global_position", h1.global_position + MOVE_UP_AMOUNT, flight_time)
	tween.parallel().tween_property(h2, "global_position", h2.global_position - MOVE_UP_AMOUNT, flight_time)
	tween.tween_callback(h1.take_damage.bind(h2).bind(h2.stats.damage))
	tween.tween_callback(h2.take_damage.bind(h1).bind(h1.stats.damage))
	tween.tween_callback(friendly_line.update_hero_positions).set_delay(0.15 / Settings.battle_speed)
	tween.parallel().tween_callback(enemy_line.update_hero_positions).set_delay(0.15 / Settings.battle_speed)
	tween.tween_callback(finish)


func get_effect_name() -> String:
	return "AttackEffect"
