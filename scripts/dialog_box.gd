# script/dialog-box.gd

# Classe usada por `dialog_manager.gd`.
# Configura espacialmente a caixa de diálogo e exibi uma página de texto com efeito de digitação. 

extends MarginContainer

@onready var textLabel = $LabelMarginMC/TextLabel
@onready var letterDisplayTimer = $LetterDisplayTimer

const MAX_WIDTH = 256

var pageText = ""                                                               # Texto de cada página do diálogo.
var letterIndex = 0

var letterDisplayTime := 0.07
var spaceDisplayTime := 0.05
var punctuactionDisplayTime := 0.02

signal textDisplayFinished()                                                    # Este sinal é todo implementado via script, ou seja, sem usar a interface do Godot.

func displayText(textToDisplay: String):                                        # Apenas configura as dimensões e posição da caixa de diálogo para o texto a ser exibido.
	pageText = textToDisplay
	textLabel.text = textToDisplay                                              # Ainda não exibe o texto no jogo, apenas armazena temporariamente para ajustar as dimensões da caixa de dialógo.

	await resized                                                               # Aguarda até que o nó seja redimensionado [Qwen].

	custom_minimum_size.x = min(size.x, MAX_WIDTH)                              # A largura da página é estática enquanto a altura é dinâmica, ou seja, a largura é definida antes da página ser exibida, com o tamanho do texto da página e no máximo 256, enquanto a altura da caixa de diálogo vai aumentando a medida que o texto é exibido. Obs.: método do `Control` pai do `MarginContainer`.

	if size.x > MAX_WIDTH:
		textLabel.autowrap_mode = TextServer.AUTOWRAP_WORD                      # Aciona a quebra de linha automática [Qwen].
		await resized
		custom_minimum_size.y = size.y

	global_position.x -= size.x/2
	global_position.y -= size.y + 24
	textLabel.text = ""
	displayLetter()                                                             # Dispara a iteração sobre o texto da página.

func displayLetter():                                                           # Função chamada para cada letra, acrescenta uma nova letra e exibe o texto da página acumulado.
	textLabel.text += pageText[letterIndex]
	letterIndex += 1

	if letterIndex >= pageText.length():                                        # Condição de parada do ciclo iterativo.
		textDisplayFinished.emit()
		return
	
	match pageText[letterIndex]:
		"!", "?", ",", ".":
			letterDisplayTimer.start(punctuactionDisplayTime)                   # `displayLetter` chama o temporizador, e a função do temporizador `_on_LetterDisplayTimer_timeout` chama `displayLetter`. Isto causa uma recursão indireta que itera sobre todas as letras do texto da página.
		" ":
			letterDisplayTimer.start(spaceDisplayTime)
		_:
			letterDisplayTimer.start(letterDisplayTime)

func _on_LetterDisplayTimer_timeout() -> void:
	displayLetter()






