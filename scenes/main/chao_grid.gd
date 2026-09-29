extends MeshInstance3D

@export var largura := 20
@export var profundidade := 20

@export var centro_serra := Vector2(8, -8)
@export var comprimento_serra := 12.0   
@export var largura_serra := 4.0        
@export var altura_serra := 6.0
@export var angulo_serra_graus := 20.0 

func _ready() -> void:
	gerar_terreno()
	
func altura_em(x: float, z: float) -> float:
	var p := Vector2(x, z) - centro_serra
	
	var ang := deg_to_rad(angulo_serra_graus)
	var px : float = p.x * cos(ang) + p.y * sin(ang)
	var pz : float = -p.x * sin(ang) + p.y * cos(ang)
	
	var d : float = sqrt(pow(px / (comprimento_serra * 0.5), 2) + pow(pz / (largura_serra * 0.5), 2))
	var t : float = clamp(1.0 - d, 0.0, 1.0)
	t = t * t * (3.0 - 2.0 * t)  
	
	var ondulacao : float = sin(px * 1.3) * 0.15 + 1.0
	return t * altura_serra * ondulacao
	
func gerar_terreno() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for x in range(-largura, largura):
		for z in range(-profundidade, profundidade):
			var y1 := altura_em(x, z)
			var y2 := altura_em(x + 1, z)
			var y3 := altura_em(x, z + 1)
			var y4 := altura_em(x + 1, z + 1)

			var p1 := Vector3(x, y1, z)
			var p2 := Vector3(x + 1, y2, z)
			var p3 := Vector3(x, y3, z + 1)
			var p4 := Vector3(x + 1, y4, z + 1)

			st.add_vertex(p1); st.add_vertex(p3); st.add_vertex(p2)
			st.add_vertex(p2); st.add_vertex(p3); st.add_vertex(p4)
	
	st.generate_normals()
	mesh = st.commit()
	create_trimesh_collision()
