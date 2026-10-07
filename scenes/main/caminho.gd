@tool
extends Path3D

@export var no_maloca: Node3D:
	set(valor):
		no_maloca = valor
		atualizar_caminho()

@export var forcar_atualizacao: bool = false:
	set(valor):
		atualizar_caminho()

@export_range(1.0, 25.0) var força_curva: float = 10.0:
	set(valor):
		força_curva = valor
		atualizar_caminho()

func _ready() -> void:
	atualizar_caminho()

func atualizar_caminho() -> void:
	if not is_inside_tree() or not curve:
		return

	# Se a Maloca estiver configurada, garante que o último ponto esteja na posição dela
	if is_instance_valid(no_maloca) and no_maloca.is_inside_tree():
		var pos_local_maloca = to_local(no_maloca.global_position)
		pos_local_maloca.y = 0.1
		
		# Atualiza a posição do último ponto para a Maloca
		if curve.point_count > 0:
			curve.set_point_position(curve.point_count - 1, pos_local_maloca)

	# Suaviza as tangentes dos pontos que você editou manualmente no Viewport
	var qtd_pontos = curve.point_count
	for i in range(qtd_pontos):
		var vetor_in = Vector3.ZERO
		var vetor_out = Vector3.ZERO

		if i > 0 and i < qtd_pontos - 1:
			var pos_atual = curve.get_point_position(i)
			var pos_anterior = curve.get_point_position(i - 1)
			var pos_proximo = curve.get_point_position(i + 1)

			var dist_anterior = pos_atual.distance_to(pos_anterior)
			var dist_proximo = pos_atual.distance_to(pos_proximo)
			
			var direcao = (pos_proximo - pos_anterior).normalized()
			
			# Limita a tangente a no máximo 40% do menor segmento vizinho,
			# para a curva nunca "estourar"/fazer laço em viradas fechadas
			var forca_segura = min(força_curva, min(dist_anterior, dist_proximo) * 0.4)

			vetor_in = -direcao * forca_segura
			vetor_out = direcao * forca_segura
			
		curve.set_point_in(i, vetor_in)
		curve.set_point_out(i, vetor_out)
