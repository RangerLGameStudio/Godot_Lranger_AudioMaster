extends Resource
class_name AudioSFXFXRequest


@export var AudioPath:String
@export var RemoveAtEnd:bool=true
@export_category("DefaultModifier")
@export var ModPitch:float = 1.0
@export var ModVolume:float = 0.0
@export_category("Randomize")
@export var IsRand:bool
@export var RandPitch:float=0.2
@export var RandVolume:float=0.0

@export_category("RemovePrevious")
@export var RemovePreviousAudio: Array[String]=[]

func GetPitch():
	if IsRand:
		return ModPitch + randf_range(-RandPitch, RandPitch)
	else:
		return ModPitch
func GetVolume():
	if IsRand:
		return (ModVolume + randf_range(-RandVolume, RandVolume))
	else:
		return ModVolume
	
