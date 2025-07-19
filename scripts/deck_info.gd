extends TextureButton

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
		self.position.y -= dist

func lower():
	if raised:
		raised = false
		self.position.y += dist
