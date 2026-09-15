extends CharacterBody2D

# Vida total do inimigo
@export var vida_maxima: int = 30
var vida_atual: int

# Velocidade de movimento (pixels por segundo)
@export var velocidade: float = 60.0

# Lista de pontos (Vector2) que o inimigo vai seguir, na ordem
var caminho: Array = []
var indice_caminho_atual: int = 0


func _ready() -> void:
	vida_atual = vida_maxima
	add_to_group("inimigos")


func _physics_process(delta: float) -> void:
	# _physics_process roda a cada "frame físico" — é aqui que movimento
	# e colisão devem ser calculados, ao contrário de _process (usado para
	# coisas que não envolvem física).

	if indice_caminho_atual >= caminho.size():
		return  # chegou ao fim do caminho, não faz nada

	var destino: Vector2 = caminho[indice_caminho_atual]
	var direcao: Vector2 = (destino - global_position).normalized()

	velocity = direcao * velocidade
	move_and_slide()

	if global_position.distance_to(destino) < 4.0:
		indice_caminho_atual += 1


func receber_dano(quantidade: int) -> void:
	vida_atual -= quantidade
	if vida_atual <= 0:
		queue_free()
