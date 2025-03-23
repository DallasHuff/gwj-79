class_name CabbageItem
extends Node2D

@onready var drag_drop: DragDropItem = %Area2D


func apply(hero: Hero) -> void:
	hero.get_buffed(1, 1)

