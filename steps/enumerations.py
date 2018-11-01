from enum import Enum

class Syscall_Type(Enum):
	computate = 1
	create = 2
	destroy = 3
	receive = 4
	access = 5
	release = 8
	schedule = 9

