# Scripts and their output for the CAMI revision


### binners_rankking.py
Input: 
* ../binning/tables/\<data set\>\_unsupervised\_by\_genome\_all.tsv
* ../metadata/ANI/unique_common.tsv
* FILTER\_TAIL and EXCLUDE\_PLASMIDS
* BINNER and BINNER_NAMES
Output:
* binners\_ranking.txt


Given the table of result of the by_genome evaluation, ranks the binners according to their average precision/recall/sum of precision and recall.

FILTER\_TAIL and EXCLUDE\_PLASMIDS are options which by default are set to True. Using these options first excludes the *precision values* of the smallest genomes whichs sum of genome sizes do add up to less than 1% of all the genomes' sizes.
EXCLUDE\_PLASMIDS then removes all genomes which have been flagged as "circular element" in "../metadata/ANI/unique\_common.tsv".
For the remaining values, the precision and recall are averaged over all genomes and put out to their corresponding binners. The value for every binner is averaged over all three data sets (low, medium, high)


### genome_recovery.py
Input:
* ../binning/tables/\<data set\>\_unsupervised\_by\_genome\_all.tsv
* FILTER\_TAIL
* BINNER and BINNER\_NAMES
Output:
* binner\_completeness.tsv


Given the same table as for the binners\_ranking script, this script creates a table reporting the well recovered genomes in terms of high completeness (recall) and low contamination (1 - precision).

The first step after reading the table is again to possible perform FILTER_TAIL. Then a 3x2 table is created for every tool, containing as rows the genomes which have been recovered with
at least 50%, at least 70% and at least 90% and as columns the genomes with less than 10% and less than 5% contamination respectively. This is summed over all three data sets (low, medium, high).
Also, the cells are not mutually exclusive, i.e. a genome with >90% completeness and less than 5% contamination will increase the value of every cell.


### taxon_ranking.py
Input:
* ../binning/tables/\<data set\>\_supervised\_by\_bin\_all.tsv
* ../binning/data/taxonomic/\<Gold Standard\>/output/perbin\_stats.tsv
Output:
* per_taxon.tsv


This script produces a table which for every taxon present in the gold standard computes its precision/recall/sum of precision and recall.

First, the gold standard file is read which will give the considered taxa, sorted by their rank, disregarding unassigned sequences. Since some taxon names are only unique in combination with their rank (i.e. phylum/class both named
Actinobacteria), the mapping is done with respect to both rank as well as taxon. So the table \_supervised\_by\_bin is read and for every taxon/rank combination all the precision and recall values of
the tools are collected. If no tool predicted a taxon, the precision is set to "NA" and the recall to 0. These values are then averaged over all tools. If precision is "NA" it is excluded from the calculation,
i.e. precision + recall with precision "NA" is the same as just recall. Additionally it is stored how many tools made a non-NA prediction for that genome and how many tools could have made a prediction.
Finally, all the three data sets are merged and the precision/recall/sum of precision and recall again averaged over all three data sets (in case a taxon appears in all three data sets). Additionally the
total number of predictions and the possible number of predictions for each genome is reported. Since the input table is rounded with two decimal places, there might be taxa having a recall of 0 but a non-NA precision.


### TODO:
which binning tools where chosen if multiple parameter sets were present
binners ranking using summary\_stats\_99

