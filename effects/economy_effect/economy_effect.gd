class_name EconomyEffect
extends Effect

const COIN_SPRITE := preload("res://effects/economy_effect/economy_sprite.tscn")

@export_category("values")
@export var money_change_amount : int = 0
@export var income_change_amount : int = 0


func execute() -> void:
	flight_time = flight_time / Settings.battle_speed

	var effect_owner: Hero = context[ContextBuilder.ContextKey.EFFECT_OWNER]

	var position := _get_owner_position() + Vector2(0, HEIGHT_ABOVE_HERO)

	var coin_sprite: Node2D = COIN_SPRITE.instantiate()
	effect_owner.add_child(coin_sprite)
	coin_sprite.global_position = position + Vector2(0, HEIGHT_ABOVE_HERO)

	var tween: Tween = effect_owner.create_tween()
	tween.tween_property(coin_sprite, "global_position:y", position.y + ARC_HEIGHT, flight_time / 2).set_ease(Tween.EASE_OUT)
	tween.tween_property(coin_sprite, "global_position:y", position.y, flight_time / 2).set_ease(Tween.EASE_OUT)
	tween.tween_callback(coin_sprite.queue_free).set_delay(flight_time / 2)
	tween.tween_callback(finish)
	if effect_owner.friendly:
		tween.tween_callback(_add_values)

func _add_values() -> void:
	var player_stats: PlayerStats = context[ContextBuilder.ContextKey.PLAYER_STATS]
	player_stats.money += money_change_amount
	player_stats.income += income_change_amount
	EventsBus.player_stats_changed.emit(player_stats)
