class_name Main
extends Node2D

const ARENA_SCENE := preload("res://combat/arena/arena.tscn")
const SHOP_SCENE := preload("res://shop/shop.tscn")
const MAIN_MENU_SCENE := preload("res://menus/main_menu/main_menu.tscn")
const SETTINGS_MENU_SCENE := preload("res://menus/settings_menu/settings_menu.tscn")
const GAME_OVER_SCENE := preload("res://menus/game_over_screen/game_over.tscn")
const ARENA_SETTINGS_SCENE := preload("res://menus/arena_settings_menu/arena_settings_menu.tscn")
const CREDITS_SCENE := preload("res://menus/credits_screen/credits_screen.tscn")
const ROUND_FINISHED_SCENE := preload("res://menus/round_finished_screen/round_finished.tscn")

@export var player_stats: PlayerStats
var shop: Shop
var arena: Arena
var arena_settings_menu: ArenaSettingsMenu


func _ready() -> void:
	Global.main = self
	go_to_main_menu()
	
	EventsBus.pause_button_pressed.connect(_on_pause_button_pressed)
	EventsBus.player_effect_finished.connect(_on_player_effect_finished)
	EventsBus.hero_died.connect(_on_hero_died)


func new_game_start() -> void:
	player_stats.setup_for_new_game()
	go_to_shop()


# Arena
func go_to_arena() -> void:
	arena = ARENA_SCENE.instantiate()
	add_child(arena)
	arena.exit_button.pressed.connect(go_to_main_menu)
	arena.exit_button.pressed.connect(arena.queue_free)
	arena.exit_button.pressed.connect(EffectQueue.clear)
	arena.settings_button.pressed.connect(_on_arena_settings_button_pressed)
	arena.combat_finished.connect(go_to_round_finished_screen)
	arena.start_battle(player_stats)


func _on_arena_settings_button_pressed() -> void:
	arena_settings_menu = ARENA_SETTINGS_SCENE.instantiate()
	add_child(arena_settings_menu)
	arena_settings_menu.exit_button.pressed.connect(_on_arena_settings_exit_button_pressed.bind(arena_settings_menu))
	arena.get_tree().paused = true


func _on_arena_settings_exit_button_pressed(scene: ArenaSettingsMenu) -> void:
	scene.queue_free()
	arena.get_tree().paused = false


# Round / Game Finished
func go_to_round_finished_screen(round_win: bool) -> void:
	arena.queue_free()
	EffectQueue.clear()
	var round_finished: RoundFinishedScreen = ROUND_FINISHED_SCENE.instantiate()
	round_finished.next_button_pressed.connect(after_round_finished)
	round_finished.next_button_pressed.connect(round_finished.queue_free)
	add_child(round_finished)
	round_finished.setup(round_win, player_stats)


func after_round_finished() -> void:
	# Lose or Win
	if player_stats.health <= 0 or player_stats.rounds_won >= player_stats.rounds_required_to_win:
		go_to_game_over_screen()
	else:
		go_to_shop()


func go_to_game_over_screen() -> void:
	var game_over: GameOverScreen = GAME_OVER_SCENE.instantiate()
	game_over.player_stats = player_stats
	add_child(game_over)
	game_over.play_again_button.pressed.connect(new_game_start)
	game_over.exit_button.pressed.connect(get_tree().quit)


# Shop
func go_to_shop() -> void:
	shop = SHOP_SCENE.instantiate()
	shop.player_stats = player_stats
	add_child(shop)
	shop.next_round_requested.connect(shop.queue_free)
	shop.next_round_requested.connect(go_to_arena)


# Main Menu
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


func go_to_credits_screen() -> void:
	var credits: CreditsScreen = CREDITS_SCENE.instantiate()
	add_child(credits)
	credits.back_button.pressed.connect(credits.queue_free)


# EventsBus signals
func _on_pause_button_pressed() -> void:
	if is_instance_valid(arena_settings_menu):
		return
	get_tree().paused = not get_tree().paused


func _on_player_effect_finished(eff: Effect) -> void:
	if eff is AttackEffect:
		return
	player_stats.effects_triggered += 1


func _on_hero_died(hero: Hero) -> void:
	if not hero.friendly:
		player_stats.units_slain += 1
