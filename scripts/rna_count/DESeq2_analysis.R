# 0) Load tidyverse for dplyr/purrr helpers
library(tidyverse)

files <- c("/Users/william/Documents/Github/GenomeAnalysis/analyses/05_rna_count/R7/featureCount_R7.txt",
           "/Users/william/Documents/Github/featureCount_DV3_2.txt",
           "/Users/william/Documents/Github/featureCount_HP126_2.txt")

read_counts <- function(path) {
  df <- read.delim(path, comment.char = "#", check.names = FALSE)
  
  # columns 1–6 are annotation; the rest are counts
  keep <- c("Geneid", names(df)[-(1:6)])
  df <- df[keep]
  
  ## Sanitize sample names so they are valid R column names:
  ## - remove directories like "R7/"
  ## - replace spaces or symbols with dots
  names(df)[-1] <- make.names(basename(names(df)[-1]))
  
  df          # returned tibble
}



countData <- files |>                 # take the three paths
  map(read_counts) |>                 # read each into a tibble
  reduce(full_join, by = "Geneid") |> # successively join on Geneid
  arrange(Geneid) |>                  # put rows in a stable order
  column_to_rownames("Geneid") |>     # row names = Gene IDs
  as.matrix()                         # DESeq2 wants a matrix

dim(countData)     # genes × 9 samples
head(countData[, 1:5])   # peek at the first few columns

anyNA(countData)          # should be FALSE – no missing genes?
all(apply(countData, 2, is.integer))  # TRUE – all columns integer?

write.table(countData, "/Users/william/Documents/Github/GenomeAnalysis/analyses/05_rna_count/all_samples_counts.tsv",
            sep = "\t", quote = FALSE, col.names = NA)




colData <- data.frame(
  row.names = colnames(countData),      # must be identical order
  condition = c(rep("HP126", 3),        # ⚠️ adjust to your design
                rep("DV3",   3),
                rep("R7",    3)),
  replicate = rep(1:3, 3)               # optional extra column
)
colData



library(DESeq2)

dds <- DESeqDataSetFromMatrix(countData = countData,
                              colData   = colData,
                              design    = ~ condition)   # simplest two-group model


keep <- rowSums(counts(dds)) >= 10
dds  <- dds[keep, ]


dds <- DESeq(dds)          # this does normalisation, dispersion, tests


# syntax: results(dds, contrast = c(variable, testLevel, refLevel))
res <- results(dds, contrast = c("condition", "DV3", "R7"))
summary(res)


res_HP126_R7 <- results(dds, contrast = c("condition", "HP126", "R7"))
res_DV3_R7   <- results(dds, contrast = c("condition", "DV3",   "R7"))


## ----- HP126 vs R7 only -----
dds_HP <- dds[ , dds$condition %in% c("HP126", "R7") ]
dds_HP$condition <- droplevels(dds_HP$condition)   # remove DV3 from the factor levels

vsd_HP <- vst(dds_HP, blind = FALSE)               # transform
plotPCA(vsd_HP, intgroup = "condition")            # PCA shows ONLY HP126 + R7



## ----- DV3 vs R7 only -----
dds_DV <- dds[ , dds$condition %in% c("DV3", "R7") ]
dds_DV$condition <- droplevels(dds_DV$condition)

vsd_DV <- vst(dds_DV, blind = FALSE)
plotPCA(vsd_DV, intgroup = "condition")





library(dplyr)      # for filter / arrange / slice
library(pheatmap)   # install.packages("pheatmap") once if needed

## 1) define the contrast result and the transformed counts
res_use <- res_HP126_R7   # <- change to res_DV3_R7 for the other pair
vsd_use <- vsd_HP         # <- change to vsd_DV for the other pair

## 2) pick genes that are BOTH strongly changed AND statistically solid
topGenes <- res_use |>
  as.data.frame() |>
  rownames_to_column("gene") |>
  filter( padj < 0.05, abs(log2FoldChange) > 1 ) |>  # biological + stat filter
  arrange( padj ) |>
  slice( 1:20 ) |>                 # top 50 “most impactful” genes
  pull( gene )

length(topGenes)   # sanity-check


## 3) extract just those genes and centre each row (gene)
mat <- assay(vsd_use)[ topGenes , ]
mat <- mat - rowMeans(mat)

## 4) small annotation data-frame for nicer column labels
ann <- data.frame(Strain = colData(vsd_use)$condition)
rownames(ann) <- colnames(mat)

## 5) draw the heat-map
pheatmap(mat,
         annotation_col = ann,
         show_rownames  = TRUE,      # switch to TRUE if you want gene labels
         cluster_cols   = TRUE,
         cluster_rows   = TRUE,
         scale = "row",
         fontsize = 8,
         main = "Top 50 DE genes – HP126 vs R7")