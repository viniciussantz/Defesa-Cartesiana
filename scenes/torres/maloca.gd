extends Node3D

# Sinal emitido para a Main saber que o jogo acabou
signal destruida

@export var vida_maxima: float = 500.0
var vida_atual: float


func _ready() -> void:
	vida_atual = vida_maxima


func receber_dano(quantidade: float) -> void:
	vida_atual -= quantidade
	vida_atual = max(vida_atual, 0.0)
	
	print("Maloca atingida! Vida restante: ", vida_atual, "/", vida_maxima)

	if vida_atual <= 0.0:
		derrota()


func derrota() -> void:
	destruida.emit()
	print("GAME OVER: A Maloca foi destruída pelos invasores!")
	# Aqui você poderá chamar a tela de Game Over ou pausar o jogo
