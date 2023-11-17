extends Node

var current_checkpoint : Checkpoint

var player : CharacterBody2D

var level_start: bool = true
var last_position : Vector2

func respawn_player():
	if current_checkpoint != null:
		player.position = current_checkpoint.global_position
