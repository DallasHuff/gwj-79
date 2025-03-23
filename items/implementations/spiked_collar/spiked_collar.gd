class_name SpikedCollar
extends Resource


func apply(hero: Hero) -> void:
	hero.stats.item_list.append(self)
