# Krys Kibler
# 2025-09-24

# goal: get coverages from trinas blasted spacers

# directory for all the data
# /home/glbrc.org/trina.mcmahon/ebpr/analysis/array_hunting/spacer_blast_reads/all_reads_paths.txt

ls /home/glbrc.org/trina.mcmahon/ebpr/analysis/array_hunting/spacer_blast_reads/

echo -e "filename\tcov" > EBPR_spacer_95_cov.txt
for f in /home/glbrc.org/trina.mcmahon/ebpr/analysis/array_hunting/spacer_blast_reads/*_spacer_*.txt
do
name=`basename $f`
filename=${name%.txt}
cov=`wc -l $f`
echo -e "$filename\t$cov" >> EBPR_spacer_95_cov.txt
done
