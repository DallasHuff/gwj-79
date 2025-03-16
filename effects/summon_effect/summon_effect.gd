class_name SummonEffect
extends Effect

const SUMMON_SPRITE := preload("res://effects/summon_effect/art/summon_sprite.tscn")
const SUMMON_PARTICLES := preload("res://effects/summon_effect/art/summon_particles.tscn")

enum SummonPosition {
	SELF,
	FRONT,
	FRONT_OTHER_SIDE,
	BACK,
	BACK_OTHER_SIDE,
	TRIGGER,
}

@export var summon_hero_stats: HeroStats
@export var summon_position: SummonPosition = SummonPosition.SELF
@export var use_effect_owner_hp := false
@export var use_effect_owner_attack := false


func execute() -> void:
	var effect_owner: Hero = context[ContextBuilder.ContextKey.EFFECT_OWNER]
	var friendly_line: HeroLine = context[ContextBuilder.ContextKey.SAME_SIDE_HERO_LINE]
	var other_line: HeroLine = context[ContextBuilder.ContextKey.OTHER_SIDE_HERO_LINE]
	var target_line: HeroLine = context[ContextBuilder.ContextKey.OTHER_SIDE_HERO_LINE]
	var summon_hero_pos: int = 0

	if use_effect_owner_hp:
		summon_hero_stats.max_hp = effect_owner.stats.max_hp
		summon_hero_stats.current_hp = summon_hero_stats.max_hp
	if use_effect_owner_attack:
		summon_hero_stats.damage = effect_owner.stats.damage	

	match summon_position:
		SummonPosition.SELF:
			target_line = friendly_line
			summon_hero_pos = effect_owner.line_position
		SummonPosition.FRONT:
			target_line = friendly_line
			summon_hero_pos = 0
		SummonPosition.FRONT_OTHER_SIDE:
			target_line = other_line
			summon_hero_pos = 0
		SummonPosition.BACK:
			target_line = friendly_line
			summon_hero_pos = clampi(friendly_line.get_back_pos(), 0, friendly_line.hero_list.size()-1)
		SummonPosition.BACK_OTHER_SIDE:
			target_line = other_line
			summon_hero_pos = clampi(other_line.get_back_pos(), 0, other_line.hero_list.size()-1)
		SummonPosition.TRIGGER:
			var trigger_hero: Hero = context[ContextBuilder.ContextKey.TRIGGER_HERO]
			summon_hero_pos = trigger_hero.pos
	
	if target_line.is_line_full():
		finish()
		return
		
	# Animate the sprite
	var position := _get_owner_position()
	var summon_sprite: Node2D = SUMMON_SPRITE.instantiate()
	friendly_line.add_child(summon_sprite)
	summon_sprite.global_position = position + Vector2(0, HEIGHT_ABOVE_HERO)

	var tween := effect_owner.get_tree().create_tween()
	tween.tween_property(summon_sprite, "global_position:x", target_line.get_global_from_line_pos(summon_hero_pos).x, flight_time)
	var y_tween := effect_owner.get_tree().create_tween()
	y_tween.tween_property(summon_sprite, "global_position:y", target_line.get_global_from_line_pos(summon_hero_pos).y + HEIGHT_ABOVE_HERO + ARC_HEIGHT, flight_time / 2).set_ease(Tween.EASE_OUT)
	y_tween.tween_property(summon_sprite, "global_position:y", target_line.get_global_from_line_pos(summon_hero_pos).y, flight_time / 2).set_ease(Tween.EASE_IN)
	tween.tween_callback(summon_sprite.queue_free)
	tween.tween_callback(_make_summon_particles.bind(summon_hero_pos).bind(target_line))

	await tween.finished

	target_line.summon(summon_hero_pos, summon_hero_stats)
	finish()


func _make_summon_particles(target_line: HeroLine, summon_hero_pos: int) -> void:
	var particles: Node2D = SUMMON_PARTICLES.instantiate()
	target_line.add_child(particles)
	particles.global_position = target_line.get_global_from_line_pos(summon_hero_pos)
	particles.emitting = true


func get_effect_name() -> String:
	return "SummonEffect"
