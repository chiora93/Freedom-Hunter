extends RigidBody

var timeout = 5
var lifetime = null
var voice = null

onready var light_node = get_node("explosion/light")
onready var particle_node = get_node("explosion/particles")
onready var Entity = preload("res://src/entity.gd")

func _ready():
	set_process(true)

func _process(delta):
	timeout -= delta
	if lifetime != null:
		lifetime -= delta
		if lifetime < 0:
			set_process(false)
			queue_free()
	elif voice != null and not get_node("explosion/sound").is_voice_active(voice):
		particle_node.set_emitting(false)
		light_node.set_enabled(false)
		lifetime = particle_node.get_variable(Particles.VAR_LIFETIME)
	elif timeout < 0 and voice == null:
		voice = get_node("explosion/sound").play("explosion")
		particle_node.set_emitting(true)
		get_node("mesh").hide()
		light_node.set_enabled(true)
		var r = get_node("explosion/radius").get_shape().get_radius()
		for body in get_node("explosion").get_overlapping_bodies():
			if body extends Entity:
				var d = body.get_global_transform().origin - get_global_transform().origin
				var dmg = int((r - d.length()) * 5 + 1)
				body.damage(dmg, 0.1)
