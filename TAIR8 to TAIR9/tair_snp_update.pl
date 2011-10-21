#!/usr/bin/perl

# used to upgrade positions of SNPs (or any other bas position) when new version of genome
# input is chr <tab> base position <tab> ref base <tab> snp
# Requires each chromosome update to be in separate files, using the subtratcive difference between the update file from TAIR
# Output returns input with updated base position, need to check output for 'substitutions' where actual snp site is modified

$snps = "snps.txt";
$chrup1 = "chr1up.txt";
$chrup2 = "chr2up.txt";
$chrup3 = "chr3up.txt";
$chrup4 = "chr4up.txt";
$chrup5 = "chr5up.txt";
$result = "result.txt";

open (SNP, "$snps") || die "Can't open snps.txt: $!\n";

open (OUT, ">>$result") || die "Can't open result.txt: $!\n";

while (<SNP>)  {

		my @oldsnp = split (" ", $_);

			if (@oldsnp[0] =~ /1$/) {

				open (INPUT1, "$chrup1") || die "Can't open chr1up.txt: $!\n";

					while (<INPUT1>) {

						my @tair9chr1 = split (" ", $_);

							if ((@tair9chr1[0] < @oldsnp[1]) && (@oldsnp[1] < @tair9chr1[1])) {

								my $newsnp1 = (@oldsnp[1] + @tair9chr1[2]);

								print OUT "@oldsnp[0]\t";

								print OUT "$newsnp1\t";

								print OUT "@oldsnp[2]\t";
							
								print OUT "@oldsnp[3]\n";

							}

							elsif (@oldsnp[1] eq @tair9chr1[0]) {  

								print OUT "Substitution\n";

							}

							else {next;}		
				
					}


				close (INPUT1);
			
			}

			elsif (@oldsnp[0] =~ /2$/ ) {

				open (INPUT2, "$chrup2") || die "Can't open chr2up.txt: $!\n";

					while (<INPUT2>) {

						my @tair9chr2 = split (" ", $_);

							if ((@tair9chr2[0] < @oldsnp[1]) && (@oldsnp[1] < @tair9chr2[1])) {

								my $newsnp2 = (@oldsnp[1] + @tair9chr2[2]);

								print OUT "@oldsnp[0]\t";

								print OUT "$newsnp2\t";

								print OUT "@oldsnp[2]\t";
							
								print OUT "@oldsnp[3]\n";

							}

							elsif (@oldsnp[1] eq @tair9chr2[0]) {  

								print OUT "Substitution\n";

							}

							else {next;}
				
					}


				close (INPUT2);
			
			}

			elsif (@oldsnp[0] =~ /3$/ ) {

				open (INPUT3, "$chrup3") || die "Can't open chr3up.txt: $!\n";

					while (<INPUT3>) {

						my @tair9chr3 = split (" ", $_);

							if ((@tair9chr3[0] < @oldsnp[1]) && (@oldsnp[1] < @tair9chr3[1])) {

								my $newsnp3 = (@oldsnp[1] + @tair9chr3[2]);

								print OUT "@oldsnp[0]\t";

								print OUT "$newsnp3\t";

								print OUT "@oldsnp[2]\t";
							
								print OUT "@oldsnp[3]\n";

							}

							elsif (@oldsnp[1] eq @tair9chr3[0]) {  

								print OUT "Substitution\n";

							}

							else {next;}
					}


				close (INPUT3);
			
			}

			elsif (@oldsnp[0] =~ /4$/ ) {

				open (INPUT4, "$chrup4") || die "Can't open chr4up.txt: $!\n";

					while (<INPUT4>) {

						my @tair9chr4 = split (" ", $_);

							if ((@tair9chr4[0] < @oldsnp[1]) && (@oldsnp[1] < @tair9chr4[1])) {

								my $newsnp4 = (@oldsnp[1] + @tair9chr4[2]);

								print OUT "@oldsnp[0]\t";

								print OUT "$newsnp4\t";

								print OUT "@oldsnp[2]\t";
							
								print OUT "@oldsnp[3]\n";

							}

							elsif (@oldsnp[1] eq @tair9chr4[0]) {  

								print OUT "Substitution\n";

							}

							else {next;}
		
				
					}


				close (INPUT4);
			
			}


			elsif (@oldsnp[0] =~ /5$/ ) {

				open (INPUT5, "$chrup5") || die "Can't open chr5up.txt: $!\n";

					while (<INPUT5>) {

						my @tair9chr5 = split (" ", $_);

							if ((@tair9chr5[0] < @oldsnp[1]) && (@oldsnp[1] < @tair9chr5[1])) {

								my $newsnp5 = (@oldsnp[1] + @tair9chr5[2]);

								print OUT "@oldsnp[0]\t";

								print OUT "$newsnp5\t";

								print OUT "@oldsnp[2]\t";
							
								print OUT "@oldsnp[3]\n";

							}

							elsif (@oldsnp[1] eq @tair9chr5[0]) {  

								print OUT "Substitution\n";

							}

							else {next;}
				
					}


				close (INPUT5);
			
			}

			else {next;}

		}
close (SNP);
close (OUT);