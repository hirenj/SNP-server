#!/bin/sh

S3PASSWDFILE=/tmp/.passwd-s3fs

if [ ! -e $S3PASSWDFILE ]; then
    read -p "Username: " accessKeyId 
    stty -echo 
    read -p "Password: " secretAccessKey; echo 
    stty echo
    echo "$accessKeyId"":""$secretAcessKey" > $S3PASSWDFILE
    chmod 600 $S3PASSWDFILE
fi

bin/setup_s3fs.sh

bin/snp_generator.sh

sudo umount $HOME/mnt_s3