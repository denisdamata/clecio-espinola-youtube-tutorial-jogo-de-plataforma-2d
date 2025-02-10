extends Control

@onready var coinCounter := $MarginContainer/CoinHBC/CoinCounterLabel
@onready var scoreCounter := $MarginContainer/ScoreHBC/ScoreCounterLabel
@onready var timerCounter := $MarginContainer/TimerHBC/TimerCounterLabel
@onready var lifeCounter := $MarginContainer/LifeHBC/LifeCounterLabel
@onready var clockTimer := $Control/ClockTimer

var minutes := 0
var seconds := 0
@export_range(0, 5) var totalDurationMinutes := 1
@export_range(0, 59) var totalDurationSeconds := 0

signal time_is_up

func _ready() -> void:                         
	updateGlobals()
	timerCounter.text = str("%02d" % totalDurationMinutes) + ":" +\
	                    str("%02d" % totalDurationSeconds) 
	minutes = totalDurationMinutes
	seconds = totalDurationSeconds
	
func _process(delta: float) -> void:
	updateGlobals()
	if minutes == 0 && seconds == 0:
		emit_signal("time_is_up")

func updateGlobals():
	coinCounter.text = str("%04d" % Globals.coins)                              # Inteiro convertido para string e formatado
	scoreCounter.text = str("%06d" % Globals.score)  
	lifeCounter.text = str("%02d" % Globals.playerLife)

func _on_ClockTimer_timeout():
	if seconds == 0:
		if minutes > 0:
			minutes -= 1
			seconds = 60
		else: 
			return                                                              # Evita tempo negativo
	seconds -= 1

	timerCounter.text = str("%02d" % minutes) + ":" +\
	                    str("%02d" % seconds) 

