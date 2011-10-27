#!/bin/sh

fastadir=$1

if [ ! -d $fastadir ]; then
    echo "FASTA dir '$fastadir' does not exist"
    exit 1
fi

echo "<html><head><title>Fasta files</title><link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\"></head><body>" > $fastadir/index.html

for acc in `find $fastadir/* -type d | sort`; do
    accname=${acc##*/}
    echo "<div><h2>$accname</h2><ul>" >> $fastadir/index.html
    echo "<li><a href=\"$accname/protein_chr1.fas\">Chromosome 1</a></li>" >> $fastadir/index.html
    echo "<li><a href=\"$accname/protein_chr2.fas\">Chromosome 2</a></li>" >> $fastadir/index.html
    echo "<li><a href=\"$accname/protein_chr3.fas\">Chromosome 3</a></li>" >> $fastadir/index.html
    echo "<li><a href=\"$accname/protein_chr4.fas\">Chromosome 4</a></li>" >> $fastadir/index.html
    echo "<li><a href=\"$accname/protein_chr5.fas\">Chromosome 5</a></li>" >> $fastadir/index.html
    echo "<li><a href=\"$accname/protein_chrm.fas\">Chromosome M</a></li>" >> $fastadir/index.html
    echo "<li><a href=\"$accname/protein_chrm.fas\">Chromosome C</a></li>" >> $fastadir/index.html
    echo "</ul></div>" >> $fastadir/index.html
done

echo "</body></html>" >> $fastadir/index.html