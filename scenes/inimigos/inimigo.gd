extends CharacterBody3D

@export var vida_maxima: int = 30
var vida_atual: int

@export var velocidade: float = 3.0

var caminho: Array = []
var indice_caminho_atual: int = 1

# Gravidade, para manter o inimigo "grudado" no chão em 3D
var gravidade: float = 9.8


func _ready() -> void:
	vida_atual = vida_maxima
	add_to_group("inimigos")
	$blockbench_export/AnimationPlayer.play("andar")
	$blockbench_export/AnimationPlayer.get_animation("andar").loop_mode = Animation.LOOP_LINEAR


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravidade * delta

	if indice_caminho_atual >= caminho.size():
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	var destino: Vector3 = caminho[indice_caminho_atual]
	var direcao: Vector3 = (destino - global_position)
	direcao.y = 0.0
	direcao = direcao.normalized()

	velocity.x = direcao.x * velocidade
	velocity.z = direcao.z * velocidade

	# Gira o personagem para encarar a direção do movimento
	if direcao.length() > 0.01:
		var alvo_look: Vector3 = global_position + direcao
		look_at(alvo_look, Vector3.UP)

	move_and_slide()

	var pos_plana := Vector2(global_position.x, global_position.z)
	var destino_plano := Vector2(destino.x, destino.z)
	if pos_plana.distance_to(destino_plano) < 0.6:
		indice_caminho_atual += 1


func receber_dano(quantidade: int) -> void:
	vida_atual -= quantidade
	if vida_atual <= 0:
		queue_free()
