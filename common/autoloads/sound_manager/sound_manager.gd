extends Node2D

var button_presses: Array[AudioStreamPlayer2D]
var button_releases: Array[AudioStreamPlayer2D]

@onready var attack_effect: AudioStreamPlayer2D = %AttackEffect
@onready var heal_effect: AudioStreamPlayer2D = %HealEffect
@onready var battle_music: AudioStreamPlayer2D = %BattleMusic
@onready var main_menu_music: AudioStreamPlayer2D = %MainMenuMusic
@onready var summon_effect: AudioStreamPlayer2D = %SummonEffect
@onready var buff_effect: AudioStreamPlayer2D = %BuffEffect
@onready var coins: AudioStreamPlayer2D = %Coins
@onready var button_press_4: AudioStreamPlayer2D = %ButtonPress4
@onready var button_press_2: AudioStreamPlayer2D = %ButtonPress2
@onready var button_press_3: AudioStreamPlayer2D = %ButtonPress3
@onready var button_release_4: AudioStreamPlayer2D = %ButtonRelease4
@onready var button_release_2: AudioStreamPlayer2D = %ButtonRelease2
@onready var button_release_3: AudioStreamPlayer2D = %ButtonRelease3
@onready var game_over: AudioStreamPlayer2D = %GameOver
@onready var victory: AudioStreamPlayer2D = %Victory


func _ready() -> void:
	global_position = DisplayServer.screen_get_size() / 2
	button_presses.append(button_press_4)
	button_presses.append(button_press_2)
	button_presses.append(button_press_3)
	button_releases.append(button_release_4)
	button_releases.append(button_release_2)
	button_releases.append(button_release_3)


func press_button() -> void:
	button_presses[randi() % button_presses.size()].play()


func release_button() -> void:
	button_releases[randi() % button_releases.size()].play()
