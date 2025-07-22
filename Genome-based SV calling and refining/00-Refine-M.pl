#! /usr/bin/perl
$i=$ARGV[0];#input.bed
	$LINE=0;
	open (INDEL,"$i");
	while(<INDEL>){
	chomp;
	@A =split (/\s+/ ,$_);
	$LINE+=1;
	$Record{$LINE}{ChrA}=$A[0];
	$Record{$LINE}{StartA}=$A[1];
	$Record{$LINE}{EndA}=$A[2];
	$Record{$LINE}{ChrB}=$A[3];
	$Record{$LINE}{StartB}=$A[4];
	$Record{$LINE}{EndB}=$A[5];
	}

	$LINE=0;
	$ID=0;
	$P=1;	
	open (INDEL,"$i");
	while(<INDEL>){
	chomp;
	@A =split (/\s+/ ,$_);
	$LINE+=1;
	$Down1=$LINE+1;
 	if($Record{$LINE}{ChrA} eq $Record{$Down1}{ChrA}){
 	$Down1ChrA=1;	
 	}else{
 	$Down1ChrA=0;
 	};
 	if($Record{$LINE}{ChrB} eq $Record{$Down1}{ChrB}){
 	$Down1ChrB=1;	
 	}else{
 	$Down1ChrB=0;
 	};
 	$Down1dist=abs($Record{$LINE}{StartA}-$Record{$Down1}{StartA});
 	$Down1dist+=abs($Record{$LINE}{EndA}-$Record{$Down1}{EndA});
 	$Down1dist+=abs($Record{$LINE}{StartB}-$Record{$Down1}{StartB});
 	$Down1dist+=abs($Record{$LINE}{EndB}-$Record{$Down1}{EndB});

 	$MARK=0;
 	if($Record{$Down1}{StartA} <= $Record{$LINE}{EndA}){
    $MARK=1;
 	}
 	if($Record{$Down1}{StartB} <= $Record{$LINE}{EndB}){
    $MARK=1;
 	}

 	if($Down1ChrA == 1 && $Down1ChrB == 1 && $MARK == 1 && $Down1dist < 500){
 	$ID+=$P;	
	$P=0;
	$Three{$ID}=1;
 	}else{
  	$ID+=$P;		
	$P=1;	
 	}

	$YES{$ID}{ChrA}=$A[0];

	if($YES{$ID}{StartA} ne ""){
		if($YES{$ID}{StartA} > $A[1]){
		$YES{$ID}{StartA}=$A[1];
		}
	}else{
	$YES{$ID}{StartA}=$A[1];
	}

	if($YES{$ID}{EndA} ne ""){
		if($YES{$ID}{EndA} < $A[2]){
		$YES{$ID}{EndA}=$A[2];
		}
	}else{
	$YES{$ID}{EndA}=$A[2];
	}

	$YES{$ID}{ChrB}=$A[3];

	if($YES{$ID}{StartB} ne ""){
		if($YES{$ID}{StartB} > $A[4]){
		$YES{$ID}{StartB}=$A[4];
		}
	}else{
	$YES{$ID}{StartB}=$A[4];
	}

	if($YES{$ID}{EndB} ne ""){
		if($YES{$ID}{EndB} < $A[5]){
		$YES{$ID}{EndB}=$A[5];
		}
	}else{
	$YES{$ID}{EndB}=$A[5];
	}

	}
	
	$ALL=$ID;
	for $m(1..$ALL){
		if($Three{$m} eq 1){
		print "$YES{$m}{ChrA}	$YES{$m}{StartA}	$YES{$m}{EndA}	$YES{$m}{ChrB}	$YES{$m}{StartB}	$YES{$m}{EndB}\n";					
		}
	}

