class_name Main
extends Node2D

const ARENA_SCENE: PackedScene = preload("res://combat/arena/arena.tscn")
const SHOP_SCENE: PackedScene = preload("res://shop/shop.tscn")
const MAIN_MENU_SCENE: PackedScene = preload("res://menus/main_menu/main_menu.tscn")
const SETTINGS_MENU_SCENE: PackedScene = preload("res://menus/settings_menu/settings_menu.tscn")
const GAME_OVER_SCENE: PackedScene = preload("res://menus/game_over_screen/game_over.tscn")
const ARENA_SETTINGS_SCENE: PackedScene = preload("res://menus/arena_settings_menu/arena_settings_menu.tscn")
const CREDITS_SCENE: PackedScene = preload("res://menus/credits_screen/credits_screen.tscn")

@export var player_stats: PlayerStats
var shop: Shop
var arena: Arena
var arena_settings_menu: ArenaSettingsMenu
var round_number: int = 0


func _ready() -> void:
	Global.main = self
	go_to_main_menu()
	
	EventsBus.pause_button_pressed.connect(_on_pause_button_pressed)


func new_game_start() -> void:
	round_number = 0
	# TODO: set up play stats init
	# player_stats = PlayerStats.new()
	go_to_shop()


func go_to_arena() -> void:
	arena = ARENA_SCENE.instantiate()
	add_child(arena)
	arena.exit_button.pressed.connect(go_to_main_menu)
	arena.exit_button.pressed.connect(arena.queue_free)
	arena.exit_button.pressed.connect(EffectQueue.clear)
	arena.settings_button.pressed.connect(_on_arena_settings_button_pressed)
	arena.combat_finished.connect(_on_arena_combat_finished)
	arena.start_battle(round_number, player_stats.heroes)


func go_to_shop() -> void:
	round_number += 1
	shop = SHOP_SCENE.instantiate()
	shop.player_stats = player_stats
	add_child(shop)
	shop.next_round_button.pressed.connect(go_to_arena)


func go_to_main_menu() -> void:
	var menu: MainMenu = MAIN_MENU_SCENE.instantiate()
	add_child(menu)
	menu.play_button.pressed.connect(menu.queue_free)
	menu.play_button.pressed.connect(new_game_start)
	menu.settings_button.pressed.connect(menu.queue_free)
	menu.settings_button.pressed.connect(go_to_settings_menu)
	menu.exit_button.pressed.connect(get_tree().quit)
	menu.credits_button.pressed.connect(go_to_credits_screen)


func go_to_settings_menu() -> void:
	var menu: SettingsMenu = SETTINGS_MENU_SCENE.instantiate()
	add_child(menu)
	menu.exit_button.pressed.connect(menu.queue_free)
	menu.exit_button.pressed.connect(go_to_main_menu)


func go_to_game_over_screen() -> void:
	var game_over: GameOverScreen = GAME_OVER_SCENE.instantiate()
	add_child(game_over)
	game_over.game_over_label.text = "Game Over on Round " + str(round_number) + "!!"
	game_over.play_again_button.pressed.connect(new_game_start)
	game_over.exit_button.pressed.connect(get_tree().quit)	


func go_to_credits_screen() -> void:
	var credits: CreditsScreen = CREDITS_SCENE.instantiate()
	add_child(credits)
	credits.back_button.pressed.connect(credits.queue_free)


func _on_arena_combat_finished(player_win_flag: bool) -> void:
	arena.queue_free()
	EffectQueue.clear()
	if player_win_flag == false:
		player_stats.health -= 1
	if player_stats.health <= 0:
		go_to_game_over_screen()
	else:
		go_to_shop()


func _on_arena_settings_button_pressed() -> void:
	arena_settings_menu = ARENA_SETTINGS_SCENE.instantiate()
	add_child(arena_settings_menu)
	arena_settings_menu.exit_button.pressed.connect(_on_arena_settings_exit_button_pressed.bind(arena_settings_menu))
	arena.get_tree().paused = true


func _on_arena_settings_exit_button_pressed(scene: ArenaSettingsMenu) -> void:
	scene.queue_free()
	arena.get_tree().paused = false


func _on_pause_button_pressed() -> void:
	if is_instance_valid(arena_settings_menu):
		return
	get_tree().paused = not get_tree().paused
