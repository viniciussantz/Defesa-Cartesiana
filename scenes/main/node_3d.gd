extends Node3D

@export var cena_inimigo: PackedScene
@export var path_do_caminho: Path3D

@export var qtd_inimigos := 5
@export var intervalo_spawn := 1

var _ja_iniciou := false

func _ready() -> void:
	pass

func iniciar_horda() -> void:
	if _ja_iniciou:
		return  # trava pra não spawnar de novo se chamarem 2x
	_ja_iniciou = true
	
	for i in qtd_inimigos:
		_spawnar_inimigo()
		await get_tree().create_timer(intervalo_spawn).timeout
		
func _spawnar_inimigo() -> void:
	var inimigo = cena_inimigo.instantiate()
	add_child(inimigo)
	
	var pontos: Array = []
	var curva := path_do_caminho.curve

	for i in curva.point_count:
		var local_pos := curva.get_point_position(i)
		pontos.append(path_do_caminho.to_global(local_pos))
		

	inimigo.caminho = pontos
	inimigo.global_position = pontos[0]
