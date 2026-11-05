
extends Node2D

var speed = 150.0
var direction = Vector2(1, 1)

var screen_size = Vector2()
var window_size = Vector2()

var idle_timer = 0.0
var is_idling = false

var is_dragging = false
var drag_offset = Vector2i()
var is_eating = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D


func _ready() -> void:
	screen_size = Vector2(DisplayServer.screen_get_size())
	window_size = Vector2(DisplayServer.window_get_size())

	area.input_pickable = true
	animated_sprite.play("walk")

	if not area.input_event.is_connected(_on_area_input_event):
		area.input_event.connect(_on_area_input_event)


func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:

			if event.button_index == MOUSE_BUTTON_LEFT:
				is_dragging = true

				var mouse_screen_pos = DisplayServer.mouse_get_position()
				var win_pos = DisplayServer.window_get_position()

				drag_offset = mouse_screen_pos - win_pos
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				is_eating = !is_eating
				if is_eating:
					animated_sprite.play("eat")
				else:
					animated_sprite.play("walk")
					
					

		elif event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = false


func _physics_process(delta: float) -> void:
	if is_eating:
		return
	
	if is_dragging:
		var current_mouse_pos = DisplayServer.mouse_get_position()
		DisplayServer.window_set_position(current_mouse_pos - drag_offset)
		return

	if is_idling:
		idle_timer -= delta

		if idle_timer <= 0:
			is_idling = false
			speed = 150.0
			animated_sprite.play("walk")

		return

	var window_position = Vector2(DisplayServer.window_get_position())

	window_position += direction * speed * delta

	var max_x = screen_size.x - window_size.x
	var max_y = screen_size.y - window_size.y

	if window_position.x <= 0 or window_position.x >= max_x:
		direction.x *= -1
		animated_sprite.flip_h = direction.x < 0
		maybe_idle()

	if window_position.y <= 0 or window_position.y >= max_y:
		direction.y *= -1
		maybe_idle()

	window_position.x = clamp(window_position.x, 0, max_x)
	window_position.y = clamp(window_position.y, 0, max_y)

	DisplayServer.window_set_position(Vector2i(window_position))


func maybe_idle():
	if randf() < 0.3:
		is_idling = true
		idle_timer = randf_range(1.0, 3.0)

		var r = randi() % 3

		if r == 0:
			animated_sprite.play("idle")
			speed = 0
