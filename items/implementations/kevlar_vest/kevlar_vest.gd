class_name KevlarVest
extends ItemData


func apply(hero: Hero) -> void:
	hero.stats.item_list.append(self)
