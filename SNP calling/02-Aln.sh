#!/bin/bash
####################################################################################
export SENTIEON_LICENSE=mgt03:8990
module load sentieon/202308.01
Sentieon=/share/apps/sentieon/202308.01/sentieon-genomics-202308.01/bin/sentieon
Samtools=/share/home/zju_zhaopj/00-Software/samtools-1.16.1/samtools
Thread=12
####################################################################################
Gff=/share/home/zju_zhaopj/01-PanCattle/00-Index/Cattle.gff
IndexDir=/share/home/zju_zhaopj/01-PanCattle-RNA/00-Index
WorkDir=/share/home/zju_zhaopj/01-PanCattle-RNA/00-Data/Cleandata
RNAout=/share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAout
####################################################################################
###Index###
#source /share/apps/anaconda3/bin/activate RNA-seq
#$Sentieon STAR --runMode genomeGenerate --genomeDir $IndexDir/STARindex --genomeSAindexNbases 13 --runThreadN 10 --genomeFastaFiles $IndexDir/Cattle.fa --sjdbGTFfile $Gff
####################################################################################
###RNA###
while read ID ;
do
#1.Mapping the sequencing reads to reference genomes.
mkdir $RNAout/$ID/
sentieon STAR   --runThreadN $Thread \
                --genomeDir $IndexDir/STARindex \
                --sjdbGTFfile $Gff \
                --runMode alignReads \
                --readFilesIn $WorkDir/RNAQC/$ID\_1.fq.gz $WorkDir/RNAQC/$ID\_2.fq.gz \
                --readFilesCommand zcat \
                --outSAMtype BAM SortedByCoordinate \
                --outFileNamePrefix $RNAout/$ID/$ID. \
                --outBAMsortingThreadN $Thread \
                --twopassMode Basic \
                --outSAMunmapped Within \
                --outFilterMultimapNmax 1 \
                --outFilterType BySJout \
                --outSAMattrRGline ID:$ID SM:$ID PL:PLATFORM \
                --outSAMstrandField intronMotif \
                --outSAMattributes All \
                --chimSegmentMin 10 \
                --twopass1readsN -1 \
                --outFilterMismatchNmax 999 \
                --outFilterMismatchNoverLmax 0.03 \
                --alignIntronMin 20 \
                --alignIntronMax 1000000 \
                --alignMatesGapMax 1000000 \
                --chimOutType SeparateSAMold \
                --alignSJoverhangMin 8 \
                --alignSJDBoverhangMin 1 \
                --sjdbOverhang 100
done < $WorkDir/RNA.id.txt

####################################################################################
###DNA###
:<<Masknote
Masknote