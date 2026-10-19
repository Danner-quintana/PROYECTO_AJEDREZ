extends RefCounted

const TIPO_SALTADOR := "caballo"   # el tipo de pieza que salta al moverse

const CLAVES_IDLE := ["idle", "quiet", "pose", "static", "estatic", "stand"]
const CLAVES_CORRER := ["run", "corr", "walk", "camin"]
const CLAVES_SALTAR := ["jump", "salt"]

# Busca el AnimationPlayer del modelo y los nombres de sus animaciones
func preparar(p: Dictionary) -> void:
	p["anim_player"] = null
	p["anim_idle"] = ""
	p["anim_correr"] = ""
	p["anim_saltar"] = ""
	var lista = p["nodo"].find_children("*", "AnimationPlayer", true, false)
	if lista.is_empty():
		return
	var player: AnimationPlayer = lista[0]
	p["anim_player"] = player
	p["anim_idle"] = buscar(player, CLAVES_IDLE)
	p["anim_correr"] = buscar(player, CLAVES_CORRER)
	p["anim_saltar"] = buscar(player, CLAVES_SALTAR)
	# La pose y la carrera se repiten sin parar
	for clave in ["anim_idle", "anim_correr"]:
		if p[clave] != "":
			player.get_animation(p[clave]).loop_mode = Animation.LOOP_LINEAR
	quieto(p)

func buscar(player: AnimationPlayer, claves: Array) -> String:
	for nombre in player.get_animation_list():
		var n: String = String(nombre).to_lower()
		for c in claves:
			if n.contains(c):
				return String(nombre)
	return ""

func reproducir(p: Dictionary, clave: String) -> void:
	var player = p.get("anim_player", null)
	if player == null:
		return
	var nombre: String = p.get(clave, "")
	if nombre != "":
		player.play(nombre)

func quieto(p: Dictionary) -> void:
	reproducir(p, "anim_idle")

func saltar(p: Dictionary) -> void:
	reproducir(p, "anim_saltar")

# Animación mientras se desplaza (si no tiene, se queda en su pose y se desliza)
func moviendo(p: Dictionary) -> void:
	if p["tipo"] == TIPO_SALTADOR and p.get("anim_saltar", "") != "":
		saltar(p)
	else:
		reproducir(p, "anim_correr")

# Al empezar a moverse: gira hacia el destino y empieza la animación
func empezar_movimiento(p: Dictionary, destino_pos: Vector3) -> void:
	var dir: Vector3 = destino_pos - p["nodo"].position
	dir.y = 0.0
	if dir.length() > 0.01:
		p["nodo"].rotation.y = atan2(dir.x, dir.z)
	moviendo(p)

# Al llegar: vuelve a mirar al frente de su equipo y se queda quieto
func terminar_movimiento(p: Dictionary, giro_grados: float) -> void:
	p["nodo"].rotation_degrees.y = giro_grados
	quieto(p)
