class_name SummonEffect
extends Effect

enum SummonPosition {
	SELF,
	FRONT,
	FRONT_OTHER_SIDE,
	TARGET,
}

@export var summon_hero_stats : HeroStats
@export var summon_position : SummonPosition = SummonPosition.TARGET


func execute(context: Dictionary) -> void:
	var friendly_line: HeroLine = context[ContextKey.SAME_SIDE_HERO_LINE]
	var other_line: HeroLine = context[ContextKey.OTHER_SIDE_HERO_LINE]
	var target_hero: Hero = context[ContextKey.TARGET_HERO]
	var target_line: HeroLine = context[ContextKey.OTHER_SIDE_HERO_LINE]

	match summon_position:
		SummonPosition.SELF:
			friendly_line.summon(owner_line_position, summon_hero_stats)
		SummonPosition.FRONT:
			friendly_line.summon(0, summon_hero_stats)
		SummonPosition.FRONT_OTHER_SIDE:
			other_line.summon(0, summon_hero_stats)
		SummonPosition.TARGET:
			target_line.summon(target_hero.pos, summon_hero_stats)

	# TODO: remove finish method, just emit the signal. the finished bool doesn't get reset when the hero uses the same effect?
	# TODO: maybe do CONNECT ONE_SHOT from the arena instead of awaiting the finish you can just make a method idk?
	finish()


func get_effect_name() -> String:
	return "SummonEffect"
