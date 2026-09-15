extends Node2D

# Tempo entre cada ataque, em segundos
@export var intervalo_ataque: float = 1.0

# Dano causado por ataque
@export var dano: int = 10

# Lista de inimigos que estão dentro do alcance da torre agora
var inimigos_no_alcance: Array = []

func _ready() -> void:
	# _ready() roda uma vez, quando a torre é criada no jogo.
	# Aqui a gente conecta os "sinais" (eventos) dos nós filhos a funções nossas.

	$Timer.wait_time = intervalo_ataque
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start()

	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	# Chamada automaticamente quando algo entra na área de alcance (Area2D)
	if body.is_in_group("inimigos"):
		inimigos_no_alcance.append(body)


func _on_body_exited(body: Node2D) -> void:
	# Chamada automaticamente quando algo sai da área de alcance
	if body in inimigos_no_alcance:
		inimigos_no_alcance.erase(body)


func _on_timer_timeout() -> void:
	# Chamada a cada "intervalo_ataque" segundos (definido pelo Timer)
	if inimigos_no_alcance.size() > 0:
		var alvo = inimigos_no_alcance[0]
		atacar(alvo)


func atacar(inimigo: Node2D) -> void:
	if inimigo.has_method("receber_dano"):
		inimigo.receber_dano(dano)
