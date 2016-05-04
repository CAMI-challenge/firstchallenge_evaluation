As a lot of people are working on the binning evaluation, this file is supposed to be a collection of metrics and methods for binning evaluation. If you have any ideas or suggestions, please edit this file accordingly!

The metrics used are:
* entropy
* rand index
* adjusted rand index

As an additional measure, we calculate the profile implied by the different binners:
For all bins:
 * (Sum_(contig in bin) coverage \* length) / length of all contigs in bin

Coverage \* length is basically the number of base pairs for a certain contig, in the end normalised by bin size.

The data sets for which these metrics are calculated, are:
* binning tools (original submissions)
* binning tools, where the contigs are separated by novelty category (work in progress by Cristina and me)
* ?
