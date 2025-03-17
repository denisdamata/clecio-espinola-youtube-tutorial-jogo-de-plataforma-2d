# scripts/ground_pumpkin.gd

extends AbstractEnemy

func _ready() -> void:
	wallDetector = $WallDetectorRC2D
	texture = $Sprite2D 
	animPlayer = $AnimationPlayer 
	animPlayer.animation_finished.connect(freeAndScoreAP)

func _physics_process(delta: float) -> void:
	moveAndAnimeDeathEnemyGround(delta)
