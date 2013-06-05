#!/bin/sh
L1=sample-l1.pairs
L2=sample-modules.pairs
echo Creating network using the BCR+ model...
./create_bcr+.rb -i sample-architecture.pairs -1 $L1 -2 $L2 -n 300 --p1=0.1 --p2=0.1 --p3=0.8 -m 0.09 --din=3 --dout=3
echo Done. Check the files $L1 and $L2.
