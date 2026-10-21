extends CanvasLayer

const ESCENA_MENU := "res://menu_principal.tscn"
var juego: Node = null
var modo := "guardar"   # "guardar" o "cargar"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	$Botones/BtnContinuar.pressed.connect(cerrar)
	$Botones/BtnGuardar.pressed.connect(_abrir_ranuras.bind("guardar"))
	$Botones/BtnCargar.pressed.connect(_abrir_ranuras.bind("cargar"))
	$Botones/BtnMenu.pressed.connect(_on_menu)
	$Ranuras/BtnVolver.pressed.connect(_on_volver)

func configurar(j: Node) -> void:
	juego = j

func abrir(puede_guardar: bool = true) -> void:
	get_tree().paused = true
	$Ranuras.hide()
	$Botones.show()
	$Botones/BtnGuardar.disabled = not puede_guardar
	$Botones/BtnCargar.disabled = not GestorPartidas.hay_partidas()
	$Aviso.text = "" if puede_guardar else "La partida terminó: ya no se puede guardar"
	show()

func cerrar() -> void:
	hide()
	get_tree().paused = false

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		if $Ranuras.visible:
			_on_volver()
		else:
			cerrar()
		get_viewport().set_input_as_handled()

func _abrir_ranuras(m: String) -> void:
	modo = m
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
		var hay: bool = GestorPartidas.existe(i)
		if hay:
			var d := GestorPartidas.cargar(i)
			b.text = "Ranura %d  -  %s" % [i, d.get("fecha", "")]
		else:
			b.text = "Ranura %d  -  vacía" % i
		if modo == "cargar":
			b.disabled = not hay
			b.pressed.connect(_cargar_de.bind(i))
		else:
			if hay:
				b.text += "  (sobrescribir)"
			b.pressed.connect(_guardar_en.bind(i))
		$Ranuras/Lista.add_child(b)

func _guardar_en(n: int) -> void:
	if GestorPartidas.guardar(n, juego.datos_de_partida()):
		$Aviso.text = "Partida guardada en la ranura %d" % n
	else:
		$Aviso.text = "No se pudo guardar"
	refrescar_ranuras()

func _cargar_de(n: int) -> void:
	GestorPartidas.ranura_a_cargar = n
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(ESCENA_MENU)
