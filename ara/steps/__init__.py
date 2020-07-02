import ara.steps.py_logging

def provide_steps():
    from .step import provide_steps as _native_provide
    from .dummy import Dummy

    for step in _native_provide():
        yield step

    yield Dummy
