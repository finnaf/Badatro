extends TextureButton

@onready var fade = $FadedBackground
@onready var info = $CoverMat

func _on_pressed() -> void:
	info.visible = true
	fade.visible = false
