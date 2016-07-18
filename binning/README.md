##Supervised plots:
[Precition/Recall sorted low](plots/supervised/prec_rec_sorted_all_ranks_low.pdf)  
[Precition/Recall sorted medium](plots/supervised/prec_rec_sorted_all_ranks_medium.pdf)  
[Precition/Recall sorted high](plots/supervised/prec_rec_sorted_all_ranks_high.pdf)  

###by bin
[Precition/Recall by bin all](plots/supervised/prec_recall_combined_all_ranks_by_bin_ANI_all.pdf)
[Precition/Recall by bin common strain](plots/supervised/prec_recall_combined_all_ranks_by_bin_ANI_common_strain.pdf)  
[Precition/Recall by bin unique strain](plots/supervised/prec_recall_combined_all_ranks_by_bin_ANI_unique_strain.pdf)  

###by genome
[Precition/Recall by genome all](plots/supervised/prec_recall_combined_all_ranks_by_genome_ANI_all.pdf)  
[Precition/Recall by genome common strain](plots/supervised/prec_recall_combined_all_ranks_by_genome_ANI_common_strain.pdf)  
[Precition/Recall by genome unique strain](plots/supervised/prec_recall_combined_all_ranks_by_genome_ANI_unique_strain.pdf)  

### Avg. Precition/Recall
[supervised Avg. Precition/Recall](plots/supervised/supervised_summary_all.pdf)  
[supervised Avg. Precition/Recall](plots/supervised/supervised_summary_all_99.pdf)  

### Basepair count
[supervised relative bp count](plots/supervised/supervised_bp_count_relative_all.pdf)  
[supervised bp count in k basepairs](plots/supervised/supervised_bp_count_absolute_all.pdf)  

### Adjusted rand index
[supervised ari including notassigned](plots/supervised/supervised_ari_including_notassigned_all.pdf)  
[supervised ari excluding notassigned](plots/supervised/supervised_ari_excluding_notassigned_all.pdf)  
[supervised ari including notassigned split by novelty](plots/supervised/supervised_ari_including_notassigned_novelty.pdf)  
[supervised ari excluding notassigned split by novelty](plots/supervised/supervised_ari_excluding_notassigned_novelty.pdf)  
[supervised ari including notassigned split by uniqueness](plots/supervised/supervised_ari_including_notassigned_uniqueness.pdf)  
[supervised ari excluding notassigned split by uniqueness](plots/supervised/supervised_ari_excluding_notassigned_uniqueness.pdf)  

###Unupervised plots:
[Precition/Recall by genome all](plots/unsupervised/prec_recall_combined_all_ranks_by_genome_ANI_all.pdf)  
[Precition/Recall by genome common strain](plots/unsupervised/prec_recall_combined_all_ranks_by_genome_ANI_common_strain.pdf)  
[Precition/Recall by genome unique strain](plots/unsupervised/prec_recall_combined_all_ranks_by_genome_ANI_unique_strain.pdf)  

[unsupervised ari including notassigned](plots/unsupervised/unsupervised_ari_including_notassigned_all.pdf)  
[unsupervised ari excluding notassigned](plots/unsupervised/unsupervised_ari_excluding_notassigned_all.pdf)  
[unsupervised ari including notassigned split by novelty](plots/unsupervised/unsupervised_ari_including_notassigned_novelty.pdf)  
[unsupervised ari excluding notassigned split by novelty](plots/unsupervised/unsupervised_ari_excluding_notassigned_novelty.pdf)  
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
