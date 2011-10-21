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


PERLPROG='open(FASTA,$ARGV[0]); while(my $line = <FASTA>) { $line =~ s/\n$//; if ($line =~ s/^>// ) { if ($line !~ /^\s*$/) { print qq|{"data" : ["$line","","|; } } elsif ($line !~ /^\s*$/) { $line =~ s/\*$//; print qq|$line"]}\n|; } }'
for i in `find $FASTADIR -name 'protein*M.fas'`; do
    ecotype=${i%/*}
    result=${ecotype##*/}
    if [ ! -e $WORKDIR/$result-json.txt ]; then
        touch "$WORKDIR/$result-json.txt"
        for fasta in `ls -1 $ecotype`; do
            perl -e "$PERLPROG" "$ecotype/$fasta" >> "$WORKDIR/$result-json.txt"
            echo "$ecotype/$fasta converted to a json"
        done
    fi
done

for acc in $WORKDIR/*-json.txt; do
    accname=`echo $acc |  sed -e 's/.*\(TAIR[0-9][0-9]*-.*\)-.*/\1/'`;
    if [ ! -e $WORKDIR/$accname-seqs.txt ]; then
        cat $acc | awk -F'","' '{ print $1 "," $3 }' | sed -e 's/"]}//' | sed -e 's/^.*"//' > $WORKDIR/$accname-seqs.txt
        echo $accname-seqs.txt
    fi
done

for acc in $WORKDIR/*-json.txt; do
    accname=`echo $acc | sed -e 's/.*\(TAIR[0-9][0-9]*-.*\)-.*/\1/'`;
    tairver=`echo $acc | sed -e 's/.*\(TAIR[0-9][0-9]*\).*/\1/'`;
    if [ ! -e $WORKDIR/$accname-subs.txt ]; then
        bin/fast_diff $WORKDIR/$tairver-Col0-seqs.txt $WORKDIR/$accname-seqs.txt > $WORKDIR/$accname-subs.txt;  
        echo $accname-subs.txt
    fi
done

for acc in $WORKDIR/*-subs.txt; do\
    accname=`echo "$acc" | sed -e 's/TAIR.*-\(.*\)-subs.txt/\1/'`;\
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
                    printf $1 ",\{ \"data\": {" rest_of_line; current_agi = $1;\
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