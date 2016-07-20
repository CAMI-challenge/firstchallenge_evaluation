## Plots for taxonomic binners, sorted by bin size:
[Precision/Recall sorted by bin size, low complexity data set](plots/supervised/prec_rec_sorted_all_ranks_low.pdf)  
[Precision/Recall sorted by bin size, medium complexity data set](plots/supervised/prec_rec_sorted_all_ranks_medium.pdf)  
[Precision/Recall sorted by bin size, high complexity data set](plots/supervised/prec_rec_sorted_all_ranks_high.pdf)  

###by bin
[Precision/Recall by bin, all bins](plots/supervised/prec_recall_combined_all_ranks_by_bin_ANI_all.pdf)
[Precision/Recall by bin, strains in groups with more than 95% ANI similarity to other strains](plots/supervised/prec_recall_combined_all_ranks_by_bin_ANI_common_strain.pdf)  
[Precision/Recall by bin, unique strain with ANI below 95% to all other strains.](plots/supervised/prec_recall_combined_all_ranks_by_bin_ANI_unique_strain.pdf)  

Question: ANI cutoff is >= 95% or > 95% ANI?

###by genome, across all data sets and all ranks
[Precision/Recall by genome, all](plots/supervised/prec_recall_combined_all_ranks_by_genome_ANI_all.pdf)  
[Precision/Recall by genome, strains in groups with more than 95% ANI similarity to other strains](plots/supervised/prec_recall_combined_all_ranks_by_genome_ANI_common_strain.pdf)  
[Precision/Recall by genome, unique strain with ANI below 95% to all other strains.](plots/supervised/prec_recall_combined_all_ranks_by_genome_ANI_unique_strain.pdf)  

### Avg. Precision/Recall, across all data sets and all ranks
[Precision/Recall](plots/supervised/supervised_summary_all.pdf)  
[Precision/Recall, with smallest predicted bins summing up to 1% of entire data set removed](plots/supervised/supervised_summary_all_99.pdf)  

### Basepair count
[relative bp count](plots/supervised/supervised_bp_count_relative_all.pdf)  
[bp count in k basepairs](plots/supervised/supervised_bp_count_absolute_all.pdf) 

Question: What is meant with k basepairs here?

### Adjusted rand index (ARI)
[ARI for taxonomic binners on bins including unassigned bin](plots/supervised/supervised_ari_including_notassigned_all.pdf)  
[ARI for taxonomic binners on bins without unassigned bin - a purity measure](plots/supervised/supervised_ari_excluding_notassigned_all.pdf)  
[ARI for taxonomic binners on bins including unassigned bin, split by taxonomic novelty category](plots/supervised/supervised_ari_including_notassigned_novelty.pdf)  
[ARI for taxonomic binners on bins without unassigned bin - a purity measure, split by taxonomic novelty category](plots/supervised/supervised_ari_excluding_notassigned_novelty.pdf)  
[ARI for taxonomic binners on bins including unassigned bin,  by uniqueness](plots/supervised/supervised_ari_including_notassigned_uniqueness.pdf)  
[ARI for taxonomic binners on bins without unassigned bin - a purity measure , split by uniqueness. Q: define uniqueness ](plots/supervised/supervised_ari_excluding_notassigned_uniqueness.pdf)  

###Plots for binners:
[Precision/Recall by genome,  all](plots/unsupervised/prec_recall_combined_all_ranks_by_genome_ANI_all.pdf)  
[Precision/Recall by genome, strains in groups with more than 95% ANI similarity to other strains](plots/unsupervised/prec_recall_combined_all_ranks_by_genome_ANI_common_strain.pdf)  
[Precision/Recall by genome, unique strains](plots/unsupervised/prec_recall_combined_all_ranks_by_genome_ANI_unique_strain.pdf)  

[ARI for binners including unassigned bin](plots/unsupervised/unsupervised_ari_including_notassigned_all.pdf)  
[ARI for binners excluding uassigned bin - a purity measure](plots/unsupervised/unsupervised_ari_excluding_notassigned_all.pdf)  
[ARI including unassigned bin, split by novelty category](plots/unsupervised/unsupervised_ari_including_notassigned_novelty.pdf)  
[ARI, excluding unassigned bin, split by novelty category](plots/unsupervised/unsupervised_ari_excluding_notassigned_novelty.pdf)  
[unsupervised ari including notassigned split by uniqueness](plots/unsupervised/unsupervised_ari_including_notassigned_uniqueness.pdf)  
[unsupervised ari excluding notassigned split by uniqueness](plots/unsupervised/unsupervised_ari_excluding_notassigned_uniqueness.pdf)  



## Making plots:
The calls to create most plots are contained in a [bash script](make_plots.sh), which must be called within this binning directory.
Unix only, sorry. Some scripts are not yet suitable for windown, but all work using a unix system, given all R packages are available.  

### 'by_bin' and 'by_genome' combining of tables into one file
    Rscript perbin_sumup.r target/directory/ "perbin"

###Example:
    Rscript perbin_sumup.r data/taxonomic "perbin"  
    Rscript perbin_sumup.r data/taxonomic "bygenome"  
