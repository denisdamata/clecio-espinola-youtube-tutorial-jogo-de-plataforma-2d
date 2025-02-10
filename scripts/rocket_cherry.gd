extends CharacterBody2D

enum State {PATROLLING, HURT}#, STANDING}  
var currentState = State.PATROLLING

@onready var anim := $AnimetedSprite2D 

func _process(delta: float) -> void:
    if currentState == State.HURT:
        anim.play("hurt")

func _on_AnimetedSprite2D_animation_finished() -> void:
    queue_free()
    Globals.score += 5
