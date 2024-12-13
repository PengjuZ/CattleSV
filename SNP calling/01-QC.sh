#!/bin/bash
####################################################################################
Fastp=/share/home/zju_zhaopj/00-Software/fastp
Bbduk=/share/home/zju_zhaopj/00-Software/bbmap/bbduk.sh
Thread=12
####################################################################################
Adapters=/share/home/zju_zhaopj/00-Software/bbmap/resources/adapters.fa
WorkDir=/share/home/zju_zhaopj/01-PanCattle-RNA/00-Data/Cleandata
####################################################################################
###RNA###
:<<Masknote 
while read ID ;
do
$Bbduk  -Xmx20g \
        threads=$Thread \
        in1=$WorkDir/RNA/$ID\_1.clean.fq.gz \
        in2=$WorkDir/RNA/$ID\_2.clean.fq.gz \
        out1=$WorkDir/RNAtmp/$ID\_1.fq.gz \
        out2=$WorkDir/RNAtmp/$ID\_2.fq.gz \
        minlen=50 qtrim=rl trimq=10 ktrim=r k=23 mink=11 hdist=1 \
        ref=$Adapters
$Fastp  -w $Thread \
        -i $WorkDir/RNAtmp/$ID\_1.fq.gz \
        -I $WorkDir/RNAtmp/$ID\_2.fq.gz \
        -o $WorkDir/RNAQC/$ID\_1.fq.gz \
        -O $WorkDir/RNAQC/$ID\_2.fq.gz \
        -j $WorkDir/RNAQC/$ID.fastp.json \
        -h $WorkDir/RNAQC/$ID.fastp.html \
        -q 20 -u 30 -l 50
done < $WorkDir/RNA.id.txt
Masknote
####################################################################################
###DNA###
while read ID ;
do
$Fastp  -w $Thread \
        -i $WorkDir/WGS/$ID\_1.clean.fq.gz \
        -I $WorkDir/WGS/$ID\_2.clean.fq.gz \
        -o $WorkDir/WGSQC/$ID\_1.fq.gz \
        -O $WorkDir/WGSQC/$ID\_2.fq.gz \
        -j $WorkDir/WGSQC/$ID.fastp.json \
        -h $WorkDir/WGSQC/$ID.fastp.html \
        -q 20 -u 30 -l 75
done < $WorkDir/WGS.id.txt        
####################################################################################
