# scripts/rocket_cherry.gd

#extends CharacterBody2D                                                        # `AbstractEnemy` já tem `CharacterBody2D.
extends AbstractEnemy

#@onready var animS2D := $AnimetedSprite2D                                       # A animação de `hurt` do inimigo aéreo, um `AnimatedSprite2D`, é diferente do inimigo terrestre, um `AnimationPlayer`, por isso a abstração da animação de morte é mais complicada.

#enum State {PATROLLING, HURT}                                                  # `AbstractEnemy já tem `State` e `currentState`.
#var currentState = State.PATROLLING

@onready var spawnEnemy =  $"../Path2D/PathFollow2D/SpawnEnemyM2D"

func _ready() -> void:
	animS2D = $AnimetedSprite2D
	spawnScene = preload("res://actors/ground_cherry.tscn")                  # Carrega a cena, mas ainda ela não foi instanciada.
	spawnInstancePosition = spawnEnemy
	canSpawn = true
	animS2D.animation_finished.connect(freeAndScoreAS2D)

func _process(_delta: float) -> void:                                           # Foi colocado um `_` no `delta`, pois ele não é usado, e o Godot exige que ele seja declarado.
	animeDeathEnemyAir()
