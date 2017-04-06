# Scripts and their output for the CAMI revision. 


## The files described in "output" are always created using the default values.


### binners_ranking.py
Input: 
* ../binning/tables/\<data set\>\_unsupervised\_by\_genome\_all.tsv \[[low](../binning/tables/low_unsupervised_by_genome_all.tsv), [medium](../binning/tables/medium_unsupervised_by_genome_all.tsv), [high](../binning/tables/high_unsupervised_by_genome_all.tsv)]
* [unique_common.tsv](../metadata/ANI/unique_common.tsv)
* FILTER\_TAIL and EXCLUDE\_PLASMIDS (default: True)
* BINNER and BINNER_NAMES (default: [bin\_mapping.txt](bin_mapping.txt))

Output:
* [binners\_ranking.txt](binners_ranking.txt)


Given the table of result of the by_genome evaluation, ranks the binners according to their average precision/recall/sum of precision and recall.

FILTER\_TAIL and EXCLUDE\_PLASMIDS are options which by default are set to True. Using these options first excludes the *precision values* of the smallest genomes whichs sum of genome sizes do add up to less than **1%** of all the genomes' sizes.
EXCLUDE\_PLASMIDS then removes all genomes which have been flagged as "circular element" in "../metadata/ANI/unique\_common.tsv".
For the remaining values, the precision and recall are averaged over all genomes and put out to their corresponding binners. The value for every binner is averaged over all three data sets (low, medium, high)


### genome_recovery.py
Input:
* ../binning/tables/\<data set\>\_unsupervised\_by\_genome\_all.tsv \[[low](../binning/tables/low_unsupervised_by_genome_all.tsv), [medium](../binning/tables/medium_unsupervised_by_genome_all.tsv), [high](../binning/tables/high_unsupervised_by_genome_all.tsv)]
* FILTER\_TAIL (default: True)
* BINNER and BINNER\_NAMES (default: [bin\_mapping.txt](bin_mapping.txt))

Output:
* [binner\_completeness.tsv](binner_completeness.tsv)


Given the same table as for the binners\_ranking script, this script creates a table reporting the well recovered genomes in terms of high completeness (recall) and low contamination (1 - precision).

The first step after reading the table is again to possible perform FILTER_TAIL. Then a 3x2 table is created for every tool, containing as rows the genomes which have been recovered with
at least 50%, at least 70% and at least 90% and as columns the genomes with less than 10% and less than 5% contamination respectively. This is summed over all three data sets (low, medium, high).
Also, the cells are not mutually exclusive, i.e. a genome with >90% completeness and less than 5% contamination will increase the value of every cell.


### taxon_ranking.py
Input:
* ../binning/tables/\<data set\>\_supervised\_by\_bin\_all.tsv \[[low](../binning/tables/low_supervised_by_bin_all.tsv), [medium](../binning/tables/medium_supervised_by_bin_all.tsv), [high](../binning/tables/high_supervised_by_bin_all.tsv)]
* ../binning/data/taxonomic/\<Gold Standard\>/output/perbin\_stats.tsv \[[low](../binning/data/taxonomic/determined_meitner_=_Gold_Standard_0/output/perbin_stats.tsv), [medium](../binning/data/taxonomic/adoring_lalande_=_Gold_Standard_1/output/perbin_stats.tsv), [high](../binning/data/taxonomic/adoring_lalande_=_Gold_Standard_0/output/perbin_stats.tsv)\]

Output:
* [per_taxon.tsv](per_taxon.tsv)
* [tools\_by\_sample.txt](tools_by_sample.txt)

This script produces a table which for every taxon present in the gold standard computes its precision/recall/sum of precision and recall.

First, the gold standard file is read which will give the considered taxa, sorted by their rank, disregarding unassigned sequences. Since some taxon names are only unique in combination with their rank (i.e. phylum/class both named
Actinobacteria), the mapping is done with respect to both rank as well as taxon. So the table \_supervised\_by\_bin is read and for every taxon/rank combination all the precision and recall values of
the tools are collected. If no tool predicted a taxon, the precision is set to "NA" and the recall to 0. These values are then averaged over all tools. If precision is "NA" it is excluded from the calculation,
i.e. precision + recall with precision "NA" is the same as just recall. Additionally it is stored how many tools made a non-NA prediction for that genome and how many tools could have made a prediction.
Finally, all the three data sets are merged and the precision/recall/sum of precision and recall again averaged over all three data sets (in case a taxon appears in all three data sets). Additionally the
total number of predictions and the possible number of predictions for each genome is reported. There are 7 methods doing predictions for the low data set and 11 for both the medium and the high data set
(namely [these](tools_by_sample.txt)), so the number of possible predictions for a taxon are 7 (appearing only low data set), 11 (only in medium xor only in high), 18 (low and medium xor high), 22 (medium and high) or 29 (all three).

Since the input table is rounded with two decimal places, there might be taxa having a recall of 0 but a non-NA precision.


### create\_summary\_table.py
Input:
* ../binning/data/taxonomic/*/description.properties \[[folder](../binning/data/taxonomic)\]
* ../binning/data/taxonomic/*/output/summary\_stats\_99.tsv \[[folder](../binning/data/taxonomic)\]
* DATASETS names (default: "1st CAMI Challenge Dataset 1 CAMI_low":"low",
		"1st CAMI Challenge Dataset 2 CAMI_medium":"medium",
		"1st CAMI Challenge Dataset 3 CAMI_high":"high")

Output:
* ../binning/data/\<data set\>\_supervised\_summary\_stats\_99.tsv \[[low](../binning/data/low_supervised_summary_stats_99.tsv), [medium](../binning/data/medium_supervised_summary_stats_99.tsv), [high](../binning/data/high_supervised_summary_stats_99.tsv)\]


This script appends the summary\_stats\_99.tsv results of every tool to a single file (including only the 4 metrics
which will be used for ranking: precision, recall, accuracy, misclassification rate). The individual files'
headers are removed and instead the name of the tool appended as last column in the tsv.
The .properties files are basically sectionless INI files, so after adding a dummy header the configparse module
can be used to read the files and retrieve the data set.


### tax_binner_ranking.py
Input:
* ../binning/data/\<data set\>\_supervised\_summary\_stats\_99.tsv \[[low](../binning/data/low_supervised_summary_stats_99.tsv), [medium](../binning/data/medium_supervised_summary_stats_99.tsv), [high](../binning/data/high_supervised_summary_stats_99.tsv)\]
* BINNER and BINNER\_NAMES (default: [bin\_mapping.txt](bin_mapping.txt))

Output:
* [tax\_binner\_ranking.tsv](tax_binner_ranking.tsv)
* [tax\_binner\_table.tsv](tax_binner_table.tsv)


This script uses the output of create\_summary\_table.py, which is the appended tables from summary\_stats\_99 for all the tools.
This tables are read in for all data sets and ranks. For every rank the values of every data set are averaged and then sorted
to produce the ranking which then is written to tax\_binner\_ranking.tsv. Additionally, the ranks are summed up among all ranks
and the average value of each metric is calculated and this result stored in the table tax\_binner\_table.tsv
Since there are 4 tools and 7 ranks (kingdom, phylum, class, order, family, genus, species) the minimal (best) value for ranks is 7 and
the maximal (worst) value is 28.

### TODO:
* which binning tools where chosen if multiple parameter sets were present

