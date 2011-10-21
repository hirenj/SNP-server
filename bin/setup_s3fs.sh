#!/bin/sh

BASE=$HOME

S3MNTDIR=$BASE/s31001proteomes
FASTADIR=$S3MNTDIR/translated
SNPDIR=$S3MNTDIR/snps
GATORDIR=$S3MNTDIR/gator-snps
REFDATA=$S3MNTDIR/TAIR-data

LOCAL_OUT=out
LOCAL_FASTAS=fastas
LOCAL_SNPS=snps

s3fs -o passwd_file=$BASE/passwd-s3fs 1001proteomes $S3MNTDIR
if $?
then
    exit $?
fi

if [ ! -d $S3MNTDIR ]; then
    mkdir $S3MNTDIR
fi

if [ ! -d $REFDATA ]; then
    mkdir $REFDATA
fi

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