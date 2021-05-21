if __name__ == '__main__':
    __package__ = 'test.posix_test'

from .remove_sysfunc_body import test_remove_sysfunc_step
from ara.os.posix.posix import POSIX

def main():
    test_remove_sysfunc_step(POSIX)

if __name__ == '__main__':
    main()
