extends Node3D

@export var velocidade := 25.0

var alvo: Node3D
var dano := 0
var _destino_fixo: Vector3

func iniciar(origem: Vector3, alvo_inimigo: Node3D, dano_causado: int) -> void:
	global_position = origem
	alvo = alvo_inimigo
	dano = dano_causado
	_destino_fixo = alvo_inimigo.global_position
	look_at(_destino_fixo, Vector3.UP)

func _physics_process(delta: float) -> void:
	var destino := _destino_fixo
	if is_instance_valid(alvo):
		destino = alvo.global_position
		look_at(destino, Vector3.UP)

	global_position = global_position.move_toward(destino, velocidade * delta)

	if global_position.distance_to(destino) < 0.3:
		if is_instance_valid(alvo) and alvo.has_method("receber_dano"):
			alvo.receber_dano(dano)
		queue_free()
