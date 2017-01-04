# Assembly Evaluation

Plots are generated with this tool:

https://github.com/pbelmann/quast-evaluator

1.Analysis for assemblies submitted for [low complexity dataset](low_summary.md)

2.Analysis for assemblies submitted for [medium complexity dataset](medium_summary.md)

3.Analysis for assemblies submitted for [high complexity dataset](high_summary.md)

# Reproducibility

All figures can preduced either by using the script provided in the low, medium or high *scripts* subfolder (using the asm_summary.r scripts) or by
using the [quast-evaluator](https://github.com/pbelmann/quast-evaluator) Tool  (Release [0.1.0](www.github.com/pbelmann/quast-evaluator/releases)) with the *reuse*
Mode and the input files provided in the low, medium, or high *data* subfolder (all the other plots).

* The *combined_plot.tsv* file is a configuration fle that defines for example the upper and lower bound for the line plots used in the publication figures.

* *combined_ref_data.tsv* file is an exported dataframe that is used for quast-evaluator. The columns are described on the QUAST [website](http://quast.bioinf.spbau.ru/manual.html). The only additional column is the "name" column which is the assembler name.

* *ref_data.tsv* file is an exported dataframe that is used for quast-evaluator. The columns are described on the QUAST [website](http://quast.bioinf.spbau.ru/manual.html). The only additional columns are the following:

 * *gid* is an identifier for the reference genome.

 * *refLength* is the length of the reference genome.

 * *refMapping* is the amount of reads mapped to this reference.

 * *group* shows the group based on the ANI score, we destinguish between three groups: (strains (ANI >=95%), uniq genomes (ANI <95%) and circular elements (viruses, plasmids))

 * *assemblerGroup* defines assembler groups. The same assembler executed with different settingsis defined as one group.

 * *assemblerRealName* is the assembler name used in the CAMI publication.

 * *cov* is the coverage information of the reference.

