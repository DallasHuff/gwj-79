class_name SummonEffect
extends Effect

enum SummonPosition {
	SELF,
	FRONT,
	FRONT_OTHER_SIDE,
	BACK,
	BACK_OTHER_SIDE,
	TRIGGER,
}

@export var summon_hero_stats : HeroStats
@export var summon_position : SummonPosition = SummonPosition.SELF


func execute() -> void:
	var effect_owner: Hero = context[ContextBuilder.ContextKey.EFFECT_OWNER]
	var friendly_line: HeroLine = context[ContextBuilder.ContextKey.SAME_SIDE_HERO_LINE]
	var other_line: HeroLine = context[ContextBuilder.ContextKey.OTHER_SIDE_HERO_LINE]
	var target_line: HeroLine = context[ContextBuilder.ContextKey.OTHER_SIDE_HERO_LINE]

	match summon_position:
		SummonPosition.SELF:
			friendly_line.summon(effect_owner.line_position, summon_hero_stats)
		SummonPosition.FRONT:
			friendly_line.summon(0, summon_hero_stats)
		SummonPosition.FRONT_OTHER_SIDE:
			other_line.summon(0, summon_hero_stats)
		SummonPosition.BACK:
			friendly_line.summon(friendly_line.hero_list.size()-1, summon_hero_stats)
		SummonPosition.BACK_OTHER_SIDE:
			other_line.summon(other_line.hero_list.size()-1, summon_hero_stats)
		SummonPosition.TRIGGER:
			var trigger_hero: Hero = context[ContextBuilder.ContextKey.TRIGGER_HERO]
			target_line.summon(trigger_hero.pos, summon_hero_stats)

	# TODO: remove finish method, just emit the signal. the finished bool doesn't get reset when the hero uses the same effect?
	# TODO: maybe do CONNECT ONE_SHOT from the arena instead of awaiting the finish you can just make a method idk?
	finish()


func get_effect_name() -> String:
	return "SummonEffect"
