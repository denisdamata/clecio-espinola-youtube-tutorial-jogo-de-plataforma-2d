# script/coin.gd

extends Area2D

func _on_body_entered(body: Node2D) -> void:
	$AnimatedSprite2D.play("collected")
	# Evita coleta dupla da mesma moeda. 
	await $CollisionShape2D.call_deferred("queue_free")
	Globals.coins += 1
	Globals.score += 1

func _on_AnimatedSprite2D_animation_finished() -> void:
	queue_free()  


