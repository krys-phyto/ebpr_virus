# Krys Kibler
# 2025-09-27

# pulled condor scripts from cyanoSTRONG analyses

# goal of mapping reads

# 1) what is the viral biomass through time
      # run concatenated list of viral contigs against metagenomes

BOWTIE2=/mnt/bigdata/bifxapps/bowtie2-2.4.5
#version 2.4.5

#cd /home/glbrc.org/kjkibler/cyanoSTRONG/krys/analysis/bowtie2
cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/bowtie2



# arguments
reads=$1
sampleID=$2


# bowtie2 code
# make an index
mkdir bt2
$BOWTIE2/bowtie2-build /home/glbrc.org/kjkibler/ebpr_virus/analysis/VIBRANT/output/files/viral_ebpr_VIBRANT_combined.fna\
                    bt2/viral_ebpr_VIBRANT_combined_fasta.fa


# do the mapping
$BOWTIE2/bowtie2 -p 16 -x bt2/viral_ebpr_VIBRANT_combined_fasta.fa --very-sensitive --interleaved --best \
$reads > /home/glbrc.org/kjkibler/ebpr_virus/analysis/bowtie2/concatenated/bt2/${sampleID}_vs_concatenated-viral.sam

# --sensitive -D 15 -R 2 -N 0 -L 22 -i S,1,1.15



# 2) how similar is viral community through time
# 3) how similar are viral "populations" through time
      # so, run all the individual assembly contigs (by themselves)
      # against all of the metagenomes


# need a queue file that lists every assembly with every assembly
# need to also adequately adapt above code to pull the right index
# reads,reads_sampleID,assembly_index

assembly_index=$1
reads=$2
reads_sampleID=$3

BOWTIE2=/mnt/bigdata/bifxapps/bowtie2-2.4.5
#version 2.4.5

# building an index for each individual viral assembly
cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/VIBRANT/output/renamed_viral_contigs

mkdir /home/glbrc.org/kjkibler/ebpr_virus/analysis/bowtie2/individual

# f=ebpr_nexterav1_20100312_modified_phages.combined.fna
for f in *
do
sampleID=${f%_modified_phages.combined.fna}
mkdir /home/glbrc.org/kjkibler/ebpr_virus/analysis/bowtie2/individual/$sampleID
mkdir /home/glbrc.org/kjkibler/ebpr_virus/analysis/bowtie2/individual/$sampleID/bt2
$BOWTIE2/bowtie2-build $f \
      /home/glbrc.org/kjkibler/ebpr_virus/analysis/bowtie2/individual/$sampleID/bt2/${sampleID}_fasta.fa
done

# create the queue file
cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/bowtie2/individual

for f in ebpr*
do
cp /home/glbrc.org/kjkibler/ebpr_virus/metadata/all_reads_paths.txt reads.files_$f.txt
index=${f}_fasta
sed -i "1,\$s/^/$index\t/" reads.files_$f.txt
done
cat reads.files_* > individual.assembly.mapping.queue.txt
rm -f reads.files*

# do the mapping
$BOWTIE2/bowtie2 -p 16 -x $assembly_sampleID/bt2/${assembly_index}.fa --very-sensitive --interleaved \
$reads > /home/glbrc.org/kjkibler/ebpr_virus/analysis/bowtie2/individual/$assembly_sampleID/bt2/${reads_sampleID}_vs_${assembly_sampleID}_viral.sam

# --sensitive -D 15 -R 2 -N 0 -L 22 -i S,1,1.15


# remove sam files in directories
for f in ebpr*
do
  rm -f $f/bt2/*.sam
done
