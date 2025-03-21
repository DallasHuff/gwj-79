extends Node2D

var button_presses: Array[AudioStreamPlayer2D]
var button_releases: Array[AudioStreamPlayer2D]

@onready var attack_effect: AudioStreamPlayer2D = %AttackEffect
@onready var summon_effect: AudioStreamPlayer2D = %SummonEffect
@onready var coins: AudioStreamPlayer2D = %Coins
# @onready var button_press_1: AudioStreamPlayer2D = %ButtonPress1
@onready var button_press_2: AudioStreamPlayer2D = %ButtonPress2
# @onready var button_press_3: AudioStreamPlayer2D = %ButtonPress3
# @onready var button_release_1: AudioStreamPlayer2D = %ButtonRelease1
@onready var button_release_2: AudioStreamPlayer2D = %ButtonRelease2
# @onready var button_release_3: AudioStreamPlayer2D = %ButtonRelease3
@onready var round_lost: AudioStreamPlayer2D = %RoundLost


func _ready() -> void:
	global_position = DisplayServer.screen_get_size() / 2
	# button_presses.append(button_press_1)
	button_presses.append(button_press_2)
	# button_presses.append(button_press_3)
	# button_releases.append(button_release_1)
	button_releases.append(button_release_2)
	# button_releases.append(button_release_3)


func press_button() -> void:
	button_presses[randi() % button_presses.size()].play()


func release_button() -> void:
	button_releases[randi() % button_releases.size()].play()

