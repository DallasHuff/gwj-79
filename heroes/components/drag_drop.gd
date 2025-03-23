class_name DragDrop
extends Area2D

signal drag_started
signal dropped(hero: Hero, starting_position: Vector2)
signal drag_canceled(starting_position: Vector2)

@export var enabled := true
@export var target : Hero

var starting_position : Vector2
var dragging := false


func _ready() -> void:
	assert(target, "No target set for DragDrop Component!")


func _process(_delta: float) -> void:
	if dragging and target:
		target.global_position = lerp(target.global_position, get_global_mouse_position(), 0.2)


func _input(event: InputEvent) -> void:
	if dragging and event.is_action_pressed("cancel"):
		_cancel_dragging()
	elif dragging and event.is_action_released("select"):
		_drop()


func _end_dragging() -> void:
	dragging = false
	target.remove_from_group("dragging")


func _cancel_dragging() -> void:
	_end_dragging()
	drag_canceled.emit(starting_position)


func _start_dragging() -> void:
	dragging = true
	starting_position = target.global_position
	target.add_to_group("dragging")
	drag_started.emit()


func _drop() -> void:
	_end_dragging()
	dropped.emit(target, starting_position)


func _on_input_event(_viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	if not enabled:
		return
	var dragging_object := get_tree().get_first_node_in_group("dragging")

	if not dragging and dragging_object:
		return
	elif not dragging and event.is_action_pressed("select"):
		_start_dragging()
