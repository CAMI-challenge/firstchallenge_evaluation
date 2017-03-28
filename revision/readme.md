#Scripts and their output for the CAMI revision
###binners_rankking.py
Input: 
*../binning/tables/\<data set\>\_unsupervised\_by\_genome\_all.tsv
*"../metadata/ANI/unique_common.tsv"
*FILTER\_TAIL and EXCLUDE\_PLASMIDS
*BINNER and BINNER_NAMES
Output:
*binners_ranking.txt

Given the table of result of the by_genome evaluation, ranks the binners according to their average precision/recall/sum of precision and recall.
FILTER\_TAIL and EXCLUDE\_PLASMIDS are options which by default are set to True. Using these options first excludes the *precision values* of the smallest genomes whichs sum of genome sizes do add up to less than 1% of all the genomes' sizes.
EXCLUDE\_PLASMIDS then removes all genomes which have been flagged as "circular element" in "../metadata/ANI/unique\_common.tsv".
For the remaining values, the precision and recall are averaged over all genomes and put out to their corresponding binners

###TODO:
which binning tools where chosen if multiple parameter sets were present
binners ranking using summary\_stats\_99

