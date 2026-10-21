extends Control

# Cambia esto por la ruta real de tu escena del juego
const ESCENA_JUEGO := "res://esenas/node_3d.tscn"

func _ready() -> void:
	$Botones/BtnNueva.pressed.connect(_on_nueva)
	$Botones/BtnContinuar.pressed.connect(_on_continuar)
	$Botones/BtnSalir.pressed.connect(get_tree().quit)
	$Ranuras/BtnVolver.pressed.connect(_on_volver)
	# Si no hay ninguna partida guardada, "Continuar" no tiene sentido
	$Botones/BtnContinuar.disabled = not hay_partidas()

func hay_partidas() -> bool:
	for i in range(1, GestorPartidas.MAX_RANURAS + 1):
		if GestorPartidas.existe(i):
			return true
	return false

func _on_nueva() -> void:
	GestorPartidas.ranura_a_cargar = -1
	get_tree().change_scene_to_file(ESCENA_JUEGO)

func _on_continuar() -> void:
	$Botones.hide()
	$Ranuras.show()
	refrescar_ranuras()

func _on_volver() -> void:
	$Ranuras.hide()
	$Botones.show()

func refrescar_ranuras() -> void:
	for h in $Ranuras/Lista.get_children():
		h.queue_free()
	for i in range(1, GestorPartidas.MAX_RANURAS + 1):
		var b := Button.new()
		if GestorPartidas.existe(i):
			var d := GestorPartidas.cargar(i)
			b.text = "Partida %d  -  %s" % [i, d.get("fecha", "")]
			b.pressed.connect(_cargar_ranura.bind(i))
		else:
			b.text = "Partida %d  -  vacía" % i
			b.disabled = true
		$Ranuras/Lista.add_child(b)

func _cargar_ranura(n: int) -> void:
	GestorPartidas.ranura_a_cargar = n
	get_tree().change_scene_to_file(ESCENA_JUEGO)
