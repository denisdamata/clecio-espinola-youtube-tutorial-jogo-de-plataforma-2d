# script/break-box.gd

extends CharacterBody2D                                                         # Este tipo de nó é usado para situações mais complexas, que exigem movimentação controlada ou detecção de colisão com física, que não é o caso, um `StaticBody2D` ou, mais simples ainda, um `Area2D` já seria suficiente. Existe física e aplicação de impulso nas peças da caixa (um `RigidBody2D`), mas na caixa inteira, não. Então, o autor deve ter escolhido usar um `CharacterBody2D` para a caixa inteira pensando em aplicações futuras, onde a caixa pode ser controlada ou empurrada [DeepSeek].

const boxPieces = preload("res://prefabs/box-pieces.tscn")                      # Cuidado com o carregamento, pois operações de I/O são caras. `preload` carrega apenas na inicialização do jogo, que é ótimo para desempenho, mas gasta memória durante todo o jogo [DeepSeek].
const coinRigidScene = preload("res://prefabs/coin-rigid.tscn")

@onready var anim := $AnimationPlayer
@onready var spawnCoin := $SpawnCoinM2D
@export var pieces: PackedStringArray                                           # Esta variável é definada no inspetor, é o endereço de cada imagem da caixa quebrável.`PackedStringArray` é um arranjo que só pode armazenar strings, é mais eficiente que um `Array` comum. Uma vez criado não pode ser alterado ou, equivalentemente, na modificação é criado outro. [DeepSeek].
@export var hitpoints := 3
var impulse := 200
			
func breakBox(): 
	for piece in pieces.size():                                                 # Inteiro
		var pieceInstance = boxPieces.instantiate()                             # Uma instância para cada peça.
		get_parent().add_child(pieceInstance)                                   # `pieceInstance` é um `RigidBody2D` com vários filhos.
		pieceInstance.get_node("Sprite2D").texture = load(pieces[piece])        # `load` é o carregamento dinâmico, economiza memória mas é mais lento, por isso tome cuidado. Da pra fazer isso com `preload` ou Singleton Autoload. Aqui é feito a associação de uma imagem ao `texture` de um `Sprite2D`, equivalente a arrastar a imagem e soltar no inspetor.
		pieceInstance.global_position = global_position
		var pieceImpulse = Vector2(randi_range( impulse,   -impulse), \
								   randi_range(-impulse, -2*impulse))
		pieceInstance.apply_impulse(pieceImpulse)                               # Como `pieceInstance` é um `RigidBody2D` ele tem o método `apply_impulse`.
	queue_free()                                                                # Não se esqueça da limpeza

# # Código original, mas com erro. Sem `call_deferred` funciona corretamente, mas fica emitindo mensagem de erro devido a falta dele, com o `call_deferred` as moedas não aparecem, mas para de emitir a mensagem de erro, a solução foi a implementação abaixo do Qwen, onde esta função é dividida em duas. Mexer com os nós durante o processamento de alguma função ou sinal pode causar problema, e o `call_deferred` serve para que tudo ocorra na ordem certa [DeepSeek]. O autor do código alega que isso é relevante "porque o `RigidBody2D` trás com ele um `Area2D` do `coin.tscn`"? Quando você adiciona um `RigidBody2D` à cena e imediatamente aplica um impulso, o sistema de física pode não estar pronto para lidar com isso no mesmo quadro. Outra possibilidade é o `Area2D`, dentro do `coin.tscn`, pode estar emitindo sinais (como `_on_body_entered`) enquanto você está manipulando o nó, ou seja, os sinais estão sendo processados antes que o nó esteja completamente configurado [Qwen].
# func spawnCoinOnHit():
# 	var coinRigid = coinRigidScene.instantiate()
# 	get_parent().add_child(coinRigid)                          
# 	coinRigid.global_position = spawnCoin.global_position
# 	var coinImpulse = Vector2(0.5*randi_range(impulse, -impulse), -0.75*impulse)
# 	coinRigid.apply_impulse(coinImpulse)

func spawnCoinOnHit():
	var coinRigid = coinRigidScene.instantiate()
	get_parent().call_deferred("add_child", coinRigid)                          # Adiciona a moeda à cena de forma segura usando `call_deferred`, adiando para o próximo quadro e sem interferir no processamento ativo [Qwen].
	call_deferred("_initialize_coin", coinRigid)                                # Mesmo adicionando o nó de forma segura, ele não pode ser manipulado de imediato por causa da física, você precisa de mais um quadro para manipula-ló [Qwen].

func _initialize_coin(coinRigid: Node2D):
	coinRigid.global_position = spawnCoin.global_position                       # Aqui o nó já foi adicionado à cena e está pronto para ser manipulado [Qwen].
	var coinImpulse = Vector2(0.5 * randi_range(impulse, -impulse),\
	                          -0.75 * impulse)
	coinRigid.apply_impulse(coinImpulse)
