#! /bin/bash

#################################################################
###                  Krys Kibler 2025-09-22                   ###
###           CONDOR SUBMIT EXECUTABLE BASH SCRIPT            ###
### Purpose: run seqkit to obtain full stats on assemblies    ###
#################################################################

# load up instrain
source /home/GLBRCORG/kjkibler/miniconda3/etc/profile.d/conda.sh

export PATH=//home/GLBRCORG/kjkibler/miniconda3/bin:$PATH
unset PYTHONPATH

PYTHONPATH=""
PERL5LIB=""

cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/seqkit/assembly_ebpr/


# arguments
assembly=$1
sampleID=$2


seqkit stats --tabular -o seqkit_$sampleID.tsv $assembly

# run after (not pushed to glbrc)
cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/seqkit/assembly_ebpr
mkdir concat
head -n 1 seqkit_ebpr_nexterav1_20100312.tsv > concat/seqkit_ebpr_assembly_concat.tsv
for f in seqkit_ebpr*
do
# Append the rest of the files, starting from the second line of each
tail -n +2 $f >> concat/seqkit_ebpr_assembly_concat.tsv
done
