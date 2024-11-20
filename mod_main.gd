extends Node


const AUTHORNAME_MODNAME_DIR := "Squix-ShrekDealer"
const AUTHORNAME_MODNAME_LOG_NAME := "Squix-ShrekDealer:Main"

var mod_dir_path := ""

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir() + AUTHORNAME_MODNAME_DIR

#helper function to fade in/out shrek (like what happens with the dealer mesh)
func fade_sprite3d(sprite: Sprite3D, mode: String):
	
	# Create and configure a Tween node
	var tween = sprite.create_tween()
	var start_value
	var end_value
	
	if mode == "fadein":
		start_value = 1
		end_value = 0
	elif mode == "fadeout":
		start_value = 0
		end_value = 1
	
	sprite.visible = (mode == "fadein")
	sprite.transparency = start_value
	# Tween the alpha value over 1 second
	tween.tween_property(
		sprite, 
		"transparency",  # Property to tween
		end_value,               # Final value (fully opaque)
		1.5                # Duration (in seconds)
	)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Start the tween
	tween.play()

#magic happens here
var menu_passed = false	
func _process(delta) -> void:
	var current_scene = get_tree().get_current_scene()
	#debug : autostart solo game by skipping menu
	#if current_scene and current_scene.name == "menu" and !menu_passed:
		#var menuManager = current_scene.get_node("standalone managers/menu manager")
		#menu_passed = true
		#menuManager.Start()
		
	if current_scene and current_scene.name == "main":
		var dealer_parent : Node3D = current_scene.get_node("dealer model parent")
		var dealer_head : Node3D = dealer_parent.get_node("dealer head rigged1")
		if not dealer_parent.has_node("shrekHead"):
			#create shrek head
			var shrekHead : Sprite3D = Sprite3D.new()
			var texture = load(mod_dir_path.path_join("shrek_head.png"))
			shrekHead.name = "shrekHead"
			shrekHead.texture = texture
			shrekHead.position = dealer_head.position
			shrekHead.rotation = Vector3(20, 102, 0)
			shrekHead.set_billboard_mode(BaseMaterial3D.BILLBOARD_ENABLED)
			shrekHead.scale = Vector3.ONE * 0.25
			#hide og head
			dealer_head.visible = false
			#add shrek one to the scene
			dealer_parent.add_child(shrekHead)
			#rename dealer
			var health_counter_dealer_label = current_scene.get_node("tabletop parent/main tabletop/health counter/health counter ui parent/health UI_dealer side/text_dealer")
			health_counter_dealer_label.text = "SHREK"
			ModLoaderLog.info("Shrek has eaten the dealer!", AUTHORNAME_MODNAME_LOG_NAME)
		else:
			var shrekHead : Sprite3D = dealer_parent.get_node("shrekHead")
			shrekHead.position = dealer_head.position
			#if dealer is ejected from the table
			if dealer_parent.position.x > 30 and shrekHead.visible:
				fade_sprite3d(shrekHead, "fadeout")
			#if dealer came back
			elif dealer_parent.position.x < 30 and not shrekHead.visible:
				fade_sprite3d(shrekHead, "fadein")
