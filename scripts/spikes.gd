extends Area2D

@onready var spikes := $Sprite2D
@onready var collision := $CollisionShape2D  

func _ready() -> void:
	collision.shape.size.x =  spikes.get_rect().size.x
	
func _on_body_entered(body) -> void:
	if body.name == "PlayerCB2D" && body.has_method("takeDamage"):
		body.takeDamage(Vector2(0, -500))
