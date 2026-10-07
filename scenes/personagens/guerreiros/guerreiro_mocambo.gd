extends CharacterBody3D

@export var velocidade_movimento: float = 3.0
@export var dano: int = 8
@export var intervalo_ataque: float = 1.0
@export var vida_maxima: int = 40

var destino_rally: Vector3
var em_posicao_rally: bool = false

var inimigos_no_alcance: Array = []
var tempo_ate_ataque: float = 0.0
var vida_atual: int


func _ready() -> void:
	vida_atual = vida_maxima
	add_to_group("guerreiros")
	$AreaAlcance.body_entered.connect(_on_body_entered)
	$AreaAlcance.body_exited.connect(_on_body_exited)


func definir_ponto_rally(posicao: Vector3) -> void:
	destino_rally = posicao
	em_posicao_rally = false


func _physics_process(delta: float) -> void:
	tempo_ate_ataque = max(0.0, tempo_ate_ataque - delta)

	if not em_posicao_rally:
		_andar_ate_rally()

	# Ataque funciona em qualquer momento, inclusive durante a caminhada
	var alvo = _escolher_alvo()
	if alvo != null:
		_encarar(alvo)
		if tempo_ate_ataque <= 0.0:
			atacar(alvo)


func _andar_ate_rally() -> void:
	var direcao = destino_rally - global_position
	direcao.y = 0.0

	if direcao.length() > 0.2:
		velocity = direcao.normalized() * velocidade_movimento
		move_and_slide()
	else:
		velocity = Vector3.ZERO
		em_posicao_rally = true


func _escolher_alvo() -> Node3D:
	# Descarta inimigos já destruídos ou que estão morrendo (saem do grupo ao morrer)
	inimigos_no_alcance = inimigos_no_alcance.filter(
		func(i): return is_instance_valid(i) and i.is_in_group("inimigos")
	)

	var mais_proximo: Node3D = null
	var menor_dist := INF
	for inimigo in inimigos_no_alcance:
		var d = global_position.distance_to(inimigo.global_position)
		if d < menor_dist:
			menor_dist = d
			mais_proximo = inimigo
	return mais_proximo


func _encarar(alvo: Node3D) -> void:
	var olhar_para = alvo.global_position
	olhar_para.y = global_position.y  # gira só no plano horizontal
	if olhar_para.distance_to(global_position) > 0.1:
		look_at(olhar_para, Vector3.UP)


func atacar(alvo: Node3D) -> void:
	tempo_ate_ataque = intervalo_ataque
	if alvo.has_method("receber_dano"):
		alvo.receber_dano(dano)


func receber_dano(quantidade: int) -> void:
	vida_atual -= quantidade
	if vida_atual <= 0:
		remove_from_group("guerreiros")
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("inimigos"):
		inimigos_no_alcance.append(body)


func _on_body_exited(body: Node3D) -> void:
	inimigos_no_alcance.erase(body)
