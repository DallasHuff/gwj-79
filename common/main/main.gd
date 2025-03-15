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
	arena.connect("combat_finished", Callable(self, "go_to_shop"))


# Called via combat_finished signal from arena
func go_to_shop(player_win_flag: bool) -> void:
	if player_win_flag:
		arena.queue_free()
		player_stats.money += player_stats.income
		round_number += 1
		shop = SHOP_SCENE.instantiate()
		shop.connect("request_friendly_hero_list", Callable(self, "_on_shop_request_heroes"))
		shop.money = player_stats.money
		add_child(shop)
		shop.next_round_button.pressed.connect(go_to_arena) # Any changes to the player roster will not reflect, this loads a fresh arena scene as if just starting the game
		shop.next_round_button.pressed.connect(shop.queue_free)


func _on_shop_request_heroes() -> void:
	shop.import_player_party(test_friendly_hero_list)


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
