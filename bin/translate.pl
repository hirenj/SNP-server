#!/usr/bin/perl -w

use lib "./perllib";

use strict;
use warnings;

use Bio::Seq;
use Bio::SeqIO;

use Getopt::Long;
use Pod::Usage;
use File::Basename;

my $help = 0;
my $fasta_file = '';
my $cds_file = '';
my $chromosome = 0;
my $verbose = 0;
my $out_file;
my $use_fileout;
my $truncate;

my $add_val = sub {
    my $seq = shift;
    my $position = shift;
    my $arg = shift;
    substr($seq,$position,0,$arg);
    return $seq;
};

my $del_val = sub {
    my $seq = shift;
    my $position = shift;
    my $arg = shift;
    substr($seq,$position,1,"");
    return $seq;
};

my $sub_val = sub {
    my $seq = shift;
    my $position = shift;
    my $arg = shift;
    substr($seq,$position,1,$arg);
    return $seq;
};

my $edits = {
"tair9" => {
'AT1G03495.1' => [ 874463, $add_val, "A" ],
"AT1G07290.1" => [ 2243386, $add_val, "C" ],
"AT1G17000.1" => [ 5815327, $add_val, "N" ],
"AT1G23450.1" => [ 8325811, $add_val, "T" ],
"AT1G24880.1" => [ 8782824, $add_val, "G" ],
"AT1G27565.1" => [ 9574710, $sub_val, "A" ],
"AT1G76820.1" => [ 28838561, $add_val, "A" ],
"AT1G79920.1" => [ 30059783, $add_val, "G" ],
"AT2G06210.1" => [ 2435192, $add_val, "C" ],
"AT2G19940.1" => [ 8613362, $add_val, "C" ],
"AT2G31100.1" => [ 13257724, $sub_val, "G" ],
"AT3G08943.1" => [  [ 2720586, $add_val, "T" ],
                    [ 2720587, $add_val, "C" ]],
"AT3G08947.1" => [ 2724614, $add_val, "G" ],
"AT3G12915.1" => [  [ 4113962, $del_val, "" ],
                    [ 4114587, $sub_val, "G" ]],
"AT3G18150.1" => [ 6218435, $add_val, "C" ],
"AT3G55270.1" => [ 20497326, $add_val, "T" ],
"AT4G14272.1" => [ 8219957, $del_val, "" ],
"AT4G15130.1" => [  [ 8638672, $sub_val, "G" ],
                    [ 8638681, $add_val, "T" ]],
"AT4G15200.1" => [  [ 8663538, $add_val, "G" ],
                    [ 8663543, $add_val, "G" ]],
"AT4G15780.1" => [  [ 8980213, $del_val, "" ],
                    [ 8980214, $del_val, "" ]],
"AT4G16110.1" => [  [ 9112829, $del_val, "" ],
                    [ 9114387, $add_val, "G" ]],
"AT4G16144.1" => [  [ 9138616, $add_val, "A" ],
                    [ 9138630, $add_val, "A" ]],
"AT4G16150.1" => [ 9151948, $add_val, "G" ],
"xAT4G16370.1" => [  [ 9247915, $sub_val, "T" ],
                    [ 9247916, $sub_val, "C" ]],
"AT4G17100.1" => [  [ 9612479, $del_val, "" ],
                    [ 9612480, $del_val, "" ],
                    [ 9612481, $del_val, "" ],
                    [ 9612482, $del_val, "" ],
                    [ 9612483, $del_val, "" ]],
"AT4G21326.1" => [  [ 11346415, $sub_val, "G" ],
                    [ 11346687, $del_val, "" ],
                    [ 11348287, $sub_val, "G" ]],
"AT4G23000.1" => [  [ 12059496, $del_val, "" ],
                    [ 12059504, $del_val, "" ],
                    [ 12059529, $del_val, "" ],
                    [ 12059568, $del_val, "" ],
                    [ 12059680, $del_val, "" ],
                    [ 12059702, $del_val, "" ]],
"AT4G32640.1" => [ 15749530, $sub_val, "G" ],
"AT4G35335.1" => [ 16807915, $add_val, "G" ],
"AT5G11100.1" => [ 3532791, $add_val, "G" ],
"AT5G13590.1" => [  [ 4377506, $sub_val, "G" ],
                    [ 4377801, $sub_val, "A" ],
                    [ 4377965, $sub_val, "G" ]],
"AT5G18710.1" => [ 6242822, $del_val, "" ],
"AT5G23480.1" => [ 7918410, $add_val, "C" ]
},
"tair10" => {
"AT1G54360.1"   => [ 20291172, $add_val,"T"],
"AT1G54360.2"   => [ 20291172, $add_val,"T"],
"AT1G54360.3"   => [ 20291172, $add_val,"T"],
"AT1G54360.4"   => [ 20291172, $add_val,"T"],
"AT1G54360.5"   => [ 20291172, $add_val,"T"],
"AT1G54360.1"   => [ 20291171, $add_val,"C"],
"AT1G54360.2"   => [ 20291171, $add_val,"C"],
"AT1G54360.3"   => [ 20291171, $add_val,"C"],
"AT1G54360.4"   => [ 20291171, $add_val,"C"],
"AT1G54360.5"   => [ 20291171, $add_val,"C"],
"AT1G60930.1"   => [ 22435331, $add_val,"A"],
"AT4G16770.1"   => [ 9435266, $del_val,""],
"AT4G15950.1"   => [ 9041376, $del_val,""],
"AT5G26800.1"   => [ 9425619, $add_val,"G"],
"AT3G57180.1"   => [ 21165336, $add_val,"G"],
"AT1G18320.1"   => [ 6304996, $sub_val,"C"],
"AT4G15200.1"   => [ 8664046, $add_val,"C"],
"AT4G15200.2"   => [ 8664046, $add_val,"C"]
}
};

