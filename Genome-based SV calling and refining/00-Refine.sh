#!/bin/bash
module load bedtools2/2.26.0-gcc-4.8.5
echo Ref:$1
echo Ass:$2
echo ID:$3
echo Out:$4
echo Work:$5

grep -v "#" $4/$3/Svrefine/$3.vcf | sed 's/;/\t/g' | awk '{print $1,$2,$8,$14}' | sed 's/ /\t/g' | grep -v "comp" | sed 's/END=//g' | sed 's/ALTPOS=//g' | sed 's/:/\t/g' | sed 's/-/\t/g' > $4/$3/Svrefine.bed
grep -v "#" $4/$3/Assemblytics/$3.Assemblytics_structural_variants.bed | awk '{print $1,$2,$3,$10 }' | sed 's/:/ /g' | sed 's/-/ /g' | awk '{print $1,$2,$3,$4,$5,$6}' | sed 's/ /\t/g' > $4/$3/Assemblytics.bed
grep -v "#" $4/$3/Minimap2/$3.vcf | sed 's/=/\t/g' | sed 's/;/\t/g' | awk '{L1=length($4);L2=length($5);if(L1 > 50 || L2 > 50){print $1,$2,$2+L1-1,$9,$11,$11+L2-1}}' | sed 's/ /\t/g' > $4/$3/Minimap2.bed
cat $4/$3/Assemblytics.bed $4/$3/Minimap2.bed $4/$3/Svrefine.bed | sort -k1,1 -k2n,2 > $4/$3/Merge.bed
$5/00-Refine-M.pl $4/$3/Merge.bed > $4/$3/Merge.RM.bed
$5/00-Refine-R.pl $4/$3/Merge.RM.S.bed $1 $2 $3 $4 $5
uniq $4/$3/Merge.fa.pre.vcf > $4/$3/$3.vcf
