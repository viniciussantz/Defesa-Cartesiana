extends CharacterBody3D

@export var vida_maxima: int = 30
var vida_atual: int

@export var velocidade: float = 3.0

var caminho: Array = []
var indice_caminho_atual: int = 0

# Gravidade, para manter o inimigo "grudado" no chão em 3D
var gravidade: float = 9.8


func _ready() -> void:
	vida_atual = vida_maxima
	add_to_group("inimigos")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravidade * delta

	if indice_caminho_atual >= caminho.size():
		move_and_slide()
		return

	var destino: Vector3 = caminho[indice_caminho_atual]
	var direcao: Vector3 = (destino - global_position)
	direcao.y = 0.0  # ignora diferença de altura no cálculo de direção
	direcao = direcao.normalized()

	velocity.x = direcao.x * velocidade
	velocity.z = direcao.z * velocidade

	move_and_slide()

	if global_position.distance_to(destino) < 0.2:
		indice_caminho_atual += 1


func receber_dano(quantidade: int) -> void:
	vida_atual -= quantidade
	if vida_atual <= 0:
		queue_free()
