# Krys Kibler
# 2025-09-29

# Goal is to blast spacers id'ed in cas arrays (with cctk) to viral contigs (id'ed with VIBRANT)



mkdir /home/glbrc.org/kjkibler/ebpr_virus/analysis/blast/2025-09-29

# path to spacers from trina from slack
# /home/glbrc.org/kjkibler/ebpr_virus/analysis/blast/2025-09-29/CRISPR_spacers_found_using_contigs_w_repeats.fna
# path to concatenated ebpr viral seqs from VIBRANT
# /home/glbrc.org/kjkibler/ebpr_virus/analysis/VIBRANT/output/files/viral_ebpr_VIBRANT_combined.fna

condor_submit --interactive anvio-interactive.submit
source /home/GLBRCORG/kjkibler/miniconda3/etc/profile.d/conda.sh
export PATH=//home/GLBRCORG/kjkibler/miniconda3/bin:$PATH
unset PYTHONPATH
PYTHONPATH=""
PERL5LIB=""

### Code
cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/blast/2025-09-29
# createing a blastdb
makeblastdb -in /home/glbrc.org/kjkibler/ebpr_virus/analysis/blast/2025-09-29/CRISPR_spacers_found_using_contigs_w_repeats.fna \
            -input_type fasta \
            -title "EBPR_Spacers_1E" \
            -parse_seqids -blastdb_version 5 \
            -dbtype nucl \
            -out EBPR_Spacers_1E

#Building a new DB, current time: 09/29/2025 12:41:21
#New DB name:   /mnt/bigdata/linuxhome/kjkibler/ebpr_virus/analysis/blast/2025-09-29/EBPR_Spacers_1E
#New DB title:  EBPR_Spacers_1E
#Sequence type: Nucleotide
#Keep MBits: T
#Maximum file size: 3000000000B
#Adding sequences from FASTA; added 294 sequences in 0.073281 seconds.

# run EBPR_Spacers_1E blastdb on ebpr viral contigs
cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/blast/2025-09-25/
blastn -query /home/glbrc.org/kjkibler/ebpr_virus/analysis/VIBRANT/output/files/viral_ebpr_VIBRANT_combined.fna \
       -db EBPR_Spacers_1E \
       -out blast_results.txt \
       -task blastn \
       -q -1 \
       -r 1 \
       -word_size 7 \
       -outfmt 6

# headers qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore
