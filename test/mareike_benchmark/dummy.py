# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import sys
#from time import sleep

# Template for test cases
def main():
    print(f"stdout - args: {sys.argv}")
    print("stderr", file=sys.stderr)
    
    # Test ok
    sys.exit(0)

    # Test timeout
    # sleep(10)

    # Test fail
    # sys.exit(1)
    
if __name__ == '__main__':
    main()
