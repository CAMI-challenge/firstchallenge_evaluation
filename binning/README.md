NOTE: This document is to be synched with the CAMI binning results on google drive

## Results of the binning challenge

Current metagenome assembly and scaffolding methods return mixtures of variable length fragments originating from individual genomes of a sequenced microbiome. Metagenome binning algorithms were thus devised to tackle the problem of "binning" these according to their taxonomic origins. These  “bins”, or sets of assembled sequences and reads in the best case group data from individual strains or higher-ranking taxa present in the sequenced microbial community.  Such bin reconstruction allows the subsequent analysis of the genomes and pangenomes of different microbial community members. While binning methods group sequences into bins without assignment of taxonomic labels, taxonomic binning methods group sequences into bins with a taxonomic label attached. Reference taxonomies used by the taxonomic binners, such as the NCBI taxonomy used here, allowed determination of taxonomic bins from species to domain-level, while strain-level taxon assignment is currently not supported. 

We evaluated nine binning and taxonomic binning methods for which the software was submitted in a binning-biobox in the CAMI challenge, or implemented within a biobox by the CAMI team and developers. These methods are MaxBin 2.0, MyCC, MetaBAT, MetaWatt-3.5, CONCOCT, PhyloPythiaS+ (26870609[uid]), taxator-tk (25388150), Megan-6 and Kraken.  We then determined their performance for important questions in microbial community studies: Do current methods allow the recovery of high quality bins for individual strains, meaning with on average high completeness (high recall), and low contamination levels (high precision)?  Such high quality bins are most suitable for genome-level analyses of the strains or higher-ranking taxa present in a studied community. How does performance vary for taxa represented by many closely related strains in the community in comparison to taxa represented by one strain only? Can the evaluated tools resolve the genomes of individual strains in the challenge data sets?  How is performance of all methods affected by the presence of non-bacterial sequences in a sample, such as viruses, plasmids and other uncharacterized DNA? For the taxonomic binners, we further investigated which methods returned bins of species rank or above with high quality. Which methods make few false positive assignments in taxonomic binning? The results of highly precise taxon binning methods can be used to assign a taxon to the output of binning methods. Which methods show high recall in the detection of taxon bins from low abundance community members? This question is of relevance for ancient metagenomics and pathogen detection, where an indication of the presence of pathogenic taxa can be the starting point for subsequent genome recovery efforts. How does the performance of the taxonomic binners vary across taxonomic ranks? Finally, which methods perform well in the recovery of bins from deep-branching phyla, for which no sequenced genomes yet exist? In every known microbial community, a substantial fraction of its members is not closely related to isolates represented by sequenced genomes in public databases. For their characterization, methods allowing bin recovery from such deep-branchers are required. 

## BINNERS: 
### Recovery of genome bins
We first investigated the performance of all methods in the recovery of individual genome (strain-level) bins. For this, we determined the precision and recall for every bin relative to the genome that was most abundant in the bin in terms of bps. To determine whether the data partitioning achieved by taxonomic binners can also be used for strain-level genome recovery, we compared the predicted taxonomic bins at all ranks to the genome bins. Precision and recall for a predicted bin were calculated in the same way as for the unsupervised binners. Note that for taxonomic binners thus only bin quality in terms of completeness (recall) and purity (precision) relative to a reference genome, not the taxon assignment, was evaluated.

For the binners, both recall (ranging from 30 to 80%) and precision (ranging from 40 to almost 100%) varied substantially across the three challenge data sets.  For the medium and low complexity data sets, MaxBin 2.0 had the highest recall and precision of all tools (70-80% recall, more than 90% precision), followed by all other tools with similar, still good performances in a narrow range.  Not suprisingly, performances on the high complexity data set was for all tools substantially less good, with recall value of around 50% and varying precision (here MaxBin 2.0 again showed an outstanding precision of above 90%).

![Figure: Precision and recall for binners by genome, for all genomes](plots/unsupervised/binner_prec_recall_combined_all_ranks_by_genome_all_ANI_all.png)

*[Figure](tables/unsupervised/prec_recall_combined_all_ranks_by_genome_all_ANI_all.csv): Precision and recall for binners by genome, for all genomes. Shown is for each binner the submission with the largest sum of the average bin precision and recall values for each of the three challenge data sets. Bars denote the standard error of precision and recall across genome bins. As some tools tended to predict many very small, incorrect bins, for determination of precision, the smallest predicted bins summing up to 1% of the data set size overall were removed.*

For the taxonomic binners, the recall was generally notably lower than for the binners, mostly less than 30%, with that of PhyloPythiaS+ being the highest, while for all other methods, recall was below 10%. The technical limitations of taxonomic binning methods for genome bin recovery is evident by the positioning of the gold standard here - even when performing perfect binning down to the species level, the presence of multiple strains for many species in our data sets prevents these approaches from achieving high recall values. Notably, though, the precision had a similar range to that of the binning methods. The most precise of all methods was Kraken, with precision reaching values of above 80%, closely followed by the other methods. Note that this does not mean that Kraken assigned many taxonomic labels correctly, but rather tended to most consistently grouping a few of the fragments of the same genomes together. 

