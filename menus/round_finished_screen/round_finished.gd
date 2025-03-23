class_name RoundFinishedScreen
extends Control

signal next_button_pressed

const COIN_SPRITE := preload("res://effects/economy_effect/economy_sprite.tscn")
const DMG_SPRITE := preload("res://effects/damage_effect/damage_sprite.tscn")

@onready var canvas: CanvasLayer = %CanvasLayer
@onready var next_button: Button = %NextButton
@onready var round_outcome_label: Label = %RoundOutcomeLabel
@onready var rounds_to_finish: Label = %RoundsToFinishLabel
@onready var previous_money: Label = %PreviousMoneyLabel
@onready var new_money: Label = %NewMoneyLabel
@onready var income_label: Label = %IncomeLabel
@onready var previous_health: Label = %PreviousHealthLabel
@onready var new_health: Label = %NewHealthLabel
@onready var level_label: Label = %LevelUpLabel


func setup(round_won: bool, player_stats: PlayerStats) -> void:
	player_stats.round_number += 1
	previous_health.text = str(player_stats.health)
	new_health.text = str(player_stats.health)
	income_label.text = "Income: " + str(player_stats.income)
	previous_money.text = str(player_stats.money)
	new_money.text = str(player_stats.money)
	player_stats.money += player_stats.income
	if player_stats.round_number % 2 != 0:
		player_stats.level += 1
		level_label.show()
	if round_won:
		player_stats.rounds_won += 1
		round_outcome_label.text = "Round Won!"
		rounds_to_finish.text = str(player_stats.rounds_required_to_win - player_stats.rounds_won) + " more wins needed"
	else:
		rounds_to_finish.text = str(player_stats.rounds_required_to_win - player_stats.rounds_won) + " more wins needed"
		round_outcome_label.text = "Round Lost!"
		player_stats.health -= 1
		# SoundManager.round_lost.play()
		await get_tree().create_timer(0.5).timeout
		play_heart_animation()
		await get_tree().create_timer(0.7).timeout

	await get_tree().create_timer(0.2).timeout

	play_coin_animations(player_stats)


func play_coin_animations(player_stats: PlayerStats) -> void:
	for i in range(player_stats.income):
		var coin_sprite: Node2D = COIN_SPRITE.instantiate()
		canvas.add_child(coin_sprite)
		coin_sprite.global_position = previous_money.global_position + Vector2(50, 25)
		coin_sprite.scale *= 0.5

		var tween := create_tween()
		tween.tween_property(coin_sprite, "global_position:x", new_money.global_position.x - 40, 0.8)
		tween.tween_callback(add_money)
		tween.tween_callback(coin_sprite.queue_free)
		tween.tween_callback(SoundManager.coins.play)
		await get_tree().create_timer(0.3).timeout


func play_heart_animation() -> void:
	var dmg_sprite: Node2D = DMG_SPRITE.instantiate()
	canvas.add_child(dmg_sprite)
	dmg_sprite.global_position = previous_health.global_position + Vector2(50, 25)
	dmg_sprite.scale *= 0.7

	var tween := create_tween()
	tween.tween_property(dmg_sprite, "global_position:x", new_health.global_position.x - 40, 0.7)
	tween.tween_callback(dmg_sprite.queue_free)
	await tween.finished
	new_health.text = str(int(new_health.text) - 1)


func add_money() -> void:
	new_money.text = str(int(new_money.text) + 1)


func _on_next_button_pressed() -> void:
	next_button_pressed.emit()


func _on_next_button_button_up() -> void:
	SoundManager.release_button()


func _on_next_button_button_down() -> void:
	SoundManager.press_button()
