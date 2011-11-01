#!/bin/bash

S3PASSWDFILE=/tmp/.passwd-s3fs
BUCKET=$1

shift

if [ ! -e $S3PASSWDFILE ]; then
    read -p "Access Key Id: " accessKeyId 
    stty -echo 
    read -p "Secret Access Key: " secretAccessKey; echo 
    stty echo
    read -p "Bucket name: " BUCKET
    echo "$accessKeyId"":""$secretAccessKey" > $S3PASSWDFILE
    chmod 600 $S3PASSWDFILE
fi

export S3PASSWDFILE

bin/setup_s3fs.sh $BUCKET

FILES=($@)
if [[ $# = 0 ]]; then
   FILES=(snps/*snp*.txt)
fi

ECOTYPES=()
for snp in "${FILES[@]}"; do
    ecotype=`echo "$snp" | perl -pe 's/.*(tair\d+)-snp-([^-]+)\..*$/\1-\2/i'`
    ECOTYPES+=($ecotype)
done

bin/snp_generator.sh "${FILES[@]}"

bin/results_to_json.sh "${ECOTYPES[@]}"

bin/generate_indexes.sh fastas "${ECOTYPES[@]}"

sudo umount $HOME/mnt_s3
