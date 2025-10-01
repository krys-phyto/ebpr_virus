#! /bin/bash

#################################################################
###                  Krys Kibler 2025-09-27                   ###
###           CONDOR SUBMIT EXECUTABLE BASH SCRIPT            ###
### Purpose: mapping the viral ebpr contigs                   ###
### https://bowtie-bio.sourceforge.net/bowtie2/manual.shtml   ###
#################################################################


BOWTIE2=/mnt/bigdata/bifxapps/bowtie2-2.4.5
#version 2.4.5

cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/bowtie2/individual/


# arguments
assembly_index=$1
reads=$2
reads_sampleID=$3
assembly_sampleID=${assembly_index%_fasta}

# bowtie2 code # this is further adapted in general bowtie bash script
# make an index
#mkdir bt2
#$BOWTIE2/bowtie2-build /home/glbrc.org/kjkibler/ebpr_virus/analysis/VIBRANT/output/files/viral_ebpr_VIBRANT_combined.fna\
#                    bt2/viral_ebpr_VIBRANT_combined_fasta.fa


# do the mapping
$BOWTIE2/bowtie2 -p 16 -x $assembly_sampleID/bt2/${assembly_index}.fa --very-sensitive --interleaved \
$reads > /home/glbrc.org/kjkibler/ebpr_virus/analysis/bowtie2/individual/$assembly_sampleID/bt2/${reads_sampleID}_vs_${assembly_sampleID}_viral.sam

# --sensitive -D 15 -R 2 -N 0 -L 22 -i S,1,1.15
