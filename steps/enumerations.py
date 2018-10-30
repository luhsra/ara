class Vertex_Type(Enum):
	function = 1
	task = 2
	isr = 3
	alarm = 4
	resource = 5
	counter = 6
	buffer = 7
	event = 8
	timer = 9
	semaphore = 10
	os = 11

class Syscall_Type(Enum):
	computate = 1
	create = 2
	destroy = 3
	receive = 4
	access = 5
	release = 8
	schedule = 9

