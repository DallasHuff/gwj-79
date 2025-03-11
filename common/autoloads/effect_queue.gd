extends Node

@onready var queue1 : Array[Effect] = []
@onready var queue2 : Array[Effect] = []


func front() -> Effect:
	if not queue2.is_empty():
		return queue2[0]
	return queue1[0]


func push_back(effect: Effect, priority: int) -> void:
	match priority:
		2:
			queue2.push_back(effect)
		_:
			queue1.push_back(effect)


func push_front(effect: Effect, priority: int) -> void:
	match priority:
		2:
			queue2.push_front(effect)
		_:
			queue1.push_front(effect)


func execute_next(context: Dictionary) -> void:
	var effect: Effect
	if not queue2.is_empty():
		effect = queue2.pop_front()
	else:
		effect = queue1.pop_front()
	if is_instance_valid(effect):
		# print("Executing effect: ", effect.effect_name)
		effect.execute(context)
		return
	push_error("effect wasn't valid")


func is_empty() -> bool:
	return queue1.is_empty() and queue2.is_empty()


func print_info() -> void:
	print("queue1: ", queue1, " queue2: ", queue2)
