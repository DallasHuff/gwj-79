class_name CreditsScreen
extends Control

@onready var back_button: Button = %BackButton


func _on_back_button_button_up() -> void:
	SoundManager.release_button()


func _on_back_button_button_down() -> void:
	SoundManager.press_button()
