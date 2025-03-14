class_name SettingsMenu
extends Control

@onready var fullscreen: CheckButton = %FullscreenButton
@onready var master_volume: HSlider = %MasterVolumeSlider
@onready var sfx_volume: HSlider = %SFXVolumeSlider
@onready var music_volume: HSlider = %MusicVolumeSlider
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	fullscreen.button_pressed = Settings.full_screen
	master_volume.value = Settings.music_volume
	sfx_volume.value = Settings.sfx_volume
	music_volume.value = Settings.music_volume
	get_tree().paused = false


func _on_fullscreen_button_toggled(toggled_on:bool) -> void:
	Settings.full_screen = toggled_on
	if Settings.full_screen:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else: # not full screen
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_master_volume_slider_value_changed(value: float) -> void:
	Settings.master_volume = value
	AudioServer.set_bus_volume_db(0, convert_percentage_to_decibels(value))
	

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	Settings.sfx_volume = value
	AudioServer.set_bus_volume_db(1, convert_percentage_to_decibels(value))


func _on_music_volume_slider_value_changed(value: float) -> void:
	Settings.music = value
	AudioServer.set_bus_volume_db(2, convert_percentage_to_decibels(value))


func convert_percentage_to_decibels(percent: float) -> float:
	const _scale: float = 20.0
	const _divisor: float = 50.0
	return _scale * log(percent / _divisor) / log(10)
