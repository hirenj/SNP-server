#!/bin/bash

WORKDIR=work
FASTADIR=fastas
OUTDIR=out

if [ ! -d "$WORKDIR" ]
then mkdir $WORKDIR
fi

if [ ! -d "$OUTDIR" ]
then mkdir $OUTDIR
fi

if [ ! -d "$FASTADIR" ]
then
    echo "Could not find FASTA directory at $FASTADIR"
    exit 1;
fi

ECOTYPES=($@)
if [[ $# = 0 ]]; then
   FILES=($WORKDIR/*done)
   for snp in "${FILES[@]}"; do
       ecotype=`echo "$snp" | perl -pe 's/.*(tair\d+)-snp-([^-]+)\..*$/\1-\2/i'`
       ECOTYPES+=($ecotype)
   done
fi


PERLPROG='open(FASTA,$ARGV[0]); while(my $line = <FASTA>) { $line =~ s/\n$//; if ($line =~ s/^>// ) { if ($line !~ /^\s*$/) { print qq|{"data" : ["$line","","|; } } elsif ($line !~ /^\s*$/) { $line =~ s/\*$//; print qq|$line"]}\n|; } }'
for ecotype in "tair9-col0" "tair10-col0" "${ECOTYPES[@]}"; do
    if [ ! -e $WORKDIR/$ecotype-json.txt ]; then
        touch "$WORKDIR/$ecotype-json.txt"
        counter=0
        for fasta in `ls -1 $FASTADIR/$ecotype/*.fas`; do
            counter=counter+1
            perl -e "$PERLPROG" "$fasta" >> "$WORKDIR/$ecotype-json.txt"
            echo "$fasta converted to a json"
        done
        if [ ! $counter = 7 ]
        then
            rm "$WORKDIR/$ecotype-json.txt"
        fi
    fi
done

for ecotype in "tair9-col0" "tair10-col0" "${ECOTYPES[@]}"; do
    acc="$WORKDIR/$ecotype-json.txt"
    if [ ! -e $acc ]; then
        continue
    fi
    accname=`echo $acc | perl -pe 's/.*(TAIR[0-9][0-9]*-.*)-.*/\1/i'`;
    if [ ! -e $WORKDIR/$accname-seqs.txt ]; then
        cat $acc | awk -F'","' '{ print $1 "," $3 }' | sed -e 's/"]}//' | sed -e 's/^.*"//' > $WORKDIR/$accname-seqs.txt
        echo $accname-seqs.txt
    fi
done

for ecotype in "tair9-col0" "tair10-col0" "${ECOTYPES[@]}"; do
    acc="$WORKDIR/$ecotype-seqs.txt"
    if [ ! -e $acc ]; then
        continue
    fi
    accname=`echo $acc | perl -pe 's/.*(TAIR[0-9][0-9]*-.*)-.*/\1/i'`
    tairver=`echo $acc | perl -pe 's/.*(TAIR[0-9][0-9]*).*/\1/i'`
    if [ ! -e $WORKDIR/$tairver-col0-seqs.txt ]; then
        continue
    fi
    echo "Subs for $accname"
    if [ ! -e "$WORKDIR/$accname-subs.txt" ]; then
        PROG="bin/fast_diff $WORKDIR/$tairver-col0-seqs.txt $WORKDIR/$accname-seqs.txt"
        $PROG > "$WORKDIR/$accname-subs.txt"        
        echo $accname-subs.txt
    fi
done

for ecotype in "${ECOTYPES[@]}"; do
    acc="$WORKDIR/$ecotype-subs.txt"
    if [ ! -e $acc ]; then
        continue
    fi    
    accname=`echo "$acc" | perl -pe 's/TAIR.*-(.*)-subs.txt/\1/i'`;\
    cat $acc | sed -e 's/\([:,]\)/"\1"/g' | sed -e 's/ \([0-9]\)/ "\1/' |\
    awk "{ print \$1 \",\\\"$accname\\\" : {\" \$2 \"},\" }" |\
    sed -e 's/,\"}/}/';\
done |\
sort -t',' -k1 |\
awk -F',' '{    rest_of_line = substr($0, index($0,$2));\
                gsub(/\\n/,"",rest_of_line); \
                if (current_agi == $1) {\
                    printf rest_of_line; \
                } else {\
                    if (current_agi != "") { \
                        print "}}";\
                    }\
                    printf $1 ",{ \"data\": {" rest_of_line; current_agi = $1;\
                }\
            }\
            END {\
                if (current_agi != "") { \
                    print "}}"\
                }\
            }' |\
sed -e 's/,}/}/' | perl -pe 's/"data"/#data#/' | perl -pe 's/"[^,]+" : {}//g' | perl -pe 's/,+((,")|})/$1/g' | perl -pe 's/{,+/{/g' | tr '#' '"' > $WORKDIR/MASCP.SnpReader.txt

if [ -e $WORKDIR/MASCP.SnpReader.txt ]; then
    CURRDATE=$(date +%Y-%m-%d)
    cp $WORKDIR/MASCP.SnpReader.txt $OUTDIR/MASCP.SnpReader-$CURRDATE.txt
fi