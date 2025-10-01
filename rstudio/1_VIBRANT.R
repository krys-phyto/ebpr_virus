###################################################################################################
### Krys Kibler 2025-09-22
### Goal: Visualize VIBRANT data, annotated viral contigs from ebpr assemblies
###################################################################################################

library(tidyverse)

###################################################################################################
### Files

# contig to sampleID
viral_seq_ids <- "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/analysis/VIBRANT/output/viral_seq_ids.txt"
# viral seq genome quality
genome_quality <- "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/analysis/VIBRANT/output/ebpr_VIBRANT_genome_quality.tsv"
# assembly seqkit stats
assembly_seqkit <- "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/analysis/seqkit/seqkit_ebpr_assembly_concat.tsv"
# assembly file path to sampleID
assembly_sampleID <- "/Users/kjkibler/Library/CloudStorage/GoogleDrive-kjkibler@wisc.edu/My Drive/epbr_virus/metadata/assemblies.files.txt"

# read in the files
viral_seq_ids <- read.delim(viral_seq_ids, sep = " ", header = FALSE)
viral_seq_ids <- viral_seq_ids %>% na.omit()
genome_quality <- read.delim(genome_quality)
assembly_seqkit <- read.delim(assembly_seqkit)
assembly_sampleID <- read.delim(assembly_sampleID, header = FALSE)

# check that we have assemblies for all samples
assembly_sampleID_check <- left_join(assembly_sampleID, assembly_seqkit, by = c("V1" = "file"))

###################################################################################################


###################################################################################################
### Figure 1: viral vs microbial 

### data managerie

# fix headers
colnames(viral_seq_ids) <- c("contig", "length")
viral_seq_ids$contig <- gsub(">", "", viral_seq_ids$contig)

# extract sampleID from contig defline 
viral_seq_ids$sampleID <- gsub(".+__", "", viral_seq_ids$contig)

# calc total viral bp assemblage # 2 assemblies had no viral contigs
viral_assemble_tot <- viral_seq_ids %>% group_by(sampleID) %>% 
  summarise(v_sum_len = sum(length, na.rm = TRUE))

# fix headers
colnames(assembly_sampleID) <- c("file", "sampleID")

# join dataframes to match assembly seqkit data with sampleID
assembly_seqkit <- left_join(assembly_seqkit, assembly_sampleID, by = "file")

# join dataframes to add viral assemblage length to total assemblage length
assembly_seqkit <- left_join(assembly_seqkit, viral_assemble_tot, by = "sampleID")

# calc microbial assemblage (in theory)
assembly_seqkit$m_sum_length <- assembly_seqkit %>% with(sum_len - v_sum_len)

# extract sample date from sampleID
assembly_seqkit$sampledate <- gsub("ebpr.+_", "", assembly_seqkit$sampleID)
assembly_seqkit$sampledate <- as_date(assembly_seqkit$sampledate)

# calc ratio of viral:non-viral in assembly 
assembly_seqkit$v.to.m <- assembly_seqkit %>% with(v_sum_len / m_sum_length)
assembly_seqkit[is.na(assembly_seqkit)] <- 0

### figure
assembly_seqkit %>% #filter(sampledate >= as_date("2010-01-01") &
                    #         sampledate <= as_date("2014-01-01")) %>% 
  ggplot(aes(x = sampledate, y = v.to.m)) +
  geom_line() +
  geom_point() +
  labs(x = "Sample Date", y = "Viral:Microbial by bp in assemblies") +
  theme_classic() +
  theme(axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 14),
        axis.title.x = element_text(size = 16, face = "bold", margin = margin(t = 10, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size = 16, face = "bold", margin = margin(t = 0, r = 10, b = 0, l = 0)),
        plot.margin = unit(c(1, 0.5, 1, 0.5), "cm")) # Top, right, bottom, left margins in cm)


###################################################################################################


###################################################################################################
### Figure 2: total viral contigs id'ed and quality

### data managerie

# count number of viral contigs
viral_seq_ids$count <- 1
viral_seq_ids %>% summarise(count = sum(count)) #8715 total viral contigs across all assemblies
viral_seq_ids_tot <- viral_seq_ids %>% group_by(sampleID) %>% 
  summarise(tot_count = sum(count))

# extract sampledate from sampleID
viral_seq_ids_tot$sampledate <- gsub("ebpr.+_", "", viral_seq_ids_tot$sampleID)
viral_seq_ids_tot$sampledate <- as_date(viral_seq_ids_tot$sampledate)


### figure
plot_1 <- viral_seq_ids_tot %>% ggplot(aes(x = as.factor(sampledate), y = tot_count)) +
  geom_bar(stat = "identity") +
  labs(x = "Sample Date", y = "Count Viral Contigs") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) + # Remove expansion at lower end (0), keep default at upper (0.05)
  theme_classic() +
  theme(axis.text.x = element_text(size = 14, angle = 45, hjust = 1), 
        axis.text.y = element_text(size = 14), 
        axis.title.x = element_text(size = 16, face = "bold", margin = margin(t = 10, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size = 16, face = "bold", margin = margin(t = 0, r = 10, b = 0, l = 0)),
        plot.margin = unit(c(1, 0.5, 1, 0.5), "cm")) # Top, right, bottom, left margins in cm


### total type and quality viral contigs id'ed
### data managerie
genome_quality$scaffold <- paste(genome_quality$scaffold, genome_quality$sampleID, sep = "__")

genome_quality <- left_join(genome_quality, viral_seq_ids, by = c("scaffold" = "contig", "sampleID"))
genome_quality$count <- 1
genome_quality_tot <- genome_quality %>% group_by(type, Quality) %>% 
  summarise(count_tot = sum(count, na.rm = TRUE))

# figure
plot_2 <- genome_quality_tot %>% ggplot(aes(x = type, y = count_tot, fill = Quality)) +
  geom_bar(position="dodge", stat="identity") +
  labs(x = "Viral Types", y = "Count Viral Contigs", fill = "VIBRANT Quality") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) + # Remove expansion at lower end (0), keep default at upper (0.05)
  theme_classic() +
  theme(axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 14),
        axis.title.x = element_text(size = 16, face = "bold", margin = margin(t = 10, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size = 16, face = "bold", margin = margin(t = 0, r = 10, b = 0, l = 0)),
        plot.margin = unit(c(1, 0.5, 1, 0.5), "cm"),
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 16, face = "bold")) 


library(patchwork)
library(gridExtra)

my_table_grob <- tableGrob(genome_quality_tot)

plot_1 / (plot_2 | wrap_table(genome_quality_tot))


###################################################################################################


###################################################################################################
### Figure 3: scaffold lengths

# count viral scaffold lengths

genome_quality %>% ggplot(aes(x = length)) +
  geom_histogram(boundary = 1000, binwidth = 10000) +
  stat_bin(bins = 100) +
 # scale_x_continuous(breaks = seq(1000, 4e5, by=25000))
  labs(y = "Count Viral Contigs", x = "Contig Length") +
  theme_classic() +
  theme(axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 14),
        axis.title.x = element_text(size = 16, face = "bold", margin = margin(t = 10, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size = 16, face = "bold", margin = margin(t = 0, r = 10, b = 0, l = 0)),
        plot.margin = unit(c(1, 1, 1, 0.5), "cm"),
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 16, face = "bold")) 


