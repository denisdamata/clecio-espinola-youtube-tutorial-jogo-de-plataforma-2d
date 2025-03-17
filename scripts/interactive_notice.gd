# script/interactive-notice.gd 

# Classe responsável pela detecção da entrada do usuário e ativação da exibição da mensagem.

extends Node2D

@onready var texture := $Sprite2D
@onready var area := $Area2D

const pagesText : Array[String] = [
	"Olá, aventureiro!",
	"É muito bom vê-lo por aqui",
	"Espero que esteja  preparado",
	"Sua jornada está apenas...",
	"COMEÇANDO!"
]

# Se o usuário se aproxima da placa de aviso, exibe mensagem. 
func _unhandled_input(event: InputEvent) -> void:                               # Semelhante a função `_input`, mais voltada para entradas de teclado e mouse casuais e globais (não-contínuas) como pausar o jogo. 'unhandled event' significa 'evento não tratado', pois esta função é secundária, ela é executada depois de `_input` e `.is_action_...`.
	if area.get_overlapping_bodies().size() > 0:                                # Algum corpo entrou na área? 'overlap' é intersecção.
		texture.show()    
		if event.is_action_pressed("interact") &&\
		   !DialogManager.isMessageActive:                                      # `DialogManager` é o nome dado ao script singleton `dialog_manager.gd` em 'Project Settings' > 'Globals'.
			texture.hide()
			DialogManager.startMessage(global_position, pagesText)   
	else: 
		texture.hide()
		if DialogManager.dialogBox != null:
			DialogManager.dialogBox.queue_free()
			DialogManager.isMessageActive = false
