#!/usr/bin/env python3.6

import logging

from init_test import init_test


def main():
    graph, data, manager = init_test(['ValidationStep', 'DisplayResultsStep'])

    side_data = manager.get_step('ValidationStep').get_side_data()

    #TODO ABB3 nicht im kritischen Bereich

    log = logging.getLogger('test')
    for tmp in side_data:
        log.debug(f"critical side data {tmp['location'].get_name()}")

    assert len(data) == len(side_data)
    for should, have in zip(data, side_data):
        assert should['type'] == have['type']
        assert should['location'] == have['location'].get_name()


if __name__ == '__main__':
    main()
