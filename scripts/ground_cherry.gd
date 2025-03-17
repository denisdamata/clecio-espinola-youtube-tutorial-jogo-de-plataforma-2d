# scripts/ground_cherry.gd

# AVISO!!! O Godot tem um bug com troca de sprite de animação. É necessário clicar com o botão direito do mouse em cima do arquivo de cena TSCN, ir em "Edit Dependencies..." e trocar o arquivo de sprite manualmente [1].

# O Cherry de chão é quase igual o Pumpkin, a diferença é apenas que, ele tem uma animação logo depois que virou inimigo de chão, até chegar no chão, e não tem animação de `standing`do Pumpkin. Mesmo assim, a nova cena e script dele foi criada duplicando o Pumpkin. Se as animações fossem as mesma, só bastaria mudar o sprite da animação. 

extends AbstractEnemy 

func _ready() -> void:
	wallDetector = $WallDetectorRC2D
	texture = $Sprite2D 
	animPlayer = $AnimationPlayer 
	animPlayer.animation_finished.connect(freeAndScoreAP)

func _physics_process(delta: float) -> void:
	moveAndAnimeDeathEnemyGround(delta)

# [1] https://github.com/godotengine/godot/issues/103927#issuecomment-2719096375
