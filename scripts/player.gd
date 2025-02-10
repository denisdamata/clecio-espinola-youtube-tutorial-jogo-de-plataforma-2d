# player.gd
# Código "Clésio Espindola" do YouTube [1]
# Direção Denis da Mata
# 12-01-2025

extends CharacterBody2D                                                         # [Denis] Classe nativa do Godot para objetos mais complexos que exigem de manipulação manual ou direta. Não tem física embutida como `RigidBody2D`, é apenas um nó cinemático (não-dinâmico), mesmo assim é pesada e deve ser usada apenas quando necessário [ChatGPT].

const SPEED = 150.0                                                             # Velocidade de movimento horizontal do personagem.
const JUMP_VELOCITY = -400.0                                                    # Velocidade do salto (valor negativo para mover para cima).
var knockbackVector := Vector2.ZERO
var direction
var State = {
	"IDLE": "idle",
	"RUNNING": "running",
	"JUMPING": "jumping",
	"HURTED": "hurted"
}
var currentState = State["IDLE"]
var isHurted := false
	
@onready var textureAnimated := $AnimatedSprite2D 
@onready var remoteTransform := $RemoteTransform2D
@onready var headCollider := $HeadColliderA2D

signal playerHasDied

func _physics_process(delta: float) -> void:                                    # Função chamada a cada quadro de física.
	# Adiciona a gravidade ao personagem.
	if not is_on_floor():                                                       # Método nativo que verifica se o personagem não esta no chão. [Denis] A física só é calculada uma vez por quadro, o retorno do método `is_on_floor` é apenas uma variável booleana, ou seja, não há problema em chamar esse método várias vezes para o mesmo quadro. Evite comparação de strings.
		# [Denis] Da cinemática da física temos que
		#
		# v = v_0 + a*t,
		#
		# onde 'v_0' é a velocidade inicial, 'a' a aceleração e 't' a variação
		# de tempo. Como a aceleração aqui é devido a gravidade, 
		# g = 9.8 m/s^2, então temos que
		#
		# v = v_0 + g*t
		#
		velocity += get_gravity() * delta                                       # Aplica a gravidade a velocidade vertical (eixo 'y' positivo é para baixo).
  
	# Lógica para o salto.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():             # Verifica se a ação de salto foi pressionada e se o personagem esta no chão. '_just' é importante, porque pega o clique somente uma vez, e não durante todo o tempo que é o botão é pressionado.
		velocity.y = JUMP_VELOCITY                                              # [Denis] O personagem empurra o chão, e o chão reage, com a força normal, empurrando ele para cima (3a Lei de Newton). A força do chão atua por um intervalo de tempo finito (impulso), acelerando o corpo durante o processo, mas depois que o personagem perde o contato com o chão, a aceleração cessa e o personagem adquiri uma velocidade final, devido a este processo, que é a velocidade inicial do pulo. Esta é a velocidade que é "aplicada" nesta linha de código.
		
	# Obtem a direção de entrada do jogador para movimento horizontal.
	direction = Input.get_axis("ui_left", "ui_right")                           # Método nativo que diz se jogador está apertando para a esquerda ou direita, naquele instante de tempo.

	if direction:                                                               # Se houver entrada (o jogador esta pressionando uma tecla de esquerda ou direita).
		velocity.x = direction * SPEED                                          # Define a velocidade horizontal com base na direção e na velocidade. [Denis] Este é um 'Design de Controle Rápido', onde a velocidade é alterada instantaneamente, que é diferente do 'Design de Movimento Físico' onde é aplicado uma inércia [ChatGPT]. Cada um tem seus prós e contras. Ambos podem ser achados em uma variedade de jogos famosos.
		textureAnimated.scale.x = direction                                   
	else:                                                                       # Senão houver entrada.
		velocity.x = move_toward(velocity.x, 0, SPEED)                          # Suavemente reduz a velocidade horizontal a zero. [Denis] Diferente do iniciar da caminhada, aqui tem um efeito de inércia [ChatGPT].
							   
	if knockbackVector != Vector2.ZERO:
		velocity = knockbackVector  
	
	_setState()
	move_and_slide()                                                            # Método nativo que move o personagem e lida com colisões automaticamente. Se você não usar `move_and_slide`, o corpo pode atravessar outros objetos, o movimento pode parecer instantâneo e não natural, e você precisará gerenciar a gravidade e as colisões manualmente [ChatGPT].

	for platforms in get_slide_collision_count():                               # Vá para o script `falling_platform.gd` do "Ep 15 - Criando PLATAFORMAS que CAEM". `move_and_slice` move e, caso ocorra uma colisão, ele retorna uma classe de dados `KinematicBody2D`, que é pai de `CharacterBody2D`. `get_..._count` assim como `move_and_slice` são métodos do `KinematicBody2D` usando para a cinemática, ele diz a quantidade de colisões que ocorreram no último `move_and_slice` [ChatGPT].
		var collision = get_slide_collision(platforms)                          # Retorna o `KinematicCollision2D` do inteiro passado.
		if collision.get_collider().has_method("hasCollidedWith"):              # Pode colidir com vários objetos ao mesmo tempo, por isso é importante checar se é uma plataforma que cai. Para o jogador, o `collider` é a plataforma, e para o plataforma, o jogador.
			collision.get_collider().hasCollidedWith(collision, self)           # Faz o 'shake',

