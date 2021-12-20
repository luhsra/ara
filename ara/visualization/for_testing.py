
class A:
    def __init__(self):
        self.print()

    def print(self):
        print("A")


class B(A):

    def print(self):
        print("B")
