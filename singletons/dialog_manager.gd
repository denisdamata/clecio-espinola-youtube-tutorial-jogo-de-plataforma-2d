# singletons/dialog_manager.gd

# Classe usada por `interactive-notice.gd`. 
# Gerencia as páginas da mensagem. Por que essa classe é singleton, por que a transição entre páginas é a reaproveitada em outros contextos, além do aviso interativo da plaquinha com efeito de digitação? 

extends Node

@onready var dialogBoxScene = preload("res://prefabs/dialog_box.tscn")
var pages: Array[String] = []                                                   # O texto completo, todas as páginas.
var currentPage = 0                                                             # Além do índice para cada letra, também tem um índice para cada página.

var dialogBox
var dialogBoxPosition := Vector2.ZERO

var isMessageActive := false                                                    # Relativo a todas as páginas
var canAdvancePage := false 

func startMessage(position: Vector2, pagesArg: Array[String]):
	if isMessageActive:
		return
	
	pages = pagesArg
	dialogBoxPosition = position
	showText()
	isMessageActive = true

func showText():                                                                # Mostra uma página
	dialogBox = dialogBoxScene.instantiate()                                    # Uma caixa de diálogo para cada página.
	dialogBox.textDisplayFinished.connect(_onAllTextDisplayed)
	get_tree().root.add_child(dialogBox)
	dialogBox.global_position = dialogBoxPosition
	dialogBox.displayText(pages[currentPage])
	canAdvancePage = false                                                      # Espera a página ser totalmente exibida pelo objeto `DialogBox`, e quando o processo de exibição termina, `DialogBox` emite um sinal de volta pra cá que chama `_onAllTextDisplayed`.

func _onAllTextDisplayed():
	canAdvancePage = true

func _unhandled_input(event: InputEvent) -> void: 
	if (event.is_action_pressed("interact") && \
	   isMessageActive && canAdvancePage):                                      # Passa para a próxima página da mensagem.
		dialogBox.queue_free()
		currentPage += 1
		if currentPage >= pages.size():                                  
			isMessageActive = false
			currentPage = 0
			return
		showText()
