import sys
import os
import pandas as pd
infile=sys.argv[1]
outfile=sys.argv[2]

D = pd.read_csv("./output/blood.cis_qtl_fdr0.05.txt", sep="\t", dtype=str)
d = pd.read_parquet(infile)
d['threshold'] = d['phenotype_id'].map(D.set_index('phenotype_id')['pval_nominal_threshold'])
d['pval_nominal'] = d['pval_nominal'].astype(float)
d['threshold'] = d['threshold'].astype(float)
result = d[d['pval_nominal'] < d['threshold']]
result.to_csv(outfile, index=False, sep="\t")