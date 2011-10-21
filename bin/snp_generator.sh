#!/bin/bash

SNP_APPLY=bin/apply_snp.pl
TRANSLATE=bin/translate.pl

INPUTDIR=snps
WORKDIR=work
REFDATA=ref-data
FASTADIR=fastas

if [ ! -d "$WORKDIR" ]
then
    echo "Could not find reference data at $WORKDIR"
    exit 1;
fi

if [ ! -d "$REFDATA" ]
then
    echo "Could not find reference data at $REFDATA"
    exit 1;
fi

if [ ! -d "$FASTADIR" ]
then
    echo "Could not find FASTA directory at $FASTADIR"
    exit 1;
fi



FILES=($@)
if [[ $# = 0 ]]; then
   FILES=($INPUTDIR/*SNP*.txt)
fi
for snp in ${FILES[@]}
do
    a_snp=`echo ${snp%%.txt} | sed 's#^.*/##'`
    tair_ver=${a_snp%%-*}; rest=${a_snp#*-}
    is_snp=${rest%%-*}; rest=${rest#*-}
    snp_ver=${rest%%-*};
    
    work_id="$tair_ver-$snp_ver"

    finished_count=`ls -1 $FASTADIR/$work_id/protein_chr*.fas 2> /dev/null | wc -l | sed -e 's/ *//'`

    if [ ! -e $WORKDIR/$work_id.done ] && [ $finished_count -eq '7' ]
    then
        touch "$WORKDIR/$work_id.done"
        continue
    fi
    
    if [ "$snp" -nt "$WORKDIR/$work_id.done" ]
    then
        rm "$WORKDIR/$work_id.done"
        rm -rf "$WORKDIR/$work_id"
        rm -rf "$WORKDIR/$work_id.work"
    fi
    
    if [ -e "$WORKDIR/$work_id.done" ]
    then
        continue
    fi

    if [ ! -d "$WORKDIR/$work_id" ]; then
        mkdir "$WORKDIR/$work_id"
    fi

    workdir="$WORKDIR/$work_id.work"
    
    if [ ! -d $workdir ]; then
        mkdir $workdir
    fi
    pseudoname="_pseudochromosomes/chr*.fas"
    for chr_file in `ls -1 $REFDATA/$tair_ver/$tair_ver$pseudoname`
    do
        chr=`echo ${chr_file%%.fas} | sed 's#^.*/chr##'`
        if [ -e $workdir/chr$chr.inprogress ]; then
            current_status
            exit 0
        fi
        
        if [ -e $workdir/chr$chr.fas ]; then
            continue
        fi
        
        if [ -e $workdir/chr$chr.error ]; then
            continue
        fi

        touch $workdir/chr$chr.inprogress
        
        $SNP_APPLY --chromosome $chr_file --snp $snp --write "$workdir/chr$chr.inprogress" -v -v -v 2> $workdir/chr$chr.log
        
        if [ $? -ne 0 ]; then
            mv "$workdir/chr$chr.log" "$workdir/chr$chr.error"
            rm "$workdir/chr$chr.inprogress"
            echo "Did not complete updating chromsome $chr for $tair_ver using SNP $snp_ver"
            continue
        fi
        
        mv "$workdir/chr$chr.inprogress" "$workdir/chr$chr.fas"
        
        echo "Completed updating chromsome $chr for $tair_ver using SNP $snp_ver"
    done
    
    chromosome_count=`ls -1 $workdir/chr*.fas 2> /dev/null | wc -l | sed -e 's/ *//'`
    
    if [ $chromosome_count -ne '7' ]; then
        echo "Not enough chromosome files $work_id"
        # EMAIL ERROR
        continue 
    fi
    
    
    for chr_file in "$workdir"/chr*.fas
    do
        chr=`echo ${chr_file%%.fas} | sed 's#^.*/chr##'`

        if [ -e $workdir/protein_chr$chr.inprogress ]; then
            exit 0
        fi
        
        if [ -e out/$work_id/protein_chr$chr.fas ]; then
            continue
        fi
        
        if [ -e $workdir/protein_chr$chr.error ]; then
            continue
        fi

        touch $workdir/protein_chr$chr.inprogress


        $TRANSLATE --fasta $chr_file --cds "$REFDATA/$tair_ver/$tair_ver""_CDS.txt" --chromosome $chr --write "$workdir/protein_chr$chr.inprogress" -v -v -v 2> $workdir/protein_chr$chr.log
        

        if [ $? -ne 0 ]; then
            mv "$workdir/protein_chr$chr.log" "$workdir/protein_chr$chr.error"
            rm "$workdir/protein_chr$chr.inprogress"
            echo "Did not complete translation of $chr for $tair_ver using SNP $snp_ver"
            continue
        fi
        
        if [ ! -d $FASTADIR/$work_id ]; then
            mkdir $FASTADIR/$work_id
        fi
        
        mv "$workdir/protein_chr$chr.inprogress" "$FASTADIR/$work_id/protein_chr$chr.fas"
        
        echo "Completed translation of $chr for $tair_ver using SNP $snp_ver"
    done
    finished_count=`ls -1 $FASTADIR/$work_id/protein_chr*.fas 2> /dev/null | wc -l | sed -e 's/ *//'`

    if [ $finished_count -ne '7' ]; then
        echo "Could not complete for $work_id"
        continue
    fi

    touch "$WORKDIR/$work_id.done"

done

bin/results_to_json.sh