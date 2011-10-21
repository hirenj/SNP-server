#!/usr/bin/perl -w

use Getopt::Long;
use Pod::Usage;
use File::Basename;
use Inline C => <<'END_C';
char replace_char(int pos,char is, char *file) {
    FILE *ptr = fopen(file, "r+");
    char was;
    fpos_t position;
    position = pos;
    fsetpos(ptr,&position);
    was = fgetc(ptr);
    fsetpos(ptr,&position);
    fputc(is,ptr);
    fclose(ptr);
    return was;
}
END_C


my $help = 0;
my $chr_file = '';
my $snp_file = '';
my $verbose = 0;
my $out_file;
my $use_fileout;

GetOptions(
    'help|?' => \$help,
    'verbose+' => \$verbose,
    'snp=s' => \$snp_file,
    'chromosome=s' => \$chr_file,
    'write:s' => sub { $out_file = $_[1]; $use_fileout = 1; }
) or pod2usage(2);

pod2usage(1) if $help;

sub apply_snp {
    my ($seq,$pos,$was,$is,$outfile) = @_;
    
    my $old_was;
    
    if ($outfile) {
        $old_was = replace_char($pos - 1,$is,$outfile);
    } else {
        $old_was = substr($seq,($pos - 1),1,$is);        
        return $seq;
    }
    
    if ($was eq $old_was) {
        if ($outfile) {
            return;
        } else {
            return $seq;
        }
    }
    
    if ($was eq 'R' || $old_was eq 'R') {
        $was =~ tr/AG/R/;
        $old_was =~ tr/AG/R/;
    }
    if ($was eq 'Y' || $old_was eq 'Y') {
        $was =~ tr/TC/Y/;
        $old_was =~ tr/TC/Y/;
    }
    if ($was eq 'W' || $old_was eq 'W') {
        $was =~ tr/AT/W/;
        $old_was =~ tr/AT/W/;
    }
    if ($was eq 'S' || $old_was eq 'S') {
        $was =~ tr/GC/S/;
        $old_was =~ tr/GC/S/;
    }
    if ($was eq 'M' || $old_was eq 'M') {
        $was =~ tr/AC/M/;
        $old_was =~ tr/AC/M/;
    }
    if ($was eq 'K' || $old_was eq 'K') {
        $was =~ tr/GT/K/;
        $old_was =~ tr/GT/K/;
    }
    if ($was eq 'H' || $old_was eq 'H') {
        $was =~ tr/ATC/H/;
        $old_was =~ tr/ATC/H/;
    }
    if ($was eq 'B' || $old_was eq 'B') {
        $was =~ tr/GCT/B/;
        $old_was =~ tr/GCT/B/;
    }
    if ($was eq 'V' || $old_was eq 'V') {
        $was =~ tr/GAC/V/;
        $old_was =~ tr/GAC/V/;
    }
    if ($was eq 'D' || $old_was eq 'D') {
        $was =~ tr/GAT/D/;
        $old_was =~ tr/GAT/D/;
    }
    if ($was eq 'N' || $old_was eq 'N') {
        $was =~ tr/AGCTRYWSMKHBVD/N/;
        $old_was =~ tr/AGCTRYWSMKHBVD/N/;
    }
    
    if ($was ne $old_was) {        
        die "At position ${pos} actually is ${old_was} should be ${was}";
    }
    return $seq;
}

open(CHR, $chr_file);

my @seq = <CHR>;

close(CHR);

shift @seq;

my $sequence = join '', @seq;

$sequence =~ s/[\s\n\r]//g;

my $pos_shift = 0;

open(SNP, $snp_file);

my @snps = <SNP>;

close(SNP);

splice (@snps,0,1);

my @current_chr_file = fileparse($chr_file);

my $current_chr = shift @current_chr_file;

$current_chr =~ s/\..*//;

my $current_chr_num = $current_chr;

$current_chr_num =~ s/chr//i;

my @current_snp_file = fileparse($snp_file);

my $current_snp = shift @current_snp_file;

$current_snp =~ s/\..*//;

if ($use_fileout && ! $out_file) {
    $out_file = "${current_snp}_${current_chr}.fas";
}

if ($out_file) {
    open (OUT,">${out_file}");
    print OUT ">${current_snp}_${current_chr}\n$sequence";
    $pos_shift += length(">${current_snp}_${current_chr}\n");
    close(OUT);
}

@snps = map { $_ =~ s/[\n\r]//g; $_; } @snps;

sub fix_val {
    my $origval = shift;
    if ($origval =~ /^(Chr)?M$/i) {
        return 7;
    }
    if ($origval =~ /^(Chr)?C$/i) {
        return 6;
    }
    if ($origval !~ /^\d+$/) {
        return -1;
    }
    return $origval;
}

@snps = grep { my $chr = $_->[0]; $chr =~ s/Chr//i; fix_val(lc $current_chr_num) == fix_val(lc $chr) } map { [split /\t/]; } @snps;

my $i = 1;

my $snp_length = scalar @snps;

my $fh;

#exit unless $snp_length > 0;

foreach my $snp (@snps) {
    warn "Completed ${i} of ${snp_length}" if ($verbose);
    $sequence = apply_snp($sequence,$snp->[1]+$pos_shift,$snp->[2],$snp->[3], $out_file);
    $i++;
}


if ($out_file) {
    # close_output($fh);
    # open (OUT,">${out_file}");
    # print OUT ">${current_snp}_${current_chr}\n$sequence";
    # close(OUT);
} else {
    print ">${current_snp}_${current_chr}\n$sequence";    
}



__END__

=head1 NAME

apply_snp.pl - Apply a set of SNPS to a chromosome file

=head1 SYNOPSIS

apply_snp.pl [options]

    Options:
        --help       Brief help message
        --verbose    Increase verbosity of messages
        --snp        Specify SNP file
        --chr        Specify Chromosome file
        --write      Write the chromosome to a generated filename, or specify a filename    