GetOptions(
    'help|?' => \$help,
    'verbose+' => \$verbose,
    'fasta=s' => \$fasta_file,
    'cds=s' => \$cds_file,
    'chromosome=s' => \$chromosome,
    'truncate' => \$truncate,
    'write:s' => sub { $out_file = $_[1]; $use_fileout = 1; }
) or pod2usage(2);

pod2usage(1) if $help;

my $in = Bio::SeqIO->new('-file' => $fasta_file, '-format' => 'Fasta');

my ($tairversion) = ($cds_file =~ /(TAIR\d+)/i);

$tairversion = lc $tairversion;

# error on empty values, ensure no CR/LF at end of file
open (INFILE, $cds_file ) or die "file not found!";

my $final_sequence = '';

my $total_proteins = $verbose ? `cat $cds_file | awk '{ print \$2\$1 }' | grep "^$chromosome" | sort | uniq | wc -l` : 0;

my $current_agi = '';

if ($use_fileout) {
    
    my @current_fasta_file = fileparse($fasta_file);

    my $current_fasta = shift @current_fasta_file;
    
    $current_fasta =~ s/\..*//;
    
    $out_file = $out_file || "${current_fasta}_protein.fas";
    
    open(OUTFILE, ">", "$out_file") or die "Can't open out file: $!";
}

