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
var round_number: int = 1


func _ready() -> void:
	Global.main = self
	go_to_settings_menu()


func go_to_arena() -> void:
	for child: Node in get_children():
		child.queue_free()
	arena = ARENA_SCENE.instantiate()
	add_child(arena)
	arena.start_battle(round_number, test_friendly_hero_list)
	round_number += 1


func go_to_shop() -> void:
	for child: Node in get_children():
		child.queue_free()
	player_stats.money += player_stats.income


func go_to_main_menu() -> void:
	for child: Node in get_children():
		child.queue_free()
	var menu: MainMenu = MAIN_MENU_SCENE.instantiate()
	add_child(menu)
	menu.exit_button.pressed.connect(get_tree().quit)


func go_to_settings_menu() -> void:
	for child: Node in get_children():
		child.queue_free()
	var menu: SettingsMenu = SETTINGS_MENU_SCENE.instantiate()
	add_child(menu)
	menu.exit_button.pressed.connect(go_to_main_menu)
