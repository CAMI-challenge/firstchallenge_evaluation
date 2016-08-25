# Contig based assembler analysis

The references in the following plots are grouped by ANI score. 
References with an ANI score higher then 95 percent are in the group 'strain' and references below 95 percent are in group 'uniq'. 
Circular elements such as viruses are labeled 'circular_elem'.

## Assemblers

| Assembler      | Group    | # Tools part of the pipeline (i.e. postprocessing tools) |
|----------------|-----|----------|-------|
| Gold_Standard  |  1  |   -   |
| Minia Pipeline |  2  |   5   |
| Ray_MegaMerge  |  3  |   2   |
| Megahit_mc300  |  5  |   1   |
| Megahit_mc300_ep   | 5  |   1   |
| Megahit_mc300_ep_mtl200 | 5    |   1   |
| VELOUR_P256_K31_C2.0  |    6   |   1   |
| VELOUR_P256_K31_C4.01 |    6    |   1   |
| VELOUR_P256_K63_C2.0  |    6    |   1   |
| VELOUR_P256_K63_C4.01 |    6     |   1   |
| Velvet                |    7     |   1   |
| Ray_51                |    4     |   1   |
| Ray_71 		|    4     |   1   |
| Ray_91                |    4     |   1   |

## Overview of combined MetaQuast Metrics

**Description**:

