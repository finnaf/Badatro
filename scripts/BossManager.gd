extends Node

const BASE_REQ = {
	"0": 100,
	"1": 10,
	"2": 800,
	"3": 2000,
	"4": 5000,
	"5": 11000,
	"6": 20000,
	"7": 35000,
	"8": 50000,
}

# 1x small blind 1.5x big blind 2x boss blind
func get_chip_req(ante: int, blind: int) -> int:
	if blind == 0:
		return BASE_REQ[str(ante)]
	if blind == 1:
		return BASE_REQ[str(ante)] * 1.5
	return BASE_REQ[str(ante)] * 2
