# script/world-1.gd

extends Node2D

@onready var player := $PlayerCB2D
@onready var camera := $Camera2D
@onready var HUBControl := $HUDCanvasLayer/Control  

func _ready() -> void:
	player.followCamera(camera)
	player.playerHasDied.connect(reloadGame)                                    # Quando recebe o sinal do `player.gd` que ele morreu, executa a função `reloadGame`.
	HUBControl.time_is_up.connect(reloadGame)
	Globals.coins = 0                                                           # Reseta `globals.gd`.
	Globals.score = 0
	Globals.playerLife = 3

func reloadGame():
	await get_tree().create_timer(1.0).timeout                                  # Esse temporizador não está conectado com nada. Ele é criado aqui só pra dá um cochilo de 1 segundo. `await` é pro jogo continar rodando (assincronamente), mas o fluxo contínua síncrono aqui dentro, por isso o `reload_current_scene` só é executado depois de 1 segundo [ChatGPT].
	get_tree().reload_current_scene()