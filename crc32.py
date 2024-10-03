#!/usr/bin/env python3
import sys
from zlib import crc32

with open(sys.argv[1], 'rb') as f:
    crc = crc32(f.read())
    print(f'crc: {crc:x}', file=sys.stderr)
    sys.stdout.buffer.write(crc.to_bytes(4, 'little'))
