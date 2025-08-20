#!/bin/bash
#$1
#$2

echo $2
module load mafft/7.453-with-extensions

if [[ "$3" -le "50000" ]];then
mafft --thread 24 --quiet --maxiterate 1000 --genafpair $1 > $1.MSA.fa
else
mafft --thread 24 --quiet --auto $1 > $1.MSA.fa
fi

module load anaconda3/2020.07
source activate jvarkit

msa2vcf.py -R $2 -c $2 $1.MSA.fa | grep -v "#" | sed 's/:/\t/g' | sed 's/-/\t/g' | cut -f 1,2,4,6,7 | awk '{$3-=S;if($4 != "N"){print $1,$2+$3,".",$4,$5,".",".","DP=1","GT:DP","1/1"};if(NR==1 && $4 == "N"){S+=length($5)};if(NR==1 && $4 != "N" && length($5) > length($4)){S+=length($5)-length($4)};if(NR!=1 && length($5) > length($4)){S+=length($5)-length($4)}}' | grep -v "NNNNN" | awk '{if(length($4) > 50 || length($5) > 50){print}}' | sed 's/ /\t/g' >  $1.MSA.fa.out

cat $1.MSA.fa.out >> $1.pre.vcf
echo OK!