##Supervised plots:
### Avg. Precition/Recall
[supervised Avg. Precition/Recall](plots/supervised/supervised_summary_all.pdf)  

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
[unsupervised ari including notassigned](plots/unsupervised/unsupervised_ari_including_notassigned_all.pdf)  
[unsupervised ari excluding notassigned](plots/unsupervised/unsupervised_ari_excluding_notassigned_all.pdf)  
[unsupervised ari including notassigned split by novelty](plots/unsupervised/unsupervised_ari_including_notassigned_novelty.pdf)  
[unsupervised ari excluding notassigned split by novelty](plots/unsupervised/unsupervised_ari_excluding_notassigned_novelty.pdf)  
[unsupervised ari including notassigned split by uniqueness](plots/unsupervised/unsupervised_ari_including_notassigned_uniqueness.pdf)  
[unsupervised ari excluding notassigned split by uniqueness](plots/unsupervised/unsupervised_ari_excluding_notassigned_uniqueness.pdf)  


## Making plots:
The calls to create most plots are contained in a [bash script](make_plots.sh), which must be called using this binning directory. Unix only, sorry.  
Some scripts are not yet suitable for windown, but all work using a unix system, given all R packages are available.  

### by_bin and by_genome combining of tables into one file
perbin_sumup.r target/directory/ "perbin"

###Example:
perbin_sumup.r data/taxonomic "perbin"
perbin_sumup.r data/taxonomic "bygenome"
