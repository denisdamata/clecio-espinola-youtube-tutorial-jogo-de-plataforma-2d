# script/falling-plataform.gd

extends AnimatableBody2D

@onready var anim := $AnimationPlayer
@onready var respawnTimer := $RespawnTimer
@onready var respawnPosition := global_position

@export var resetTime := 3.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")  # Diferente do `RigidBody2D` e `CharacterBody2D` com o nó `AnimatableBody2D` é necessario implementar a gravidade manualmente [DeepSeek].
var velocity := Vector2.ZERO
var isTriggered := false 

func _ready() -> void:
	set_physics_process(false)                                                  # Senão a plataforma cai de imediato.
	
func _physics_process(delta: float) -> void:	
	velocity.y += gravity*delta
	position += velocity*delta

# A resposabilidade pela detecção da colisão é transferida para o `player`. Isto exige uma CALLBACK e deixa o código mais complicado. O jogador que avisa a platafomra que ela deve se mexer. O motivo para fazer isso pode ser por uma questão de engenharia, para centralizer a detecção de colisões no jogador, ou até por uma questão de desempenho.
func hasCollidedWith(collision: KinematicCollision2D, \
					 collider: CharacterBody2D):                                # `KinematicCollision2D` não é um nó, ele é apenas uma classe que retorna dados quando acontece uma colisão. O `CharacterBody2D` é o personagem.
	if !isTriggered:
		isTriggered = true
		anim.play("shake")
		velocity = Vector2.ZERO

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	print("falling-platform:_on_AnimationPlayer_animation_finished")
	set_physics_process(true)                                                   # A plataforma cai.
	respawnTimer.start(resetTime)

func _on_RespawnTimer_timeout():
	print("falling-platform:_on_RespawnTimer_timeout")
	set_physics_process(false)
	global_position = respawnPosition                                           # O objeto não foi destruído (`queue_free`), logo basta reposicionar ele.
	if isTriggered:                                                             # Evitar bug!?
		var spawnTween = create_tween().set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_IN_OUT)
		spawnTween.tween_property($Sprite2D, "scale", Vector2(1, 1), 0.2).\
		from(Vector2.ZERO)
	isTriggered = false