![Figure: Precision and recall for taxonomic binners by genome, for all genomes](plots/supervised/taxbinner_prec_recall_combined_all_ranks_by_genome_all_ANI_all.png)
*[Figure](tables/supervised/prec_recall_combined_all_ranks_by_genome_all_ANI_all.csv): Precision and recall for taxonomic binners by genome, for all genomes. Shown is for each binner the submission with the largest sum of the average bin precision and recall values for each of the three challenge data sets. Bars denote the standard error of precision and recall across genome bins. As some tools tended to predict many very small, incorrect bins, for determination of precision, the smallest predicted bins summing up to 1% of the data set size overall were removed.*

####Can the tools separate different strains from the same species? 
We next investigated the effect that the presence of multiple strains from one species had on tool performances in more detail. We separated the data into two groups, one group containing all the strains which have another genome in the set with an Average Nucleotide Identity (ANI) of more than 95% ("common strains") and the other group containing all “unique” strains - strains for which every other genome in the set has an ANI of less than or equal to 95%. If considering only the genomes of unique strains, the performance of all binners improved substantially, both in terms of precision and recall. For the medium and low complexity data sets, all binners had precision values of above 80%, while recall was more variable. MaxBin 2.0 performed best across all three data sets, showing precision values above 90% and recall values of 70% or higher. An almost equally good performance for two of the three data sets was delivered by MetaBat, CONCOCT and MetaWatt-3.5.

![Figure: Precision and recall for binners by genome, unique strains with equal to or less than 95% ANI to others](plots/unsupervised/binner_prec_recall_combined_all_ranks_by_genome_all_ANI_unique_strain.png)
*[Figure](tables/unsupervised/prec_recall_combined_all_ranks_by_genome_all_ANI_unique_strain.csv): Precision and recall for binners by genome, unique strains with equal to or less than 95% ANI to others. Shown is for each binner the submission with the largest sum of the average bin precision and recall values for each of the three challenge data sets. Bars denote the standard error of precision and recall across genome bins. As some tools tended to predict many very small, incorrect bins, for determination of precision, the smallest predicted bins summing up to 1% of the data set size overall were removed.*

For the taxonomic binners, both precision and recall improved by around 10%, with recall values of up to 40% reached by PhyloPythiaS+, while simultaneously showing a precision of more than 70%. Precision values of more than 90%, though with very low recall, were obtained by Kraken. A similar behaviour to Kraken was shown by Megan, 6 and taxator-tk. Interestingly, all three tools showing a similar performance behaviour also share methodological similarites (Variations of the "LCA algorithm" on the identified similar sequences from a reference database to a query, Supplementary Table on Methods).

![Figure: Precision/Recall for taxonomic binners by genome, unique strain with ANI below or equal to 95% to all other strains.](plots/supervised/taxbinner_prec_recall_combined_all_ranks_by_genome_all_ANI_unique_strain.png)
*[Figure](tables/supervised/prec_recall_combined_all_ranks_by_genome_all_ANI_unique_strain.csv): Precision/Recall for taxonomic binners by genome, unique strain with ANI below or equal to 95% to all other strains. Shown is for each binner the submission with the largest sum of the average bin precision and recall values for each of the three challenge data sets. Bars denote the standard error of precision and recall across genome bins. As some tools tended to predict many very small, incorrect bins, for determination of precision, the smallest predicted bins summing up to 1% of the data set size overall were removed.*

For the genomes of the "common strains", however, recall dropped substantially for all methods, to below 70% in one case, and for most methods to values around 20 to 50%. Precision for most methods also dropped substantially. MaxBin 2.0 still stood out from the other methods, with precision values of more than 90% on all data sets.

![Figure: Precision and recall for binners by genome, strains in groups with more than 95% ANI similarity to other strains](plots/unsupervised/binner_prec_recall_combined_all_ranks_by_genome_all_ANI_common_strain.png)
*[Figure](tables/unsupervised/prec_recall_combined_all_ranks_by_genome_all_ANI_common_strain.csv): Precision and recall for binners by genome, strains in groups with more than 95% ANI similarity to other strains. Shown is for each binner the submission with the largest sum of the average bin precision and recall values for each of the three challenge data sets. Bars denote the standard error of precision and recall across genome bins. As some tools tended to predict many very small, incorrect bins, for determination of precision, the smallest predicted bins summing up to 1% of the data set size overall were removed.*

