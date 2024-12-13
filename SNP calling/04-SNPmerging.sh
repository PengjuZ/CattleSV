######Softwares######
source /share/apps/anaconda3/bin/activate PanCattle
export SENTIEON_LICENSE=mgt03:8990
#module load sentieon/202308.01
sentieon=/share/apps/sentieon/202308.01/sentieon-genomics-202308.01/bin/sentieon
#================================================================================
DataDir=/share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAout
Index=/share/home/zju_zhaopj/01-PanCattle-RNA/00-Index
Thread=12
#find $DataDir | grep "g.vcf.gz" | grep -v "tbi" | sort -n > $DataDir/List.txt
#cat $DataDir/List.txt | $sentieon driver -r $Index/Cattle.fa -t $Thread --algo GVCFtyper $DataDir/Cattle.R.Joint.vcf.gz -
source /share/apps/anaconda3/bin/activate Gatk4
#gatk CreateSequenceDictionary --REFERENCE $Index/Cattle.fa
#gatk VariantFiltration -R $Index/Cattle.fa -V $DataDir/Cattle.R.Joint.vcf.gz -O $DataDir/Cattle.F.Filter.vcf.gz --window 35 --cluster 3 --filter-name "FS" --filter "FS>30.0" --filter-name "QD" --filter "QD<2.0"
#bcftools view $DataDir/Cattle.F.Filter.vcf.gz --min-af 0.01:minor -e 'F_MISSING>0.5' -m 2 -M 2 -v snps -f PASS -O z -o $DataDir/Cattle.F2.Filter.vcf.gz
gatk IndexFeatureFile -I $DataDir/Cattle.F2.Filter.vcf.gz
gatk SelectVariants -R $Index/Cattle.fa -V $DataDir/Cattle.F2.Filter.vcf.gz -select-type SNP -O $DataDir/Cattle.SNP.Filter.vcf.gz




