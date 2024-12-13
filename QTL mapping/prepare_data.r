options(stringsAsFactors = FALSE)
library(edgeR)
library(preprocessCore)
library(RNOmni)
library(data.table)
library(R.utils)
library(SNPRelate)
library(PCAForQTL)

#----------------------------------------------------------------------------
### functions
"%&%" = function(a, b) { paste0(a, b) }
# Transform rows to a standard normal distribution
inverse_normal_transform = function(x) {
    qnorm(rank(x) / (length(x)+1))
}
#----------------------------------------------------------------------------
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
### data input <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
ARGS <- commandArgs(trailingOnly = TRUE)
file_counts = ARGS[1] # Counts file. Row is gene, column is sample; rowname is gene id, colname is sample id
file_tpm = ARGS[2] # TPM file. Row is gene, column is sample; rowname is gene id, colname is sample id
vcf.fn = ARGS[3]  # Input data for genotype PCA. genotype data from imputation (VCF format)
tis = ARGS[4] # Prefix of output file, like tissue name
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
### main program
#----------------------------------------------------------------------------
# Input data for TMM calculation
# Read counts matrix. Row is gene, column is sample; rowname is gene id, colname is sample id
Counts = read.table(file_counts,header=T)
# TPM matrix. Row is gene, column is sample; rowname is gene id, colname is sample id
TPM = read.table(file_tpm,header=T)

## 1. prepare TMM
expr_counts = t(Counts)
samids = colnames(expr_counts) # sample id
expr = DGEList(counts=expr_counts) # counts
nsamples = length(samids) # sample number
ngenes = nrow(expr_counts) # gene number

# calculate TMM
y = calcNormFactors(expr, method="TMM")
TMM = cpm(y,normalized.lib.sizes=T)

# expression thresholds
count_threshold = 6
tpm_threshold = 0.1
sample_frac_threshold = 0.2

#keep the genes with >=0.1 tpm and >=6 read counts in >=20% samples.
cTPM=t(TPM)
expr_tpm = cTPM[rownames(expr_counts),samids]
tpm_th = rowSums(expr_tpm >= tpm_threshold)
count_th = rowSums(expr_counts >= count_threshold)
ctrl1 = tpm_th >= (sample_frac_threshold * nsamples)
ctrl2 = count_th >= (sample_frac_threshold * nsamples)
mask = ctrl1 & ctrl2
TMM_pass = TMM[mask,] ##row is gene; column is sample

###expression values (TMM) were inverse normal transformed across samples.
TMM_inv = t(apply(TMM_pass, MARGIN = 1, FUN = inverse_normal_transform)) #apply to each row, each row represents one gene, observed values for all the samples. scale across samples.
#----------------------------------------------------------------------------
### 2. prepare bed file

region_annot = fread("TSS.bed") # load gtf file
geneid = region_annot$V4

expr_matrix = TMM_inv[rownames(TMM_inv) %in% geneid,] # expr_matrix TMM_inv

# prepare bed file for tensorQTL
bed_annot = region_annot[region_annot$V4 %in% rownames(expr_matrix),]
bed = data.frame(bed_annot,expr_matrix[bed_annot$V4,])
colnames(bed)[1] = "#Chr"
colnames(bed)[2] = "Start"
colnames(bed)[3] = "End"
colnames(bed)[4] = "Name"

# output bed file
fwrite(bed,file = tis %&% ".phenotype.bed", sep = "\t")

### 3. Genotype PCA
snpgdsVCF2GDS(vcf.fn,tis %&% ".ccm.gds", method = "biallelic.only")
genofile <- snpgdsOpen(tis %&% ".ccm.gds")
ccm_pca <- snpgdsPCA(genofile,num.thread=12)

if(length(ccm_pca$sample.id) < 150 ) {
pca_genotype<-ccm_pca$eigenvect[,1:3]
colnames(pca_genotype)<-c("genotypePC1","genotypePC2","genotypePC3")
pca_var0 = data.frame(genotypePC=1:3,eigenval=ccm_pca$eigenval[1:3],varprop=ccm_pca$varprop[1:3])
}else if (length(ccm_pca$sample.id) < 250){
pca_genotype<-ccm_pca$eigenvect[,1:5]
colnames(pca_genotype)<-c("genotypePC1","genotypePC2","genotypePC3","genotypePC4","genotypePC5")
pca_var0 = data.frame(genotypePC=1:5,eigenval=ccm_pca$eigenval[1:5],varprop=ccm_pca$varprop[1:5])
}else{
pca_genotype<-ccm_pca$eigenvect[,1:10]
colnames(pca_genotype)<-c("genotypePC1","genotypePC2","genotypePC3","genotypePC4","genotypePC5","genotypePC6","genotypePC7","genotypePC8","genotypePC9","genotypePC10")
pca_var0 = data.frame(genotypePC=1:10,eigenval=ccm_pca$eigenval[1:10],varprop=ccm_pca$varprop[1:10])
}
rownames(pca_genotype) <- ccm_pca$sample.id
pca_genotype0 = data.frame(SampleID=ccm_pca$sample.id,pca_genotype)


# output
write.table(pca_genotype0,tis %&% ".PCA_eigenvect.txt", sep = "\t", row.names = F, quote = FALSE)
write.table(pca_var0,tis %&% ".PCA_var.txt", sep = "\t", row.names = F, quote = FALSE)


### 4. PCAforQTL
expr<-t(bed[,-(1:4)])
prcompResult<-prcomp(expr,center=TRUE,scale.=TRUE) 
PCs<-prcompResult$x
resultRunElbow<-PCAForQTL::runElbow(prcompResult=prcompResult)
print(resultRunElbow)
K_elbow<-resultRunElbow
knownCovariates<-pca_genotype0
identical(rownames(knownCovariates),rownames(expr)) 
PCsTop<-PCs[,1:K_elbow]
knownCovariatesFiltered<-PCAForQTL::filterKnownCovariates(knownCovariates,PCsTop,unadjustedR2_cutoff=0.9)
PCsTop<-scale(PCsTop)
covariatesToUse<-cbind(knownCovariatesFiltered,PCsTop)
covariates<-t(covariatesToUse)
write.table(covariates,tis %&% ".covariates.txt",sep="\t",row.names=T,quote =FALSE)
