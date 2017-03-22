# crate all plots:
```
./make.sh
```

# prec_rec_plots.R
Creates average precision/recall plots  
Called within R environment using:
```
source(prec_rec_plots.R)
```

# prec_rec_size_sorted.R
Creates precision/recall scatter plots  
Called within R environment using:
```
source(prec_rec_size_sorted.R)
```

# average_prec_rec_plots.r
Wrapper for 'prec_rec_plots.R' and 'prec_rec_size_sorted.R'
Is called from console:
```
Rscript average_prec_rec_plots.r
```

# parse_raw_result_data.R
Contains functions that parse raw data

# table_concatinate.r
Concatinates all by_genome tables into one saving it in the table folder
```
Rscript table_concatinate.r
```

# supervised_absolute_count_absoulte.r
Creates plot showing the amount of correctly and incorrectly assigned basepairs

# supervised_absolute_count_relative.r
Creates plot showing the amount of correctly and incorrectly assigned basepairs in percent

# supervised_ari.r / unsupervised_ari.r
Create plot showing adjusted rand index values

# supervised_ari_by_category.r / unsupervised_ari_by_category.r
Create plot showing adjusted rand index values by a specific catergory like a novelty category

# supervised_macro_precision.r
Create plot of taxonomic binners showing average precition/recall and standard deviation, misclassification rate

# unsupervised_precision_recall.r
Create plot with precition and recall for binners

