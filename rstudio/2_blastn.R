###################################################################################################
### Krys Kibler
### 2025-09-24
###################################################################################################

library(tidyverse)


###################################################################################################
### Files

# blast results onto epbr VIBRANT viral contigs
blast_results <- "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/analysis/blast/2025-09-24/blast_results.txt"
viral_seq_ids <- "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/analysis/VIBRANT/output/viral_seq_ids.txt"


blast_results <- read_delim(blast_results)

viral_seq_ids <- read.delim(viral_seq_ids, sep = " ", header = FALSE)
colnames(viral_seq_ids) <- c("contig", "length", "sampleID")
viral_seq_ids$contig <- gsub(">", "", viral_seq_ids$contig)

blast_results <- left_join(blast_results, viral_seq_ids, by = c("qseqid" = "contig"))



###################################################################################################
### data menagerie


# what percentage of spacers hit a contig?
blast_results$count <- 1
blast_results_count <- blast_results %>% group_by(sseqid) %>% 
  summarise(count = sum(count))

52/181 # 29% of spacers got a hit
write_tsv(blast_results_count, "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/analysis/blast/2025-09-24/spacer_count_hit.txt")


hit_contigs <- unique(blast_results$qseqid)
hit_contigs <- as_data_frame(hit_contigs)

# contig to sampleID
viral_seq_ids <- "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/analysis/VIBRANT/output/viral_seq_ids.txt"
# viral seq genome quality
genome_quality <- "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/analysis/VIBRANT/output/ebpr_VIBRANT_genome_quality.tsv"

viral_seq_ids <- read.delim(viral_seq_ids, sep = " ", header = FALSE)
genome_quality <- read.delim(genome_quality)

colnames(viral_seq_ids) <- c("contig", "length", "sampleID")
viral_seq_ids$contig <- gsub(">", "", viral_seq_ids$contig)

hit_contigs <- left_join(hit_contigs, viral_seq_ids, by = c("value" = "contig"))
hit_contigs <- left_join(hit_contigs, genome_quality, by = c("value" = "scaffold"))


write_tsv(hit_contigs, "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/analysis/blast/2025-09-24/hit_contigs_info.txt")



###################################################################################################
### Trinas spacer coverage 

spacer_95 <- "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/analysis/spacers_cov/2025-09-24/EBPR_spacer_95_cov.txt"
spacer_95 <- read_delim(spacer_95)

spacer_95 <- spacer_95 %>% separate_wider_delim(cov, delim = " ", names = c("cov", "filepath"))
spacer_95$sampledate <- gsub("_vs_spacer_95", "", spacer_95$filename)
spacer_95$sampledate <- gsub("-EBPR", "", spacer_95$sampledate)
spacer_95$sampledate <- gsub("EBPR-R1-", "", spacer_95$sampledate)
spacer_95$sampledate <- gsub("EBPRR1", "", spacer_95$sampledate)
spacer_95$sampledate <- gsub("R1-", "", spacer_95$sampledate)
spacer_95$sampledate <- as_date(spacer_95$sampledate)

spacer_95$sampleID <- gsub("_vs_spacer_95", "", spacer_95$filename)



write_tsv(spacer_95, "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/analysis/spacers_cov/2025-09-24/EBPR_spacer_95_cov.txt")

# normalized coverage
metags <- "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/analysis/seqkit/seqkit_ebpr_reads_concat.tsv"
metags <- read_delim(metags)

metags$sampledate <- gsub(".+/", "", metags$file)
metags$sampledate <- gsub(".fastq.fna", "", metags$sampledate)
metags$sampledate <- gsub("-EBPR", "", metags$sampledate)
metags$sampledate <- gsub("EBPR-R1-", "", metags$sampledate)
metags$sampledate <- gsub(".qced", "", metags$sampledate)
metags$sampledate <- gsub(".fna", "", metags$sampledate)
metags$sampledate <- gsub("EBPRR1", "", metags$sampledate)
metags$sampledate <- gsub("R1-", "", metags$sampledate)
metags$sampledate <- gsub("_interleaved", "", metags$sampledate)
metags$sampledate <- as_date(metags$sampledate)

metags$sampleID <- gsub(".+/", "", metags$file)
metags$sampleID <- gsub(".fastq.fna", "", metags$sampleID)
metags$sampleID <- gsub(".qced", "", metags$sampleID)
metags$sampleID <- gsub(".fna", "", metags$sampleID)
metags$sampleID <- gsub("_interleaved", "", metags$sampleID)


metags_avg <- mean(metags$sum_len) # 7434118261.59

spacer_95 <- left_join(spacer_95, select(metags, c("sampledate", "sampleID", "sum_len")), by = c("sampledate", "sampleID"))

# normalize coverage
spacer_95$norm_cov <- spacer_95 %>% with(cov * (sum_len / metags_avg))

write_tsv(spacer_95, "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/analysis/spacers_cov/2025-09-24/EBPR_spacer_95_cov.txt")