For the taxonomic binners, precision and recall also dropped notably. PhyloPythiaS+ still showed the highest recall values, which were less than 30% though, at lower precision. Precision was down to 70% for the best performing method, which here was taxator-tk.recall for the "common strains" was not substantially altered and less than 25% for all methods, as before.  In part, this is expected,  even under ideal circumstances, as the reference taxonomy does not resolve below species level, which result in strains of the same species being placed in one bin even in the case of perfect assignment. A one bin equals one strain assignment can thus only be achieved if there is no more than one strain per species present. This effect is evident by the varying, and not ideal performance of the taxonomic binning gold standard on the "unique" and "common" data sets, where it performs quite well on the first, but poorly on the second. Interestingly, for the common data sets, taxonomic binning methods by assigning genomes of the same species either not at all or consistently to bins at different ranks, achieve a better genome resolution than the gold standard.

![Figure: Precision/Recall for taxonomic binners by genome, strains in groups with more than 95% ANI similarity to other strains](plots/supervised/taxbinner_prec_recall_combined_all_ranks_by_genome_all_ANI_common_strain.png)
*[Figure](tables/supervised/prec_recall_combined_all_ranks_by_genome_all_ANI_common_strain.csv): Precision/Recall for taxonomic binners by genome, strains in groups with more than 95% ANI similarity to other strains. Shown is for each binner the submission with the largest sum of the average bin precision and recall values for each of the three challenge data sets. Bars denote the standard error of precision and recall across genome bins. As some tools tended to predict many very small, incorrect bins, for determination of precision, the smallest predicted bins summing up to 1% of the data set size overall were removed.*

Overall, the presence of multiple related strains in a metagenome sample had a substantial effect on the quality of reconstructed genomes, both if using binning or taxonomic binning tools. Vey high quality genome reconstructions are attainable with binning methods for the genomes of "unique" strains, while the presence of several, closely related strains in a sample presents a notable hurdle to current methods. Taxonomic binners had lower recall than binners for genome reconstructions, likely also due to limitations of the reference taxonomy, with similar precisions reached, thus delivering high quality, partial genome bins. 

[####How does genome abundance affect performance?
TBD

####Are there performance trends evident based on the kind of approaches the tools use? 
TBD]


## Performance in taxonomic binning
####How do we recover “good quality” bins?
We next investigated the performance of taxonomic binning methods (Kraken, Megan, taxator-tk, PhyloPythiaS+) in recovering taxon-level bins at different ranks. These results can be used for taxon-level evolutionary or functional pangenome analyses or further conversion into taxonomic profiles. As performance metrics, again the average precision and recall were calculated for individual ranks. In addition, we determined the overall classification accuracy for the entire samples, as measured in bps, and the misclassification rate for all assignments in bps. While the former two measures allow to assess performance as averaged over bins, where all bins are treated the same irrespecitve of their sizes, the later are influenced by the actual sample taxonomic constitution, with large bins having a proportionally larger influence.

![Precision/Recall](plots/supervised/supervised_summary_all_1.png)
*Performance metrics across ranks for the LC data set*

![Precision/Recall, with smallest predicted bins summing up to 1% of entire data set removed](plots/supervised/supervised_summary_all_99_1.png)
*Performance metrics across ranks for the LC data set, with smallest predicted bins summing up to 1% of entire data set removed*

For the low complexity data set, PhyloPythiaS+ had the highest accuracy, average recall and precision, which were all above 75% from domain to family level. Kraken followed, with average recall and accuracy still above 50% down to family level, though precision was notably lower, mostly caused by prediction of many small false bins, which affected precision more than overall accuracy, as explained above. If removing 1% of the data set, correspondig to the smallest predicted bins, precision notably increased for Kraken, Megan, and most strongly, for taxator-tk, for which it was above 75% until the family level. This shows that small predicted bins are not very trustworthy by current methods. Below family level, no method performed very well, with all either assigning very little (low recall and accuracy, accompanied by a low misclassification rate), or assigning with a substantial amount of misclassification. Another interesting observation we made is the similarity of the performance profiles for Kraken and Megan. These methods do not share the source of information used (kmer usage versus local sequence similarity scores), but used the same input (read data, instead of assembled data) and rely on similar algorithms.


![Precision/Recall](plots/supervised/supervised_summary_all_2.png)
*Performance metrics across ranks for the MC data set*

![Precision/Recall, with smallest predicted bins summing up to 1% of entire data set removed](plots/supervised/supervised_summary_all_99_2.png)
*Performance metrics across ranks for the MC data set, with smallest predicted bins summing up to 1% of entire data set removed*

The results for the MC data set qualitatively agree with those for the LC data set, except that Kraken, Megan and taxator-tk performed better. With 1% of the smallest bins removed, both Kraken and PhyloPythiaS+ performed similarly well, reaching performance statistics of above 75% for accuray, average recall and precision until the family rank. Similarly, taxator-tk showed an average precision of almost 75% even down to the genus level on these data and Megan had an average precision of more than 75% down to the order level while maintaining accuracy and average recall values of around 50%. The similarity of performance profiles of Megan and Kraken was less pronounced on this data set.

