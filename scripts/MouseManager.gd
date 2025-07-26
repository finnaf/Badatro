extends Node

# DRAG
var can_drag := false
var is_pressed := false
var is_dragging := false
var drag_target = null
var drag_start_position := Vector2.ZERO

const BIG_Z_VALUE = 100

const DRAG_THRESHOLD := 4

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_pressed = event.pressed

		if not is_pressed:
			if is_dragging:
				_end_drag()
				is_dragging = false
			else:
				if (drag_target):
					drag_target.on_clicked()
		
		drag_target = null
		can_drag = false

	elif event is InputEventMouseMotion:
		if is_pressed and not is_dragging:
			if can_drag and event.position.distance_to(drag_start_position) > DRAG_THRESHOLD:
				is_dragging = true
				drag_target.z_index += BIG_Z_VALUE
				if drag_target:
					drag_target._on_drag_start()

		if is_dragging and drag_target:
			drag_target._on_drag_motion(event)

func start_drag(card: Area2D, start_pos: Vector2):
	drag_target = card
	drag_start_position = start_pos
	is_pressed = true
	is_dragging = false
	
	if (not card.is_shop_card() and (card.is_card() or card.is_joker() or card.is_consumable())):
		can_drag = true

func _end_drag():
	if drag_target:
		drag_target.z_index -= BIG_Z_VALUE
		drag_target._on_drag_end()
