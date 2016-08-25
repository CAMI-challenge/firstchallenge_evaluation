## Scaffold based assembler analysis

The references in the following plots are grouped by ANI score. 
References with an ANI score higher then 95 percent are in the group 'strain' and references below 95 percent are in group 'uniq'.
Circular elements such as viruses are labeled 'circular_elem'.

## Assemblers

| Assembler      | Group  | # Tools part of the pipeline (i.e. postprocessing tools) |
|----------------|-----|----------|-------|
| Gold_Standard  |  1   |   -   |
| Ray_51_s              |    4   |   1   |
| Ray_71_s              |    4   |   1   |
| Ray_91_s              |    4   |   1   |
| Ray Blacklight        |    4   |   1   |
| Meraga	        |    8   |   1   |  
| OperaMS		|    9   |   2   |

## Overview of combined MetaQuast metrics

**Description**:

These metrics are computed by using all reference genomes in combination.
You can find a description for these metrics on the Quast manual website (http://quast.bioinf.spbau.ru/manual.html).

![parallel](scaffold/parallel.png)

* predicted unique genes are labeled as 'predicted genes'

* mismatches are labeled a mismatches per 100 kbp
 
#### Conclusions

* Meraga produces the most contigs and the longest assembly

* Ray_91_s contains the least contigs and the shortest assembly

* Meraga collects the most misassembly events

* Ray Blacklight has the highest duplication ratio 

* Ray_51_s has the most mismatches

* Meraga reconstructs the most genes 

* Ray_91_s reconstructs the least genes

| name                    | #contigs | Total length | #misassemblies | Unaligned length | Genome fraction | Duplication ratio | #mismatches per 100 kbp | #predicted genes unique | NA50   |
|-------------------------|----------|--------------|------------------|------------------|-----------------|-------------------|-------------------------|-------------------------|--------|
| Gold_Standard           | 39140    | 2795766632   | 0                | 2195             | 98.901          | 1.01              | 0                       | 2351198                 | 249666 |
| Ray_51_s                | 324603   | 746134138    | 1047             | 47643            | 25.634          | 1.04              | 37.57                   | 934145                  | 5111   |
| Ray_71_s                | 115197   | 171698491    | 160              | 4058             | 5.896           | 1.04              | 29.96                   | 244563                  | 1934   |
| Ray_91_s                | 13787    | 12334816     | 11               | 249              | 0.431           | 1.023             | 7.22                    | 21664                   | 889    |
| Ray Blacklight          | 265198   | 407196128    | 379              | 19760            | 13.911          | 1.046             | 27.1                    | 574964                  | 1990   |
| Meraga                  | 745109   | 1811857522   | 2334             | 2592339          | 63.976          | 1.011             | 34.83                   | 2219054                 | 4194   |
| OperaMS                 | 228594   | 373347299    | 430              | 23442            | 12.886          | 1.035             | 33.29                   | 512483                  | 2466   |

## Genome Fraction

**Metric:**

Genome fraction (%) is the percentage of aligned bases in the reference. A base in the reference is aligned if there is at least one contig with at least one alignment to this base. Contigs from repetitive regions may map to multiple places, and thus may be counted multiple times.

### Box Plot containing strains, uniq genomes and circular elements

**Description:**

Each point represents genome fraction for a specific reference sequence. The boxplots show the distribution of the reference genome fraction for each assembler.

![Genome Fraction Box Plot](scaffold/Genome_fraction_boxplot_ref.png)

#### Conclusions

* Meraga performs best 

### Box Plot containing only strains

**Description:**

Each point represents genome fraction for a specific reference sequence. The boxplots show the distribution of the reference genome fraction for each assembler.

![Genome Fraction Box Plot](scaffold/Genome_fraction_boxplot_strain.png)

#### Conclusions

* All assemblers perform bad on strains

* Meraga performs best

### Box Plot containing only uniq genomes

**Description:**

Each point represents genome fraction for a specific reference sequence. The boxplots show the distribution of the reference genome fraction for each assembler.

![Genome Fraction Box Plot](scaffold/Genome_fraction_boxplot_uniq.png)

#### Conclusions

* With the exception of Meraga, all assemblers have a higher genome fraction

### Box Plot containing only circular elements

![Genome Fraction Box Plot](scaffold/Genome_fraction_boxplot_circular_elem.png)

#### Conclusions

* Meraga and Ray_91_s perform well on circular elements

* Ray kmer setting 91 is better then the other kmer settings

### Facet line plot containing strains, uniq genomes and circular elements 

**Description:**

The X-Axis represents the references sorted by their coverage and is depicted in log scale.
The Y-Axis represents the genome fraction.

![Genome Fraction Line Plot](scaffold/Genome_fraction_line.png)

#### Conclusions

* All assemblers have a problem with high coverage

* Ray: The higher the kmer, the less low coverage references are assembled.

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

![Misassemblies per MB Line Plot](scaffold/normalized_misassemblies_per_MB_line.png)

#### Conclusions

* Inspite of the fact that Meraga reconstructs many circular elements (see genome fraction) it contains comparatively less misassemblies

* Ray produces multiple misassembly events for the circular elements

## Duplication ratio

**Metric:**

Duplication ratio is the total number of aligned bases in the assembly divided by the total number of aligned bases in the reference genome (see Genome fraction (%) for the 'aligned base' definition). If the assembly contains many contigs that cover the same regions of the reference, its duplication ratio may be much larger than 1. This may occur due to overestimating repeat multiplicities and due to small overlaps between contigs, among other reasons.

### Facet line plot containing strains, uniq genomes and circular elements

**Description:**

The X-Axis represents the references sorted by their coverage and is depicted in log scale.
The Y-Axis represents the duplication ratio.

![Duplication ratio Line Plot](scaffold/Duplication_ratio.png)

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

![Contigs Line Plot](scaffold/contigs.png)

#### Conclusions

* Ray is using a single kmer approach. The following behaviour can be
  observed:

  * The assembly starts with a low number of contigs. This is because at the beginning there is a very low coverage and thus nearly no overlaps between reads.

  * When there is enough read overlaps the number of contigs starts to rise.

  * Coverage reaches a point where no more but longer contigs can be build, so the line starts to decrease again.

  * This peak is for each assembler different and depends for example on the kmer parameter.

## Mismatches

**Metric:**

Number of mismatches per 100000 aligned bases divided by the assembly length. True SNPs and sequencing errors are not distinguished and are counted equally.

### Boxplot containing strains, uniq genomes and circular elements

![Mismatches Boxplot](scaffold/normalized_mismatches_per_100_kbp_boxplot.png)

## NGA50

**Metric:**

NGA50 are similar to the corresponding NG50 metric without but in this case aligned blocks instead of contigs are considered.
Aligned blocks are obtained by breaking contigs at misassembly events and removing all unaligned bases.

### Line plot containing strains, uniq genomes and circular elements

**Description:**

The X-Axis represents the references sorted by their coverage and is depicted in log scale.
The Y-Axis represents the NGA50.

![NGA50 Line Plot](scaffold/NGA50_line.png)

## Predicted Unique Genes

**Metric:**

Number of unique genes found by a gene prediction tool.

### Boxplot containing strains, uniq genomes and circular elements

![Predicted Genes Boxplot](scaffold/predicted_boxplot.png)

