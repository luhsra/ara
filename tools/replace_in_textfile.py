
import sys

if len(sys.argv) < 2:
    print("Usage: {} FILE_SOURCE FILE_DEST TO_REPLACE REPLACE_BY".format(sys.argv[0]))
    print("Replaces all TO_REPLACE with REPLACE_BY in FILE_SOURCE and write output to FILE_DEST")
    sys.exit(1)

FILE_SOURCE = sys.argv[1]
FILE_DEST = sys.argv[2]
TO_REPLACE = sys.argv[3]
REPLACE_BY = sys.argv[4]

with open(FILE_SOURCE, 'r') as f:
    orig_content = f.read()
    escaped_content = orig_content.replace(TO_REPLACE, REPLACE_BY)
with open(FILE_DEST, 'w') as f:
    f.write(escaped_content)
