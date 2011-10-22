# Snp generation server for 1001 proteomes #

## Installation ##

    make
    sudo perl -MCPAN -e 'install Inline::C'

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
        +--tairX
            +--tairX_cds.txt
            +--tairX_pseudochromosomes
                +--chr1.fas
                +--chr2.fas
                +--chr3.fas
                +--chr4.fas
                +--chr5.fas
                +--chrc.fas
                +--chrm.fas

    snps

Place any SNP files you want to translate into here. The converter will check to see if it has been
translated already, and normally won't do any translation. However, if the timestamp on the SNP file
is newer than the timestamp on the output translated files (actually the *.done files found in the 
work directories), then it will re-do the translation.
    
## SNP file format ##

The SNPS follow a slightly weird file format. Tab-separated, it is a subset of the GFF file format.
All filenames that you put in here should be in lowercase.

    #HEADER LINE OF SOME SORT
    Chromosome <TAB> position <TAB> original_base <TAB> new_base
    
For example:

    #HEADER LINE OF SOME SORT
    Chr1	575	G	T
    Chr1	597	C	T
    Chr1	603	G	A

## Setup on an Amazon EC2 Instance, storing data on S3 ##

You can back the execution of this using EC2. Start up an instance of the following AMI

Log in to this machine, and set the following environment variables: AWSACCESSKEYID and AWSSECRETACCESSKEY

Following that, from the snp-server directory:

    git pull
    
    make clean && make

    bin/setup_s3fs.sh BUCKETNAME
    