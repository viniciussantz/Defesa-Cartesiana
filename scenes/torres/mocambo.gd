extends Node3D

@export var cena_guerreiro: PackedScene
@export var intervalo_spawn: float = 5.0
@export var max_guerreiros: int = 3

@export var distancia_rally: float = 12.0   # Distância da porta até o ponto de guarda
@export var variacao_rally: float = 2.5     # Área de espalhamento dos guerreiros no ponto de guarda

var guerreiros_ativos: Array = []
var ponto_rally: Vector3

func _ready() -> void:
	# Define o ponto de guarda padrão (3 unidades à frente no chão Y=0)
	ponto_rally = global_position + (transform.basis.z * distancia_rally)
	ponto_rally.y = 0.0

	$Timer.wait_time = intervalo_spawn
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start()

	# Gera o primeiro guerreiro assim que o Mocambo é construído
	_on_timer_timeout()


func _on_timer_timeout() -> void:
	# Remove guerreiros que foram destruídos/mortos em combate
	guerreiros_ativos = guerreiros_ativos.filter(func(guer): return is_instance_valid(guer))

	if guerreiros_ativos.size() < max_guerreiros and cena_guerreiro != null:
		gerar_guerreiro()


func gerar_guerreiro() -> void:
	var novo_guerreiro = cena_guerreiro.instantiate() as Node3D
	
	# Instancia o guerreiro na cena do jogo
	get_parent().add_child(novo_guerreiro)
	
	# Posiciona na porta ($PontoSpawn) ou na própria origem do Mocambo
	if has_node("PontoSpawn"):
		novo_guerreiro.global_position = $PontoSpawn.global_position
	else:
		novo_guerreiro.global_position = global_position
		
	novo_guerreiro.global_position.y = 0.0

	# Aplica uma leve variação na posição final para os guerreiros não ficarem sobrepostos
	var offset = Vector3(
		randf_range(-variacao_rally, variacao_rally),
		0.0,
		randf_range(-variacao_rally, variacao_rally)
		)
	var destino = ponto_rally + offset

	if novo_guerreiro.has_method("definir_ponto_rally"):
		novo_guerreiro.definir_ponto_rally(destino)

	guerreiros_ativos.append(novo_guerreiro)
