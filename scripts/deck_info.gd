extends TextureButton

@onready var game = $"../.."
@onready var info = $CoverMat
@onready var fade = $"FadedBackground"

var in_shop = false
var raised = false
var dist = 4

func enter_shop():
	in_shop = true
	raise()

func exit_shop():
	in_shop = false
	lower()

func raise():
	if not raised:
		raised = true
		info.lower()
		fade.position.y += dist
		self.position.y -= dist

func lower():
	if raised:
		raised = false
		info.raise()
		fade.position.y -= dist
		self.position.y += dist

func _on_pressed() -> void:
	info.display(in_shop)
	fade.visible = true


func _on_back_button_pressed() -> void:
	fade.visible = false
	info.close()
