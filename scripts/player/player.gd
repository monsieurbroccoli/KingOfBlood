# Diese Klasse repräsentiert einen spielbaren Charakter, der sich bewegen und animieren kann.
class_name Player extends CharacterBody2D

# Die Richtung, in die der Spieler aktuell schaut (standardmäßig: nach unten).
var cardinal_direction : Vector2 = Vector2.DOWN
# Die Eingaberichtung basierend auf Tasteneingaben (x und y).
var direction : Vector2 = Vector2.ZERO

# Referenz auf den AnimationPlayer-Knoten im Szenenbaum.
@onready var animation_player : AnimationPlayer = $AnimationPlayer
# Referenz auf den Sprite2D-Knoten (für Richtungsspiegelung und Darstellung).
@onready var sprite : Sprite2D = $Sprite2D
@onready var state_machine: PlayerStateMachine = $StateMachine


# Wird aufgerufen, wenn der Knoten das erste Mal in den Szenenbaum geladen wird.
func _ready() -> void:
	state_machine.Initialize(self)
	pass # (Hier könnte Initialisierungslogik stehen.)


# Läuft jeden Frame (unabhängig von der Physik-Engine).
func _process(delta: float) -> void:
	# Berechnet die horizontale Eingaberichtung: rechts positiv, links negativ.
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	# Berechnet die vertikale Eingaberichtung: unten positiv, oben negativ.
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction = direction.normalized() # fixes diagonal speed bug
	pass


# Physikberechnung — sorgt dafür, dass der Körper sich korrekt bewegt und mit Kollisionen interagiert.
func _physics_process(delta: float) -> void:
	move_and_slide()


# Aktualisiert die Blickrichtung des Charakters basierend auf der Eingabe.
func SetDirection() -> bool:
	var new_dir : Vector2 = cardinal_direction  # Speichert die bisherige Blickrichtung.
	
	# Kein Input -> keine Richtungsänderung.
	if direction == Vector2.ZERO:
		return false
	
	# Wenn sich nur horizontal bewegt wird, setze Blickrichtung auf links/rechts.
	if direction.y == 0:
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	# Wenn sich nur vertikal bewegt wird, setze Blickrichtung auf oben/unten.
	elif direction.x == 0:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN
	
	# Wenn keine Änderung der Richtung, verlasse die Funktion.
	if new_dir == cardinal_direction:
		return false
	
	# Speichere die neue Blickrichtung.
	cardinal_direction = new_dir
	# Spiegele den Sprite, falls nach links geschaut wird.
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	
	return true


# Spielt die passende Animation ab (z. B. "walk_down", "idle_side").
func UpdateAnimation( state: String ) -> void:
	animation_player.play(state + "_" + AnimDirection())
	pass


# Gibt den String-Namen der Blickrichtung für die Animation zurück.
func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"
