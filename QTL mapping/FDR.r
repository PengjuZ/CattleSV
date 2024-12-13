library(qvalue)
library(data.table)
library(R.utils)
"%&%" = function(a, b) { paste0(a, b) }
ARGS <- commandArgs(trailingOnly = TRUE)
file_perm = ARGS[1]
tis = ARGS[2]
fdr_thresholds = as.numeric(0.05)

#Read data
eqtl = fread(file_perm)
eqtl = eqtl[which(!is.na(eqtl$pval_beta)),]
cat("  * Number of molecular phenotypes =", nrow(eqtl), "\n")
cat("  * Correlation between Beta approx. and Empirical p-values =", round(cor(eqtl$pval_beta, eqtl$pval_perm), 4), "\n")

#Run qvalue on pvalues for best signals
#Q = qvalue(eqtl$pval_beta,lambda=0.85)
#cat("  * Proportion of significant phenotypes =" , round((1 - Q$pi0) * 100, 2), "%\n")

#Alternative: Run p.adjust (BH) on pvalues for best signals
pval_adj_BH = p.adjust(eqtl$pval_beta, method = "BH")

#Determine significance threshold
set0 = eqtl[which(pval_adj_BH <= 0.05),]
set1 = eqtl[which(pval_adj_BH > 0.05),]
pthreshold = (sort(set1$pval_perm)[1] - sort(-1.0 * set0$pval_perm)[1]) / 2
cat("  * Corrected p-value threshold = ", pthreshold, "\n")

#Calculate nominal pvalue thresholds; binominal
nthresholds = qbeta(pthreshold, eqtl$beta_shape1, eqtl$beta_shape2, ncp = 0, lower.tail = TRUE, log.p = FALSE)

#eqtl$qval = Q$qvalues
eqtl$pval_adj_BH = pval_adj_BH
eqtl$pval_nominal_threshold = nthresholds
eqtl$is_eGene = (eqtl$pval_nominal < nthresholds) & (eqtl$pval_adj_BH <= 0.05)
count=sum(eqtl$is_eGene)
cat("  * eGene count(10Covariates) = ", count, "\n")
eqtl <- eqtl[eqtl$is_eGene=="TRUE",]
#Output
fwrite(eqtl,tis %&% ".cis_qtl_fdr0.05.txt",sep="\t")
cat("Done\n")