![Precision/Recall](plots/supervised/supervised_summary_all_3.png)
*Performance metrics across ranks for the HC data set*

![Precision/Recall, with smallest predicted bins summing up to 1% of entire data set removed](plots/supervised/supervised_summary_all_99_3.png)
*Performance metrics across ranks for the HC data set, with smallest predicted bins summing up to 1% of entire data set removed*

The performances of the HC data set were similar to those for the MC data set.

####Which tools return very precise bins, with few sequences of other taxa included? 
Precise taxonomic binning results can be intersected with the results of binning tools for assignment of taxonomic labels to genome bins. For all data sets, taxator-tk returned few, but very precise assignments, if removing low abundance predicted bins, down to the genus level. 

####Which tools have high recall (very sensitive), also for low abundance taxa? 
This is required when screening for pathogens, in diagnostic settings, or for ancient metagenomics studies of human diseases, where interesting leads are further pursued by validation with experimental techniques. Even though high recall was achieved by PhyloPythiaS+ and Kraken also for low abundance bins until the rank of family, this degraded substantially for the ranks below, which are of most interest for these applications. It therefore remains an open challenge to further improve predictive performance here.

####Which tools are good for reconstructing taxon bins for genomes from novel species, genera, family (deep-branchers). 
-Which tools are suitable for taxon bin recovery from “deep-branching” phyla with few reference genomes? Across taxonomic ranks.
Conclusion: 



####Are there trends evident by approach?
-e.g. read based methods versus methods run on assembled sequences (Megan and Kraken versus PPSP and taxator-tk), homology-based methods versus kmer methods (not really, e.g. Megan and taxator-tk versus Kraken and PhyloPythiaS+), LCA-using methods (also Megan and Kraken versus others).

####How does the presence of viral material, plasmids and other circular elements affect the taxonomic binning results? 

Contrary to profiling, this had almost no effect on overall binning results. Even though the copy numbers of plasmids and viral data are substantial, in terms of sequence size the fraction of viral, plasmid and unassigned data is very small (Supplementary table on abundances).


## Conclusions
- managed reproducibilty of tool results, benchmark data sets, and performance evaluations.
- associated performance metrics with different biological use cases, to be informative also for applied metagenomics community.

- all methods performed surprisingly well in strain-level genome reconstruction, if strains are not too closely related. Taxonomic binners performed acceptably down to the family rank. This leaves a gap in current species and genus-level reconstruction that is to be closed, also for not closely related genomes. As taxonomic binners were able to achieve better precision in genome reconstruciton than in species or genus-level binning, this raises the possibility that a larger part of the performance problem in low ranking taxon assignment might be caused by limitations of the taxonomy. ADD SOME more informed discussion here, if this seems sensible, and propositions for resolution. E.g. Should one use a phylogeny instead as a reference? Are there comparisons of the species tree to the ncbi taxonomy? Another challenge is genome deconvolution in the presence of many closely related strains, which we found to be challenging for all kinds of methods that we evaluated.
- runtime assessment should be done in the future.


## Supplementary information


## Taxonomic assignments in % and kp sequence
![Assignments to different taxonomic ranks in % bp](plots/supervised/supervised_bp_count_relative_all_1.png)
*Assignments to different taxonomic ranks in % bp*
![Assignments to different taxonomic ranks in % bp](plots/supervised/supervised_bp_count_relative_all_2.png)
*Assignments to different taxonomic ranks in % bp*
![Assignments to different taxonomic ranks in % bp](plots/supervised/supervised_bp_count_relative_all_3.png)
*Assignments to different taxonomic ranks in % bp*

![Assignments to differnet taxonomic ranks in kb](plots/supervised/supervised_bp_count_absolute_all_1.png)
*Assignments to differnet taxonomic ranks in kb*
![Assignments to differnet taxonomic ranks in kb](plots/supervised/supervised_bp_count_absolute_all_2.png)
*Assignments to differnet taxonomic ranks in kb*
![Assignments to differnet taxonomic ranks in kb](plots/supervised/supervised_bp_count_absolute_all_3.png)

## Taxonomic assignments sorted by bin size:

####How does taxon abundance affect performance? 

![Precision/Recall sorted by bin size, low complexity data set](plots/supervised/prec_rec_sorted_all_ranks_low_all.png)
*Figure: Precision/Recall sorted by bin size, low complexity data set*

![Precision/Recall sorted by bin size, medium complexity data set](plots/supervised/prec_rec_sorted_all_ranks_medium_all.png)
*Figure: Precision/Recall sorted by bin size, medium complexity data set*

