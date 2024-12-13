#!/bin/bash
#================================================================================
######Softwares######
Gff=/share/home/zju_zhaopj/01-PanCattle/00-Index/Cattle.gff
IndexDir=/share/home/zju_zhaopj/01-PanCattle-RNA/00-Index
WorkDir=/share/home/zju_zhaopj/01-PanCattle-RNA/00-Data/Cleandata
RNAout=/share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAout
Thread=24
#================================================================================
#awk '{if($3 == "mRNA" || $3 == "lnc_RNA")print}' /share/home/zju_zhaopj/01-PanCattle/00-Index/Cattle.gff | cut -f 9 | sed 's/;/\t/g' | cut -f 1,2 | sed 's/=/\t/g' | awk '{print $4"\t"$2}' > Cattle.list.txt
#rsem-prepare-reference --transcript-to-gene-map Cattle.list.txt --STAR /share/home/zju_zhaopj/01-PanCattle-RNA/00-Index/Cattle.fa --gff3 /share/home/zju_zhaopj/01-PanCattle/00-Index/Cattle.gff /share/home/zju_zhaopj/01-PanCattle-RNA/00-Index/Rsem
#================================================================================
source /share/apps/anaconda3/bin/activate RNA-seq
:<<Masknote

while read ID ;
do
stringtie -p $Thread \
                -e \
                -G $Gff \
                -b $RNAout/$ID/$ID.stringtie \
                -o $RNAout/$ID/$ID.stringtie.gtf \
                -A $RNAout/$ID/$ID.stringtie.tsv \
                $RNAout/$ID/$ID.Aligned.sortedByCoord.out.bam
done < $WorkDir/RNA.id.txt

while read ID ;
do
awk '{if($1 != "Gene")print $1,$2}' /share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAout/$ID/$ID.stringtie.tsv
done < $WorkDir/RNA.id.txt | sort | uniq > /share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAexpress/Gene.list.ID.txt

while read ID ;
do
awk 'ARGIND==2{A[$1][$2]=$9}ARGIND==3{if($1 != "Gene"){print A[$1][$2]+0}else{print ID}}' ID=$ID \
     /share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAout/$ID/$ID.stringtie.tsv \
     /share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAexpress/Gene.list.ID.txt > \
     /share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAexpress/List/$ID.txt
done < $WorkDir/RNA.id.txt
paste /share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAexpress/Gene.list.ID.txt \
      /share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAexpress/List/*.txt > /share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAexpress/Gene.Matrix.txt


gffread /share/home/zju_zhaopj/01-PanCattle/00-Index/Cattle.gff -T -o Cattle.gtf
grep "gene_id" Cattle.gtf > Cattle.a.gtf


while read ID ;
do
    echo /share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAout/$ID/$ID.Aligned.sortedByCoord.out.bam
done < $WorkDir/RNA.id.txt > Cattle.a.sh
Masknote
cd /share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAexpress
featureCounts \
-a /share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAexpress/Cattle.a.gtf -o /share/home/zju_zhaopj/01-PanCattle-RNA/05-RNAexpress/final_count.tsv \
-t exon \
-p \
-g gene_id \
-T 10 $(cat Cattle.a.sh | tr '\n' ' ')