# Mesmo que você não use o parâmetro `body`, e o editor fique chateando com aviso do tipo 'declarado mas nunca usado', você tem que manter a função com o parâmetro esperado (um `CharacterBody2D, no caso), senão não funciona. 
func _on_HurtBoxA2D_body_entered(body: CharacterBody2D) -> void:                # Não tem uma animação de `AnimatedSprite2D` para o personagem machucado, essa animação é feita diretamente no código usando TWEEN [Denis].

	if $RightRC2D.is_colliding():
		takeDamage(Vector2(-200, -200))
	elif $LeftRC2D.is_colliding():
		takeDamage(Vector2(200, -200))

func takeDamage(knockbackForce := Vector2.ZERO, duration := 0.25):
	if Globals.playerLife < 1:
		queue_free()
		emit_signal("playerHasDied")                                            # Esse sinal é recebido lá no `world-1.gd` que recarrega a cena.
	else:
		Globals.playerLife -= 1
	
	if knockbackForce != Vector2.ZERO:                                          # Programação defensiva.
		knockbackVector = knockbackForce
	
		var knockbackTween := get_tree().create_tween().parallel()              # [Denis] `get_tree` é um método da classe `Node`, presente em todos os nós. Esse método dá acesso a instância `SceneTree` da cena atual, que dá acesso a árvore de nós e permite gerenciar os nós, assim como mudar de cena, enfim, é uma classe bem geral do Godot. Apesar de no Godot 4 não ter mais um nó TWEEN (interpolador) na interface, o TWEEN ainda é um nó do Godot, por isso que é necessário acessar a árvore de nós, para acrescentar o novo nó a atual árvore [ChatGPT].
		knockbackTween.tween_property(self, "knockbackVector", Vector2.ZERO,\
									  duration)                                 # [Denis] TWEEN é um animador para animações simples. `self` é o mesmo que `player`, o nome do nó `CharacterBody2D`. Depois vem o vetor velocidade que causa o empurrão do personagem, vetor final depois da animação e tempo de duração. Depois de `duration` segundos a velocidade é imediatamente zerada.
		textureAnimated.modulate = Color(1, 0, 0, 1)
		knockbackTween.tween_property(textureAnimated, "modulate",\
									  Color(1, 1, 1, 1), duration)
	isHurted = true
	await get_tree().create_timer(.3).timeout                                   # [Denis] `await` congela toda a função que contém ele, mas o jogo continuando rodando (assincronamente). O nó criado aqui é temporário. O `timeout` é apenas um sinal pra avisar que o tempo de espera terminou e, quando isto acontece, a execução da função continua de onde parou. [ChatGPT].
	isHurted = false
	
func _setState():                                                               # O código fica mais simples e modular usando uma função para os estados, que é uma máquina de estados. Somente uma instrução é necessária para animação (`play()`) [Denis].
	currentState = State["IDLE"]
	
	if not is_on_floor():
		currentState = State["JUMPING"]
	elif direction != 0:
		currentState = State["RUNNING"]
	
	if isHurted:
		currentState = State["HURTED"]
	
	textureAnimated.play(currentState)
	
func followCamera(camera):                                                      # Com a câmera no `player` dá bug quando ele morre, pois a câmera também desaparece. Por isso, ela foi transferida para `World-01` e acrescentado código para ela seguir o `player` usando `RemoteTransform2D`.
	var cameraPath = camera.get_path()
	remoteTransform.remote_path = cameraPath

func _on_HeadColliderA2D_body_entered(body: Node2D) -> void:
	print("_on_HeadColliderA2D_body_entered")
	if body.has_method("breakBox"):
		if body.hitpoints > 0:
			body.anim.play("hit")
			body.hitpoints -= 1
			body.spawnCoinOnHit()
		else:
			body.breakBox()

#func _input(event: InputEvent) -> void:                                         # Apenas para resolver o bug do botão de pulo do celular.
	#if event is InputEventScreenTouch:
		#if Input.is_action_just_pressed("ui_accept") and is_on_floor():         # Verifica se a ação de salto foi pressionada e se o personagem esta no chão. '_just' é importante, porque pega o clique somente uma vez, e não durante todo o tempo que é o botão é pressionado.
			#velocity.y = JUMP_VELOCITY                                          # [Denis] O personagem empurra o chão, e o chão reage, com a força normal, empurrando ele para cima (3a Lei de Newton). A força do chão atua por um intervalo de tempo finito (impulso), acelerando o corpo durante o processo, mas depois que o personagem perde o contato com o chão, a aceleração cessa e o personagem adquiri uma velocidade final, devido a este processo, que é a velocidade inicial do pulo. Esta é a velocidade que é "aplicada" nesta linha de código.

# [1] "Ep01 - Introdução GODOT 4.0 - Criando um Jogo de Plataforma 2D" 
# [egniMIdMoMU].
