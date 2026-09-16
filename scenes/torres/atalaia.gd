extends Node3D

@export var intervalo_ataque: float = 1.0
@export var dano: int = 10

var inimigos_no_alcance: Array = []


func _ready() -> void:
	$Timer.wait_time = intervalo_ataque
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start()

	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("inimigos"):
		inimigos_no_alcance.append(body)


func _on_body_exited(body: Node3D) -> void:
	if body in inimigos_no_alcance:
		inimigos_no_alcance.erase(body)


func _on_timer_timeout() -> void:
	if inimigos_no_alcance.size() > 0:
		var alvo = inimigos_no_alcance[0]
		atacar(alvo)


func atacar(inimigo: Node3D) -> void:
	if inimigo.has_method("receber_dano"):
		inimigo.receber_dano(dano)
