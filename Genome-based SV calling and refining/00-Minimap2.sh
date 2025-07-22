#!/bin/bash
echo Ref:$1
echo Ass:$2
echo ID:$3
echo Out:$4

minimap2 -cx asm5 -t24 --cs $1 $2 > $4/$3/Minimap2/$3.paf

sort -k6,6 -k8,8n $4/$3/Minimap2/$3.paf | k8 /BIGDATA2/zju_pjzhao_1/00-Software/Minimap2/minimap2-2.17_x64-linux/paftools.js call -L 10000 -f $1 - > $4/$3/Minimap2/$3.vcf