![Precision/Recall sorted by bin size, high complexity data set](plots/supervised/prec_rec_sorted_all_ranks_high_all.png)
*Figure: Precision/Recall sorted by bin size, high complexity data set*
####low complexity data set

![Precision/Recall sorted by bin size, low complexity data set only common_strain](plots/supervised/prec_rec_sorted_all_ranks_low_common_strain.png)
*Figure: Precision/Recall sorted by bin size, low complexity data set only common_strain*

![Precision/Recall sorted by bin size, low complexity data set only unique_strain](plots/supervised/prec_rec_sorted_all_ranks_low_unique_strain.png)
*Figure: Precision/Recall sorted by bin size, low complexity data set only unique_strain*

![Precision/Recall sorted by bin size, low complexity data set only new_order](plots/supervised/prec_rec_sorted_all_ranks_low_new_order.png)
*Figure: Precision/Recall sorted by bin size, low complexity data set only new_order*

![Precision/Recall sorted by bin size, low complexity data set only new_family](plots/supervised/prec_rec_sorted_all_ranks_low_new_family.png)
*Figure: Precision/Recall sorted by bin size, low complexity data set only new_family*

![Precision/Recall sorted by bin size, low complexity data set only new_genus](plots/supervised/prec_rec_sorted_all_ranks_low_new_genus.png)
*Figure: Precision/Recall sorted by bin size, low complexity data set only new_genus*

![Precision/Recall sorted by bin size, low complexity data set only new_species](plots/supervised/prec_rec_sorted_all_ranks_low_new_species.png)
*Figure: Precision/Recall sorted by bin size, low complexity data set only new_species*

![Precision/Recall sorted by bin size, low complexity data set only new_strain](plots/supervised/prec_rec_sorted_all_ranks_low_new_strain.png)
*Figure: Precision/Recall sorted by bin size, low complexity data set only new_strain*

####medium complexity data set

![Precision/Recall sorted by bin size, medium complexity data set only common_strain](plots/supervised/prec_rec_sorted_all_ranks_medium_common_strain.png)
*Figure: Precision/Recall sorted by bin size, medium complexity data set only common_strain*

![Precision/Recall sorted by bin size, medium complexity data set only unique_strain](plots/supervised/prec_rec_sorted_all_ranks_medium_unique_strain.png)
*Figure: Precision/Recall sorted by bin size, medium complexity data set only unique_strain*

![Precision/Recall sorted by bin size, medium complexity data set only new_family](plots/supervised/prec_rec_sorted_all_ranks_medium_new_family.png)
*Figure: Precision/Recall sorted by bin size, medium complexity data set only new_family*

![Precision/Recall sorted by bin size, medium complexity data set only new_genus](plots/supervised/prec_rec_sorted_all_ranks_medium_new_genus.png)
*Figure: Precision/Recall sorted by bin size, medium complexity data set only new_genus*

![Precision/Recall sorted by bin size, medium complexity data set only new_species](plots/supervised/prec_rec_sorted_all_ranks_medium_new_species.png)
*Figure: Precision/Recall sorted by bin size, medium complexity data set only new_species*

![Precision/Recall sorted by bin size, medium complexity data set only new_strain](plots/supervised/prec_rec_sorted_all_ranks_medium_new_strain.png)
*Figure: Precision/Recall sorted by bin size, medium complexity data set only new_strain*

<!--![Precision/Recall sorted by bin size, medium complexity data set only new_order](plots/supervised/prec_rec_sorted_all_ranks_medium_new_order.png)  -->
####high complexity data set

![Precision/Recall sorted by bin size, high complexity data set only common_strain](plots/supervised/prec_rec_sorted_all_ranks_high_common_strain.png)
*Figure: Precision/Recall sorted by bin size, high complexity data set only common_strain*

![Precision/Recall sorted by bin size, high complexity data set only unique_strain](plots/supervised/prec_rec_sorted_all_ranks_high_unique_strain.png)
*Figure: Precision/Recall sorted by bin size, high complexity data set only unique_strain*

![Precision/Recall sorted by bin size, high complexity data set only new_genus](plots/supervised/prec_rec_sorted_all_ranks_high_new_genus.png)
*Figure: Precision/Recall sorted by bin size, high complexity data set only new_genus*

![Precision/Recall sorted by bin size, high complexity data set only new_species](plots/supervised/prec_rec_sorted_all_ranks_high_new_species.png)
*Figure: Precision/Recall sorted by bin size, high complexity data set only new_species*

![Precision/Recall sorted by bin size, high complexity data set only new_strain](plots/supervised/prec_rec_sorted_all_ranks_high_new_strain.png)
*Figure: Precision/Recall sorted by bin size, high complexity data set only new_strain*

