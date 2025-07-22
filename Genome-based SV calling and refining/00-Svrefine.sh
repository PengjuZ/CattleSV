#!/bin/bash
module load anaconda3/2020.07
source activate SVanalyzer 
echo Ref:$1
echo Ass:$2
echo ID:$3
echo Out:$4

SVrefine --delta $4/$3/Nucmer/$3.delta --ref_fasta $1 --query_fasta $2 --outvcf $4/$3/Svrefine/$3.vcf --maxsize 1000000 --includeseqs
