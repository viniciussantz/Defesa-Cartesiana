extends Node3D

const CENA_ATALAIA = preload("res://scenes/torres/atalaia.tscn")

@export var tamanho_celula: float = 2.0
@export var alcance_grid: int = 15 # Gera marcadores de -10 até +10

@onready var chao_grid: MeshInstance3D = $ChaoGrid

var container_marcadores: Node3D
var grid_visivel: bool = true

func _ready() -> void:
	$CanvasLayer/BotaoConstruir.pressed.connect(_on_botao_construir_pressed)
	gerar_marcadores_cartesiano()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			alternar_grid()
			
func alternar_grid() -> void:
	grid_visivel = !grid_visivel
	
	# Esconde ou mostra as legendas numéricas
	if container_marcadores:
		container_marcadores.visible = grid_visivel
		
	# Envia o novo estado para o material do Shader
	if chao_grid:
		var mat = chao_grid.get_surface_override_material(0) as ShaderMaterial
		if mat:
			mat.set_shader_parameter("exibir_grid", grid_visivel)
	
func gerar_marcadores_cartesiano() -> void:
	container_marcadores = Node3D.new()
	container_marcadores.name = "MarcadoresGrid"
	add_child(container_marcadores)

	for i in range(-alcance_grid, alcance_grid + 1):
		if i == 0:
			continue

		var label_x = Label3D.new()
		label_x.text = str(i)
		label_x.pixel_size = 0.01
		label_x.font_size = 48
		label_x.modulate = Color(1, 0.3, 0.3)
		label_x.position = Vector3(i * tamanho_celula, 0.1, 0.5)
		label_x.rotation_degrees.x = -90
		container_marcadores.add_child(label_x)

		var label_z = Label3D.new()
		label_z.text = str(i)
		label_z.pixel_size = 0.01
		label_z.font_size = 48
		label_z.modulate = Color(0.3, 0.7, 1)
		label_z.position = Vector3(0.5, 0.1, i * tamanho_celula)
		label_z.rotation_degrees.x = -90
		container_marcadores.add_child(label_z)

func _on_botao_construir_pressed() -> void:
	var x: int = int($CanvasLayer/InputX.text)
	var z: int = int($CanvasLayer/InputY.text)

	var posicao_mundo: Vector3 = grade_para_mundo(x, z)

	var nova_torre = CENA_ATALAIA.instantiate()
	nova_torre.position = posicao_mundo
	$Torres.add_child(nova_torre, true)


func grade_para_mundo(x: int, z: int) -> Vector3:
	# Converte coordenada de grade (x, z) em posição real no mundo 3D.
	# Y fica fixo em 0 porque as torres ficam sempre no chão.
	return Vector3(x * tamanho_celula, 0.0, z * tamanho_celula)
