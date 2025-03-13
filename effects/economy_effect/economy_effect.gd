extends Effect

@export_category("values")
@export var money_change_amount : int = 0
@export var income_change_amount : int = 0


func execute() -> void:
	var player_stats: PlayerStats = context[ContextBuilder.ContextKey.PLAYER_STATS]

	player_stats.money += money_change_amount
	player_stats.income += income_change_amount
