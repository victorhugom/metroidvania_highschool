extends Node

var sound: AudioStreamPlayer
const BACKGROUND_MUSIC_DAY = preload("res://assets/sfx/background_music_day.mp3")
func _ready():
	sound = AudioStreamPlayer.new()
	add_child(sound)
	sound.stream = BACKGROUND_MUSIC_DAY
	sound.play()
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
