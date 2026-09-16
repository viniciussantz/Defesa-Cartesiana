extends Node3D

const CENA_ATALAIA = preload("res://scenes/torres/atalaia.tscn")

@export var tamanho_celula: float = 2.0


func _ready() -> void:
	$CanvasLayer/BotaoConstruir.pressed.connect(_on_botao_construir_pressed)


func _on_botao_construir_pressed() -> void:
	var x: int = int($CanvasLayer/InputX.text)
	var z: int = int($CanvasLayer/InputY.text)

	var posicao_mundo: Vector3 = grade_para_mundo(x, z)

	var nova_torre = CENA_ATALAIA.instantiate()
	nova_torre.position = posicao_mundo
	$Torres.add_child(nova_torre, true)


func grade_para_mundo(x: int, z: int) -> Vector3:
	# Converte coordenada de grade (x, z) em posição real no mundo 3D.
	# Y fica fixo em 0 porque as torres ficam sempre no chão.
	return Vector3(x * tamanho_celula, 0.0, z * tamanho_celula)
