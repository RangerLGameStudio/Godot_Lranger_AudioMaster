extends Node
class_name AudioMaster_Autoload

var num_players_SFX = 8
var num_player_FX = 4
var BGMBus = "BGM"
var SFXBus = "SFX"
var FXBus = "FX"

var BGMAudioPlayer: AudioStreamPlayer
var BGM_name: String = ""

var available_SFXPlayer = []
var available_FXPlayer = []
var SFXqueue: Array[AudioSFXFXRequest] = []
var FXqueue: Array[AudioSFXFXRequest] = []
var SFXPlayerToRequestDict: Dictionary
var FXPlayerToRequestDict: Dictionary

func _ready():
	BGMAudioPlayer = AudioStreamPlayer.new()
	add_child(BGMAudioPlayer)
	BGMAudioPlayer.bus = BGMBus

	for i in num_players_SFX:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available_SFXPlayer.append(p)
		p.finished.connect(_on_SFXstream_finished.bind(p))
		p.bus = SFXBus

	for i in num_player_FX:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available_FXPlayer.append(p)
		p.finished.connect(_on_FXstream_finished.bind(p))
		p.bus = FXBus
	
	#TESTONLY
	#call_deferred("play_BGM", "res://Assets/Audio/BGM/Forest of beginning.mp3")
func play_BGM(sound_path):
	if BGM_name == sound_path:
		return
	BGMAudioPlayer.stream = load(sound_path)
	BGMAudioPlayer.play()
	BGM_name = sound_path
func stop_BGM():
	BGMAudioPlayer.stream_paused=true
func resume_BGM():
	BGMAudioPlayer.stream_paused=false
	
	
func _on_SFXstream_finished(stream):
	if SFXPlayerToRequestDict[stream].RemoveAtEnd:
		ReturnSFXPlayerToQueue(stream)
	else:
		stream.play(0.0)

func _on_FXstream_finished(stream):
	if FXPlayerToRequestDict[stream].RemoveAtEnd:
		ReturnFXPlayerToQueue(stream)
	else:
		stream.play(0.0)

func play_SFX(soundRequest: AudioSFXFXRequest):
	SFXqueue.append(soundRequest)

func play_FX(soundRequest: AudioSFXFXRequest):
	FXqueue.append(soundRequest)

func SearchAndRemoveSFX(soundpath: String):
	for audioPlayer in SFXPlayerToRequestDict:
		if SFXPlayerToRequestDict[audioPlayer].AudioPath == soundpath:
			ReturnSFXPlayerToQueue(audioPlayer)

func SearchAndRemoveFX(soundpath: String):
	for audioPlayer in FXPlayerToRequestDict:
		if FXPlayerToRequestDict[audioPlayer].AudioPath == soundpath:
			ReturnFXPlayerToQueue(audioPlayer)

func ReturnSFXPlayerToQueue(audioPlayer):
	audioPlayer.stop()
	available_SFXPlayer.append(audioPlayer)

func ReturnFXPlayerToQueue(audioPlayer):
	audioPlayer.stop()
	available_FXPlayer.append(audioPlayer)

func _process(delta):
	# Play a queued sound if any players are available.
	if not SFXqueue.is_empty() and not available_SFXPlayer.is_empty():
		var SFXRequest: AudioSFXFXRequest = SFXqueue.pop_front()
		var audioPlayer = available_SFXPlayer.pop_front()
		audioPlayer.stream = load_audio_stream(SFXRequest.AudioPath)
		if audioPlayer.stream:
			audioPlayer.volume_db = SFXRequest.GetVolume()
			audioPlayer.pitch_scale = SFXRequest.GetPitch()
			if SFXRequest.RemovePreviousAudio.size() > 0:
				for audioname in SFXRequest.RemovePreviousAudio:
					SearchAndRemoveSFX(audioname)
			audioPlayer.play()
			SFXPlayerToRequestDict[audioPlayer] = SFXRequest
		else:
			available_SFXPlayer.append(audioPlayer)

	if not FXqueue.is_empty() and not available_FXPlayer.is_empty():
		var FXRequest: AudioSFXFXRequest = FXqueue.pop_front()
		var audioPlayer = available_FXPlayer.pop_front()
		audioPlayer.stream = load_audio_stream(FXRequest.AudioPath)
		if audioPlayer.stream:
			audioPlayer.volume_db = FXRequest.GetVolume()
			audioPlayer.pitch = FXRequest.GetPitch()
			if FXRequest.RemovePreviousAudio.size() > 0:
				for audioname in FXRequest.RemovePreviousAudio:
					SearchAndRemoveFX(audioname)
			audioPlayer.play()
			FXPlayerToRequestDict[audioPlayer] = FXRequest
		else:
			available_FXPlayer.append(audioPlayer)

func load_audio_stream(audio_path: String) -> AudioStream:
	var audio_stream = ResourceLoader.load(audio_path, "AudioStream")
	if audio_stream == null:
		printerr("Error loading audio stream from path: ", audio_path)
	return audio_stream

