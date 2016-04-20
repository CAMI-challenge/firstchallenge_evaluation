As a lot of people are working on the binning evaluation, this file is supposed to be a collection of metrics and methods for binning evaluation. If you have any ideas or suggestions, please edit this file accordingly!

The metrics used are:
* entropy
* rand index
* adjusted rand index

As an additional measure, we calculate:
 * A \* B for all bins at all taxonomic ranks, where
  * A = #reads per bin / bin size in bp
  * B = #reads mapped / total number of reads
  
As additional explanation (from my understanding):
  * the more accurate name for "reads" is probably "contigs", as the GSA is used for this?  
    * Can be either, reads or contigs, it is possible contigs have to be maped back to all the reads it is made of for it to work
  * reads per bin is just the size of the particular bin
  * as the contigs have different sizes, bin size in bp is not just 150 \* reads
  * reads mapped / total number of reads is the percentage of all contigs which are assigned to a bin

The data sets for which these metrics are calculated, are:
* binning tools (original submissions)
* binning tools, where the contigs are separated by novelty category (work in progress by Cristina and me)
* ?
