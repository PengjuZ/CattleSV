#fine-mapping
cat blood.cis_qtl_pairs.all.parquet.csv|awk '$2 ~ /SV/' | cut -f 1 | sort | uniq > SV_egene

for gene in `cat SV_egene`; do
    grep -w ${gene} blood.cis_qtl_pairs.all.parquet.txt | awk '$2 ~ /SNP/'|awk '!($7 == "")' | sort -g -k7 | head -n 100 > ./finemapping/${gene}.100
    grep -w ${gene} blood.cis_qtl_pairs.all.parquet.txt | awk '$2 ~ /SV/'| awk '!($7 == "")'| sort -g -k7 | head -n 1 | cat - ./finemapping/${gene}.100 > ./finemapping/${gene}.101
    awk '{print $2,$8/$9}' ./finemapping/${gene}.101|sed 's/ /\t/g' > ./finemapping/${gene}.z
    cut -f 1 ./finemapping/${gene}.z | sed 's/[A-Za-z]//g' | paste - ./finemapping/${gene}.z | sort | cut -f 2,3 > ./finemapping/${gene}.z.txt
    cut -f 2 ./finemapping/${gene}.101 > ./finemapping/${gene}.id
    vcftools --gzvcf blood.filtered.vcf.gz --snps ./finemapping/${gene}.id --recode --recode-INFO-all --out ./finemapping/${gene}
    plink2 --make-bed --vcf ./finemapping/${gene}.recode.vcf --out ./finemapping/${gene} --cow --update-sex sex.txt
    plink --bfile ./finemapping/${gene} --r square --out ./finemapping/${gene} --cow
    CAVIAR -l ./finemapping/${gene}.ld -z ./finemapping/${gene}.z.txt -c 1 -o ./finemapping/${gene}.out
done