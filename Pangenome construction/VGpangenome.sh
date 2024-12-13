#!/bin/bash
####################################################################################
###Files
Index=/share/home/zju_zhaopj/01-PanCattle-RNA/00-Index/
thread=24
####################################################################################
source /share/apps/anaconda3/bin/activate PanCattle
cd 00-Index
bwa index Cattle.fa
vg construct -r Cattle.fa -v Cattle.vcf -S -f -t $thread -a -p > Cattle.vg
vg index -L -x Cattle.xg -t $thread -p Cattle.vg
vg convert Cattle.xg -t $thread > Cattle.pg
vg gbwt -p -g Cattle.gg -o Cattle.gbwt -x Cattle.xg -P
vg snarls --include-trivial Cattle.xg -t $thread > Cattle.snarls
vg index -t $thread -j Cattle.dist Cattle.xg
vg minimizer -o Cattle.min -g Cattle.gbwt -G Cattle.gg -d Cattle.dist -t $thread
