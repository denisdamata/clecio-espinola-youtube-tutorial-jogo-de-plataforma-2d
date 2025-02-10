# script/enemy.gd

extends CharacterBody2D

const SPEED = 30.0
var direction := -1
enum State {PATROLLING, HURT}                                                   # [Denis] Não dá para parar o inimigo via callback no script `hitbox.gd` com `owner.velocity.x = 0`. Quando o inimigo é atingido, toca a animação `hurt` e ele desaparece, mas ele continua se movendo, por isso foi criado esta máquina de estado.
var currentState = State.PATROLLING

@onready var wallDetector := $WallDetectorRC2D
@onready var texture := $Sprite2D 
@onready var anim := $AnimationPlayer                                           # Aqui não é usado, mas é usado numa callback de outro script.

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if wallDetector.is_colliding():
		direction *= -1
		wallDetector.scale.x *= -1
	texture.flip_h = true if direction == 1 else false
	
	match currentState:                                                         # [Denis] A máquina de estado.
		State.PATROLLING:
			velocity.x = direction * SPEED
			move_and_slide()
		State.HURT:
			velocity.x = 0
			anim.play("hurt")
	
func _on_AnimationPlayer_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hurt":
		queue_free()
		Globals.score += 5
