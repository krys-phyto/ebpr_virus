#! /bin/bash

#################################################################
###                  Krys Kibler 2025-09-24                   ###
###           CONDOR SUBMIT EXECUTABLE BASH SCRIPT            ###
### Purpose: run seqkit to obtain full stats on metagenomes   ###
#################################################################

# load up instrain
source /home/GLBRCORG/kjkibler/miniconda3/etc/profile.d/conda.sh

export PATH=//home/GLBRCORG/kjkibler/miniconda3/bin:$PATH
unset PYTHONPATH

PYTHONPATH=""
PERL5LIB=""

cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/seqkit/reads_ebpr/


# arguments
reads=$1
sampleID=`basename $reads`


seqkit stats --tabular -o seqkit_${sampleID%.fastq.fna}.tsv $reads

# run after
#cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/seqkit/reads_ebpr
#head -n 1 seqkit_EBPRR120100312.fna.tsv > concat/seqkit_ebpr_reads_concat.tsv
#for f in seqkit_*.tsv
#do
#Append the rest of the files, starting from the second line of each
#echo $f
#tail -n +2 $f >> concat/seqkit_ebpr_reads_concat.tsv
#done
