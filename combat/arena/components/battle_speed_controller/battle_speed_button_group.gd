class_name BattleSpeedController
extends MarginContainer

enum BattleSpeeds {
	DOUBLE,
	NORMAL,
	HALF,
}

@onready var half_button: Button = %HalfSpeedButton
@onready var normal_button: Button = %NormalSpeedButton
@onready var double_button: Button = %DoubleSpeedButton


func _ready() -> void:
	match Settings.battle_speed_indicator:
		BattleSpeeds.DOUBLE:
			double_button.button_pressed = true
		BattleSpeeds.NORMAL:
			normal_button.button_pressed = true
		BattleSpeeds.HALF:
			half_button.button_pressed = true


func _on_double_speed_button_pressed() -> void:
	Settings.battle_speed = 2
	Settings.battle_speed_indicator = BattleSpeeds.DOUBLE


func _on_normal_speed_button_pressed() -> void:
	Settings.battle_speed = 1
	Settings.battle_speed_indicator = BattleSpeeds.NORMAL


func _on_half_speed_button_pressed() -> void:
	Settings.battle_speed = 0.5
	Settings.battle_speed_indicator = BattleSpeeds.HALF
