class_name Main
extends Node2D

signal transitioned_in

const ARENA_SCENE := preload("res://combat/arena/arena.tscn")
const SHOP_SCENE := preload("res://shop/shop.tscn")
const MAIN_MENU_SCENE := preload("res://menus/main_menu/main_menu.tscn")
const SETTINGS_MENU_SCENE := preload("res://menus/settings_menu/settings_menu.tscn")
const GAME_OVER_SCENE := preload("res://menus/game_over_screen/game_over.tscn")
const ARENA_SETTINGS_SCENE := preload("res://menus/arena_settings_menu/arena_settings_menu.tscn")
const CREDITS_SCENE := preload("res://menus/credits_screen/credits_screen.tscn")
const ROUND_FINISHED_SCENE := preload("res://menus/round_finished_screen/round_finished.tscn")

@export var player_stats: PlayerStats
var menu: MainMenu
var settings_menu: SettingsMenu
var credits: CreditsScreen
var shop: Shop
var arena: Arena
var arena_settings_menu: ArenaSettingsMenu
var game_over: GameOverScreen
var start_time: float

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	Global.main = self
	animation_player.play("out")
	startup()
	
	EventsBus.pause_button_pressed.connect(_on_pause_button_pressed)
	EventsBus.player_effect_finished.connect(_on_player_effect_finished)
	EventsBus.hero_died.connect(_on_hero_died)


func new_game_start() -> void:
	player_stats.setup_for_new_game()
	start_time = Time.get_unix_time_from_system()
	go_to_shop()


# It's just go_to_main_menu() but without the await
func startup() -> void:
	menu = MAIN_MENU_SCENE.instantiate()
	add_child(menu)
	menu.play_button.pressed.connect(delayed_queue_free.bind(menu))
	menu.play_button.pressed.connect(new_game_start)
	menu.settings_button.pressed.connect(delayed_queue_free.bind(menu))
	menu.settings_button.pressed.connect(go_to_settings_menu)
	menu.exit_button.pressed.connect(get_tree().quit)
	menu.credits_button.pressed.connect(go_to_credits_screen)
	menu.credits_button.pressed.connect(delayed_queue_free.bind(menu))


# Arena
func go_to_arena() -> void:
	await transitioned_in
	if is_instance_valid(arena):
		return
	arena = ARENA_SCENE.instantiate()
	add_child(arena)
	arena.exit_button.pressed.connect(go_to_main_menu)
	arena.exit_button.pressed.connect(delayed_queue_free.bind(arena))
	arena.exit_button.pressed.connect(EffectQueue.clear)
	arena.settings_button.pressed.connect(_on_arena_settings_button_pressed)
	arena.combat_finished.connect(go_to_round_finished_screen)
	arena.combat_finished.connect(func(_b:bool) -> void: delayed_queue_free(arena))
	arena.start_battle(player_stats)


func _on_arena_settings_button_pressed() -> void:
	if is_instance_valid(arena_settings_menu):
		return
	arena_settings_menu = ARENA_SETTINGS_SCENE.instantiate()
	add_child(arena_settings_menu)
	arena_settings_menu.exit_button.pressed.connect(_on_arena_settings_exit_button_pressed.bind(arena_settings_menu))
	arena.get_tree().paused = true


func _on_arena_settings_exit_button_pressed(scene: ArenaSettingsMenu) -> void:
	scene.queue_free()
	arena.get_tree().paused = false


# Round / Game Finished
func go_to_round_finished_screen(round_win: bool) -> void:
	await transitioned_in
	EffectQueue.clear()
	var round_finished: RoundFinishedScreen = ROUND_FINISHED_SCENE.instantiate()
	round_finished.next_button_pressed.connect(after_round_finished)
	round_finished.next_button_pressed.connect(delayed_queue_free.bind(round_finished))
	add_child(round_finished)
	round_finished.setup(round_win, player_stats)


func after_round_finished() -> void:
	# Lose or Win
	if player_stats.health <= 0 or player_stats.rounds_won >= player_stats.rounds_required_to_win:
		go_to_game_over_screen()
	else:
		go_to_shop()


func go_to_game_over_screen() -> void:
	await transitioned_in
	if is_instance_valid(game_over):
		return
	game_over = GAME_OVER_SCENE.instantiate()
	game_over.player_stats = player_stats
	add_child(game_over)
	game_over.play_again_button.pressed.connect(delayed_queue_free.bind(game_over))
	game_over.play_again_button.pressed.connect(go_to_main_menu)
	game_over.exit_button.pressed.connect(get_tree().quit)


# Shop
func go_to_shop() -> void:
	await transitioned_in
	if is_instance_valid(shop):
		return
	shop = SHOP_SCENE.instantiate()
	shop.player_stats = player_stats
	add_child(shop)
	shop.next_round_requested.connect(delayed_queue_free.bind(shop))
	shop.next_round_requested.connect(go_to_arena)


# Main Menu
func go_to_main_menu() -> void:
	await transitioned_in
	if is_instance_valid(menu):
		return
	menu = MAIN_MENU_SCENE.instantiate()
	add_child(menu)
	menu.play_button.pressed.connect(delayed_queue_free.bind(menu))
	menu.play_button.pressed.connect(new_game_start)
	menu.settings_button.pressed.connect(delayed_queue_free.bind(menu))
	menu.settings_button.pressed.connect(go_to_settings_menu)
	menu.exit_button.pressed.connect(get_tree().quit)
	menu.credits_button.pressed.connect(go_to_credits_screen)
	menu.credits_button.pressed.connect(delayed_queue_free.bind(menu))


func go_to_settings_menu() -> void:
	await transitioned_in
	if is_instance_valid(settings_menu):
		return
	settings_menu = SETTINGS_MENU_SCENE.instantiate()
	add_child(settings_menu)
	settings_menu.exit_button.pressed.connect(delayed_queue_free.bind(settings_menu))
	settings_menu.exit_button.pressed.connect(go_to_main_menu)


func go_to_credits_screen() -> void:
	await transitioned_in
	if is_instance_valid(credits):
		return
	credits = CREDITS_SCENE.instantiate()
	add_child(credits)
	credits.back_button.pressed.connect(delayed_queue_free.bind(credits))
	credits.back_button.pressed.connect(go_to_main_menu)


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


# Loading Animation
func in_finished() -> void:
	transitioned_in.emit()
	animation_player.play("out")


func delayed_queue_free(scene: Node) -> void:
	animation_player.play("in")
	await transitioned_in
	scene.queue_free()
