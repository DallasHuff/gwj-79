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


func execute_next() -> void:
	var effect: Effect
	if not queue2.is_empty():
		effect = queue2.pop_front()
	else:
		effect = queue1.pop_front()
	if is_instance_valid(effect):
	# TODO: make effect have a context variable that gets added to it before getting pushed to the stack
		effect.execute()
		return
	push_error("effect wasn't valid")


func is_empty() -> bool:
	return queue1.is_empty() and queue2.is_empty()


func clear() -> void:
	queue1.clear()
	queue2.clear()


func print_info() -> void:
	print("queue1: ", queue1, " queue2: ", queue2)
