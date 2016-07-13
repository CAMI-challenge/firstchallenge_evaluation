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

##Unupervised plots:
[unsupervised ari including notassigned](plots/unsupervised/unsupervised_ari_including_notassigned_all.pdf)  
[unsupervised ari excluding notassigned](plots/unsupervised/unsupervised_ari_excluding_notassigned_all.pdf)  
[unsupervised ari including notassigned split by novelty](plots/unsupervised/unsupervised_ari_including_notassigned_novelty.pdf)  
[unsupervised ari excluding notassigned split by novelty](plots/unsupervised/unsupervised_ari_excluding_notassigned_novelty.pdf)  
[unsupervised ari including notassigned split by uniqueness](plots/unsupervised/unsupervised_ari_including_notassigned_uniqueness.pdf)  
[unsupervised ari excluding notassigned split by uniqueness](plots/unsupervised/unsupervised_ari_excluding_notassigned_uniqueness.pdf)  


### Example calls:

#### unsupervised
Rscript unsupervised_ari.r data/unsupervised/ plots/unsupervised/unsupervised_ari_including_notassigned_all.pdf  
Rscript unsupervised_ari.r data/unsupervised/ plots/unsupervised/unsupervised_ari_excluding_notassigned_all.pdf 1  

Rscript unsupervised_ari_by_category.r data/unsupervised_novelty/ plots/unsupervised/unsupervised_ari_including_notassigned_novelty.pdf  
Rscript unsupervised_ari_by_category.r data/unsupervised_novelty/ plots/unsupervised/unsupervised_ari_excluding_notassigned_novelty.pdf 1  

Rscript unsupervised_ari_by_category.r data/unsupervised_uniqueness/ plots/unsupervised/unsupervised_ari_including_notassigned_uniqueness.pdf  
Rscript unsupervised_ari_by_category.r data/unsupervised_uniqueness/ plots/unsupervised/unsupervised_ari_excluding_notassigned_uniqueness.pdf 1  

#### supervised
Rscript supervised_macro_precision.r data/taxonomic/ plots/supervised/supervised_summary_all.pdf  

Rscript supervised_absolute_count_relative.r data/taxonomic/ plots/supervised/supervised_bp_count_relative_all.pdf  
Rscript supervised_absolute_count_absoulte.r data/taxonomic/ plots/supervised/supervised_bp_count_absolute_all.pdf  

Rscript supervised_ari.r data/taxonomic/ plots/supervised/supervised_ari_including_notassigned_all.pdf  
Rscript supervised_ari.r data/taxonomic/ plots/supervised/supervised_ari_excluding_notassigned_all.pdf 1  

Rscript supervised_ari_by_category.r data/taxonomic_novelty/ plots/supervised/supervised_ari_including_notassigned_novelty.pdf  
Rscript supervised_ari_by_category.r data/taxonomic_novelty/ plots/supervised/supervised_ari_excluding_notassigned_novelty.pdf 1  

Rscript supervised_ari_by_category.r data/taxonomic_uniqueness/ plots/supervised/supervised_ari_including_notassigned_uniqueness.pdf  
Rscript supervised_ari_by_category.r data/taxonomic_uniqueness/ plots/supervised/supervised_ari_excluding_notassigned_uniqueness.pdf 1  

