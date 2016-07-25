## Results of the binning challenge

Current metagenome assembly and scaffolding methods return mixtures of variable length fragments originating from individual genomes of a sequenced microbiome. Metagenome binning algorithms were thus devised to tackle the problem of grouping these according to their organismal origin. These  “bins”, or sets of assembled sequences or reads ideally group data from one of the individual strains present in the sequenced microbial community.  However, resolution to this level is not always possible, in which case bins representing taxa at higher taxonomic ranks are returned, e.g. species-, or family-level bins. Bin reconstruction allows subsequent genome and pangenome analyses of the individual community members. While binning methods group sequences into bins without assignment of taxonomic labels, taxonomic binning methods group sequences into bins with a taxonomic label attached. Within CAMI, use of the NCBI taxonomy as a reference taxonomy allowed determination of taxonomic bins at all encoded taxonomic ranks, from species to root-level. 

We evaluated nine binning and taxonomic binning methods where software was submitted in a binning-biobox to the first CAMI challenge, or implemented within such a biobox by the CAMI team and developers together. These methods are MaxBin, CONCOCT, MyCC, MetaBAT, PhyloPythiaS+ (26870609[uid]), taxator-tk (25388150), Megan 6 and Kraken.  We then determined their performance for key questions in microbial community studies: Which return many bins of overall good quality, meaning with on average high completeness (high recall), and low contamination levels (high precision).  These bins are most representative for genome-level analyses of the underlying genomes and pangenomes. Which methods return bins with very low levels of contamination? The results of highly precise taxon binning methods can be used to taxonomically assign the genome bins returned by binning tools. Which methods show high recall in the recovery of bins from low abundance community members? This question is of relevance for ancient metagenomics and pathogen detection, where an indication of the presence of pathogenic taxa can be the starting point for subsequent genome recovery efforts. Which methods perform well in the recovery of bins from deep-branching phyla, for which no sequenced genomes yet exist? In every known microbial community, a substantial fraction of taxa is not represented by sequenced genomes of cultivated isolates and for their characterization, methods allowing bin recovery from such deep-branchers are required. How does the performance of the taxonomic binners vary across taxonomic ranks? How is performance affected by the presence of non-bacterial sequences in a sample, such as viruses, plasmids and other uncharacterized DNA? Finally, how does performance vary for taxa represented by many closely related strains in the community in comparison to taxa represented by one strain only? Can the evaluated tools resolve the genomes of individual strains in the challenge data sets?

## BINNERS: 
We begin with an investigation of the performance of all methods in the recovery of individual genome bins. For this, the precision and recall were determined for every predicted bin in comparison to the genome, with which the bin had the highest overlap in predicted bps (highest recall). 

### Recovery of genome bins
Shown is for each binner the submission with the best average precision and recall (defined exactly how?) for one of the three challenge data sets. Bars give the standard deviation of the measures across genome bins.
[Precision and recall by genome, for all genomes](plots/unsupervised/prec_recall_combined_all_ranks_by_genome_all_ANI_all.pdf)  
[Precision and recall by genome, for all genomes](plots/supervised/prec_recall_combined_all_ranks_by_genome_all_ANI_all.pdf)  

[Precision and recall by genome, strains in groups with more than 95% ANI similarity to other strains](plots/unsupervised/prec_recall_combined_all_ranks_by_genome_all_ANI_common_strain.pdf)  
[Precision/Recall by genome, strains in groups with more than 95% ANI similarity to other strains](plots/supervised/prec_recall_combined_all_ranks_by_genome_all_ANI_common_strain.pdf)  

[Precision and recall by genome, unique strains with equal to or less than 95% ANI to others](plots/unsupervised/prec_recall_combined_all_ranks_by_genome_all_ANI_unique_strain.pdf)  
[Precision/Recall by genome, unique strain with ANI below or equal to 95% to all other strains.](plots/supervised/prec_recall_combined_all_ranks_by_genome_all_ANI_unique_strain.pdf)  

To investigate whether the data partitioning achieved by taxonomic binners can be used for strain-level genome recovery, we compared the predicted taxonomic bins at all ranks against the genome (strain)-level bins. Precision and recall for a predicted bin were calculated relative to the strain-level bin with the highest recall, i.e. overlap in terms of common bps of sequence fragments placed in both bins.


[ARI by genome for binners including unassigned bin](plots/unsupervised/unsupervised_ari_including_notassigned_all.pdf)  
[ARI by genomefor binners excluding uassigned bin - a purity measure](plots/unsupervised/unsupervised_ari_excluding_notassigned_all.pdf)  
[ARI by genome including unassigned bin, split by novelty category](plots/unsupervised/unsupervised_ari_including_notassigned_novelty.pdf)  
[ARI by genome excluding unassigned bin, split by novelty category](plots/unsupervised/unsupervised_ari_excluding_notassigned_novelty.pdf)  
[ARI by genome for binners including unassigned bin, split by uniqueness](plots/unsupervised/unsupervised_ari_including_notassigned_uniqueness.pdf)  
[ARI for binners excluding uassigned bin - a purity measure, split by uniqueness](plots/unsupervised/unsupervised_ari_excluding_notassigned_uniqueness.pdf)  

Question: define uniqueness.



## Plots for taxonomic binners

### Average Precision/Recall, shown for individual ranks and data sets


[Precision/Recall](plots/supervised/supervised_summary_all.pdf)  
[Precision/Recall, with smallest predicted bins summing up to 1% of entire data set removed](plots/supervised/supervised_summary_all_99.pdf)  

