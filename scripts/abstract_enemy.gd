# script/enemy.gd

# Código refatorado a partir do Episódio 21 para abstrair os inimigos. Veja "Até o episódio 20" em [1]. A partir do episódio 21 o script individual de cada inimigo é bem mais simples.

extends CharacterBody2D

class_name AbstractEnemy                                                        # Classe base abstrata usada pelos inimigos. Os inimigos de ar e solo possuem semelhanças, mas o inimigo de ar não é uma mera extensão do inimigo de solo, por isso não tem como herda um do outro e é necessário uma classe pai para ambos não instanciável, que é mais conhecido como classe base [ChatGPT]. O termo "Base" lembra "chão", então foi usado o termo "Abstract" para não confundir.

const SPEED = 30.0
var direction := -1
enum State {PATROLLING, HURT}                                                   # [Denis] Não dá para parar o inimigo via callback no script `hitbox.gd` com `owner.velocity.x = 0`. Quando o inimigo é atingido, toca a animação `hurt` e ele desaparece, mas ele continua se movendo, por isso foi criado esta máquina de estado.
var currentState = State.PATROLLING

#@onready var wallDetector := $WallDetectorRC2D
#@onready var texture := $Sprite2D 
#@onready var animPlayer := $AnimationPlayer                                    # Aqui não é usado, mas é usado numa callback de outro script.
var wallDetector                                                                # Como tem inimigo que não tem Ray Cast e um nó dedicado para o seu Sprite, o `@onready` tem que ser removido e a inicialização tem que ser feita individualmente.
var texture
var animPlayer
var animS2D 

# Variáveis usadas para a desova de inimigo aéreo.
var canSpawn := false
var spawnScene: PackedScene = null                                              # Exemplo de valor de `PackedScene`: `preload("res://actors/player.tscn")`. Lembrando que `preload` é carregado no começo do jogo, é mais rápido, e o `load` é durante o jogo, gasta menos memória.
var spawnInstancePosition: Marker2D

func moveAndAnimeDeathEnemyGround(delta):                                       # O inimigo áreo não precisa de `move_and_slide` função, pois o movimento dele é sem física.
	if not is_on_floor():
		velocity += get_gravity() * delta                                       # A gravidade não se aplica ao inimigo aéreo, pois o movimento dele é fixo, então o efeito de gravidade tem que ser isolado nesta função para ser chamado apenas pelos inimigos que sentem ele.
	
	match currentState:                                                         # [Denis] Máquina de estado.
		State.PATROLLING:
			velocity.x = direction * SPEED
			move_and_slide()
		State.HURT:
			velocity.x = 0
			animPlayer.play("hurt")

	if wallDetector.is_colliding():                                             # O inimigo aéreo não tem um Ray Cast, também, assim como o efeito de gravidade.
		direction *= -1
		wallDetector.scale.x *= -1
	texture.flip_h = true if direction == 1 else false

func animeDeathEnemyAir():
	if currentState == State.HURT:
		animS2D.play("hurt")

# Infelizmente, o Godot não tem suporte a polimorfismo suficiente e é necessário criar uma função diferente para finalizar cada animação com assinatura diferente.
func freeAndScoreAP(anim_name: String) -> void:                                 # Implementando o sinal manualmente esta função pode ser usada por qualquer nó?
	freeAndScore()
func freeAndScoreAS2D() -> void:
	freeAndScore()
	if canSpawn:
		spawnNewEnemy()
		get_parent().queue_free() # Precisa fazer isto senão não causa vazamento de memória do Cherry aéreo.
	else:
		queue_free()
func freeAndScore():
	queue_free()
	Globals.score += Globals.enemyPoint  

func spawnNewEnemy():
	var spawnInstance = spawnScene.instantiate()
	get_tree().root.add_child(spawnInstance)
	spawnInstance.global_position = spawnInstancePosition.global_position

# [1] https://github.com/denisdamata/clecio-espinola-youtube-tutorial-jogo-de-plataforma-2d/tree/main/scripts
