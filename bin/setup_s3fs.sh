#!/bin/sh

BASE=$HOME

S3MNTDIR=$BASE/s31001proteomes
FASTADIR=$S3MNTDIR/translated
SNPDIR=$S3MNTDIR/snps
GATORDIR=$S3MNTDIR/gator-snps
REFDATA=$S3MNTDIR/tair-data

LOCAL_OUT=out
LOCAL_FASTAS=fastas
LOCAL_SNPS=snps
LOCAL_REFDATA=ref-data


sudo umount $S3MNTDIR
s3fs -o passwd_file=$BASE/passwd-s3fs 1001proteomes $S3MNTDIR

if [ ! -d $S3MNTDIR ]; then
    mkdir $S3MNTDIR
fi

if [ ! -d $REFDATA ]; then
    mkdir $REFDATA
fi

for tairver in "tair8" "tair9" "tair10"
do
    if [ ! -d $REFDATA/$tairver ]; then
        mkdir $REFDATA/$tairver
    fi
    if [ ! -d "$REFDATA/$tairver/$tairver""_pseudochromosomes" ]
    then
        mkdir "$REFDATA/$tairver/$tairver""_pseudochromosomes"
    fi
done
if [ ! -d $FASTADIR ]; then
    mkdir $FASTADIR
fi

if [ ! -d $SNPDIR ]; then
    mkdir $SNPDIR
fi

if [ ! -d $GATORDIR ]; then
    mkdir $GATORDIR
fi

if [ ! -d $LOCAL_OUT ]; then
    ln -s $GATORDIR $LOCAL_OUT
fi

if [ ! -d $LOCAL_FASTAS ]; then
    ln -s $FASTADIR $LOCAL_FASTAS
fi

if [ ! -d $LOCAL_SNPS ]; then
    ln -s $SNPDIR $LOCAL_SNPS
fi

if [ ! -d $LOCAL_REFDATA ]; then
    ln -s $REFDATA $LOCAL_REFDATA
fi
