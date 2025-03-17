# script/moving-platform.gd

extends Node2D

const WAIT_DURATION := 3.0
var follow := Vector2.ZERO
var platformCenter := 16                                                       # A plataforma tem 32 pixels, então o centro é 16.

@onready var platform := $PlatformAB2D
@export var moveSpeed := 3.0
@export var distance := 200
@export var moveHorizontal := true

func _ready() -> void:
	movePlatform()

func _physics_process(delta: float) -> void:
	platform.position = platform.position.lerp(follow, 0.5)

func movePlatform():
	var moveDirection = Vector2.RIGHT*distance if moveHorizontal \
						 else Vector2.UP*distance
	var duration = moveDirection.length()/float(moveSpeed*platformCenter)    # Velocidade independente do tamanho do objeto, ou falando de outra forma, objetos maiores terão velocidade maior.

	var platformTween = create_tween().set_loops()\
						 .set_trans(Tween.TRANS_LINEAR)\
						 .set_ease(Tween.EASE_IN_OUT)
	platformTween.tween_property(self, "follow", moveDirection, duration)\
				  .set_delay(WAIT_DURATION)
	platformTween.tween_property(self, "follow", Vector2.ZERO, duration)\
				  .set_delay(WAIT_DURATION)
