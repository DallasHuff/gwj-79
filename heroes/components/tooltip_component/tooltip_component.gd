class_name TooltipComponent
extends Area2D

@export var time_to_show: float = 0.5

@onready var tooltip_panel: Panel = %TooltipPanel
@onready var tooltip_label: RichTextLabel = %TooltipLabel
@onready var tooltip_timer: Timer = %TooltipTimer


func set_tooltip(value: String) -> void:
	tooltip_label.text = value


func _on_mouse_entered() -> void:
	tooltip_timer.start(time_to_show)


func _on_mouse_exited() -> void:
	tooltip_timer.stop()
	tooltip_panel.hide()


func _on_tooltip_timer_timeout() -> void:
	tooltip_panel.show()	
