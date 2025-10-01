# Krys Kibler
# 2025-09-28


# Goal: cleaing up sam files from bowtie mapping (both concat and individuals)
# Goal: extract coverage from indexed, sorted bam files

source /home/GLBRCORG/kjkibler/miniconda3/etc/profile.d/conda.sh

export PATH=//home/GLBRCORG/kjkibler/miniconda3/bin:$PATH
unset PYTHONPATH

PYTHONPATH=""
PERL5LIB=""

cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/bowtie2/concatenated/bt2/

#samtools v 1.20
#samtools view -F 4 -b ebpr_nexterav2_20130301_vs_concatenated-viral.sam > ebpr_nexterav2_20130301_vs_concatenated-viral.onlymap.bam
#samtools sort -o ebpr_nexterav2_20130301_vs_concatenated-viral.sorted.onlymap.bam ebpr_nexterav2_20130301_vs_concatenated-viral.onlymap.bam
#samtools index ebpr_nexterav2_20130301_vs_concatenated-viral.sorted.onlymap.bam
#samtools depth -a ebpr_nexterav2_20130301_vs_concatenated-viral.sorted.onlymap.bam > /mnt/bigdata/linuxhome/kjkibler/ebpr_virus/analysis/samtools/concatenated/ebpr_nexterav2_20130301_vs_concatenated-viral.txt

for f in ebpr*sam
do
echo "Converting $f to ${f%.sam}.onlymap.bam"
# remove reads that did not map and convert to bam
samtools view -F 4 -b $f > ${f%.sam}.onlymap.bam

echo "Sorting ${f%.sam}.onlymap.bam -> ${f%.sam}.sorted.onlymap.bam"
# sort bam file
samtools sort -o ${f%.sam}.sorted.onlymap.bam ${f%.sam}.onlymap.bam

echo "Indexing ${f%.sam}.sorted.onlymap.bam"
# index bam file
samtools index ${f%.sam}.sorted.onlymap.bam

echo "Done with $f!"
done

cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/bowtie2/concatenated/bt2/
# calculate read depth
for f in *.sorted.onlymap.bam
do
samtools depth -a $f > /mnt/bigdata/linuxhome/kjkibler/ebpr_virus/analysis/samtools/concatenated/${f%.sorted.onlymap.bam}_coverage-depth.txt
done

for f in *.sorted.onlymap.bam
do
samtools coverage $f > /mnt/bigdata/linuxhome/kjkibler/ebpr_virus/analysis/samtools/concatenated/${f%.sorted.onlymap.bam}_coverage-average.txt
done

# combine output files

cd /home/glbrc.org/kjkibler/ebpr_virus/analysis/samtools/concatenated
for f in *_coverage-depth.txt
do
  sampleID=${f%_coverage-depth.txt}
  sed -i "1,\$s/^/$sampleID\t/" $f
done
cat ebpr_* > concatenated-mapping_coverage-depth.txt


for f in *_coverage-average.txt
do
sampleID=${f%_coverage-average.txt}
sed -i "1s/^/sampleID\t/; 2,\$s/^/$sampleID\t/" $f
done

head -n 1 ebpr_nexterav1_20100312_vs_concatenated-viral_coverage-average.txt > concatenated-mapping_coverage-average.txt
for f in ebpr*_coverage-average.txt
do
# Append the rest of the files, starting from the second line of each
tail -n +2 $f >> concatenated-mapping_coverage-average.txt
done