###sorted by bin size:
####low
[Precision/Recall sorted by bin size, low complexity data set](plots/supervised/prec_rec_sorted_all_ranks_low_all.pdf)  
[Precision/Recall sorted by bin size, low complexity data set only common_strain](plots/supervised/prec_rec_sorted_all_ranks_low_common_strain.pdf)  
[Precision/Recall sorted by bin size, low complexity data set only unique_strain](plots/supervised/prec_rec_sorted_all_ranks_low_unique_strain.pdf)  
[Precision/Recall sorted by bin size, low complexity data set only new_order](plots/supervised/prec_rec_sorted_all_ranks_low_new_order.pdf)  
[Precision/Recall sorted by bin size, low complexity data set only new_family](plots/supervised/prec_rec_sorted_all_ranks_low_new_family.pdf)  
[Precision/Recall sorted by bin size, low complexity data set only new_genus](plots/supervised/prec_rec_sorted_all_ranks_low_new_genus.pdf)  
[Precision/Recall sorted by bin size, low complexity data set only new_species](plots/supervised/prec_rec_sorted_all_ranks_low_new_species.pdf)  
[Precision/Recall sorted by bin size, low complexity data set only new_strain](plots/supervised/prec_rec_sorted_all_ranks_low_new_strain.pdf)  
####medium
[Precision/Recall sorted by bin size, medium complexity data set](plots/supervised/prec_rec_sorted_all_ranks_medium_all.pdf)  
[Precision/Recall sorted by bin size, medium complexity data set only common_strain](plots/supervised/prec_rec_sorted_all_ranks_medium_common_strain.pdf)  
[Precision/Recall sorted by bin size, medium complexity data set only unique_strain](plots/supervised/prec_rec_sorted_all_ranks_medium_unique_strain.pdf)  
[Precision/Recall sorted by bin size, medium complexity data set only new_family](plots/supervised/prec_rec_sorted_all_ranks_medium_new_family.pdf)  
[Precision/Recall sorted by bin size, medium complexity data set only new_genus](plots/supervised/prec_rec_sorted_all_ranks_medium_new_genus.pdf)  
[Precision/Recall sorted by bin size, medium complexity data set only new_species](plots/supervised/prec_rec_sorted_all_ranks_medium_new_species.pdf)  
[Precision/Recall sorted by bin size, medium complexity data set only new_strain](plots/supervised/prec_rec_sorted_all_ranks_medium_new_strain.pdf)  
<!--[Precision/Recall sorted by bin size, medium complexity data set only new_order](plots/supervised/prec_rec_sorted_all_ranks_medium_new_order.pdf)  -->
####high
[Precision/Recall sorted by bin size, high complexity data set](plots/supervised/prec_rec_sorted_all_ranks_high_all.pdf)  
[Precision/Recall sorted by bin size, high complexity data set only common_strain](plots/supervised/prec_rec_sorted_all_ranks_high_common_strain.pdf)  
[Precision/Recall sorted by bin size, high complexity data set only unique_strain](plots/supervised/prec_rec_sorted_all_ranks_high_unique_strain.pdf)  
[Precision/Recall sorted by bin size, high complexity data set only new_genus](plots/supervised/prec_rec_sorted_all_ranks_high_new_genus.pdf)  
[Precision/Recall sorted by bin size, high complexity data set only new_species](plots/supervised/prec_rec_sorted_all_ranks_high_new_species.pdf)  
[Precision/Recall sorted by bin size, high complexity data set only new_strain](plots/supervised/prec_rec_sorted_all_ranks_high_new_strain.pdf)  
<!--[Precision/Recall sorted by bin size, high complexity data set only new_order](plots/supervised/prec_rec_sorted_all_ranks_high_new_order.pdf)  -->
<!--[Precision/Recall sorted by bin size, high complexity data set only new_family](plots/supervised/prec_rec_sorted_all_ranks_high_new_family.pdf)  -->

Precision is shown for predicted, recall for real bin sizes.  To normalize the scale, for each tool individually, sort bins by predicted size, normalize bin size relative to the size of the largest bin for each bin.
Recall was normalized in a similar way using real bin sizes.

###by bin
[Precision/Recall by bin, all bins](plots/supervised/prec_recall_combined_all_ranks_by_bin_all_ANI_all.pdf)  
[Precision/Recall by bin, all bins only common_strain](plots/supervised/prec_recall_combined_all_ranks_by_bin_common_strain_ANI_all.pdf)  
[Precision/Recall by bin, all bins only unique_strain](plots/supervised/prec_recall_combined_all_ranks_by_bin_unique_strain_ANI_all.pdf)  
[Precision/Recall by bin, all bins only new_order](plots/supervised/prec_recall_combined_all_ranks_by_bin_new_order_ANI_all.pdf)  
[Precision/Recall by bin, all bins only new_family](plots/supervised/prec_recall_combined_all_ranks_by_bin_new_family_ANI_all.pdf)  
[Precision/Recall by bin, all bins only new_genus](plots/supervised/prec_recall_combined_all_ranks_by_bin_new_genus_ANI_all.pdf)  
[Precision/Recall by bin, all bins only new_species](plots/supervised/prec_recall_combined_all_ranks_by_bin_new_species_ANI_all.pdf)  
[Precision/Recall by bin, all bins only new_strain](plots/supervised/prec_recall_combined_all_ranks_by_bin_new_strain_ANI_all.pdf)  

Black squares give: predicted  bin size in unit 10 Gb, grey square real bin size in 10 Gb.






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





## Making plots:
The calls to create most plots are contained in a [bash script](make_plots.sh), which must be called within this binning directory.
Unix only, sorry. Some scripts are not yet suitable for windown, but all work using a unix system, given all R packages are available.  

### 'by_bin' and 'by_genome' combining of tables into one file
Execute from within binning directory:  
    Rscript by__sumup.r

###Example:
Execute from within binning directory:  
    Rscript by_bin_sumup.r  
    Rscript by_bin_sumup.r  
