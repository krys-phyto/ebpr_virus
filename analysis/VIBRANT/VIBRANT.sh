# Krys Kibler
# 2025-09-18

# Goal is to run vibrant on all the available EBPR assemblies
# catalog all the potential viral genomes
      ## check quality and obtain coverage with checkV
      ## identify spacers

# path to assemblies
# OG         #/mnt/bigdata/lab_data/mcmahon_lab/ebpr_data/EBPR/R1R2/Metagenomes/spades_assemblies
# Nextera v2 #/mnt/bigdata/lab_data/mcmahon_lab/jgi/nextera_2024_version_2
# Nextera v1 #/mnt/bigdata/lab_data/mcmahon_lab/jgi/EBPRR1*

# https://github.com/AnantharamanLab/VIBRANT
### Setup VIBRANT in my GLBRC home directory
source /home/GLBRCORG/kjkibler/miniconda3/etc/profile.d/conda.sh

export PATH=//home/GLBRCORG/kjkibler/miniconda3/bin:$PATH
unset PYTHONPATH

PYTHONPATH=""
PERL5LIB=""

# install vibrant into its own environment
conda create --name VIBRANT python=3.6
conda activate VIBRANT
conda install -c bioconda prodigal
conda install -c bioconda hmmer
conda install seaborn
conda install -c anaconda numpy
conda install conda-forge/label/python_rc::_python_rc
conda install matplotlib
conda install matplotlib-base==3.10
conda install -c bioconda scikit-learn==0.21.3
conda install -c bioconda vibrant==1.2.0

# download and setup databases
cd /home/glbrc.org/kjkibler/miniconda3/envs/VIBRANT
find . -name "download-db.sh"
bin/download-db.sh

# test VIBRANT 2025-09-19 VIBRANT==1.2.0 is ready to go
./share/vibrant-1.2.0/databases/VIBRANT_setup.py -test

### Code

VIBRANT_run.py -h
# location of ^ script
# /home/glbrc.org/kjkibler/miniconda3/envs/VIBRANT/bin/VIBRANT_run.py

VIBRANT_run.py -i assemblies.files \
               -t 1 -folder output/



# 2025-09-22 VIBRANT ran successfully! running today with assemblies from nexterav2

### Output that we're looking for (2025-09-22)
# file structure to extract the really good bits
# genome fastas
# output/$sampleID/VIBRANT_phages_*/*.phages_combined.fna
# id completeness
# output/$sampleID/VIBRANT_results_*/VIBRANT_genome_quality_*.tsv


# want a file that pull some connecting pieces together before i concatenate all files together
# viral_contig,sampleID,length
# no sequences in ebpr_nexterav1_20111216 (2025-09-22 KJK)
cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/VIBRANT/output
for f in ebpr*
do
# want to rename viral contigs og-contig-name_sampleID
awk -v new_string="__$f" '/^>/ {printf "%s%s\n", $0, new_string; next} {print}' \
        $f/VIBRANT_*/VIBRANT_phages_*/*_combined.fna > ${f}_modified_phages.combined.fna
done

for f in ebpr*phages.combined.fna
do
sampleID=${f%_modified_phages.combined.fna}
#quick way to print out sequence lengths of viral genomes
awk '/^>/ {if (seqlen) print id, seqlen; id=$0; seqlen=0; next} {seqlen+=length($0)} END {print id, seqlen}' \
        $f > viral_sequences_$sampleID.txt

done
cat viral_sequences_ebpr_* > viral_seq_ids.txt
mkdir files/
mv viral_seq_ids.txt files/

# create a file directory list for viral genomes
# /home/glbrc.org/kjkibler/ebpr_virus/analysis/VIBRANT/output/files/viral_sequences.files.txt
cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/VIBRANT/output
for f in ebpr*phages.combined.fna
do
filepath=`realpath $f`
sampleID=${f%_modified_phages.combined.fna}
echo -e "$filepath\t$sampleID" >> files/viral_sequences.files.txt
done

# move and remove files
rm -f viral_sequences_*
mkdir renamed_viral_contigs/
mv *phages.combined.fna renamed_viral_contigs/

# need to edit
# concatenate all quality info from viral sequences
# analysis/VIBRANT/output/ebpr_og_20130528/VIBRANT_results_3300009517.a/VIBRANT_genome_quality_3300009517.a.tsv
cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/VIBRANT/output
for f in ebpr*/
do
f=${f%/}
sed "1s/^/sampleID\t/; 2,\$s/^/$f\t/" $f/VIBRANT_*/VIBRANT_results_*/VIBRANT_genome_quality_*.tsv > genome_quality_$f.tsv
done


head -n 1 genome_quality_ebpr_nexterav1_20100312.tsv > files/ebpr_VIBRANT_genome_quality.tsv
for f in genome_quality_*
do
# Append the rest of the files, starting from the second line of each
tail -n +2 $f >> files/ebpr_VIBRANT_genome_quality.tsv
done
rm -f genome_quality_ebpr_*

# concatenate all viral contigs into one fasta file
cd renamed_viral_contigs/
cat *modified_phages.combined.fna > viral_ebpr_VIBRANT_combined.fna
mv viral_ebpr_VIBRANT_combined.fna ../files

# no viral seqs in ebpr_nexterav1_20100617, ebpr_nexterav2_20130108
# scaffold_5219_c1 described by vibrant as a low quality lytic and complete circular lytic

### 2025-09-24 ^^^ above comments on 2025-09-22 may not be the case
# busted queue file, fixed queue file for VIBRANT condor submit and rerean VIBRANT

# no assembly stats from seqkit ebpr_nexterav1_20111216
