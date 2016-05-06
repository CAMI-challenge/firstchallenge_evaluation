# Summary DRAFT

Before you continue reading this document, please take the following points into account:

  * **At present this draft is based on low complexity dataset !!**

  * **This is just a draft, multiple points noted here must first be further examined**

### Assembler Summary:

| Assembler Anonymous | Group | Algorithms  | scaffolding | # Tools part of the pipeline (i.e. postprocessing tools) |
|---------------------|-------|-------------|-------------|----------------------------------------------------------|
| Gold_Standard_4     | 1     |  -          |    -        |                     -                                    |
| grave_lovelace_0    | 2     |  De Bruijn  |    no       |                     1                                    |                
| fervent_mayer_3     | 3     |  De Bruijn  |    no       |                     5 				     |
| fervent_blackwell_1 | 3     |    De Bruijn  |    no       |                   5 				     | 
| jolly_euclid_1  | 4    |     De Bruijn  |    no       |                       1 				     | 
| serene_shockley_0 broken | 4  |  De Bruijn  |   no      |                     1 				     | 
| jolly_bartik_1  |  4   |   De Bruijn  |    no       |                         1 			             |  
| jolly_torvalds_1 | 4   |  De Bruijn  |    no       |                          1   		             | 
| sad_galileo_0  | 5  |    -   |     -       |                          1                                 |
| clever_hypatia_0  | 5  |  -   |     -        |                          1                                    |
| goofy_tesla_2 |  6   |   -   |  no         |                           2                                |
| adoring_almeida_6 broken  |  7   |  -    |  yes |          2                                                       |
| angry_newton_2  |  8   |    -          |   no   |       2                                                          | 
| dreamy_yonath_2 |  9   |   de bruijn   |    --    |          1                                                         |


##### Remarks

* Assemblies ending with `broken` means that the scaffolded contigs were broken into contigs for further analysis.

### Number of Contigs

**Metric:**

Number of contigs is the total number of contigs in the assembly.

![Genome Fraction](summary_plots/low_coverage_no_points_contig_count.png)

#### Statements

### Genome Fraction


**Metric:**

Genome fraction (%) is the percentage of aligned bases in the reference. A base in the reference is aligned if there is at least one contig with at least one alignment to this base. Contigs from repetitive regions may map to multiple places, and thus may be counted multiple times.

![Genome Fraction](summary_plots/low_coverage_no_points_genome_fraction.png)

#### Statements

### Genome Fraction

**Metric:**

Genome fraction (%) is the percentage of aligned bases in the reference. A base in the reference is aligned if there is at least one contig with at least one alignment to this base. Contigs from repetitive regions may map to multiple places, and thus may be counted multiple times. 

References are grouped by ANI score. References with an ANI score higher then 95 percent are in the group 'strain' and references below 95 percent are in group 'uniq'. 

X-Axis represents ordered reference coverage and is depicted in log scale.

![Genome Fraction](summary_plots/low_coverage_genome_fraction_facet.png)

#### Statements

### Genome Fraction Box Plot

**Metric:**

Genome fraction (%) is the percentage of aligned bases in the reference. A base in the reference is aligned if there is at least one contig with at least one alignment to this base. Contigs from repetitive regions may map to multiple places, and thus may be counted multiple times. 

These boxplots are computed just for the strain references. 

![Genome Fraction Box Plot](summary_plots/low_boxplot_strain.png)

#### Statements
