#!/usr/bin/python3

import sys
import getopt
import os

inputfile = ''
outputfile = ''

bytes_per_line = 16

if (len(sys.argv) != 3):
        print("Usage: mkmifile.py inputfile outputfile\n");
        sys.exit()
else:
        inputfile=sys.argv[1]

        outputfile=sys.argv[2]
        
        size = os.path.getsize(inputfile)

        #addr = int(sys.argv[3],16)

        infile = open(inputfile, "rb")
        outfile = open(outputfile,"w")

        # Write start address in little endian
        #addr_bytes = addr.to_bytes(2, "little")
        #outfile.write(addr_bytes)
        
        byte = infile.read(1)
        #outstr="X\"" + format(byte[0],'02X')+"\""
        #outfile.write(outstr)

        
        while byte:
                outfile.write(byte.hex() + '\n')
                byte = infile.read(1)

        infile.close();
        outfile.close();
        



