class_name EnemyManager
extends Node

@export_range(1, 5) var rounds: int
@export_range(1, 4) var teams: int
var enemy_list : Array # Array[Array[HeroArray]]
var pre_str: String = "res://combat/enemy_arrays/round_"
var mid_str: String = "_enemies/team_"
var end_str: String = ".tres"


func _ready() -> void:
	for round_num in range(rounds):
		var round_teams: Array[HeroArray] = []
		for team_num in range(teams):
			var path_to_enemy_array: String = pre_str + str(round_num+1) + mid_str + str(team_num+1) + end_str
			if ResourceLoader.exists(path_to_enemy_array, "HeroArray"):
				var team: HeroArray = load(path_to_enemy_array)
				round_teams.append(team)
			else:
				print("couldn't load heroes at path: " + path_to_enemy_array)
		enemy_list.append(round_teams)


func get_list_for_round(round_number: int) -> HeroArray:
	print("getting enemies for round number: ", round_number)
	var team_number: int = randi() % enemy_list[round_number-1].size()
	return enemy_list[round_number-1][team_number]
