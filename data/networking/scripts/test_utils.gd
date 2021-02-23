extends Node

const FAKE_LATENCY_MIN_MS = 0
const FAKE_LATENCY_MAX_MS = 0

func get_fake_latency():
	return _rand(FAKE_LATENCY_MIN_MS, FAKE_LATENCY_MAX_MS)
		
func _rand(a, b):
	randomize()
	return rand_range(a, b)

