class_name Main
extends Node2D

const ARENA_SCENE: PackedScene = preload("res://combat/arena/arena.tscn")
const SHOP_SCENE: PackedScene = preload("res://shop/shop.tscn")
const MAIN_MENU_SCENE: PackedScene = preload("res://menus/main_menu/main_menu.tscn")
const SETTINGS_MENU_SCENE: PackedScene = preload("res://menus/settings_menu/settings_menu.tscn")
const GAME_OVER_SCENE: PackedScene = preload("res://menus/game_over_screen/game_over.tscn")

@export var friendly_hero_list: HeroArray
@export var player_stats: PlayerStats
var shop: Shop
var arena: Arena
var round_number: int = 0


func _ready() -> void:
	Global.main = self
	go_to_main_menu()


func new_game_start() -> void:
	round_number = 0
	friendly_hero_list.heroes.fill(null)
	go_to_shop()


func go_to_arena() -> void:
	arena = ARENA_SCENE.instantiate()
	add_child(arena)
	arena.exit_button.pressed.connect(go_to_main_menu)
	arena.exit_button.pressed.connect(arena.queue_free)
	# TODO: connect this to make a settings menu popup
	#arena.settings_button.connect()
	arena.start_battle(round_number, friendly_hero_list)
	arena.combat_finished.connect(_on_arena_combat_finished)

func go_to_shop() -> void:
	round_number += 1
	shop = SHOP_SCENE.instantiate()
	add_child(shop)
	shop.request_friendly_hero_list.connect(_on_shop_request_heroes)
	shop.money = player_stats.money
	shop.next_round_button.pressed.connect(go_to_arena)
	shop.next_round_button.pressed.connect(shop.queue_free)


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


func go_to_game_over_screen() -> void:
	var game_over: GameOverScreen = GAME_OVER_SCENE.instantiate()
	add_child(game_over)
	game_over.game_over_label.text = "Game Over on Round " + str(round_number) + "!!"
	game_over.play_again_button.pressed.connect(new_game_start)
	game_over.exit_button.pressed.connect(get_tree().quit)


func _on_shop_request_heroes() -> void:
	shop.import_player_party(friendly_hero_list)


func _on_arena_combat_finished(player_win_flag: bool) -> void:
	if player_win_flag == false:
		player_stats.health -= 1
	if player_stats.health <= 0:
		go_to_game_over_screen()
	else:
		go_to_shop()
