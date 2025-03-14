class_name EnemyManager
extends Node

var enemy_list : Array # Array[Array[HeroArray]]
@export var round_1_list : Array[HeroArray]


func _ready() -> void:
	enemy_list.append(round_1_list)


func get_list_for_round(i: int) -> HeroArray:
	return enemy_list[i-1][randi() % enemy_list[i-1].size()]
