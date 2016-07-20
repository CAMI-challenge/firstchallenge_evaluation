## Plots for taxonomic binners

### Average Precision/Recall, shown for individual ranks and data sets


[Precision/Recall](plots/supervised/supervised_summary_all.pdf)  
[Precision/Recall, with smallest predicted bins summing up to 1% of entire data set removed](plots/supervised/supervised_summary_all_99.pdf)  

###sorted by bin size:
[Precision/Recall sorted by bin size, low complexity data set](plots/supervised/prec_rec_sorted_all_ranks_low.pdf)  
[Precision/Recall sorted by bin size, medium complexity data set](plots/supervised/prec_rec_sorted_all_ranks_medium.pdf)  
[Precision/Recall sorted by bin size, high complexity data set](plots/supervised/prec_rec_sorted_all_ranks_high.pdf)  

procedure.
here, precision is shown for predicted, recall for real bin sizes. to normalize the scale, for each tool individually, sort bins by predicted size, normalize bin size relative to the size of the largest bin for each bin.  recall was normalized in a similar way using real bin sizes.

###by bin
[Precision/Recall by bin, all bins](plots/supervised/prec_recall_combined_all_ranks_by_bin_ANI_all.pdf)
[Precision/Recall by bin, strains in groups with more than 95% ANI similarity to other strains](plots/supervised/prec_recall_combined_all_ranks_by_bin_ANI_common_strain.pdf)  
[Precision/Recall by bin, unique strain with ANI below or equal 95% to all other strains](plots/supervised/prec_recall_combined_all_ranks_by_bin_ANI_unique_strain.pdf)  

black squares give: predicted  bin size in unit 10 Gb, grey square real bin size in 10 Gb.

###by genome, across all data sets. 
[Precision/Recall by genome, all](plots/supervised/prec_recall_combined_all_ranks_by_genome_ANI_all.pdf)  
[Precision/Recall by genome, strains in groups with more than 95% ANI similarity to other strains](plots/supervised/prec_recall_combined_all_ranks_by_genome_ANI_common_strain.pdf)  
[Precision/Recall by genome, unique strain with ANI below or equal to 95% to all other strains.](plots/supervised/prec_recall_combined_all_ranks_by_genome_ANI_unique_strain.pdf)  

To investigate whether the data partitioning achieved by taxonomic binners can be used for strain-level genome recovery, we compared the predicted taxonomic bins at all ranks against the genome (strain)-level bins. Precision and recall for a predicted bin were calculated relative to the strain-level bin with the highest recall, i.e. overlap in terms of common bps of sequence fragments placed in both bins.

Question: is my interpretation correct for ranks? Please check



### Basepair count
[Assignments to different taxonomic ranks in % bp](plots/supervised/supervised_bp_count_relative_all.pdf)  
[Assignments to differnet taxonomic ranks in kb](plots/supervised/supervised_bp_count_absolute_all.pdf) 


### Adjusted rand index (ARI)
[ARI for taxonomic binners on bins including unassigned bin](plots/supervised/supervised_ari_including_notassigned_all.pdf)  
[ARI for taxonomic binners on bins without unassigned bin - a purity measure](plots/supervised/supervised_ari_excluding_notassigned_all.pdf)  
[ARI for taxonomic binners on bins including unassigned bin, split by taxonomic novelty category](plots/supervised/supervised_ari_including_notassigned_novelty.pdf)  
[ARI for taxonomic binners on bins without unassigned bin - a purity measure, split by taxonomic novelty category](plots/supervised/supervised_ari_excluding_notassigned_novelty.pdf)  
[ARI for taxonomic binners on bins including unassigned bin,  for taxa represented by one strain (ANI to others > 95%) versus taxa represented by multiple strains (ANI to others <= 95%)](plots/supervised/supervised_ari_including_notassigned_uniqueness.pdf)  
[ARI for taxonomic binners on bins without unassigned bin - a purity measure, for taxa represented by one strain (ANI to others > 95%) versus taxa represented by multiple strains (ANI to others <= 95%).  ](plots/supervised/supervised_ari_excluding_notassigned_uniqueness.pdf)  

###Plots for binners:
[Precision/Recall by genome, all](plots/unsupervised/prec_recall_combined_all_ranks_by_genome_ANI_all.pdf)  
[Precision/Recall by genome, strains in groups with more than 95% ANI similarity to other strains](plots/unsupervised/prec_recall_combined_all_ranks_by_genome_ANI_common_strain.pdf)  
[Precision/Recall by genome, unique strains with equal to or less than 95% ANI to others](plots/unsupervised/prec_recall_combined_all_ranks_by_genome_ANI_unique_strain.pdf)  

[ARI for binners including unassigned bin](plots/unsupervised/unsupervised_ari_including_notassigned_all.pdf)  
[ARI for binners excluding uassigned bin - a purity measure](plots/unsupervised/unsupervised_ari_excluding_notassigned_all.pdf)  
[ARI including unassigned bin, split by novelty category](plots/unsupervised/unsupervised_ari_including_notassigned_novelty.pdf)  
[ARI, excluding unassigned bin, split by novelty category](plots/unsupervised/unsupervised_ari_excluding_notassigned_novelty.pdf)  
[ARI for binners including unassigned bin, split by uniqueness](plots/unsupervised/unsupervised_ari_including_notassigned_uniqueness.pdf)  
[ARI for binners excluding uassigned bin - a purity measure, split by uniqueness](plots/unsupervised/unsupervised_ari_excluding_notassigned_uniqueness.pdf)  



## Making plots:
The calls to create most plots are contained in a [bash script](make_plots.sh), which must be called within this binning directory.
Unix only, sorry. Some scripts are not yet suitable for windown, but all work using a unix system, given all R packages are available.  

### 'by_bin' and 'by_genome' combining of tables into one file
    Rscript perbin_sumup.r target/directory/ "perbin"

###Example:
    Rscript perbin_sumup.r data/taxonomic "perbin"  
    Rscript perbin_sumup.r data/taxonomic "bygenome"  