<!--![Precision/Recall sorted by bin size, high complexity data set only new_order](plots/supervised/prec_rec_sorted_all_ranks_high_new_order.png)  -->
<!--![Precision/Recall sorted by bin size, high complexity data set only new_family](plots/supervised/prec_rec_sorted_all_ranks_high_new_family.png)  -->

Precision is shown for predicted, recall for real bin sizes.  To normalize the scale, for each tool individually, sort bins by predicted size, normalize bin size relative to the size of the largest bin for each bin.
Recall was normalized in a similar way using real bin sizes.

###by bin
![Precision/Recall by bin, all bins](plots/supervised/prec_recall_combined_all_ranks_by_bin_all_ANI_all.png)
*[Figure](tables/supervised/prec_recall_combined_all_ranks_by_bin_all_ANI_all.csv): Precision/Recall by bin, all bins*

![Precision/Recall by bin, all bins only common_strain](plots/supervised/prec_recall_combined_all_ranks_by_bin_common_strain_ANI_all.png)
*[Figure](tables/supervised/prec_recall_combined_all_ranks_by_bin_common_strain_ANI_all.csv): Precision/Recall by bin, all bins only common_strain*

![Precision/Recall by bin, all bins only unique_strain](plots/supervised/prec_recall_combined_all_ranks_by_bin_unique_strain_ANI_all.png)
*[Figure](tables/supervised/prec_recall_combined_all_ranks_by_bin_unique_strain_ANI_all.csv): Precision/Recall by bin, all bins only unique_strain*

![Precision/Recall by bin, all bins only new_order](plots/supervised/prec_recall_combined_all_ranks_by_bin_new_order_ANI_all.png)
*[Figure](tables/supervised/prec_recall_combined_all_ranks_by_bin_new_order_ANI_all.csv): Precision/Recall by bin, all bins only new_order*

![Precision/Recall by bin, all bins only new_family](plots/supervised/prec_recall_combined_all_ranks_by_bin_new_family_ANI_all.png)
*[Figure](tables/supervised/prec_recall_combined_all_ranks_by_bin_new_family_ANI_all.csv): Precision/Recall by bin, all bins only new_family*

![Precision/Recall by bin, all bins only new_genus](plots/supervised/prec_recall_combined_all_ranks_by_bin_new_genus_ANI_all.png)
*[Figure](tables/supervised/prec_recall_combined_all_ranks_by_bin_new_genus_ANI_all.csv): Precision/Recall by bin, all bins only new_genus*

![Precision/Recall by bin, all bins only new_species](plots/supervised/prec_recall_combined_all_ranks_by_bin_new_species_ANI_all.png)
*[Figure](tables/supervised/prec_recall_combined_all_ranks_by_bin_new_species_ANI_all.csv): Precision/Recall by bin, all bins only new_species*

![Precision/Recall by bin, all bins only new_strain](plots/supervised/prec_recall_combined_all_ranks_by_bin_new_strain_ANI_all.png)
*[Figure](tables/supervised/prec_recall_combined_all_ranks_by_bin_new_strain_ANI_all.csv): Precision/Recall by bin, all bins only new_strain*

Black squares give: predicted  bin size in unit 10 Gb, grey square real bin size in 10 Gb.




#### ARI plots for binners
![Figure: ARI by genome for unsupervised binners](plots/unsupervised/ari_all.png "ARI by genome for unsupervised binners")
*Figure: ARI by genome for unsupervised binners.
For the ANI on the x axis only the sequences that were binned by a tool were evaluated,
On the other hand, the ARI calculated for the y axis had contigs/reads assigned to a 'trash' bin.
The more a dot deviates from the diagonal the fewer assignments were made.
[Q: Better plot with %assigned sequences on y axis?]*

<!--
All tools did quite well on the low complexity dataset,
with MaxBin 2.0 noticeably creating the purest bins.
On the medium dataset most tools managed to get similar good results,
with MetaBAT and CONCOCT even improving in purity of the bins.
MaxBin 2.0 preserves its very high purity of bins over all datasets but at the cost of assigning fewer sequences.
A good purity while still binning many sequences is archived by MetaWatt-3.5, even improved in purity of bins.
-->

<!--
![Figure: ARI by genome including unassigned bin, split by novelty category.](plots/unsupervised/unsupervised_ari_including_notassigned_novelty_1.png)
*Figure: ARI by genome including unassigned bin, split by novelty category.*
![Figure: ARI by genome including unassigned bin, split by novelty category.](plots/unsupervised/unsupervised_ari_including_notassigned_novelty_2.png)
*Figure: ARI by genome including unassigned bin, split by novelty category.*
![Figure: ARI by genome including unassigned bin, split by novelty category.](plots/unsupervised/unsupervised_ari_including_notassigned_novelty_3.png)
*Figure: ARI by genome including unassigned bin, split by novelty category.*

