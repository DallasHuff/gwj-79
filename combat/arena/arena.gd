class_name Arena
extends Node2D

signal combat_finished(player_win_flag: bool)

const MOVE_BACK_AMOUNT: float = 40
const LINE_POSITION_DIFF: float = 1000

@onready var friendly_line: HeroLine = %FriendlyHeroLine
@onready var enemy_line: HeroLine = %EnemyHeroLine
@onready var enemy_manager: EnemyManager = %EnemyManager
@onready var exit_button: Button = %ExitButton
@onready var settings_button: Button = %SettingsButton
@onready var pause_button: Button = %PauseButton
@onready var round_label: Label = %RoundLabel
@onready var player_health_label: Label = %PlayerHealthLabel
@onready var money_label: Label = %MoneyLabel


func _ready() -> void:
	EventsBus.hero_summoned.connect(_on_hero_summoned)
	EventsBus.hero_buffed.connect(_on_hero_buffed)
	EventsBus.hero_died.connect(_on_hero_died)
	EventsBus.attack_completed.connect(_on_attack_completed)
	EventsBus.hero_healed.connect(_on_hero_healed)
	EventsBus.player_stats_changed.connect(_on_player_stats_changed)

	friendly_line.position.x = friendly_line.position.x - LINE_POSITION_DIFF
	enemy_line.position.x = enemy_line.position.x + LINE_POSITION_DIFF


func start_battle(player_stats: PlayerStats) -> void:
	_on_player_stats_changed(player_stats)

	friendly_line.setup(player_stats.heroes)
	enemy_line.setup(enemy_manager.get_list_for_round(player_stats.round_number))

	# Animate the heroes running in
	var tween := get_tree().create_tween()
	tween.tween_property(friendly_line, "position:x", friendly_line.position.x + LINE_POSITION_DIFF, 2.7 / Settings.battle_speed)
	tween.parallel().tween_property(enemy_line, "position:x", enemy_line.position.x - LINE_POSITION_DIFF, 2.7 / Settings.battle_speed)
	friendly_line.make_heroes_run()
	enemy_line.make_heroes_run()

	await tween.finished
	friendly_line.update_hero_positions()
	enemy_line.update_hero_positions()
	await get_tree().create_timer(0.7 / Settings.battle_speed, false).timeout

	for hero: Hero in friendly_line.hero_list:
		if is_instance_valid(hero):
			hero.battle_start()
	for hero: Hero in enemy_line.hero_list:
		if is_instance_valid(hero):
			hero.battle_start()
	
	# Run effect queue for battle_start effects
	while not EffectQueue.is_empty():
		var effect: Effect = EffectQueue.front()
		print("Executing effect: ", effect.get_effect_name())
		EffectQueue.execute_next()
		await effect.finished
		await get_tree().create_timer(0.5 / Settings.battle_speed, false).timeout

	do_attack()


func do_attack() -> void:
	var friendly: Hero = friendly_line.front()
	var enemy: Hero = enemy_line.front()

	# Add attack and pre-attack effects to the queue
	var attack_effect := AttackEffect.new()
	attack_effect.h1 = friendly
	attack_effect.h2 = enemy
	attack_effect.context = ContextBuilder.build_default(friendly)
	EffectQueue.push_back(attack_effect, 1)
	enemy.before_attack()
	friendly.before_attack()

	# Move Heroes to prep for attack
	var tween := friendly.get_tree().create_tween()
	tween.tween_property(friendly, "global_position:x", friendly.global_position.x - MOVE_BACK_AMOUNT, 0.2 / Settings.battle_speed)
	tween.parallel().tween_property(enemy, "global_position:x", enemy.global_position.x + MOVE_BACK_AMOUNT, 0.2 / Settings.battle_speed)
	await tween.finished

	# Run effect queue
	while not EffectQueue.is_empty():
		var effect: Effect = EffectQueue.front()
		print("Executing effect: ", effect.get_effect_name())
		EffectQueue.execute_next()
		await effect.finished
		await get_tree().create_timer(0.5 / Settings.battle_speed, false).timeout
		if effect is AttackEffect:
			if effect.h1.dying and not effect.h2.dying:
				effect.h2.on_killed_enemy()
			elif effect.h2.dying and not effect.h1.dying:
				effect.h1.on_killed_enemy()			

	if _check_combat_finished():
		_check_winner()
	else:
		do_attack()


func _check_winner() -> void:
	# Ties have the friendly line winning so there is always a winner
	var player_win := true
	if enemy_line.has_alive_hero():
		player_win = false
	
	print("Combat finished. Did the player win?: ", player_win)
	print(friendly_line.line_info())
	print(enemy_line.line_info())
	combat_finished.emit(player_win)


func _check_combat_finished() -> bool:
	return not friendly_line.has_alive_hero() or not enemy_line.has_alive_hero()


func _on_hero_healed(healed_hero: Hero) -> void:
	for hero: Hero in friendly_line.hero_list:
		if is_instance_valid(hero):
			hero.on_hero_healed(healed_hero)
	for hero: Hero in enemy_line.hero_list:
		if is_instance_valid(hero):
			hero.on_hero_healed(healed_hero)


func _on_hero_summoned(summon: Hero) -> void:
	for hero: Hero in friendly_line.hero_list:
		if is_instance_valid(hero):
			hero.on_hero_summoned(summon)
	for hero: Hero in enemy_line.hero_list:
		if is_instance_valid(hero):
			hero.on_hero_summoned(summon)


func _on_hero_buffed(buffed_hero: Hero) -> void:
	for hero: Hero in friendly_line.hero_list:
		if is_instance_valid(hero):
			hero.on_hero_buffed(buffed_hero)
	for hero: Hero in enemy_line.hero_list:
		if is_instance_valid(hero):
			hero.on_hero_buffed(buffed_hero)


func _on_hero_died(died_hero: Hero) -> void:
	for hero: Hero in friendly_line.hero_list:
		if is_instance_valid(hero):
			hero.on_hero_death(died_hero)
	for hero: Hero in enemy_line.hero_list:
		if is_instance_valid(hero):
			hero.on_hero_death(died_hero)


func _on_attack_completed() -> void:
	for hero: Hero in friendly_line.hero_list:
		if is_instance_valid(hero):
			hero.on_any_attack()
	for hero: Hero in enemy_line.hero_list:
		if is_instance_valid(hero):
			hero.on_any_attack()


func _on_pause_button_pressed() -> void:
	EventsBus.pause_button_pressed.emit()


func _on_player_stats_changed(player_stats: PlayerStats) -> void:
	round_label.text = "Round: " + str(player_stats.round_number)
	player_health_label.text = str(player_stats.health)
	money_label.text = str(player_stats.money)
