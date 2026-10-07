extends CharacterBody3D

@export var vida_maxima: int = 40
var vida_atual: int

@export var velocidade: float = 15.0

# Bloqueio por guerreiros
@export var alcance_bloqueio: float = 3.0
@export var dano_ataque: int = 5
@export var intervalo_ataque: float = 1.0
var tempo_ate_ataque: float = 0.0

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

	tempo_ate_ataque = max(0.0, tempo_ate_ataque - delta)

	# Se há um guerreiro por perto, para e ataca em vez de seguir o caminho
	var bloqueador := _guerreiro_bloqueando()
	if bloqueador != null:
		velocity.x = 0.0
		velocity.z = 0.0
		_encarar(bloqueador)
		if tempo_ate_ataque <= 0.0:
			tempo_ate_ataque = intervalo_ataque
			if bloqueador.has_method("receber_dano"):
				bloqueador.receber_dano(dano_ataque)
		move_and_slide()  # mantém a gravidade aplicando
		return

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

	if direcao.length() > 0.01:
		var alvo_look: Vector3 = global_position + direcao
		look_at(alvo_look, Vector3.UP)

	move_and_slide()

	var pos_plana := Vector2(global_position.x, global_position.z)
	var destino_plano := Vector2(destino.x, destino.z)
	if pos_plana.distance_to(destino_plano) < 0.6:
		indice_caminho_atual += 1


func _guerreiro_bloqueando() -> Node3D:
	var mais_proximo: Node3D = null
	var menor := alcance_bloqueio
	var pos := Vector2(global_position.x, global_position.z)
	for g in get_tree().get_nodes_in_group("guerreiros"):
		if not is_instance_valid(g):
			continue
		var d := pos.distance_to(Vector2(g.global_position.x, g.global_position.z))
		if d < menor:
			menor = d
			mais_proximo = g
	return mais_proximo


func _encarar(alvo: Node3D) -> void:
	var olhar_para := alvo.global_position
	olhar_para.y = global_position.y
	if olhar_para.distance_to(global_position) > 0.1:
		look_at(olhar_para, Vector3.UP)


func receber_dano(quantidade: int) -> void:
	vida_atual -= quantidade

	if has_node("SomDano"):
		# Variação leve de tom para o som não ficar repetitivo (0.9 a 1.1)
		$SomDano.pitch_scale = randf_range(0.9, 1.1)
		$SomDano.play()

	if vida_atual <= 0:
		_morrer()


func _morrer() -> void:
	# Esconde a malha visual e desativa a movimentação/colisão
	visible = false
	set_physics_process(false)
	remove_from_group("inimigos")

	if has_node("CollisionShape3D"):
		$CollisionShape3D.disabled = true

	# Espera o som de dano/morte terminar de tocar antes de deletar o nó
	if has_node("SomDano") and $SomDano.playing:
		await $SomDano.finished

	queue_free()
