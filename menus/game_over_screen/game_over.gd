class_name GameOverScreen
extends Control

var player_stats: PlayerStats

@onready var game_result_label: Label = %GameResult
@onready var money_label: Label = %MoneyLabel
@onready var health_label: Label = %HealthLabel
@onready var rounds_label: Label = %RoundsLabel
@onready var reroll_label: Label = %RerollLabel
@onready var units_slain_label: Label = %UnitsSlainLabel
@onready var effects_triggered_label: Label = %EffectsTriggeredLabel
@onready var minutes_label: Label = %MinutesLabel
@onready var seconds_label: Label = %SecondsLabel
@onready var play_again_button: Button = %PlayAgainButton
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	if not is_instance_valid(player_stats):
		return

	if player_stats.health <= 0:
		game_result_label.text = "run lost on Round " + str(player_stats.round_number) + "!!"
	else:
		game_result_label.text = "run won on Round " + str(player_stats.round_number) + "!!"

	money_label.text = str(player_stats.money)
	health_label.text = str(player_stats.health)
	rounds_label.text = "Rounds won: " + str(player_stats.rounds_won)
	reroll_label.text = "Times rerolled: " + str(player_stats.times_rerolled)
	units_slain_label.text = "Enemies Slain: " + str(player_stats.units_slain)
	effects_triggered_label.text = "Effects Triggered: " + str(player_stats.effects_triggered)

	var time_spent: float = Global.main.start_time - Time.get_unix_time_from_system()
	var minutes: int = floori(time_spent / 60.0)
	var seconds: int = floori(time_spent - (60.0 * float(minutes)))
	minutes_label.text = str(minutes)
	seconds_label.text = str(seconds)


func _on_play_again_button_pressed() -> void:
	queue_free()


func _on_exit_button_pressed() -> void:
	queue_free()
