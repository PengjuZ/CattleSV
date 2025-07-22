#!/bin/bash
export PATH=/BIGDATA2/zju_pjzhao_1/00-Software/mummer-4.0.0rc1/bin/:/BIGDATA2/zju_pjzhao_1/00-Software/Assemblytics-1.2.1/scripts/:/BIGDATA2/zju_pjzhao_1/00-Software/Minimap2/minimap2-2.17_x64-linux/:/BIGDATA2/zju_pjzhao_1/00-Software/LongRepMarker_v2.0-master/programs/samtools-1.14/:$PATH

Ref=/BIGDATA2/zju_pjzhao_1/02-Cattle_Pan/01-Assemblies/02-Genome-Trans/1.fa
OUT=/BIGDATA2/zju_pjzhao_1/02-Cattle_Pan/02-SVcalling-Ass/01-OUT
Workplace=/BIGDATA2/zju_pjzhao_1/02-Cattle_Pan/02-SVcalling-Ass/00-Script
Ass=$1
AssID=$2

mkdir $OUT/$AssID/
mkdir $OUT/$AssID/Nucmer/
nucmer --batch 1 -l 100 -c 500 -t 24 --prefix=$OUT/$AssID/Nucmer/$AssID $Ref $Ass

mkdir $OUT/$AssID/Svrefine/
$Workplace/00-Svrefine.sh $Ref $Ass $AssID $OUT

mkdir $OUT/$AssID/Assemblytics/
$Workplace/00-Assemblytics.sh $Ref $Ass $AssID $OUT

mkdir $OUT/$AssID/Minimap2/
$Workplace/00-Minimap2.sh $Ref $Ass $AssID $OUT

$Workplace/00-Refine.sh $Ref $Ass $AssID $OUT $Workplace
echo $AssID Finished!