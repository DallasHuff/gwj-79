class_name Effect
extends Resource

signal finished

const HEIGHT_ABOVE_HERO: float = -100
const ARC_HEIGHT: float = -150

enum TriggerType {
	START_OF_BATTLE,
	BEFORE_ATTACK,
	HERO_ONE_IN_FRONT_ATTACKS,
	AFTER_ANY_ATTACK,
	DAMAGE_TAKEN,
	KILLED_ENEMY,
	SELF_DEATH,
	ANY_OTHER_DEATH,
	FRIENDLY_DEATH,
	ENEMY_DEATH,
	SELF_BUFFED,
	FRIENDLY_BUFFED,
	ENEMY_BUFFED,
	SELF_HEALED,
	FRIENDLY_HEALED,
	ENEMY_HEALED,
	ANY_HEALED,
	SUMMONED,
	START_OF_SHOP,
	END_OF_SHOP,
	BOUGHT,
	EFFECT_TRIGGERED,
}

enum TargetType {
	SELF,
	ONE_AHEAD,
	ONE_BEHIND,
	FRONT,
	BACK,
	ANY_SUMMONED,
	FRIENDLY_SUMMONED,
	ENEMY_SUMMONED,
	ANY_OTHER_BUFFED,
	FRIENDLY_BUFFED,
	ENEMY_BUFFED,
	FRONT_OTHER_SIDE,
	BACK_OTHER_SIDE,
	LOWEST_HP_OTHER_SIDE,
	LOWEST_HP_SAME_SIDE,
	HIGHEST_HP_OTHER_SIDE,
	HIGHEST_HP_SAME_SIDE,
	LOWEST_ATK_OTHER_SIDE,
	LOWEST_ATK_SAME_SIDE,
	HIGHEST_ATK_OTHER_SIDE,
	HIGHEST_ATK_SAME_SIDE,
	RANDOM_OTHER_SIDE,
	RANDOM_SAME_SIDE,
	RANDOM_ALL,
	TRIGGER_HERO,
}

enum AoETargetType {
	NONE,
	ALL,
	SAME_SIDE,
	OTHER_SIDE,
}

@export_category("triggers")
@export var triggers : Array[TriggerType] = []
var context : Dictionary[ContextBuilder.ContextKey, Variant] = {}
var finished_flag := false
var flight_time: float = 0.3


func execute() -> void:
	finish()
	finished.emit()


## Checks effect_owner, same_side_hero_line, other_side_hero_line and pushes an error message if one or more is missing.
func check_default_context() -> bool:
	var success_flag := true
	var error_str := get_effect_name()

	if (not context.has(ContextBuilder.ContextKey.EFFECT_OWNER)
	or not is_instance_valid(context[ContextBuilder.ContextKey.EFFECT_OWNER])):
		error_str += " doesn't have effect_owner "
		success_flag = false

	if (not context.has(ContextBuilder.ContextKey.SAME_SIDE_HERO_LINE)
	or not is_instance_valid(context[ContextBuilder.ContextKey.SAME_SIDE_HERO_LINE])):
		error_str += " doesn't have same_side_hero_line "
		success_flag = false

	if (not context.has(ContextBuilder.ContextKey.OTHER_SIDE_HERO_LINE)
	or not is_instance_valid(context[ContextBuilder.ContextKey.SAME_SIDE_HERO_LINE])):
		error_str += " doesn't have other_side_hero_line "
		success_flag = false

	if not success_flag:
		push_error(error_str)

	if success_flag:
		var effect_owner: Hero = context[ContextBuilder.ContextKey.EFFECT_OWNER]
		if effect_owner.dying and TriggerType.SELF_DEATH not in triggers:
			return false

	return success_flag


func is_finished() -> bool:
	return finished_flag


func finish() -> void:
	finished_flag = true
	if context.has(ContextBuilder.ContextKey.EFFECT_OWNER):
		if context[ContextBuilder.ContextKey.EFFECT_OWNER].friendly:
			EventsBus.player_effect_finished.emit(self)
	call_deferred("emit_signal", "finished")


func get_effect_name() -> String:
	return "Undefined Effect"


