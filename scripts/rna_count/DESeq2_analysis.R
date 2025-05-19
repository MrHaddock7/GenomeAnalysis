library(DESeq2)
library(tidyverse)
#library(airway)

# 2. Read in your CSV (skip any leading comment lines)
counts_df <- read.csv(
  "/Users/william/Documents/Github/GenomeAnalysis/analyses/05_rna_count/DV3/featureCount_DV3_withComments.csv",
  header   = TRUE,
  row.names = 1,      # assumes first column is gene IDs
  check.names = FALSE # keep sample names exactly as-is
)

# 3. Inspect
head(counts_df)
##      DV3_rep1_rna_map.sorted.bam DV3_rep2_rna_map.sorted.bam DV3_rep3_rna_map.sorted.bam
## gene1                       1234                       1456                       1678
## gene2                        234                        345                        456
## ...

# 4. Strip off extra columns (if any)
# featureCounts usually gives these first columns:
#   Geneid, Chr, Start, End, Strand, Length, <sample1>, <sample2>, ...
# so you may need to remove metadata cols and keep only sample counts:
cts <- counts_df[ , grep("\\.bam$", colnames(counts_df)) ]

# 5. Build your colData (sample metadata)
coldata <- data.frame(
  row.names = colnames(cts),
  condition = c("control","control","treatment")  # adjust to your design
)

# 6. Create DESeqDataSet
dds <- DESeqDataSetFromMatrix(
  countData = cts,
  colData   = coldata,
  design    = ~ condition
)

# 7. Run DESeq2
dds <- DESeq(dds)
res <- results(dds)

# 8. Inspect results
head(res)