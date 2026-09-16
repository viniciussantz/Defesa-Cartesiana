extends Node3D

@export_category("Movimentação")
@export var velocidade_movimento: float = 25.0
@export var suavizacao: float = 10.0

@export_category("Zoom")
@export var velocidade_zoom: float = 2.0
@export var zoom_min: float = 5.0
@export var zoom_max: float = 35.0

@export_category("Rotação")
@export var sensibilidade_mouse: float = 0.005

@onready var camera: Camera3D = $Camera3D

var _arrastando_mouse: bool = false
var _zoom_alvo: float = 15.0

func _ready() -> void:
	if camera:
		_zoom_alvo = camera.position.z

func _unhandled_input(event: InputEvent) -> void:
	# Ativa rotação segurando Botão Direito ou Botão do Meio (Scroll)
	if event is InputEventMouseButton:
		if event.button_index in [MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			_arrastando_mouse = event.pressed

		# Zoom com Scroll do Mouse
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_alvo = clamp(_zoom_alvo - velocidade_zoom, zoom_min, zoom_max)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_alvo = clamp(_zoom_alvo + velocidade_zoom, zoom_min, zoom_max)

	# Aplica rotação horizontal no pivô ao arrastar o mouse
	if event is InputEventMouseMotion and _arrastando_mouse:
		rotate_y(-event.relative.x * sensibilidade_mouse)

func _process(delta: float) -> void:
	_processar_movimento(delta)
	_processar_zoom(delta)

func _processar_movimento(delta: float) -> void:
	var input_dir := Vector2.ZERO

	# Checa W/S ou Setas (Cima/Baixo)
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		input_dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		input_dir.y += 1.0

	# Checa A/D ou Setas (Esquerda/Direita)
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		input_dir.x += 1.0

	# Normaliza para manter velocidade constante nas diagonais
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		var direcao := (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		direcao.y = 0.0 
		global_position += direcao * velocidade_movimento * delta

func _processar_zoom(delta: float) -> void:
	# Transição suave de aproximação/afastamento
	camera.position.z = lerp(camera.position.z, _zoom_alvo, suavizacao * delta)
	camera.position.y = lerp(camera.position.y, _zoom_alvo, suavizacao * delta)
