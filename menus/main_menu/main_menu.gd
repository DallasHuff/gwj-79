class_name MainMenu
extends Control

@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var exit_button: Button = %ExitButton
@onready var credits_button: Button = %CreditsButton


func _ready() -> void:
	SoundManager.main_menu_music.play()
	
	if SoundManager.battle_music.is_playing():
		SoundManager.battle_music.stop()


func _on_credits_button_button_up() -> void:
	SoundManager.release_button()


func _on_exit_button_button_up() -> void:
	SoundManager.release_button()


func _on_settings_button_button_up() -> void:
	SoundManager.release_button()


func _on_play_button_button_up() -> void:
	SoundManager.release_button()


func _on_credits_button_button_down() -> void:
	SoundManager.press_button()


func _on_exit_button_button_down() -> void:
	SoundManager.press_button()


func _on_settings_button_button_down() -> void:
	SoundManager.press_button()


func _on_play_button_button_down() -> void:
	SoundManager.press_button()
