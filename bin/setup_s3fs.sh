#!/bin/sh

BASE=$HOME

S3MNTDIR=$BASE/mnt_s3
FASTADIR=$S3MNTDIR/translated
SNPDIR=$S3MNTDIR/snps
GATORDIR=$S3MNTDIR/gator-snps
REFDATA=$S3MNTDIR/tair-data
WORKDIR=/mnt/work

LOCAL_OUT=out
LOCAL_FASTAS=fastas
LOCAL_SNPS=snps
LOCAL_REFDATA=ref-data
LOCAL_WORK=work

BUCKETNAME=$1

if [ -z $BUCKETNAME ]
then
    BUCKETNAME="1001proteomes"
fi

if [ -d $S3MNTDIR ]; then
    FILESINMNT=`ls -1 $S3MNTDIR | wc -l`
    if [ ! $FILESINMNT -gt 0 ]
    then
        sudo umount $S3MNTDIR
    fi
fi

if [ ! -d $S3MNTDIR ]; then
    mkdir $S3MNTDIR
fi

if [ -n "${S3PASSWDFILE:+1}" ]; then
    S3OPTIONS="-opasswd_file=$S3PASSWDFILE"
fi

s3fs $BUCKETNAME $S3MNTDIR $S3OPTIONS
rc=$?

if [ $rc -gt 0 ]; then
    exit $rc
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
    ln -i -s $GATORDIR $LOCAL_OUT
fi

if [ ! -d $LOCAL_FASTAS ]; then
    ln -i -s $FASTADIR $LOCAL_FASTAS
fi

if [ ! -d $LOCAL_SNPS ]; then
    ln -i -s $SNPDIR $LOCAL_SNPS
fi

if [ ! -d $LOCAL_REFDATA ]; then
    ln -i -s $REFDATA $LOCAL_REFDATA
fi

if [ ! -d $LOCAL_WORK ]; then
    if [ ! -d $WORKDIR ]; then
        mkdir $WORKDIR
    fi
    ln -i -s $WORKDIR $LOCAL_WORK
fi
