extends Node3D

const CENA_ATALAIA = preload("res://scenes/torres/atalaia.tscn")
const CENA_MOCAMBO = preload("res://scenes/torres/mocambo.tscn")

@export var tamanho_celula: float = 15.0
@export var alcance_grid: int = 15 # Gera marcadores de -15 até +15

@onready var chao_grid: MeshInstance3D = $ChaoGrid
@onready var trilha_construcao: AudioStreamPlayer = get_node_or_null("TrilhaConstrucao")
@onready var trilha_horda: AudioStreamPlayer = get_node_or_null("TrilhaHorda")

var container_marcadores: Node3D
var grid_visivel: bool = true
var primeira_torre_colocada := false
var rotacao_atual: float = 0.0 # Guarda a rotação em graus (0, 90, 180, 270)


func _ready() -> void:
	
	# Conecta os dois botões de construção
	if $CanvasLayer/MenuTorres.has_node("BtnAtalaia"):
		$CanvasLayer/MenuTorres/BtnAtalaia.pressed.connect(_on_botao_atalaia_pressed)
	if $CanvasLayer/MenuTorres.has_node("BtnMocambo"):
		$CanvasLayer/MenuTorres/BtnMocambo.pressed.connect(_on_botao_mocambo_pressed)
		
	if $CanvasLayer.has_node("InputX"):
		$CanvasLayer/InputX.text_submitted.connect(_on_input_x_submitted)
	if $CanvasLayer.has_node("InputY"):
		$CanvasLayer/InputY.text_submitted.connect(_on_input_y_submitted)

	gerar_marcadores_cartesiano()

	if trilha_construcao:
		trilha_construcao.volume_db = -10.0
		trilha_construcao.play()

	if trilha_horda:
		trilha_horda.volume_db = -80.0 # Começa muda
		trilha_horda.play()


func _unhandled_input(event: InputEvent) -> void:
	# Clique do mouse em qualquer área do jogo desmarca as caixas de texto
	if event is InputEventMouseButton and event.pressed:
		get_viewport().gui_release_focus()
	
	if event is InputEventKey and event.pressed and not event.echo:
		# Tecla ESPAÇO: Alterna a visualização da grade
		if event.keycode == KEY_SPACE:
			alternar_grid()
			
		# Tecla R: Gira a torre em 90 graus
		if event.keycode == KEY_R:
			rotacao_atual += 90.0
			if rotacao_atual >= 360.0:
				rotacao_atual = 0.0
			print("Rotação da construção definida para: ", rotacao_atual, "°")


func alternar_grid() -> void:
	grid_visivel = !grid_visivel

	if container_marcadores:
		container_marcadores.visible = grid_visivel

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


# Chamados ao clicar nos respectivos botões
func _on_botao_atalaia_pressed() -> void:
	construir_torre(CENA_ATALAIA)


func _on_botao_mocambo_pressed() -> void:
	construir_torre(CENA_MOCAMBO)


func construir_torre(cena_torre: PackedScene) -> void:
	var texto_x: String = $CanvasLayer/InputX.text
	var texto_z: String = $CanvasLayer/InputY.text

	# Evita erro caso os campos estejam vazios ao clicar
	if texto_x.strip_edges() == "" or texto_z.strip_edges() == "":
		print("Preencha as coordenadas X e Y primeiro!")
		return

	var x: int = int(texto_x)
	var z: int = int(texto_z)

	var posicao_mundo: Vector3 = grade_para_mundo(x, z)

	var nova_torre = cena_torre.instantiate()
	nova_torre.position = posicao_mundo
	nova_torre.rotation_degrees.y = rotacao_atual
	$Estruturas/Torres.add_child(nova_torre, true)

	if not primeira_torre_colocada:
		primeira_torre_colocada = true
		if has_node("Horda"):
			$Horda.iniciar_horda()


func grade_para_mundo(x: int, z: int) -> Vector3:
	return Vector3(x * tamanho_celula, 0.0, z * tamanho_celula)


func tocar_musica_horda() -> void:
	if trilha_construcao == null or trilha_horda == null:
		return

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(trilha_construcao, "volume_db", -80.0, 1.5)
	tween.tween_property(trilha_horda, "volume_db", -10.0, 1.5)


func tocar_musica_construcao() -> void:
	if trilha_construcao == null or trilha_horda == null:
		return

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(trilha_construcao, "volume_db", 0.0, 1.5)
	tween.tween_property(trilha_horda, "volume_db", -80.0, 1.5)
	
func _on_input_x_submitted(_texto: String) -> void:
	# Ao apertar Enter no InputX, passa o cursor automaticamente para o InputY
	if $CanvasLayer.has_node("InputY"):
		$CanvasLayer/InputY.grab_focus()
		
func _on_input_y_submitted(_texto: String) -> void:
	# Ao apertar Enter no InputY, remove o foco das caixas de texto
	get_viewport().gui_release_focus()