![Figure: ARI by genome excluding unassigned bin, split by novelty category.](plots/unsupervised/unsupervised_ari_excluding_notassigned_novelty_1.png)
*Figure: ARI by genome excluding unassigned bin, split by novelty category.*
![Figure: ARI by genome excluding unassigned bin, split by novelty category.](plots/unsupervised/unsupervised_ari_excluding_notassigned_novelty_2.png)
*Figure: ARI by genome excluding unassigned bin, split by novelty category.*
![Figure: ARI by genome excluding unassigned bin, split by novelty category.](plots/unsupervised/unsupervised_ari_excluding_notassigned_novelty_3.png)
*Figure: ARI by genome excluding unassigned bin, split by novelty category.*
![Figure: ARI by genome for binners including unassigned bin, split by uniqueness.](plots/unsupervised/unsupervised_ari_including_notassigned_uniqueness_1.png)
*Figure: ARI by genome for binners including unassigned bin, split by uniqueness. Not assigned contigs/reads were assigned to a 'trash' bin and with this included in the evaluation. Grouping of genomes by whether there a highly similar genomes in the same dataset (ANI>95%) or not.
If yes, such genome was declared as that of 'common strain' as opposed to from a 'unique strain'.*
![Figure: ARI by genome for binners including unassigned bin, split by uniqueness.](plots/unsupervised/unsupervised_ari_including_notassigned_uniqueness_2.png)
*Figure: ARI by genome for binners including unassigned bin, split by uniqueness. Not assigned contigs/reads were assigned to a 'trash' bin and with this included in the evaluation. Grouping of genomes by whether there a highly similar genomes in the same dataset (ANI>95%) or not.
If yes, such genome was declared as that of 'common strain' as opposed to from a 'unique strain'.*
![Figure: ARI by genome for binners including unassigned bin, split by uniqueness.](plots/unsupervised/unsupervised_ari_including_notassigned_uniqueness_3.png)
*Figure: ARI by genome for binners including unassigned bin, split by uniqueness. Not assigned contigs/reads were assigned to a 'trash' bin and with this included in the evaluation. Grouping of genomes by whether there a highly similar genomes in the same dataset (ANI>95%) or not. If yes, such genome was declared as that of 'common strain' as opposed to from a 'unique strain'.*

![Figure: ARI for binners excluding uassigned bin - a purity measure, split by uniqueness. Grouping of genomes by whether there a highly similar genomes in the same dataset (ANI>95%) or not.
If yes, such genome was declared as that of 'common strain' as opposed to from a 'unique strain'.](plots/unsupervised/unsupervised_ari_excluding_notassigned_uniqueness_1.png)
*Figure: ARI for binners excluding uassigned bin - a purity measure, split by uniqueness. Grouping of genomes by whether there a highly similar genomes in the same dataset (ANI>95%) or not.
If yes, such genome was declared as that of 'common strain' as opposed to from a 'unique strain'.*
![Figure: ARI for binners excluding uassigned bin - a purity measure, split by uniqueness.](plots/unsupervised/unsupervised_ari_excluding_notassigned_uniqueness_2.png)
*Figure: ARI for binners excluding uassigned bin - a purity measure, split by uniqueness. Grouping of genomes by whether there a highly similar genomes in the same dataset (ANI>95%) or not.
If yes, such genome was declared as that of 'common strain' as opposed to from a 'unique strain'.*
![Figure: ARI for binners excluding uassigned bin - a purity measure, split by uniqueness.](plots/unsupervised/unsupervised_ari_excluding_notassigned_uniqueness_3.png)
*Figure: ARI for binners excluding uassigned bin - a purity measure, split by uniqueness. Grouping of genomes by whether there a highly similar genomes in the same dataset (ANI>95%) or not.
If yes, such genome was declared as that of 'common strain' as opposed to from a 'unique strain'.*
-->

Novelty category:  
Grouping of genomes by their relation of genomes to a known full/draft genome from the NCBI reference database (Q: was this not a merger including also genomes from JGI and TIGR?)

excluding uassigned bin:  
Not assigned contigs/reads were discarded before ARI calculation.

*Assignments to different taxonomic ranks in kb*

### Adjusted rand index (ARI)
![ARI for taxonomic binners on bins including unassigned bin](plots/supervised/supervised_ari_including_notassigned_all.png)
*ARI for taxonomic binners on bins including unassigned bin*
![ARI for taxonomic binners on bins including unassigned bin](plots/supervised/supervised_ari_including_notassigned_all.png)
*ARI for taxonomic binners on bins including unassigned bin*
![ARI for taxonomic binners on bins including unassigned bin](plots/supervised/supervised_ari_including_notassigned_all.png)
*ARI for taxonomic binners on bins including unassigned bin*

