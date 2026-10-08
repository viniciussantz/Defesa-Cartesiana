extends Node3D

# Responsável por todo o sistema de construção de torres:
# mostra um "fantasma" da torre seguindo o mouse, valida se o local é permitido
# e instancia a torre real quando o jogador clica.

# Dicionário que liga o nome de cada torre à sua cena. preload() carrega o arquivo
# na compilação, então não há atraso na hora de construir.
const CENAS := {
	"atalaia": preload("res://scenes/torres/atalaia.tscn"),
	"mocambo": preload("res://scenes/torres/mocambo.tscn"),
}

@export var tamanho_celula: float = 2.0                   # lado de cada célula da grade (igual ao do shader do chão)
@export var limite_mapa: Vector2 = Vector2(50.0, 125.0)   # |x| e |z| máximos onde é permitido construir
@export var distancia_minima_caminho: float = 3.0         # distância mínima da torre até o centro da estrada
@export var cor_valida: Color = Color(0.2, 1.0, 0.3, 0.45)    # tom do fantasma quando pode construir
@export var cor_invalida: Color = Color(1.0, 0.2, 0.2, 0.45)  # tom do fantasma quando não pode

# Referências a outros nós da cena Main. Os caminhos são relativos a este nó,
# por isso o ColocadorTorres precisa ser filho direto de Main.
@onready var caminho: Path3D = get_node("../Caminho")
@onready var container_torres: Node3D = get_node("../Estruturas/Torres")
@onready var horda: Node = get_node("../Horda")
@onready var btn_atalaia: Button = get_node("../CanvasLayer/MenuTorres/BtnAtalaia")
@onready var btn_mocambo: Button = get_node("../CanvasLayer/MenuTorres/BtnMocambo")
@onready var label_moedas: Label = get_node("../CanvasLayer/LabelMoedas")

var selecionada: String = ""      # nome da torre escolhida ("" = nenhuma, sem modo de construção ativo)
var fantasma: Node3D              # instância translúcida que acompanha o mouse
var celula: Vector2i = Vector2i.ZERO   # célula da grade sob o mouse (coordenadas cartesianas inteiras)
var ocupadas: Dictionary = {}     # células que já têm torre: {Vector2i: torre}
var horda_iniciada: bool = false  # garante que a horda só começa uma vez
var material_fantasma: StandardMaterial3D = StandardMaterial3D.new()  # material compartilhado que tinge o fantasma

const CUSTOS := {
	"atalaia": 50,
	"mocambo": 80,
}

# Roda uma vez quando o nó entra na cena.
# Configura o material translúcido do fantasma e liga os botões do menu às seleções.
func _ready() -> void:
	# Unshaded: a cor não depende da iluminação, então o verde/vermelho fica sempre nítido.
	material_fantasma.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Habilita o canal alfa, necessário pro fantasma ser translúcido.
	material_fantasma.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	# bind() anexa o nome da torre como argumento extra do sinal "pressed",
	# assim uma única função atende os dois botões.
	btn_atalaia.pressed.connect(_selecionar.bind("atalaia"))
	btn_mocambo.pressed.connect(_selecionar.bind("mocambo"))
	
	btn_atalaia.text = "Atalaia (%d)" % CUSTOS["atalaia"]
	btn_mocambo.text = "Mocambo (%d)" % CUSTOS["mocambo"]
	Economia.moedas_mudaram.connect(_atualizar_moedas)
	_atualizar_moedas(Economia.moedas)

func _atualizar_moedas(total: int) -> void:
	label_moedas.text = "Moedas: %d" % total
	
# Roda a cada frame. Enquanto há um fantasma, move ele pra célula sob o mouse
# e atualiza a cor conforme o local seja válido ou não.
func _process(_delta: float) -> void:
	if fantasma == null:
		return

	# gui_get_hovered_control() devolve o Control sob o mouse (ou null).
	# Se o mouse está sobre um botão, esconde o fantasma pra não atrapalhar o menu.
	var sobre_ui: bool = get_viewport().gui_get_hovered_control() != null
	# Sem tipo explícito de propósito: o retorno pode ser Vector3 ou null (Variant).
	var ponto = _posicao_no_chao()
	if ponto == null or sobre_ui:
		fantasma.visible = false
		return

	var p: Vector3 = ponto
	# Arredonda a posição do mouse pra célula mais próxima (snap na grade).
	celula = Vector2i(roundi(p.x / tamanho_celula), roundi(p.z / tamanho_celula))
	# Converte a célula de volta pra posição no mundo (centro da célula, no chão).
	var pos: Vector3 = Vector3(celula.x * tamanho_celula, 0.0, celula.y * tamanho_celula)

	fantasma.global_position = pos
	fantasma.visible = true
	# Altera a cor do material compartilhado: todas as partes do fantasma mudam juntas.
	material_fantasma.albedo_color = cor_valida if _pode_construir(celula, pos) else cor_invalida


# Recebe os eventos de entrada que a interface não consumiu.
# Como é "unhandled", cliques em botões e painéis nunca chegam aqui.
# Clique esquerdo constrói na célula atual; Esc cancela a seleção.
func _unhandled_input(event: InputEvent) -> void:
	if fantasma == null:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_construir(celula)
		# Marca o evento como tratado pra outros scripts (ex.: a câmera) não reagirem ao mesmo clique.
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_cancelar()


