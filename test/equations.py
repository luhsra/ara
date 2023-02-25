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

    eqs = Equations()
    a = FakeEdge(src=1, tgt=1)
    b = FakeEdge(src=2, tgt=2)
    c = FakeEdge(src=3, tgt=3)
    d = FakeEdge(src=4, tgt=4)
    e = FakeEdge(src=5, tgt=5)
    f = FakeEdge(src=6, tgt=6)
    g = FakeEdge(src=7, tgt=7)
    h = FakeEdge(src=8, tgt=8)
    i = FakeEdge(src=9, tgt=9)
    j = FakeEdge(src=10, tgt=10)
    k = FakeEdge(src=11, tgt=11)
    l = FakeEdge(src=12, tgt=12)
    eqs.add_range(a, TimeRange(up=18, to=95))
    eqs.add_range(b, TimeRange(up=0, to=95))
    eqs.add_range(c, TimeRange(up=7, to=7))
    eqs.add_range(d, TimeRange(up=13, to=20))
    eqs.add_range(e, TimeRange(up=6, to=20))
    eqs.add_range(f, TimeRange(up=69, to=171))
    eqs.add_range(g, TimeRange(up=88, to=963))
    eqs.add_range(h, TimeRange(up=0, to=math.inf))
    eqs.add_range(i, TimeRange(up=69, to=76))
    eqs.add_range(j, TimeRange(up=3, to=43))
    eqs.add_range(k, TimeRange(up=29, to=483))
    eqs.add_range(l, TimeRange(up=0, to=math.inf))

    eqs.add_equality({a}, {b, c, d, e, f})
    eqs.add_equality({h}, {b, g})
    eqs.add_equality({l}, {j, k})
    eqs.add_equality({h}, {l})

    print(eqs)

    assert eqs.solvable()
    print(eqs.get_interval_for(l))
    assert eqs.get_interval_for(l) == TimeRange(up=88, to=526)


if __name__ == '__main__':
    main()
