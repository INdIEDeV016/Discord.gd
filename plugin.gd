@tool
extends EditorPlugin

## Adds discord.gd as an Autoload (Singleton)

func _enter_tree() -> void:
	add_autoload_singleton("DiscordError", "res://addons/discord-gd/error.gd")
	add_autoload_singleton("DiscordBot", "res://addons/discord-gd/discord.gd")


func exit_tree():
	remove_autoload_singleton("DiscordError")
	remove_autoload_singleton("DiscordBot")
