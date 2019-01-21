#!/usr/bin/env python3

from enum import IntEnum

class Shape(IntEnum):
    CIRCLE = 1
    SQUARE = 2

print(Shape.CIRCLE == 1)
print(Shape(2))
