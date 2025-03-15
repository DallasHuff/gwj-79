class_name Main
extends Node2D

const ARENA_SCENE: PackedScene = preload("res://combat/arena/arena.tscn")
const SHOP_SCENE: PackedScene = preload("res://shop/shop.tscn")
const MAIN_MENU_SCENE: PackedScene = preload("res://menus/main_menu/main_menu.tscn")
const SETTINGS_MENU_SCENE: PackedScene = preload("res://menus/settings_menu/settings_menu.tscn")

# TODO: remove this test code when we get the shop setup
@export var test_friendly_hero_list: HeroArray
@export var player_stats: PlayerStats
var shop: Shop
var arena: Arena
var round_number: int = 0


func _ready() -> void:
	Global.main = self
	go_to_main_menu()


func go_to_arena() -> void:
	arena = ARENA_SCENE.instantiate()
	add_child(arena)
	arena.exit_button.pressed.connect(go_to_main_menu)
	arena.exit_button.pressed.connect(arena.queue_free)
	# TODO: connect this to make a settings menu popup
	#arena.settings_button.connect()
	arena.start_battle(round_number, test_friendly_hero_list)


func go_to_shop() -> void:
	player_stats.money += player_stats.income
	round_number += 1


func go_to_main_menu() -> void:
	var menu: MainMenu = MAIN_MENU_SCENE.instantiate()
	add_child(menu)
	menu.play_button.pressed.connect(menu.queue_free)
	menu.play_button.pressed.connect(go_to_arena)
	menu.settings_button.pressed.connect(menu.queue_free)
	menu.settings_button.pressed.connect(go_to_settings_menu)
	menu.exit_button.pressed.connect(get_tree().quit)


func go_to_settings_menu() -> void:
	var menu: SettingsMenu = SETTINGS_MENU_SCENE.instantiate()
	add_child(menu)
	menu.exit_button.pressed.connect(menu.queue_free)
	menu.exit_button.pressed.connect(go_to_main_menu)
