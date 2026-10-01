extends Node3D

@export var cena_inimigo: PackedScene
@export var path_do_caminho: Path3D

@export var qtd_inimigos := 5
@export var intervalo_spawn := 1.0

var _ja_iniciou := false


func _ready() -> void:
	pass


func iniciar_horda() -> void:
	if _ja_iniciou:
		return  # Trava para não spawnar de novo se chamarem 2x
	
	# Validação de segurança para evitar erros
	if not cena_inimigo or not path_do_caminho:
		push_warning("Spawner: 'cena_inimigo' ou 'path_do_caminho' não foram atribuídos no Inspector!")
		return
		
	_ja_iniciou = true

	var main = get_parent()
	if main and main.has_method("tocar_musica_horda"):
		main.tocar_musica_horda()

	# Obtém os pontos já suavizados da curva uma única vez para toda a horda
	var pontos_globais = _obter_pontos_suaves_do_caminho()

	for i in qtd_inimigos:
		_spawnar_inimigo(pontos_globais)
		await get_tree().create_timer(intervalo_spawn).timeout


func _spawnar_inimigo(pontos: Array[Vector3]) -> void:
	if pontos.is_empty():
		return

	var inimigo = cena_inimigo.instantiate()
	add_child(inimigo)

	inimigo.caminho = pontos
	inimigo.global_position = pontos[0]


func _obter_pontos_suaves_do_caminho() -> Array[Vector3]:
	var pontos_globais: Array[Vector3] = []
	var curva := path_do_caminho.curve

	if not curva:
		return pontos_globais

	# get_baked_points() pega todos os pontos interpolados ao longo da curva Bezier
	var pontos_locais = curva.get_baked_points()
	
	for ponto_local in pontos_locais:
		pontos_globais.append(path_do_caminho.to_global(ponto_local))

	return pontos_globais
