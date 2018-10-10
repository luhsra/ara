from .oil import OilPassage

from .test1 import Test1Passage
from .test2 import Test2Passage
from .test3 import Test3Passage
from .test4 import Test4Passage

from native_passage import Passage
from native_passage import provide_passages as _native_provide

__all__ = ['Passage', 'OilPassage',
           'Test1Passage', 'Test2Passage', 'Test3Passage', 'Test4Passage']

def provide_passages(config: dict):
    for passage in  _native_provide(config):
        yield passage

    yield OilPassage(config)
    yield Test1Passage(config)
    yield Test2Passage(config)
    yield Test3Passage(config)
    yield Test4Passage(config)
