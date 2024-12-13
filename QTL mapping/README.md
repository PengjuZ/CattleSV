1. eqtl-mapping.sh
Perform TensorQTL for cis-eQTL mapping.

（1）prepare_data.r

  Prepare input files for cis-eQTL mapping.
  
（2）FDR.r

  Identify genome-wide significant genes, known as eGenes.
  
（3）pairs.py

  Extract significant eGene–eVariant pairs.

3. fine-mapping.sh
Predict a causal variant for each eGene by untangling linkage disequilibrium.
