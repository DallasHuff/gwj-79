extends Resource
class_name WeightedRandomList

# A list of possible items to choose from, alongside their weight
@export var list: Array[WeightedItem] = []

# Returns an item chosen at random based on the weights.
func get_random() -> ItemData:
	var total_weight: float = 0
	for weighted_item in list:
		total_weight += weighted_item.weight

	if total_weight <= 0:
		return null

	var random_value: float = randf() * total_weight
	var sum_weight: float = 0

	# Return an item when the random value is reached or exceeded
	for weighted_item in list:
		sum_weight += weighted_item.weight
		if sum_weight >= random_value:
			return weighted_item.item

	return null
