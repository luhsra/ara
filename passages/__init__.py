from .oil import OilPassage

from native_passage import Passage
from native_passage import provide_passages as _native_provide

__all__ = ['Passage', 'OilPassage']

def provide_passages(config: dict):
    for passage in  _native_provide(config):
        yield passage

    yield OilPassage(config)
