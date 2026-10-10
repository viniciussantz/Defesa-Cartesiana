extends Node3D

@export var cena_inimigo: PackedScene
@export var path_do_caminho: Path3D

@export var qtd_inimigos := 5
@export var intervalo_spawn := 1.0

@export var total_hordas: int = 6     
@export var vida_extra_por_horda: int = 10 
@export var pausa_entre_hordas: float = 1.0

var horda_atual: int = 0
var inimigos_vivos: int = 0
var _ja_iniciou := false


func _ready() -> void:
	pass


func iniciar_horda() -> void:
	if _ja_iniciou:
		return  # Trava para não spawnar de novo se chamarem 2x
	_ja_iniciou = true
	
	for i in total_hordas:
		horda_atual = i
		await _executar_horda()
		# Entre hordas espera 1 segundo; depois da última não precisa.
		if i < total_hordas - 1:
			await get_tree().create_timer(pausa_entre_hordas).timeout
	
	# Validação de segurança para evitar erros
	if not cena_inimigo or not path_do_caminho:
		push_warning("Spawner: 'cena_inimigo' ou 'path_do_caminho' não foram atribuídos no Inspector!")
		return
		
	_ja_iniciou = true

	var main = get_parent()
	if main and main.has_method("tocar_musica_horda"):
		main.tocar_musica_horda()

	# Roda as hordas em sequência: cada await só termina quando a horda acaba.
	for i in total_hordas:
		horda_atual = i
		await _executar_horda()
		# Espera 1 segundo antes da próxima; depois da última não precisa.
		if i < total_hordas - 1:
			await get_tree().create_timer(pausa_entre_hordas).timeout

func _executar_horda() -> void:
	var pontos_globais: Array[Vector3] = _obter_pontos_suaves_do_caminho()

	for i in qtd_inimigos:
		_spawnar_inimigo(pontos_globais)
		await get_tree().create_timer(intervalo_spawn).timeout

	# Todos já nasceram; agora espera o contador chegar a zero (um check por frame).
	while inimigos_vivos > 0:
		await get_tree().process_frame



func _spawnar_inimigo(pontos: Array[Vector3]) -> void:
	
	var inimigo = cena_inimigo.instantiate()

	# A vida precisa ser mudada ANTES do add_child: o _ready() do inimigo copia
	# vida_maxima para vida_atual, e ele roda assim que entra na árvore.
	inimigo.vida_maxima += horda_atual * vida_extra_por_horda

	add_child(inimigo)

	# Conta o inimigo como vivo e desconta quando ele sair da cena (morto ou removido).
	inimigos_vivos += 1
	inimigo.tree_exited.connect(_ao_inimigo_sair)

	inimigo.caminho = pontos
	inimigo.global_position = pontos[0]

func _ao_inimigo_sair() -> void:
	inimigos_vivos -= 1

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
