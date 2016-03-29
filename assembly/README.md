# Quast Evaluation

Plots were generated with this tool:

https://github.com/pbelmann/quast-evaluator

### Plots:

* abundance* :

   * x-axis: References are sorted by abundance.

   * References with more then 95% identity (ANI) are represented by the same symbol
   * Lines represent assemblies

* boxplots_groups*: 

   * x-axis: Groups represent strains with more then 95% identity.

* boxplots_assemblers_strain.pdf:

   * y-axis: Assemblers

   * boxplots are generated for references with more then 95% identity (ANI)

* boxplots_assemblers_uniq.pdf:

   * y-axis: Assemblers

   * boxplots are generated for references with less then 95% identity (ANI)

* coverage* :

   * x-axis: References are sorted by coverage.

   * References with more then 95% identity (ANI) are represented by the same symbol
   * Lines represent assemblies


* coverage-facet_multiple_smooth_log.pdf:
 
   * x-axis: References are sorted by coverage on log scale 

   * References with more then 95% identity (ANI) are represented by the same symbol
    
   * 1 regression line is calculated using references with more then 95 % identity (ANI) and the other line is calculated using references with less then 95 % identity (ANI)

* barplot.pdf:

   * x-axis: Bins for references with more then 95 % identity (ANI).

### Data:

* combined_ref_data.tsv: Quast Evaluation per Assembly

* ref_data.tsv: Quast Evaluation per Assembly for each reference

