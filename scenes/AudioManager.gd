extends AudioStreamPlayer

var tracks #= [
	#preload("res://assets/music/Track1_Chill_loopA.wav"),
	#preload("res://assets/music/Track1_Chill_loopB.wav"),
	#preload("res://assets/music/Track1_Chill_loopC.wav"),
	#preload("res://assets/music/Track1_Chill_loopD.wav"),
	#preload("res://assets/music/Track1_Chill_loopE.wav"),
	#preload("res://assets/music/Track1_Chill_loopF.wav"),
	#preload("res://assets/music/Track1_Chill_loopG.wav"),
#]

var weights = []

func _ready():
	for t in tracks:
		weights.append(1.0)  # every track starts fully in the running
	finished.connect(_on_finished)
	_play_random()

func _on_finished():
	_play_random()

func _play_random():
	var index = _pick_weighted()

	# raise everyone else's chance by 10-15%, capped at 1.0
	for i in weights.size():
		if i != index:
			weights[i] = min(1.0, weights[i] + randf_range(0.10, 0.15))

	# the track that just played drops to a low 10% chance
	weights[index] = 0.1

	stream = tracks[index]
	play()

func _pick_weighted() -> int:
	var total = 0.0
	for w in weights:
		total += w
	var roll = randf() * total
	for i in weights.size():
		roll -= weights[i]
		if roll <= 0.0:
			return i
	return weights.size() - 1
