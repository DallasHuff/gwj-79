class_name HealthComponent
extends Node

signal died
signal health_changed(prev: int, curr: int)

var max_hp : int = 1
var current_hp : int = 1

func setup(stats: HeroStats) -> void:
	max_hp = stats.max_hp
	current_hp = stats.current_hp
	health_changed.emit(current_hp, current_hp)


func increase_hp(value: int) -> void:
	if value <= 0:
		push_warning("increased hp by <= 0")
		return

	max_hp += value
	current_hp += value


func decrease_max_hp(value: int) -> void:
	if value <= 0:
		push_warning("decreased hp by <= 0")
		return

	max_hp = clampi(max_hp - value, 1, max_hp)
	current_hp = clampi(current_hp, 1, max_hp)


func take_damage(dmg: int) -> void:
	if dmg <= 0:
		print("damage was < 0")
		return
	
	var prev := current_hp
	current_hp -= dmg

	if current_hp <= 0:
		died.emit()
		return

	health_changed.emit(prev, current_hp)


func heal(value: int) -> void:
	if value <= 0:
		push_warning("healed for <= 0")
		return

	var prev_hp := current_hp
	current_hp = clampi(current_hp + value, 0, max_hp)
	health_changed.emit(prev_hp, current_hp)
