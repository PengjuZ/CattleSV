#!/bin/bash
#================================================================================
######Softwares######
source /share/apps/anaconda3/bin/activate PanCattle
export SENTIEON_LICENSE=mgt03:8990
#module load sentieon/202308.01
sentieon=/share/apps/sentieon/202308.01/sentieon-genomics-202308.01/bin/sentieon
#================================================================================
Gff=/share/home/zju_zhaopj/01-PanCattle/00-Index/Cattle.gff
IndexDir=/share/home/zju_zhaopj/01-PanCattle-RNA/00-Index
WorkDir=/share/home/zju_zhaopj/01-PanCattle-RNA/00-Data/Cleandata
RNAout=/share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAout
Thread=12
#================================================================================
while read ID ;
do
mkdir $RNAout/$ID/Tmp
echo $ID running!
###
cd $RNAout/$ID/Tmp
picard -Xmx20g MarkDuplicates \
                -R $IndexDir/Cattle.fa \
                --TMP_DIR $RNAout/$ID/Tmp/temp \
                -I $RNAout/$ID/$ID.Aligned.sortedByCoord.out.bam \
                -O $RNAout/$ID/Tmp/$ID.MarkDuplicates.bam \
                -M $RNAout/$ID/Tmp/$ID.MarkDuplicates.metrics.txt \
                --CREATE_INDEX true \
                --VALIDATION_STRINGENCY SILENT \
                --REMOVE_DUPLICATES true
#================================================================================
#2.Split reads at junction
$sentieon driver -t $Thread \
                -r $IndexDir/Cattle.fa \
                -i $RNAout/$ID/Tmp/$ID.MarkDuplicates.bam \
                --algo RNASplitReadsAtJunction \
                --reassign_mapq 255:60 $RNAout/$ID/Tmp/$ID.MarkDuplicates.Split.bam
#================================================================================
#3.Split reads at junction
$sentieon driver -t $Thread \
                -r $IndexDir/Cattle.fa \
                -i $RNAout/$ID/Tmp/$ID.MarkDuplicates.Split.bam \
                --algo Haplotyper \
                --trim_soft_clip \
                --call_conf 20 \
                --emit_mode gvcf \
                --emit_conf 20 $RNAout/$ID/$ID.RNA.g.vcf.gz
#================================================================================
#4.Delete big temporary files
rm -rf $RNAout/$ID/Tmp
###
done < $WorkDir/RNA.id.txt

