###prepare input files
#minor allele frequencies >=0.05; with the minor allele observed in at least 3 samples
bcftools view -q 0.05:minor -c 3:minor blood.recode.vcf.gz > blood.filtered.vcf

#prepare genotype files
plink2 --make-bed --vcf blood.filtered.vcf --out ./input/blood --cow --update-sex sex.txt

#prepare phenotype and covariates files
Rscript prepare_data.r blood.counts blood.tpm blood.filtered.vcf blood --no-save
sort -k1,1 -k2,2n blood.phenotype.bed |bgzip -cf > ./input/blood.phenotype.bed.gz
tabix -p bed ./input/blood.phenotype.bed.gz
bgzip -cf blood.covariates.txt > ./input/blood.covariates.txt.gz

###run TensorQTL
python3 -m tensorqtl ./input/blood ./input/blood.phenotype.bed.gz ./output/blood --covariates ./input/blood.covariates.txt.gz --mode cis
python3 -m tensorqtl ./input/blood ./input/blood.phenotype.bed.gz ./output/blood --covariates ./input/blood.covariates.txt.gz --mode cis_nominal

#detect eGenes
Rscript FDR.r ./output/blood.cis_qtl.txt ./output/blood --no-save

#extract significant eQTLs
for file in `ls ./output/*.parquet`; do { input="$file"; output="$file".csv; python3 pairs.py $input $output; }; done