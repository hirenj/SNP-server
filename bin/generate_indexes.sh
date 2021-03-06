#!/bin/bash

fastadir=$1
shift

tmpindex=/tmp/index.html

if [ ! -n "${fastadir:+1}" ]; then
    exit 1
fi

if [ ! -d $fastadir ]; then
    echo "FASTA dir '$fastadir' does not exist"
    exit 1
fi

echo "<html><head><title>Fasta files</title><link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\"></head><body>" > $tmpindex

ECOTYPES=($@)
if [[ $# = 0 ]]; then
   FILES=`find $fastadir/* -type d | sort`
   for snp in "${FILES[@]}"; do
       ecotype=`echo "$snp" | perl -pe 's/.*(tair\d+)-snp-([^-]+)\..*$/\1-\2/i'`
       ECOTYPES+=($ecotype)
   done
fi

for acc in "${ECOTYPES[@]}"; do
    echo $acc
    echo "<div><h2>$acc protein sets</h2><ul>" >> $tmpindex
    echo "<li><a href=\"$acc/protein_chr1.fas\">pep_chr1</a></li>" >> $tmpindex
    echo "<li><a href=\"$acc/protein_chr2.fas\">pep_chr2</a></li>" >> $tmpindex
    echo "<li><a href=\"$acc/protein_chr3.fas\">pep_chr3</a></li>" >> $tmpindex
    echo "<li><a href=\"$acc/protein_chr4.fas\">pep_chr4</a></li>" >> $tmpindex
    echo "<li><a href=\"$acc/protein_chr5.fas\">pep_chr5</a></li>" >> $tmpindex
    echo "<li><a href=\"$acc/protein_chrm.fas\">pep_chrm</a></li>" >> $tmpindex
    echo "<li><a href=\"$acc/protein_chrc.fas\">pep_chrc</a></li>" >> $tmpindex
    echo "</ul></div>" >> $tmpindex
done

echo "</body></html>" >> $tmpindex

rm $fastadir/index.html
cp $tmpindex $fastadir/index.html