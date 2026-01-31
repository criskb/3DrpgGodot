extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var message_label: Label = $HUD/PanelContainer/VBoxContainer/MessageLabel
@onready var message_timer: Timer = $MessageTimer

func _ready() -> void:
	player.npc_interacted.connect(_on_player_npc_interacted)
	message_timer.timeout.connect(_on_message_timeout)

func _on_player_npc_interacted(npc_name: String) -> void:
	message_label.text = "%s: Welcome to the starting village!" % npc_name
	message_timer.start()

func _on_message_timeout() -> void:
	message_label.text = ""
