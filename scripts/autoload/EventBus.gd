extends Node

signal load_level(level_id)  # load the level whit the coresponig to the id and disables all other levels

signal level_transision_screen(level_id)

#player
signal player_died
signal player_flip

#door
signal open_door(door_id)
signal close_door(door_id)
