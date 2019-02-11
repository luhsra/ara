#!/usr/bin/env python3.6

from init_test import init_test


def main():
    """Test for correction warnings in ValidationStep."""
    _, warnings, p_manager = init_test()

    val_step = p_manager.get_step('ValidationStep')
    side_data = val_step.get_side_data()

    assert len(warnings) == len(side_data)
    for should, have in zip(warnings, side_data):
        assert should['type'] == have['type']
        assert should['location'] == have['location'].get_name()


if __name__ == '__main__':
    main()
