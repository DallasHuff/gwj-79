class_name Effect
extends Resource

signal finished

const FLIGHT_TIME : float = 0.3
const HEIGHT_ABOVE_HERO := Vector2(0, -100)

enum TriggerType {
	START_OF_BATTLE,
	BEFORE_ATTACK,
	DAMAGE_TAKEN,
	FRONT_HERO_ATTACKS,
	KILLED_ENEMY,
	DEATH,
	FRIENDLY_DEATH,
	ENEMY_DEATH,
	SELF_BUFFED,
	FRIENDLY_BUFFED,
	FRIENDLY_SUMMONED,
	ENEMY_SUMMONED,
	START_OF_SHOP,
	END_OF_SHOP,
	EFFECT_TRIGGERED,
}

enum TargetType {
	SELF,
	ONE_AHEAD,
	ONE_BEHIND,
	FRONT,
	BACK,
	SUMMONED,
	SAME_POSITION_OTHER_SIDE,
	FRONT_OTHER_SIDE,
	BACK_OTHER_SIDE,
	RANDOM_OTHER_SIDE,
	RANDOM_SAME_SIDE,
	RANDOM_ALL,
}

enum AoETargetType {
	NONE,
	ALL,
	SAME_SIDE,
	OTHER_SIDE,
}

enum ContextKey {
	SAME_SIDE_HERO_LINE,
	OTHER_SIDE_HERO_LINE,
	TARGET_HERO,
}

@export_category("triggers")
@export var triggers : Array[TriggerType] = []
@export var effect_name : String = "Effect"
var error_str : String = ""
var effect_owner : Hero
var owner_line_position : int = 0
var position : Vector2
var finished_flag := false


func execute(_context: Dictionary) -> void:
	finish()
	finished.emit()


## Checks effect_owner, same_side_hero_line, other_side_hero_line and pushes an error message if one or more is missing. [br]
## Does NOT check for target_hero
func check_context(context: Dictionary) -> bool:
	var success_flag := true
	if not context.has(ContextKey.SAME_SIDE_HERO_LINE) or not is_instance_valid(context[ContextKey.SAME_SIDE_HERO_LINE]):
		error_str += (get_effect_name() + " doesn't have same_side_hero_line ")
		success_flag = false
	if not context.has(ContextKey.OTHER_SIDE_HERO_LINE) or not is_instance_valid(context[ContextKey.SAME_SIDE_HERO_LINE]):
		error_str += (get_effect_name() + " doesn't have other_side_hero_line ")
		success_flag = false
	
	if not success_flag:
		push_error(error_str)

	return success_flag


func is_finished() -> bool:
	return finished_flag


func finish() -> void:
	finished_flag = true
	call_deferred("emit_signal", "finished")

func get_effect_name() -> String:
	return "Effect"


func _get_target(target_type: TargetType, context: Dictionary) -> Hero:
	var same_team: HeroLine = context[ContextKey.SAME_SIDE_HERO_LINE]
	var other_team: HeroLine = context[ContextKey.OTHER_SIDE_HERO_LINE]

	match target_type:
		TargetType.SELF:
			return effect_owner
		TargetType.ONE_AHEAD:
			return same_team.get_hero_at(owner_line_position - 1)
		TargetType.ONE_BEHIND:
			if effect_owner.dying:
				return same_team.get_hero_at(owner_line_position)
			return same_team.get_hero_at(owner_line_position + 1)
		TargetType.FRONT:
			return same_team.front()
		TargetType.BACK:
			return same_team.back()
		TargetType.SUMMONED:
			if not context.has[ContextKey.TARGET_HERO]:
				push_warning("No summoned target for ", effect_name)
				return null
			return context[ContextKey.TARGET_HERO]
		TargetType.SAME_POSITION_OTHER_SIDE:
			return other_team.hero_at(same_team.get_hero_position(effect_owner))
		TargetType.FRONT_OTHER_SIDE:
			return other_team.front()
		TargetType.BACK_OTHER_SIDE:
			return other_team.back()
		TargetType.RANDOM_OTHER_SIDE:
			return other_team.get_random_hero()
		TargetType.RANDOM_SAME_SIDE:
			return same_team.get_random_hero()
		TargetType.RANDOM_ALL:
			var teams: Array[HeroLine] = [same_team, other_team]
			return teams[randi() % teams.size()].get_random_hero()
		_:
			return null


func _get_aoe_target(aoe_target_type: AoETargetType, context: Dictionary) -> Array[Hero]:
	var targets: Array[Hero] = []
	var same_side: HeroLine = context[ContextKey.SAME_SIDE_HERO_LINE]
	var other_side: HeroLine = context[ContextKey.OTHER_SIDE_HERO_LINE]

	match aoe_target_type:
		AoETargetType.ALL:
			targets = _add_heros_from_line(targets, other_side)
			targets = _add_heros_from_line(targets, other_side)
		AoETargetType.SAME_SIDE:
			targets = _add_heros_from_line(targets, same_side)
		AoETargetType.OTHER_SIDE:
			targets = _add_heros_from_line(targets, other_side)

	return targets


func _add_heros_from_line(arr: Array[Hero], line: HeroLine) -> Array[Hero]:
	for hero: Hero in line.hero_list:
		if is_instance_valid(hero):
			arr.append(hero)
	return arr