![ARI for taxonomic binners on bins without unassigned bin - a purity measure](plots/supervised/supervised_ari_excluding_notassigned_all.png)
*ARI for taxonomic binners on bins without unassigned bin - a purity measure*
![ARI for taxonomic binners on bins without unassigned bin - a purity measure](plots/supervised/supervised_ari_excluding_notassigned_all.png)
*ARI for taxonomic binners on bins without unassigned bin - a purity measure*
![ARI for taxonomic binners on bins without unassigned bin - a purity measure](plots/supervised/supervised_ari_excluding_notassigned_all.png)
*ARI for taxonomic binners on bins without unassigned bin - a purity measure*

![ARI for taxonomic binners on bins including unassigned bin, split by taxonomic novelty category](plots/supervised/supervised_ari_including_notassigned_novelty.png)
*ARI for taxonomic binners on bins including unassigned bin, split by taxonomic novelty category*
![ARI for taxonomic binners on bins including unassigned bin, split by taxonomic novelty category](plots/supervised/supervised_ari_including_notassigned_novelty.png)
*ARI for taxonomic binners on bins including unassigned bin, split by taxonomic novelty category*
![ARI for taxonomic binners on bins including unassigned bin, split by taxonomic novelty category](plots/supervised/supervised_ari_including_notassigned_novelty.png)
*ARI for taxonomic binners on bins including unassigned bin, split by taxonomic novelty category*

![ARI for taxonomic binners on bins without unassigned bin - a purity measure, split by taxonomic novelty category](plots/supervised/supervised_ari_excluding_notassigned_novelty.png)
*ARI for taxonomic binners on bins without unassigned bin - a purity measure, split by taxonomic novelty category*
![ARI for taxonomic binners on bins without unassigned bin - a purity measure, split by taxonomic novelty category](plots/supervised/supervised_ari_excluding_notassigned_novelty.png)
*ARI for taxonomic binners on bins without unassigned bin - a purity measure, split by taxonomic novelty category*
![ARI for taxonomic binners on bins without unassigned bin - a purity measure, split by taxonomic novelty category](plots/supervised/supervised_ari_excluding_notassigned_novelty.png)
*ARI for taxonomic binners on bins without unassigned bin - a purity measure, split by taxonomic novelty category*

![ARI for taxonomic binners on bins including unassigned bin,  for taxa represented by one strain (ANI to others > 95%) versus taxa represented by multiple strains (ANI to others <= 95%)](plots/supervised/supervised_ari_including_notassigned_uniqueness_1.png)
*ARI for taxonomic binners on bins including unassigned bin,  for taxa represented by one strain (ANI to others > 95%) versus taxa represented by multiple strains (ANI to others <= 95%)*
![ARI for taxonomic binners on bins including unassigned bin,  for taxa represented by one strain (ANI to others > 95%) versus taxa represented by multiple strains (ANI to others <= 95%)](plots/supervised/supervised_ari_including_notassigned_uniqueness_2.png)
*ARI for taxonomic binners on bins including unassigned bin,  for taxa represented by one strain (ANI to others > 95%) versus taxa represented by multiple strains (ANI to others <= 95%)*
![ARI for taxonomic binners on bins including unassigned bin,  for taxa represented by one strain (ANI to others > 95%) versus taxa represented by multiple strains (ANI to others <= 95%)](plots/supervised/supervised_ari_including_notassigned_uniqueness_3.png)
*ARI for taxonomic binners on bins including unassigned bin,  for taxa represented by one strain (ANI to others > 95%) versus taxa represented by multiple strains (ANI to others <= 95%)*

![ARI for taxonomic binners on bins without unassigned bin - a purity measure, for taxa represented by one strain (ANI to others > 95%) versus taxa represented by multiple strains (ANI to others <= 95%).  ](plots/supervised/supervised_ari_excluding_notassigned_uniqueness_1.png)
*ARI for taxonomic binners on bins without unassigned bin - a purity measure, for taxa represented by one strain (ANI to others > 95%) versus taxa represented by multiple strains (ANI to others <= 95%)*
![ARI for taxonomic binners on bins without unassigned bin - a purity measure, for taxa represented by one strain (ANI to others > 95%) versus taxa represented by multiple strains (ANI to others <= 95%).  ](plots/supervised/supervised_ari_excluding_notassigned_uniqueness_2.png)
*ARI for taxonomic binners on bins without unassigned bin - a purity measure, for taxa represented by one strain (ANI to others > 95%) versus taxa represented by multiple strains (ANI to others <= 95%)*
![ARI for taxonomic binners on bins without unassigned bin - a purity measure, for taxa represented by one strain (ANI to others > 95%) versus taxa represented by multiple strains (ANI to others <= 95%).  ](plots/supervised/supervised_ari_excluding_notassigned_uniqueness_3.png)
*ARI for taxonomic binners on bins without unassigned bin - a purity measure, for taxa represented by one strain (ANI to others > 95%) versus taxa represented by multiple strains (ANI to others <= 95%)*


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
