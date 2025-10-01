#! /bin/bash

#################################################################
###                  Krys Kibler 2025-09-19                   ###
###           CONDOR SUBMIT EXECUTABLE BASH SCRIPT            ###
### Purpose: EBPR viral detection and abundances              ###
### https://github.com/AnantharamanLab/VIBRANT                ###
#################################################################

# load up instrain
source /home/GLBRCORG/kjkibler/miniconda3/etc/profile.d/conda.sh

export PATH=//home/GLBRCORG/kjkibler/miniconda3/bin:$PATH
unset PYTHONPATH

PYTHONPATH=""
PERL5LIB=""

conda activate VIBRANT

cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/VIBRANT


# arguments
assembly=$1
sampleID=$2


/home/glbrc.org/kjkibler/miniconda3/envs/VIBRANT/bin/VIBRANT_run.py -i $assembly \
               -t 1 -folder output/$sampleID/
