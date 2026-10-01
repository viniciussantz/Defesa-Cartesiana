extends Path3D

const PONTOS := [
	Vector2(15, 115),
	Vector2(25, 85),
	Vector2(18, 55),
	Vector2(-10, 35),
	Vector2(-30, 15),
	Vector2(-25, -10),
	Vector2(-35, -35),
	Vector2(-15, -60),
	Vector2(10, -75),
	Vector2(20, -95),
	Vector2(0, -115),
]

func _ready() -> void:
	curve = Curve3D.new()
	for p in PONTOS: 
		curve.add_point(Vector3(p.x, 0.1, p.y))
	
