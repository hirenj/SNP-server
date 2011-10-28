#!/bin/sh

fastadir=$1

tmpindex=/tmp/index.html

if [ ! -n "${fastadir:+1}" ]; then
    exit 1
fi

if [ ! -d $fastadir ]; then
    echo "FASTA dir '$fastadir' does not exist"
    exit 1
fi

echo "<html><head><title>Fasta files</title><link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\"></head><body>" > $tmpindex

for acc in `find $fastadir/* -type d | sort`; do
    accname=${acc##*/}
    echo "<div><h2>$accname</h2><ul>" >> $tmpindex
    echo "<li><a href=\"$accname/protein_chr1.fas\">Chromosome 1</a></li>" >> $tmpindex
    echo "<li><a href=\"$accname/protein_chr2.fas\">Chromosome 2</a></li>" >> $tmpindex
    echo "<li><a href=\"$accname/protein_chr3.fas\">Chromosome 3</a></li>" >> $tmpindex
    echo "<li><a href=\"$accname/protein_chr4.fas\">Chromosome 4</a></li>" >> $tmpindex
    echo "<li><a href=\"$accname/protein_chr5.fas\">Chromosome 5</a></li>" >> $tmpindex
    echo "<li><a href=\"$accname/protein_chrm.fas\">Chromosome M</a></li>" >> $tmpindex
    echo "<li><a href=\"$accname/protein_chrc.fas\">Chromosome C</a></li>" >> $tmpindex
    echo "</ul></div>" >> $tmpindex
done

echo "</body></html>" >> $tmpindex

rm $fastadir/index.html
cp $tmpindex $fastadir/index.html