func _get_target(target_type: TargetType) -> Hero:
	var effect_owner: Hero = context[ContextBuilder.ContextKey.EFFECT_OWNER]
	var same_team: HeroLine = context[ContextBuilder.ContextKey.SAME_SIDE_HERO_LINE]
	var other_team: HeroLine = context[ContextBuilder.ContextKey.OTHER_SIDE_HERO_LINE]
	var trigger_hero: Hero = null
	if context.has(ContextBuilder.ContextKey.TRIGGER_HERO):
		trigger_hero = context[ContextBuilder.ContextKey.TRIGGER_HERO]
		

	match target_type:
		TargetType.SELF:
			return effect_owner
		TargetType.ONE_AHEAD:
			return same_team.get_hero_at(effect_owner.line_position - 1)
		TargetType.ONE_BEHIND:
			# If the effect owner is dying, it has been removed from its HeroLine and
			# units have been moved up so the "one behind" is now where the effect_owner was
			if effect_owner.dying:
				return same_team.get_hero_at(effect_owner.line_position)
			return same_team.get_hero_at(effect_owner.line_position + 1)
		TargetType.FRONT:
			return same_team.front()
		TargetType.BACK:
			return same_team.back()
		TargetType.ANY_SUMMONED:
			return trigger_hero
		TargetType.FRIENDLY_SUMMONED:
			return trigger_hero if trigger_hero.friendly == effect_owner.friendly else null
		TargetType.ENEMY_SUMMONED:
			return trigger_hero if trigger_hero.friendly != effect_owner.friendly else null
		TargetType.ANY_OTHER_BUFFED:
			return trigger_hero
		TargetType.FRIENDLY_BUFFED:
			return trigger_hero if trigger_hero.friendly == effect_owner.friendly else null
		TargetType.ENEMY_BUFFED:
			return trigger_hero if trigger_hero.friendly != effect_owner.friendly else null
		TargetType.FRONT_OTHER_SIDE:
			return other_team.front()
		TargetType.BACK_OTHER_SIDE:
			return other_team.back()
		TargetType.HIGHEST_HP_OTHER_SIDE:
			return other_team.get_highest_hp_hero()
		TargetType.HIGHEST_HP_SAME_SIDE:
			return same_team.get_highest_hp_hero()
		TargetType.LOWEST_ATK_OTHER_SIDE:
			return other_team.get_lowest_atk_hero()
		TargetType.LOWEST_ATK_SAME_SIDE:
			return same_team.get_lowest_atk_hero()
		TargetType.HIGHEST_ATK_OTHER_SIDE:
			return other_team.get_highest_atk_hero()
		TargetType.HIGHEST_ATK_SAME_SIDE:
			return same_team.get_highest_atk_hero()
		TargetType.RANDOM_OTHER_SIDE:
			return other_team.get_random_hero()
		TargetType.RANDOM_SAME_SIDE:
			return same_team.get_random_hero()
		TargetType.RANDOM_ALL:
			var teams: Array[HeroLine] = [same_team, other_team]
			return teams[randi() % teams.size()].get_random_hero()
		TargetType.TRIGGER_HERO:
			return trigger_hero
		_:
			return null


func _get_aoe_target(aoe_target_type: AoETargetType) -> Array[Hero]:
	var targets: Array[Hero] = []
	var same_side: HeroLine = context[ContextBuilder.ContextKey.SAME_SIDE_HERO_LINE]
	var other_side: HeroLine = context[ContextBuilder.ContextKey.OTHER_SIDE_HERO_LINE]

	match aoe_target_type:
		AoETargetType.NONE:
			return targets
		AoETargetType.ALL:
			targets = _add_heroes_from_line(targets, other_side)
			targets = _add_heroes_from_line(targets, same_side)
		AoETargetType.SAME_SIDE:
			targets = _add_heroes_from_line(targets, same_side)
		AoETargetType.OTHER_SIDE:
			targets = _add_heroes_from_line(targets, other_side)

	return targets


func _add_heroes_from_line(arr: Array[Hero], line: HeroLine) -> Array[Hero]:
	for hero: Hero in line.hero_list:
		if is_instance_valid(hero):
			arr.append(hero)
	return arr


func _get_owner_position() -> Vector2:
	var effect_owner: Hero = context[ContextBuilder.ContextKey.EFFECT_OWNER]
	var friendly_line: HeroLine = context[ContextBuilder.ContextKey.SAME_SIDE_HERO_LINE]
	return friendly_line.get_global_from_line_pos(effect_owner.line_position)


func _clean_targets_array(targets: Array[Hero]) -> Array[Hero]:
	var new_targets: Array[Hero] = []
	for hero: Hero in targets:
		if is_instance_valid(hero) and hero not in new_targets:
			new_targets.append(hero)
	return new_targets	
