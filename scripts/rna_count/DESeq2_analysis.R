
library(DESeq2)
library(tibble)      # rownames_to_column
library(dplyr)
library(ggplot2)     # for custom plots

## ----- 1.  FeatureCounts native .txt  -----------------
HP_counts <- read.delim(
  "/Users/william/Documents/Github/GenomeAnalysis/analyses/05_rna_count/HP126/featureCount_HP126.txt",
  comment.char = "#",     # skips the header line beginning with "# Program:"
  row.names    = 1,       # use Geneid as row‑names
  check.names  = FALSE    # keep the BAM paths intact as column names
)
HP_counts <- HP_counts[ , 6:ncol(HP_counts)]   # drop annotation columns

DV3_counts <- read.delim(
  "/Users/william/Documents/Github/GenomeAnalysis/analyses/05_rna_count/DV3/featureCount_DV3.txt",
  comment.char = "#",     # skips the header line beginning with "# Program:"
  row.names    = 1,       # use Geneid as row‑names
  check.names  = FALSE    # keep the BAM paths intact as column names
)
DV3_counts <- DV3_counts[ , 6:ncol(DV3_counts)]   # drop annotation columns

R7_counts <- read.delim(
  "/Users/william/Documents/Github/GenomeAnalysis/analyses/05_rna_count/R7/featureCount_R7.txt",
  comment.char = "#",     # skips the header line beginning with "# Program:"
  row.names    = 1,       # use Geneid as row‑names
  check.names  = FALSE    # keep the BAM paths intact as column names
)
R7_counts <- R7_counts[ , 6:ncol(R7_counts)]   # drop annotation columns

# ---------- 1.2  merge, keeping every gene ----------
all_counts <- R7_counts  %>% rownames_to_column("gene") %>%
  full_join(HP_counts  %>% rownames_to_column("gene"),  by = "gene") %>%
  full_join(DV3_counts %>% rownames_to_column("gene"),  by = "gene") %>%
  column_to_rownames("gene")
all_counts[is.na(all_counts)] <- 0 

sample_ids <- colnames(all_counts)
condition  <- factor(c(rep("R7",  3), rep("HP",  3), rep("DV3", 3)),
                     levels = c("R7", "HP", "DV3"))
coldata <- data.frame(row.names = sample_ids, condition)



dds <- DESeqDataSetFromMatrix(all_counts, colData = coldata,
                              design = ~ condition)

dds <- dds[rowSums(counts(dds)) >= 10, ]      # keep expressed genes
dds <- DESeq(dds, sfType = "poscounts")       # robust to zeros



plot(sizeFactors(dds), pch = 19, col = condition,
     ylab = "Size factor", xlab = "Sample")

plotDispEsts(dds)          # one line in your report: “dispersion trend good”


vsd <- vst(dds, blind = FALSE)
plotPCA(vsd, intgroup = "condition")


# HP high-producer vs wild-type R7
res_HP_vs_R7  <- lfcShrink(dds, contrast = c("condition","HP","R7"),
                           type = "ashr")
# DV3 deletion mutant vs R7
res_DV3_vs_R7 <- lfcShrink(dds, contrast = c("condition","DV3","R7"),
                           type = "ashr")
# DV3 vs HP (shows genes HP needs to over-produce)
res_DV3_vs_HP <- lfcShrink(dds, contrast = c("condition","DV3","HP"),
                           type = "ashr")


summary(res_HP_vs_R7)      # reports up/down counts at α = 0.1

write.csv(as.data.frame(res_HP_vs_R7),  "DEG_HP_vs_R7.csv")
write.csv(as.data.frame(res_DV3_vs_R7), "DEG_DV3_vs_R7.csv")
write.csv(as.data.frame(res_DV3_vs_HP), "DEG_DV3_vs_HP.csv")


library(readr)
annot <- read_tsv("/Users/william/Documents/Github/GenomeAnalysis/analyses/05_rna_count/R7/R7.tsv")   # <-- your genome annotation table

HP_sig <- res_HP_vs_R7 %>%
  as.data.frame() %>%
  rownames_to_column("gene") %>%
  filter(padj < 0.05, log2FoldChange >= 1) %>%     # ↑ ≥2-fold
  inner_join(annot, by = "gene") %>%
  arrange(desc(log2FoldChange))

head(HP_sig, 20)   # copy this into your report, highlight regulators/transporters



cluster <- c("LGFCPJMF_05000":"LGFCPJMF_05120")   # replace with real locus tags
cluster_res <- res_HP_vs_R7[cluster, ]

ggplot(cluster_res, aes(seq_along(log2FoldChange), log2FoldChange)) +
  geom_point() + geom_hline(yintercept = 0, linetype = "dashed") +
  labs(x = "Gene order in cluster", y = "log2FC HP vs R7")



library(clusterProfiler)
# Suppose your annotation provides GO IDs in a column go_id
ego <- enricher(HP_sig$gene, TERM2GENE = annot[,c("go_id","gene")])
dotplot(ego, showCategory = 15)