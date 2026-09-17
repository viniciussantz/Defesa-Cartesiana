extends Path3D

const PONTOS := [
	Vector2(0, 0),
	Vector2(10, 0),
	Vector2(10, -5),
	Vector2(-20, 10),
	Vector2(7, 7),
]

func _ready() -> void:
	curve = Curve3D.new()
	for p in PONTOS: 
		curve.add_point(Vector3(p.x, 0.1, p.y))
	
