extends RigidBody2D

# Bug da caixa que desova moeda. O `Sprite2D` da moeda desaparece, mas o resto não, o que dá pra ver pelo modo de depuração com a forma de colisão ativa. Isso causa vazamento de memória. 

func _on_coinA2D_tree_exited() -> void: # Conecta o `Sprite2D` da moeda com o `RigidBody2D` dela (presente classe).
	queue_free()


