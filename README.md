# firstchallenge_evaluation
Directory containing example result visualizations and scripts for generating figures and tables

## FAQ

For profiling-related questions and answers, please see the [profiling subdirectory](https://github.com/CAMI-challenge/firstchallenge_evaluation/tree/master/profiling).

**The IDs of all the newly sequenced genomes, used as reference genomes for the first CAMI challenge, are given in Supplementary Table 10 of the [CAMI paper](https://www.nature.com/articles/nmeth.4458). Where can I download the genomes with a Max Planck Institute (MPI) identifier?**

The table in file [supplementary_data/Supplementary_Table_10_atsphere_IDs_mapping.txt](https://github.com/CAMI-challenge/firstchallenge_evaluation/blob/master/supplementary_data/Supplementary_Table_10_atsphere_IDs_mapping.txt) contains all the genome IDs corresponding to strains sequenced at the MPI. The second column contains the final IDs that were used to upload these genomes to ENA and NCBI.

**How can I compute the same metrics for the results of my binning (or profiling) tool and compare them to the results of the CAMI challenge?** 

You can reproduce binning and profiling comparisons, as well as compute metrics for the results of other tools, using the assessment packages [AMBER](https://github.com/CAMI-challenge/AMBER) (binning) and [OPAL](https://github.com/CAMI-challenge/OPAL) (profiling). Datasets, gold standards, and the results of participating binners and profilers are available on the [CAMI benchmarking portal](https://data.cami-challenge.org/). For additional information on the profiling assessments, see also the [profiling FAQ](https://github.com/CAMI-challenge/firstchallenge_evaluation/tree/master/profiling).
