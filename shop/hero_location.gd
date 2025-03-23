class_name HeroLocation
extends Control

signal hovered(hero_location: HeroLocation)
signal not_hovered(hero_location: HeroLocation)

var enabled := true


func _on_area_2d_mouse_exited() -> void:
	not_hovered.emit(self)


func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)
