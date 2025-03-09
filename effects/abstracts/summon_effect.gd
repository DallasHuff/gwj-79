class_name SummonEffect
extends Effect

@export var summon : HeroStats
@export var friendly := true


func execute(context: Dictionary) -> void:
	if not check_context(context):
		return

	get_target_position(context)

	# Target Hero should be whatever triggered the effect. ex. whatever died if death is trigger
	var cause_of_effect : Hero = context[ContextKey.TARGET_HERO]
	# Summoning based on a summon's death can softlock the game
	if ((trigger == TriggerType.FRIENDLY_DEATH or trigger == TriggerType.ENEMY_DEATH)
			and is_instance_valid(cause_of_effect) 
			and cause_of_effect.stats.hero_name == summon.hero_name):
		print("Didn't summon because summoned unit just died and was same as what is to be summoned: ", summon.hero_name)
		return

	# pseudocode:
	# add to heroline based on effect_owner's position
	# do animation (particles like a puff of smoke)
	
	finished.emit()


func get_target_position(context: Dictionary) -> void:
	if context.has[ContextKey.TARGET_HERO]:
		return
	pass


func get_effect_name() -> String:
	return "SummonEffect"
