class_name Main
extends Node2D

var shop : Shop

@onready var arena : Arena = %Arena


func _ready() -> void:
	Global.main = self
