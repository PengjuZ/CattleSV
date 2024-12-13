#!/bin/bash
####################################################################################
###Files
Index=/share/home/zju_zhaopj/01-PanCattle-RNA/00-Index
SraList=/share/home/zju_zhaopj/01-PanCattle-RNA/00-Data/Cleandata/WGS.id.vg.txt
WorkDir=/share/home/zju_zhaopj/01-PanCattle-RNA/00-Data/Cleandata/WGSQC
OutDir=/share/home/zju_zhaopj/01-PanCattle-RNA/06-SVcalling
Thread="48" #####change
###SoftWares
source /share/apps/anaconda3/bin/activate PanCattle
export SENTIEON_LICENSE=mgt03:8990
#module load sentieon/202308.01
sentieon=/share/apps/sentieon/202308.01/sentieon-genomics-202308.01/bin/sentieon
Repair=/share/home/zju_zhaopj/00-Software/bbmap/repair.sh
####################################################################################

while read ID
do
echo $ID running
#mkdir $OutDir/$ID
mkdir $OutDir/$ID.VG
#$Repair -Xmx100g \
#        threads=$Thread \
#        in1=$WorkDir/$ID\_1.fq.gz \
#        in2=$WorkDir/$ID\_2.fq.gz \
#        out1=$WorkDir/$ID\_1.ok.fq.gz \
#        out2=$WorkDir/$ID\_2.ok.fq.gz
Fastq1=$WorkDir/$ID\_1.ok.fq.gz
Fastq2=$WorkDir/$ID\_2.ok.fq.gz
RunOUT=$OutDir/$ID.VG
RunOUTs=$OutDir/$ID.OUT
:<<Masknote
Masknote

###
rm -rf $Index/Cattle.giraffe.gbz
#vg minimizer -o $Index/Cattle.min -g $Index/Cattle.gbwt -G $Index/Cattle.gg -d $Index/Cattle.dist -t $thread
vg giraffe -x $Index/Cattle.xg -g $Index/Cattle.gg -H $Index/Cattle.gbwt -m $Index/Cattle.min -d $Index/Cattle.dist -f $Fastq1 -f $Fastq2 -t $Thread -b fast -N $ID -p | vg filter -fu -m 1 -q 15 -D 999 -x $Index/Cattle.xg -t $Thread - > $RunOUT/Cattle.gam
vg pack -x $Index/Cattle.xg -g $RunOUT/Cattle.gam -o $RunOUT/Cattle.pack -t $Thread
vg call $Index/Cattle.xg -r $Index/Cattle.snarls -k $RunOUT/Cattle.pack -s $ID -v $Index/Cattle.vcf -t $Thread --bias-mode --het-bias 2,4 > $RunOUT/$ID.SV.vcf
###
rm -rf $RunOUTs/$ID.SV.vcf
cp $RunOUT/$ID.SV.vcf $RunOUTs/$ID.SV.vcf
###
rm -rf $RunOUT
done < $SraList
