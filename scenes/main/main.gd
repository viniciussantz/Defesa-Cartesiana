extends Node2D

# Isso carrega a cena da torre, para podermos criar cópias dela em tempo real
const CENA_ATALAIA = preload("res://scenes/torres/atalaia.tscn")

# Tamanho de cada célula da grade, em pixels
@export var tamanho_celula: int = 64


func _ready() -> void:
	$BotaoConstruir.pressed.connect(_on_botao_construir_pressed)


func _on_botao_construir_pressed() -> void:
	var x: int = int($InputX.text)
	var y: int = int($InputY.text)

	var posicao_mundo: Vector2 = grade_para_mundo(x, y)

	var nova_torre = CENA_ATALAIA.instantiate()
	nova_torre.position = posicao_mundo
	$Torres.add_child(nova_torre)


func grade_para_mundo(x: int, y: int) -> Vector2:
	# Converte uma coordenada de grade (ex: 3, 5) em uma posição real
	# de tela/mundo em pixels. Esse é o requisito de "conversão de
	# coordenadas" que vocês mencionaram na proposta.
	return Vector2(x * tamanho_celula, y * tamanho_celula)
