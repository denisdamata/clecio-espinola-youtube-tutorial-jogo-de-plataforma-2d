# script/hitbox.gd

extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "PlayerCB2D":                                               # `name` é um propriedade do argumento passado, não da presente classe, por isso pode não ser reconhecido pelo editor. Essa instrução é um exemplo de callback.
		body.velocity.y = body.JUMP_VELOCITY
		get_parent().currentState = get_parent().State.HURT                     # [Denis] Criação de máquina de estado para parar o inimigo, assim que é atingido, pois aqui não adianta zerar a velocidade se a classe `enemy` continua dando valor para ela. Observe que essa comunicação depende de uma variável de `owner` chamada `current_state`, o que causa acoplamento. Isto poderia ser eliminado usando `emit_signal`.
   
