class_name ItemData
extends Resource

@export_category("values")
@export var effect: Effect
@export_category("visuals")
@export var model: Texture
@export_multiline var description: String


func apply(_hero: Hero) -> void:
	pass