sub do_output {
    my $curr_agi = shift;
    my $seq = shift;
    my $fh = ($use_fileout ? *OUTFILE : *STDOUT);
    print $fh ">${curr_agi}\n";
    my $result_seq = Bio::Seq->new(-alphabet => 'dna', -seq => $seq)->translate->seq();
    $result_seq =~ s/\*.*$/*/ if ($truncate);
    print $fh $result_seq."\n";    
}

my $count = 0;

while ( my $seq = $in->next_seq() ) {
    my $seq_string = $seq->seq();
    my $seqedited = undef;
    my $last_start = undef;
    my $last_end = undef;
    my $last_dir = '';
    while (<INFILE>) {

            my ($agi, $chr, $start, $end, $dir) = split(/\s+/);
            next if (lc($chr) ne lc($chromosome));
            if ( length $current_agi == 0 && length $agi > 0) {
                $current_agi = $agi;
            }
            if (length $current_agi > 0 && $current_agi ne $agi) {
                if ($truncate) {
                    my $pre_seq = '';
                    my $begin = $last_start;
                    my $ending = $last_end;
                    my $delta = 0;
                    while ( $final_sequence !~ /TA[AG]$/ && $final_sequence !~ /TGA$/ ) {
                        $delta += 1000;
                        if ($last_dir eq '+') {
                            $begin = $last_end;
                            $ending = $ending + 1000;
                        } else {
                            $ending = $last_start;
                            $begin = $begin - 1000;
                        }
                        if ($ending > $seq->length() || $begin < 0 || $delta > 11000 ) {
                            last;
                        }
                        $pre_seq = $seq->subseq($begin,$ending);
                        if ($last_dir eq '-') {
                            $pre_seq = Bio::Seq->new(-alphabet => 'dna', -seq => $pre_seq)->revcom->seq();
                        }

                        if ($pre_seq =~ /^((?:\w\w\w)*TA[AG])/ || $pre_seq =~ /^((?:\w\w\w)*TGA)/) {
                            my $extension = $1;
                            if ($verbose) {
                                my %seen = ();
                                warn "Extending $current_agi looking for stop codon with $extension";
                                warn join ",", sort grep { ! $seen{$_} ++ } (split /(.{3})/, $extension);                                
                            }
                            $final_sequence .= $extension;
                        }
                    }
                }
                do_output($current_agi,$final_sequence);
                $current_agi = $agi;
                $final_sequence = '';
                if ($verbose) {
                    $count +=1;
                    warn "Completed $count of $total_proteins";
                }
            }

            $last_start = $start;
            $last_end = $end;
            $last_dir = $dir;
            my $sseq = substr($seq_string,$start-1,$end-$start+1);
            #This was the old and REALLY slow method of doing a substring
            #$seq->subseq($start,$end);

            if ($edits->{$tairversion} && $edits->{$tairversion}->{$current_agi} ) {
                my $editthings = $edits->{$tairversion}->{$current_agi};
                if ($editthings->[0] =~ /^\d+$/) {
                    $editthings = [ $editthings ];
                }
                my $pos_shift = 0;
                foreach my $edit (@$editthings) {
                    my $pos = $edit->[0];
                    if ($start <=  $pos && $end >= $pos) {
                        $pos += $pos_shift;

                        $pos -= $start;

                        my $func = $edit->[1];
                        my $arg = $edit->[2];

                        if ($dir eq '-' && ($func == $add_val)) {
                            $arg = Bio::Seq->new(-alphabet => 'dna', -seq => $arg)->revcom->seq();
                            $pos += 1;
                        }
                        if ($dir eq '-' && ($func == $sub_val)) {
                            $arg = Bio::Seq->new(-alphabet => 'dna', -seq => $arg)->revcom->seq();                            
                        }
                        
                        $sseq = $func->($sseq, $pos, $arg);
                        
                        if ($func == $del_val) {
                            $pos_shift -= 1;
                        }
                        if ($func == $add_val) {
                            $pos_shift += 1;
                        }
                    }
                }
            }

            if ($dir eq '-') {
                $sseq = Bio::Seq->new(-alphabet => 'dna', -seq => $sseq)->revcom->seq();
            }
            
            if ( undef && $truncate && $final_sequence eq '' && $sseq !~ /^ATG/ ) {
                my $pre_seq = '';
                my $begin = $start;
                my $ending = $end;
                while ($final_sequence eq '') {
                    if ($dir eq '+') {
                        $begin = $begin - 1000;
                        $ending = $start;
                        if ($begin < 0) {
                            $begin = 0;
                        }
                    } else {
                        $begin = $end;
                        $ending = $ending + 1000;
                    }
                    $pre_seq = $seq->subseq($begin,$ending);
                    if ($dir eq '-') {
                        $pre_seq = Bio::Seq->new(-alphabet => 'dna', -seq => $pre_seq)->revcom->seq();
                    }

                    if ($pre_seq =~ s/.*ATG(?=(\w\w\w)*$)//) {
                        warn "Looking back for start codon with ATG$pre_seq";
                        my %seen = ();
                        warn join ",", sort grep { ! $seen{$_} ++ } (split /(.{3})/, $pre_seq);
                        $final_sequence = "ATG".$pre_seq;
                    }
                }
            }
            
            $final_sequence .= $sseq;    
    }
    
    
    if ($current_agi) {
        do_output($current_agi,$final_sequence);
    }
}

if ($use_fileout) {
    close(STDOUT);
}

__END__

=head1 NAME

translate.pl - Translate a FASTA file for a chromosome into a sequence file

=head1 SYNOPSIS

translate.pl [options]

    Options:
        --help       Brief help message
        --verbose    Increase verbosity of messages
        --fasta      Specify input fasta file
        --cds        Specify CDS file
        --chromosome Chromosome to translate
        --write      Write the chromosome to a generated filename (XXX_protein.fas), or specify a filename