# Entra no modo de construção: cria o fantasma da torre escolhida.
# É chamada pelos botões, que enviam o nome da torre via bind().
func _selecionar(nome: String) -> void:
	# Limpa uma seleção anterior, pra nunca existirem dois fantasmas ao mesmo tempo.
	_cancelar()
	selecionada = nome

	var cena: PackedScene = CENAS[nome]
	fantasma = cena.instantiate()
	# Remove o script da torre ANTES de entrar na árvore: o fantasma é só visual,
	# então não pode atirar, gerar soldados, tocar som nem rodar o _ready() da torre.
	fantasma.set_script(null)
	# Garante que nada nele processe (nem física, nem timers) enquanto existir.
	fantasma.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(fantasma)
	_aplicar_overlay(fantasma)


# Sai do modo de construção e descarta o fantasma.
# Chamada ao apertar Esc, ao trocar de torre e depois de construir.
func _cancelar() -> void:
	selecionada = ""
	if fantasma != null:
		# queue_free() remove o nó com segurança no fim do frame.
		fantasma.queue_free()
		fantasma = null


# Percorre a árvore do fantasma e aplica o material translúcido em todas as malhas.
# É recursiva porque o modelo da torre pode ter várias malhas aninhadas.
# material_overlay desenha o material POR CIMA do original, sem substituí-lo,
# então o fantasma mantém a forma da torre com uma tinta verde ou vermelha.
func _aplicar_overlay(no: Node) -> void:
	if no is GeometryInstance3D:
		(no as GeometryInstance3D).material_overlay = material_fantasma
	for filho in no.get_children():
		_aplicar_overlay(filho)


# Cria a torre de verdade na célula indicada, se o local for permitido.
# Também dispara a horda na primeira construção.
func _construir(c: Vector2i) -> void:
	var pos: Vector3 = Vector3(c.x * tamanho_celula, 0.0, c.y * tamanho_celula)
	# Revalida no momento do clique: o estado pode ter mudado desde o último frame.
	if not _pode_construir(c, pos):
		return
		
	var custo: int = CUSTOS[selecionada]
	Economia.gastar(custo)

	var cena: PackedScene = CENAS[selecionada]
	var torre: Node3D = cena.instantiate()
	# A ordem importa: o _ready() da torre roda no add_child(), então posição e
	# dependências precisam estar definidas ANTES. Sem isso, o Mocambo calcula o
	# ponto de guarda dos soldados a partir da origem do mapa.
	torre.position = pos
	# Repassa o caminho às torres que têm essa variável (o Mocambo usa pra achar
	# o ponto da estrada mais próximo). A Atalaia não tem, então é ignorada.
	if "caminho" in torre:
		torre.set("caminho", caminho)
	container_torres.add_child(torre, true)

	# Registra a célula como ocupada e libera ela automaticamente se a torre sair da cena.
	ocupadas[c] = torre
	torre.tree_exited.connect(func(): ocupadas.erase(c))

	# A primeira torre construída dá a largada da horda; as seguintes não repetem.
	if not horda_iniciada:
		horda_iniciada = true
		horda.iniciar_horda()

	_cancelar()


# Decide se uma torre pode ser construída na célula.
# Três regras: dentro do mapa, célula livre e longe da estrada dos inimigos.
func _pode_construir(c: Vector2i, pos: Vector3) -> bool:
	var custo: int = CUSTOS[selecionada]
	if Economia.moedas < custo:
		return false
	
	if absf(pos.x) > limite_mapa.x or absf(pos.z) > limite_mapa.y:
		return false
	if ocupadas.has(c):
		return false
	return _longe_do_caminho(pos)


# Verifica se a posição está a pelo menos "distancia_minima_caminho" da estrada.
# Compara só no plano XZ, ignorando a altura, porque o caminho fica a 0.1 de altura.
func _longe_do_caminho(pos: Vector3) -> bool:
	if caminho == null or caminho.curve == null:
		return true
	# A curva trabalha em coordenadas locais do Path3D, então converte entrada e saída.
	var local: Vector3 = caminho.to_local(pos)
	# get_closest_point() devolve o ponto da curva mais próximo da posição dada.
	var mais_perto: Vector3 = caminho.to_global(caminho.curve.get_closest_point(local))
	var a: Vector2 = Vector2(pos.x, pos.z)
	var b: Vector2 = Vector2(mais_perto.x, mais_perto.z)
	return a.distance_to(b) > distancia_minima_caminho


# Descobre em que ponto do chão o mouse está apontando.
# Lança um raio da câmera pelo cursor e calcula onde ele cruza o plano Y = 0.
# Faz a conta direto na matemática (sem física), então não depende do chão ter colisão.
# Devolve um Vector3, ou null se o raio não encontra o plano (ex.: olhando pro céu).
func _posicao_no_chao():
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam == null:
		return null
	var mouse: Vector2 = get_viewport().get_mouse_position()
	# Origem do raio (a câmera) e direção que passa pelo pixel do mouse.
	var origem: Vector3 = cam.project_ray_origin(mouse)
	var direcao: Vector3 = cam.project_ray_normal(mouse)
	# Plane(normal, distância): o chão é o plano horizontal que passa pela origem.
	return Plane(Vector3.UP, 0.0).intersects_ray(origem, direcao)
