extends Node

signal hero_summoned(hero: Hero)
signal hero_buffed(hero: Hero)
signal hero_healed(hero: Hero)
signal hero_died(hero: Hero)
signal attack_completed
signal pause_button_pressed
signal player_stats_changed(stats: PlayerStats)
signal player_effect_finished(effect: Effect)
