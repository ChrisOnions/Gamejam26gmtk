extends AudioStreamPlayer

# --- Calm "Chill" music: plays while sand is above 50% (95 BPM) ---
var chill_tracks = [
	preload("res://assets/Audio/music/Track1_Chill_loopA.wav"),
	preload("res://assets/Audio/music/Track1_Chill_loopB.wav"),
	preload("res://assets/Audio/music/Track1_Chill_loopC.wav"),
	preload("res://assets/Audio/music/Track1_Chill_loopD.wav"),
	preload("res://assets/Audio/music/Track1_Chill_loopE.wav"),
	preload("res://assets/Audio/music/Track1_Chill_loopF.wav"),
	preload("res://assets/Audio/music/Track1_Chill_loopG.wav"),
]

# --- Tense "Draining" layers: A=least intense ... E=most intense (125 BPM) ---
var draining_tracks = [
	preload("res://assets/Audio/music/Track2_Draining_loopA.wav"),
	preload("res://assets/Audio/music/Track2_Draining_loopB.wav"),
	preload("res://assets/Audio/music/Track2_Draining_loopC.wav"),
	preload("res://assets/Audio/music/Track2_Draining_loopD.wav"),
	preload("res://assets/Audio/music/Track2_Draining_loopE.wav"),
]

var draining_threshold := 0.5  # sand fraction below which draining music starts

var chill_bpm := 95.0
var draining_bpm := 125.0
var beats_per_bar := 4         # assumes 4/4 time

var active := false            # is the gameplay music running?
var weights = []
var mode := "chill"            # "chill" or "draining"
var layer := 0                 # current draining layer (0-4)
var current_bpm := 95.0

# a queued change, applied on the next bar line
var pending := false
var pending_mode := "chill"
var pending_layer := 0
var prev_pos := 0.0

var full_volume := 0.0         # normal loudness
var quiet_volume := -40.0      # effectively silent
var fade_time := 1.0           # fade length in seconds (tweak to taste)

func _ready():
	bus = "Music"
	for t in chill_tracks:
		weights.append(1.0)
	finished.connect(_on_finished)
	# note: does NOT auto-start. A gameplay scene calls play_gameplay().

# --- Call from a gameplay scene (e.g. the player's _ready) ---
# Starts the music, or does nothing if it's already playing (seamless across levels).
func play_gameplay() -> void:
	if active:
		return
	active = true
	pending = false
	mode = "chill"
	volume_db = quiet_volume
	_play_chill()
	var tween = create_tween()
	tween.tween_property(self, "volume_db", full_volume, fade_time)

# --- Call when leaving gameplay (game over, or back to menu) ---
func stop_music() -> void:
	if not active:
		return
	active = false
	pending = false
	var tween = create_tween()
	tween.tween_property(self, "volume_db", quiet_volume, fade_time)
	tween.tween_callback(stop)

# --- Feed the total sand left; ignored unless gameplay music is running ---
func update_intensity(current_sand: float, maximum_sand: float) -> void:
	if not active:
		return
	var frac := 0.0
	if maximum_sand > 0.0:
		frac = current_sand / maximum_sand

	var want_mode := "chill"
	var want_layer := 0
	if frac < draining_threshold:
		want_mode = "draining"
		var t := frac / draining_threshold          # 0 = empty, 1 = at the threshold
		want_layer = clampi(int((1.0 - t) * draining_tracks.size()), 0, draining_tracks.size() - 1)

	if want_mode != mode or (want_mode == "draining" and want_layer != layer):
		pending = true
		pending_mode = want_mode
		pending_layer = want_layer

# --- Waits for the next bar line so the switch lands cleanly ---
func _process(_delta):
	if not active or not pending or not playing:
		return
	var bar_len := 60.0 / current_bpm * beats_per_bar
	var pos := get_playback_position()
	if int(pos / bar_len) != int(prev_pos / bar_len) or pos < prev_pos:
		_apply_pending()
	prev_pos = pos

func _apply_pending():
	pending = false
	if pending_mode == "chill":
		mode = "chill"
		_play_chill()
	else:
		mode = "draining"
		layer = pending_layer
		_play_draining()

# A track finished naturally -> keep it going
func _on_finished():
	if not active:
		return
	if mode == "chill":
		_play_chill()          # next random chill track
	else:
		_play_draining()       # loop the current draining layer

func _play_chill():
	current_bpm = chill_bpm
	var index := _pick_weighted()
	for i in weights.size():
		if i != index:
			weights[i] = min(1.0, weights[i] + randf_range(0.10, 0.15))
	weights[index] = 0.1
	stream = chill_tracks[index]
	prev_pos = 0.0
	play()

func _play_draining():
	current_bpm = draining_bpm
	stream = draining_tracks[layer]
	prev_pos = 0.0
	play()

func _pick_weighted() -> int:
	var total := 0.0
	for w in weights:
		total += w
	var roll := randf() * total
	for i in weights.size():
		roll -= weights[i]
		if roll <= 0.0:
			return i
	return weights.size() - 1
