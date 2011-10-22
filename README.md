# Snp generation server for 1001 proteomes #

## Installation ##

    make

## Running ##

From this root directory
    
    bin/snp_generator.sh <SNPFILES>
    
If you pass in a list of SNPFILES, it will read those SNP files, otherwise it will look in
the default directory for SNPs.

## Important directories ##


    work

The work directory is a WORKING directory, and contains caches of chromosome files
after SNPs have been applied to them, etc. This directory can and will be regularly
cleaned up/changed.

    fastas

The fastas directory is an output directory. Here you'll find the finished and translated
proteins for each chromosome.

    out
    
The out directory contains output from the json-like file creator script, which will
summarise all the protein SNPs found for each of the accessions into a single file.

    ref-data
    
This contains reference data used for doing the translations. In general, the directory structure is

    ref-data
        +--TAIRx
            +--TAIRx_CDS.txt
            +--TAIRx_pseudochromosomes
                +--chr1.fas
                +--chr2.fas
                +--chr3.fas
                +--chr4.fas
                +--chr5.fas
                +--chrC.fas
                +--chrM.fas

    snps

Place any SNP files you want to translate into here. The converter will check to see if it has been
translated already, and normally won't do any translation. However, if the timestamp on the SNP file
is newer than the timestamp on the output translated files (actually the *.done files found in the 
work directories), then it will re-do the translation.
    
## SNP file format ##

The SNPS follow a slightly weird file format. Tab-seperated, it is a subset of the GFF file format

    Chromosome <TAB> position <TAB> original_base <TAB> new_base
    
For example:

    Chr1	575	G	T
    Chr1	597	C	T
    Chr1	603	G	A

## Setup on an EC2 Instance ##

    