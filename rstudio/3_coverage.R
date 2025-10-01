###################################################################################################
### Krys Kibler
### 2025-09-29
###################################################################################################

library(tidyverse)


###################################################################################################
### Files

# samtools calculate average coverage of concatenated viral contigs vs metagenomes # the og ones didnt map right revisit (2025-09-29)
coverage.average <- "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/analysis/samtools/concatenated-mapping_coverage-average.txt"
coverage.average <- read_delim(coverage.average)

# viral seq genome quality
genome_quality <- "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/analysis/VIBRANT/output/ebpr_VIBRANT_genome_quality.tsv"
genome_quality <- read.delim(genome_quality)

genome_quality$contig <- paste(genome_quality$scaffold, "__", genome_quality$sampleID, sep = "")

# metagenome seqkit
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

### Tidying 
coverage.average$sampledate <- gsub("_vs_concatenated-viral", "", coverage.average$sampleID)
coverage.average$sampledate <- gsub("ebpr.+_", "", coverage.average$sampledate)
coverage.average$sampledate <- as_date(coverage.average$sampledate)


###################################################################################################
### Data menagerie # need to normalize

# total mean coverage and reads
coverage_total_unfiltered <- coverage.average %>% 
  group_by(sampledate) %>% 
  summarize(total_mean.cov_uf = sum(meandepth),
            total_reads_uf = sum(numreads))
# figure
coverage_total_unfiltered %>% filter(sampledate >= as_date("2010-01-01") &
                                     sampledate <= as_date("2014-01-01")) %>% 
  ggplot(aes(x = sampledate, y = total_mean.cov_uf)) +
  geom_line() +
  geom_point() +
  labs(y = "Total viral mean coverage", x = "Sample Dates", title = "Unfiltered coverage data") +
  theme_classic() +
  theme(axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 14),
        axis.title.x = element_text(size = 16, face = "bold", margin = margin(t = 10, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size = 16, face = "bold", margin = margin(t = 0, r = 10, b = 0, l = 0)),
        plot.margin = unit(c(1, 0.5, 1, 0.5), "cm")) # Top, right, bottom, left margins in cm)


# filter out low mean coverage and low coverage %
coverage.average_filter <- coverage.average %>% filter(coverage >= 80 &
                                                       meandepth >= 10)

coverage_total_filtered <- coverage.average_filter %>% group_by(sampledate) %>% 
  summarize(total_mean.cov_f = sum(meandepth),
            total_reads_f = sum(numreads))

# figure
coverage_total_filtered %>% filter(sampledate >= as_date("2010-01-01") &
                                       sampledate <= as_date("2014-01-01")) %>% 
  ggplot(aes(x = sampledate, y = total_mean.cov_f)) +
  geom_line() +
  geom_point() +
  labs(y = "Total viral mean coverage", x = "Sample Dates", title = "Filtered coverage data, not normalized") +
  theme_classic() +
  theme(axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 14),
        axis.title.x = element_text(size = 16, face = "bold", margin = margin(t = 10, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size = 16, face = "bold", margin = margin(t = 0, r = 10, b = 0, l = 0)),
        plot.margin = unit(c(1, 0.5, 1, 0.5), "cm")) # Top, right, bottom, left margins in cm)


coverage.average_filter$count <- 1
coverage_total_filtered_bycontig <- coverage.average_filter %>% group_by(`#rname`) %>% 
  summarize(total_mean.cov_f = sum(meandepth),
            total_reads_f = sum(numreads),
            count = sum(count))

coverage_total_filtered_bycontig$cov_count <- coverage_total_filtered_bycontig %>% with(total_mean.cov_f / count)

coverage_total_filtered_bycontig <- left_join(coverage_total_filtered_bycontig, select(genome_quality, c("contig", "Quality", "type")), 
                                              by = c("#rname" = "contig"))


coverage_total_filtered_bycontig %>% filter(total_mean.cov_f >= 6238.2646) %>% 
  ggplot(aes(x = fct_reorder(`#rname`, total_mean.cov_f, .fun = max, .desc = TRUE), 
             y = total_mean.cov_f)) +
  geom_point() +
  geom_text(aes(y = 60000, x = fct_reorder(`#rname`, total_mean.cov_f, .fun = max, .desc = TRUE), label = count)) +
  labs(y = "Total mean coverage", x = "Viral contig", title = "Top 50 Rank Abundance Curve and number of samples detected in") +
  theme_classic() +
  theme(axis.text.x = element_text(size = 14, angle = 90, vjust = 0.5),
        axis.text.y = element_text(size = 14),
        axis.title.x = element_text(size = 16, face = "bold", margin = margin(t = 10, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size = 16, face = "bold", margin = margin(t = 0, r = 10, b = 0, l = 0)),
        plot.margin = unit(c(1, 0.5, 1, 0.5), "cm")) # Top, right, bottom, left margins in cm)

coverage_total_filtered_bycontig %>% 
  ggplot(aes(x = fct_reorder(`#rname`, total_mean.cov_f, .fun = max, .desc = TRUE), 
             y = total_mean.cov_f)) +
  geom_point() +
  geom_vline(xintercept = "scaffold_2712_c1__ebpr_nexterav2_20111104", color = "red") +
  labs(y = "Total mean coverage", x = "Viral contigs", title = "Rank Abundance Curve, names hidden, red line = top 50") +
  theme_classic() +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_text(size = 14),
        axis.title.x = element_text(size = 16, face = "bold", margin = margin(t = 10, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size = 16, face = "bold", margin = margin(t = 0, r = 10, b = 0, l = 0)),
        plot.margin = unit(c(1, 0.5, 1, 0.5), "cm")) # Top, right, bottom, left margins in cm)

  
