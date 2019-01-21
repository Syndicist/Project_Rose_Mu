extends Node2D

onready var host = get_parent().get_parent();

func enter():
	host.state = 'attack';
	pass;

func handleInput(event):
	pass;

func execute(delta):
	pass;

func exit(state):
	host.states[state].enter();
	pass;