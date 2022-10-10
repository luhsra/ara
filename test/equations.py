#!/usr/bin/env python3

# Note: init_test must be imported first
from init_test import init_test_logging
from ara.steps.multisse_helper.equations import Equations
from ara.steps.multisse_helper.common import FakeEdge, TimeRange

import math

def main():
    """Test for correct MultiSSE Equation calculation."""
    logger = init_test_logging(log_level='debug')
    eqs = Equations()

    #edges
    a = FakeEdge(src=1, tgt=30)
    b = FakeEdge(src=1, tgt=2)
    c = FakeEdge(src=2, tgt=30)
    eqs.add_range(a, TimeRange(up=60, to=80))
    eqs.add_range(b, TimeRange(up=10, to=20))
    eqs.add_range(c, TimeRange(up=0, to=math.inf))
    eqs.add_equality({a}, {b, c})
    assert eqs.get_interval_for(c) == TimeRange(up=40, to=70)

if __name__ == '__main__':
    main()
