extends Node2D

var dir := Vector2.RIGHT
export var speed := 40

func _ready():
	$ParticleTimer.wait_time = $Particles2D.lifetime

func _process(delta):
	position += dir*speed*delta

func _on_Area2D_area_entered(area):
	bullet_death()

func _on_Timer_timeout():
	queue_free()

func bullet_death():
	$BulletHit.play()
	$Area2D/CollisionShape2D.call_deferred("set_disabled", true)
	$ParticleTimer.start()
	$Particles2D.emitting = true
	$ColorRect.hide()
	yield($ParticleTimer, "timeout")
	queue_free()
