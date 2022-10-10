#!/usr/bin/env python3
import json

# Note: init_test must be imported first
from init_test import init_test, fail_if


def main():
    """Just execute the IRWriter with nothing.

    This was a problem in the past.
    """
    config = {"steps": ["IRWriter"]}
    data = init_test(extra_config=config, logger_name="tirwriter")


if __name__ == '__main__':
    main()
