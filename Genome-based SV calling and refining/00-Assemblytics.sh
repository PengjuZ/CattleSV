#!/bin/bash
module load R/4.0.3-gcc-4.8.5
module load python/3.8.0-gcc-4.8.5-anaconda
echo Ref:$1
echo Ass:$2
echo ID:$3
echo Out:$4

Assemblytics $4/$3/Nucmer/$3.delta $4/$3/Assemblytics/$3 10000 50 1000000
