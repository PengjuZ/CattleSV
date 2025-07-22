#! /usr/bin/perl
$i=$ARGV[0];#input.bed
$j=$ARGV[1];#ref.fa
$x=$ARGV[2];#ass.fa
$y=$ARGV[3];#ass.ID
$z=$ARGV[4];#OUTDIR
$tools=$ARGV[5];#OUTDIR
	open (INDEL,"$j.fai");
	while(<INDEL>){
	chomp;
	@A =split (/\s+/ ,$_);
	$RefLength{$A[0]}=$A[1];
	}

	open (INDEL,"$x.fai");
	while(<INDEL>){
	chomp;
	@A =split (/\s+/ ,$_);
	$AssLength{$A[0]}=$A[1];
	}

	open (INDEL,"$i");
	while(<INDEL>){
	chomp;
	@A =split (/\s+/ ,$_);
 	open (OUT," >> $z/$y/ref.test.bed");
	$start=$A[1]-100;
 	$end=$A[2]+100;
 	print OUT "$A[0]	$start	$end\n"; 
 	$start=$A[4]-100;	
 	$end=$A[5]+100;	
 	open (OUT," >> $z/$y/ass.test.bed"); 
 	print OUT "$A[3]	$start	$end\n"; 
 	system"bedtools getfasta -tab -fi $j -bed $z/$y/ref.test.bed >> $z/$y/Test.txt";
 	system"bedtools getfasta -tab -fi $x -bed $z/$y/ass.test.bed >> $z/$y/Test.txt";
 	system"grep 'NNNNN' $z/$y/Test.txt >> $z/$y/TestN.txt ";
 	$SUM=0;
 		open (INDEL1,"$z/$y/TestN.txt");
		while(<INDEL1>){
		chomp;
		@A =split (/\s+/ ,$_);
 	$SUM+=1;
		}
 	system"rm -rf $z/$y/ref.test.bed";
  	system"rm -rf $z/$y/ass.test.bed";
  	system"rm -rf $z/$y/Test.txt";
  	system"rm -rf $z/$y/TestN.txt";

  	if($SUM == 0){
  	$L1=$A[2]-$A[1];
  	$L2=$A[5]-$A[4];  	
    $Length=0;
    if($Length < $L1){
	$Length=$L1;
    }
    if($Length < $L2){
	$Length=$L2;
    }
    $Binsize=$Length*1;
    $Bound=$Length*3;

 	$start=$A[1]-$Binsize;
 	$end=$A[2]+$Binsize;
 	if($start < 0){
	$start=0;
 	}
 	if($end > $RefLength{$A[0]}){
	$end=$RefLength{$A[0]};
 	}
 	open (OUT," >> $z/$y/ref.bed");
 	print OUT "$A[0]	$start	$end\n";
 	$RefnameR="$A[0]:$A[1]-$A[2]";
 	$Refname="$A[0]:$start-$end";

 	$start=$A[4]-$Binsize;
 	$end=$A[5]+$Binsize;
 	if($start < 0){
	$start=0;
 	}
 	if($end > $AssLength{$A[3]}){
	$end=$AssLength{$A[3]};
 	} 	
 	open (OUT," >> $z/$y/ass.bed"); 
 	print OUT "$A[3]	$start	$end\n"; 
 	system"rm -rf $z/$y/Merge.fa";
  	system"rm -rf $z/$y/Merge.fa.MSA.fa";
 	system"bedtools getfasta -fi $j -bed $z/$y/ref.bed >> $z/$y/Merge.fa";
 	system"bedtools getfasta -fi $x -bed $z/$y/ass.bed >> $z/$y/Merge.fa";
 	system"rm -rf $z/$y/ref.bed";
  	system"rm -rf $z/$y/ass.bed";
  	print "$RefnameR	$Refname\n";
 	system"$tools/00-breakpoints.sh $z/$y/Merge.fa $Refname $Bound";

  	}
 	#system"rm -rf $z/$y/Merge.fa.MSA.fa.out";
 		}
