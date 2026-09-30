extends CharacterBody3D

@export var velocidade_movimento: float = 3.0
var destino_rally: Vector3
var em_posicao_rally: bool = false


func definir_ponto_rally(posicao: Vector3) -> void:
	destino_rally = posicao
	em_posicao_rally = false


func _physics_process(_delta: float) -> void:
	# Se ainda não chegou ao ponto de guarda, anda até lá
	if not em_posicao_rally:
		var direcao = (destino_rally - global_position)
		direcao.y = 0.0 # Mantém no plano Y=0
		
		if direcao.length() > 0.2:
			velocity = direcao.normalized() * velocidade_movimento
			move_and_slide()
		else:
			velocity = Vector3.ZERO
			em_posicao_rally = true # Chegou à posição de guarda!
