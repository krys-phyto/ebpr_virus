# Krys Kibler
# 2025-09-24

# Goal is to blast spacers id'ed in cas arrays (with cctk) to viral contigs (id'ed with VIBRANT)



mkdir /home/glbrc.org/kjkibler/ebpr_virus/analysis/blast/2025-09-25

# path to spacers from trina from ebpr google drive # cctk_75contigs_w_cas2
# /home/glbrc.org/kjkibler/ebpr_virus/analysis/blast/2025-09-25/CRISPR_spacers.fna
# path to concatenated ebpr viral seqs from VIBRANT
# /home/glbrc.org/kjkibler/ebpr_virus/analysis/VIBRANT/output/viral_ebpr_VIBRANT_combined.fna

### Code
# createing a blastdb
makeblastdb -in /home/glbrc.org/kjkibler/ebpr_virus/analysis/blast/2025-09-25/CRISPR_spacers.fna \
            -input_type fasta \
            -title "EBPR_Spacers_1E" \
            -parse_seqids -blastdb_version 5 \
            -dbtype nucl \
            -out EBPR_Spacers_1E

#Building a new DB, current time: 09/24/2025 12:58:39
#New DB name:   /mnt/bigdata/linuxhome/kjkibler/ebpr_virus/analysis/blast/2025-09-25/EBPR_Spacers_1E
#New DB title:  EBPR_Spacers_1E
#Sequence type: Nucleotide
#Keep MBits: T
#Maximum file size: 3000000000B
#Adding sequences from FASTA; added 181 sequences in 0.051122 seconds.

# run EBPR_Spacers_1E blastdb on ebpr viral contigs
condor_submit --interactive anvio-interactive.submit
source /home/GLBRCORG/kjkibler/miniconda3/etc/profile.d/conda.sh
export PATH=//home/GLBRCORG/kjkibler/miniconda3/bin:$PATH
unset PYTHONPATH
PYTHONPATH=""
PERL5LIB=""

cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/blast/2025-09-25/
blastn -query /home/glbrc.org/kjkibler/ebpr_virus/analysis/VIBRANT/output/viral_ebpr_VIBRANT_combined.fna \
       -db EBPR_Spacers_1E \
      -out blast_results.txt \
      -outfmt 6

# headers qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore
