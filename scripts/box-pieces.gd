# script/box-pieces.gd

extends RigidBody2D                                                             # O `RigidBody2D` tem um método chamado `apply_impulse` que joga o pedaço de caixa por ar com física, por isso este tipo de nó foi escolhido.

func _on_VisibleOnScreenNotifier2D_screen_exited() -> void:
	queue_free()
	# A função é só isso, o Sprite de cada peça do bloco é definido no script de `break_box`.