These metrics are computed by using all reference genomes in combination.
You can find a description for these metrics on the Quast manual website (http://quast.bioinf.spbau.ru/manual.html).

![parallel](contig/parallel.png)

* predicted unique genes are labeled as 'predicted genes'

* mismatches are labeled a mismatches per 100 kbp

#### Conclusions

* Velour produces the most contigs

* Megahit has the longest assembly and the most misassembly events

* Megahit_mc300_ep_mtl200 has the most bases unaligned

* Ray assemblies have the highest duplication ratio

* Velvet has the most mismatches

* Megahit and the minia pipeline reconsturct the most genes

| name                    | #contigs | Total length | #misassemblies | Unaligned length | Genome fraction | Duplication ratio | #mismatches per 100 kbp | #predicted genes unique | NA50   |
|-------------------------|----------|--------------|------------------|------------------|-----------------|-------------------|-------------------------|-------------------------|--------|
| Gold_Standard           | 39140    | 2795766632   | 0                | 2195             | 98.901          | 1.01              | 0                       | 2351198                 | 249666 |
| Minia_Pipeline          | 574094   | 1852281271   | 1555             | 115902           | 65.725          | 1.007             | 9.84                    | 2105340                 | 8792   |
| Ray_MegaMerge           | 319523   | 640156411    | 872              | 72891            | 22.704          | 1.008             | 36.19                   | 825929                  | 3566   |
| Megahit_mc300           | 587607   | 1965527674   | 8831             | 2278284          | 69.337          | 1.012             | 70.46                   | 2240863                 | 8669   |
| Megahit_mc300_ep        | 542635   | 1964675490   | 7029             | 1928937          | 69.43           | 1.011             | 63.68                   | 2203585                 | 10549  |
| Megahit_mc300_ep_mtl200 | 513099   | 1944201212   | 7538             | 40876445         | 67.304          | 1.011             | 71.86                   | 2165055                 | 10382  |
| VELOUR_P256_K31_C2.0    | 785677   | 1072704958   | 308              | 7635             | 38.181          | 1.004             | 5.47                    | 1584184                 | 1674   |
| VELOUR_P256_K31_C4.01   | 574665   | 790491688    | 194              | 21150            | 28.118          | 1.004             | 0.63                    | 1166794                 | 1702   |
| VELOUR_P256_K63_C2.0    | 842405   | 1064353860   | 381              | 56382            | 37.583          | 1.012             | 21.87                   | 1590223                 | 1444   |
| VELOUR_P256_K63_C4.01   | 653803   | 752687256    | 381              | 92434            | 26.645          | 1.009             | 19.21                   | 1171873                 | 1213   |
| Velvet                  | 63536    | 45547808     | 41               | 61226            | 1.62            | 1.004             | 500.18                  | 88325                   | 693    |
| Ray_51                  | 344889   | 742565124    | 982              | 53750            | 25.613          | 1.036             | 34.3                    | 933321                  | 4253   |
| Ray_71                  | 117904   | 171278818    | 159              | 4150             | 5.894           | 1.038             | 28.37                   | 244594                  | 1839   |
| Ray_91                  | 13847    | 12323681     | 11               | 249              | 0.431           | 1.022             | 6.92                    | 21668                   | 885    |


## Genome Fraction

**Metric:**

Genome fraction (%) is the percentage of aligned bases in the reference. A base in the reference is aligned if there is at least one contig with at least one alignment to this base. Contigs from repetitive regions may map to multiple places, and thus may be counted multiple times.

### Boxplot containing strains, uniq genomes and circular_elements

**Description:**

Each point represents genome fraction for a specific reference sequence. The boxplots show the distribution of the reference genome fraction for each assembler.

![Genome Fraction Box Plot](contig/Genome_fraction_boxplot_ref.png)

#### Conclusions

* Minia and Megahit perform best

### Boxplot containing only strains

**Description:**

Each point represents genome fraction for a specific reference sequence. The boxplots show the distribution of the reference genome fraction for each assembler.

![Genome Fraction Box Plot](contig/Genome_fraction_boxplot_strain.png)

#### Conclusions

* All assemblers perform bad on strains

* Megahit performs best

### Boxplot containing only uniq genomes

**Description:**

Each point represents genome fraction for a specific reference sequence. The boxplots show the distribution of the reference genome fraction for each assembler.

![Genome Fraction Box Plot](contig/Genome_fraction_boxplot_uniq.png)

#### Conclusions 

* With the exception of Ray_71, Ray_91 all assemblers perform better on uniq genomes then on strain specific genomes.

#### Boxplot containing only circular elements

**Description:**

Each point represents genome fraction for a specific reference sequence. The boxplots show the distribution of the reference genome fraction for each assembler.

![Genome Fraction Box Plot](contig/Genome_fraction_boxplot_circular_elem.png)

#### Conclusions

* Minia, Ray_91, Megahit, and Velour perform well on circular elements.

* Ray with kmer setting 91 assembles more reference sequences with a higher genome fraction.

#### Facet line plot containing strains, uniq genomes and circular elements 

**Description:**

The X-Axis represents the references sorted by their coverage and is depicted in log scale.
The Y-Axis represents the genome fraction.

![Genome Fraction Line Plot](contig/Genome_fraction_line.png)

#### Conclusions

* All assemblers have an issue with high coverage.

* Ray/Velour: The higher the kmer settings, the less low coverage references are assembled.  

* Megahit/Ray: Multi kmer approach performs better then single kmer.


## Misassemblies

**Metric:**

Misassemblies is the number of positions in the contigs that satisfy one of the following criteria:

   *  the left flanking sequence aligns over 1 kbp away from the right flanking sequence on the reference;

   *  flanking sequences overlap on more than 1 kbp;

   *  flanking sequences align to different strands or different chromosomes;

   *  flanking sequences align on different reference genomes.

Further the misassemblies are divided by the total length of the assembly divided by 1000000.
(number of misassemblies/(assembly length/1000000))

### Facet line plot containing strains, uniq genomes and circular elements

**Description:**

The X-Axis represents the references sorted by their coverage and is depicted in log scale.
The Y-Axis represents the misassemblies.

![Misassemblies per MB Line Plot](contig/normalized_misassemblies_per_MB_line.png)

#### Conclusions

* Inspite of the fact that Megahit reconstructs many circular elements (see genome fraction) it contains comparatively less misassemblies

* Ray produces multiple misassembly events for the circular elements

## Duplication ratio

**Metric:**

Duplication ratio is the total number of aligned bases in the assembly divided by the total number of aligned bases in the reference genome (see Genome fraction (%) for the 'aligned base' definition). If the assembly contains many contigs that cover the same regions of the reference, its duplication ratio may be much larger than 1. This may occur due to overestimating repeat multiplicities and due to small overlaps between contigs, among other reasons.

### Facet line plot containing strains, uniq genomes and circular elements

**Description:**

The X-Axis represents the references sorted by their coverage and is depicted in log scale.
The Y-Axis represents the duplication ratio.

![Duplication ratio Line Plot](contig/Duplication_ratio.png)

#### Conclusions

* Duplication Ratio is low for all assemblers

* The assemblies of the circular elements have a higher duplication ratio then the rest of the assembly

## Number of contigs

**Metric:**

Number of contigs

### Facet line plot containing strains, uniq genomes and circular elements

**Description:**

The X-Axis represents the references sorted by their coverage and is depicted in log scale.
The Y-Axis represents the number of contigs.

![Contigs Line Plot](contig/contigs.png)

#### Conclusions

* Ray and Velour are using a single kmer approach. The following behaviour can be
  observed:

  * The assembly starts with a low number of contigs. This is because at the beginning there is a very low coverage and thus nearly no overlaps between reads.

  * When there is enough read overlaps, the number of contigs starts to rise.

  * Coverage reaches a point where no more but longer contigs can be build, so the line starts to decrease again.

  * This peak is for each assembler different and depends for example on the kmer parameter.

## Mismatches

**Metric:**

Number of mismatches per 100000 aligned bases divided by the assembly length. True SNPs and sequencing errors are not distinguished and are counted equally.

### Boxplot containing strains, uniq genomes and circular elements

![Mismatches Boxplot](contig/normalized_mismatches_per_100_kbp_boxplot.png)

#### Conclusions

* Velvet collects in comparison to the other assemblers more mismatches

## NGA50

**Metric:**

NGA50 are similar to the corresponding NG50 metric without but in this case aligned blocks instead of contigs are considered.
Aligned blocks are obtained by breaking contigs at misassembly events and removing all unaligned bases.

### Line plot containing strains, uniq genomes and circular elements

**Description:**

The X-Axis represents the references sorted by their coverage and is depicted in log scale.
The Y-Axis represents the NGA50.

![NGA50 Line Plot](contig/NGA50_line.png)

#### Conclusions

* The Velour assembly is represented by small contigs

* The Megahit assembly is represented by large contigs in comparison to the other assemblers

## Predicted Unique Genes

**Metric:**

Number of unique genes found by a gene prediction tool.

### Boxplot containing strains, uniq genomes and circular elements

![Predicted Genes Boxplot](contig/predicted_boxplot.png)

