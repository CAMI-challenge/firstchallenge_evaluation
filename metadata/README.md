##Meta_data file
Tab separated data table with the annotation of genomes. It is the only file later used for the metagenome simulation.  
Column have no fixed order. First row must have column names.
* genome_ID:  
  Original genome id of a genome or draft genome.
* NCBI_ID:  
  Taxonomic classification. A NCBI taxonomic id.
* [novelty_category](https://github.com/CAMI-challenge/MetagenomeSimulationPipeline/wiki/Novelty-Category):  
Reflects how close a genome seems to be related to known whole genomes in reference databases.  A predicted taxid, based on 16S, is compared with a list of taxids of known whole genomes.
* OTU: Id of genomes that were clustered together ~97% identity.
