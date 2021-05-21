if __name__ == '__main__':
    __package__ = 'test.posix_test'

from .remove_sysfunc_body import test_remove_sysfunc_step 

def main():
    test_remove_sysfunc_step(None)

if __name__ == '__main__':
    main()
