#Computes Spearman correlation coefficients, (FDR ajusted) p-values, and (FDR ajusted) permutation test values from the sum of precision and recall against dissimilarity scores of NCBI to SILVA loose and strict taxonomy mappings.

ranks = c("species", "genus", "family", "order", "class", "phylum")

permutation <- function(x, y, N=1000) {
  reps <- replicate(N, cor(sample(x), y, method=c("spearman")))
  obs <- cor(x, y, method=c("spearman"))
  print(obs)
  sum(abs(reps) > abs(obs[1,1]))/N 
}
pvalues = c()
permutations = c()
j=1
for(i in 1:6) {
  print(ranks[i])
  cami_data <- read.table("per_taxon_sorted+SILVA-limited-env.tsv", header=T, sep="\t")
  cami_data = cami_data[cami_data[,1]==ranks[i],]
  two_minus_sumpr = data.matrix(cami_data["sum_prec_rec"])
  surroundings_loose = data.matrix(cami_data["surroundings_loose"])
  surroundings_str = data.matrix(cami_data["surroundings_str"])
  
  permutations[j] = permutation(two_minus_sumpr, surroundings_loose)
  print(paste("permutation test:", permutations[j]))
  permutations[j + 1] = permutation(two_minus_sumpr, surroundings_str)
  print(paste("permutation test:", permutations[j + 1]))
  
  pvalues[j] = cor.test(two_minus_sumpr, surroundings_loose, method="spearman")$p.value
  print(paste("p-value:", pvalues[j]))
  pvalues[j+1] = cor.test(two_minus_sumpr, surroundings_str, method="spearman")$p.value
  print(paste("p-value:", pvalues[j+1]))
  j=j+2
}
print(p.adjust(pvalues, method="fdr"))
print(p.adjust(permutations, method="fdr"))
