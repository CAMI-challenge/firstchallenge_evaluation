#! /bin/bash

set -o errexit
set -o nounset

echo "#### unsupervised_ari ####"
Rscript unsupervised_ari.r data/unsupervised/ plots/unsupervised/unsupervised_ari_including_notassigned_all.pdf
Rscript unsupervised_ari.r data/unsupervised/ plots/unsupervised/unsupervised_ari_excluding_notassigned_all.pdf 1

echo "#### unsupervised_ari_by_category novelty ####"
Rscript unsupervised_ari_by_category.r data/unsupervised_novelty/ plots/unsupervised/unsupervised_ari_including_notassigned_novelty.pdf 
Rscript unsupervised_ari_by_category.r data/unsupervised_novelty/ plots/unsupervised/unsupervised_ari_excluding_notassigned_novelty.pdf 1

echo "#### unsupervised_ari_by_category uniqueness ####"
Rscript unsupervised_ari_by_category.r data/unsupervised_uniqueness/ plots/unsupervised/unsupervised_ari_including_notassigned_uniqueness.pdf 
Rscript unsupervised_ari_by_category.r data/unsupervised_uniqueness/ plots/unsupervised/unsupervised_ari_excluding_notassigned_uniqueness.pdf 1



echo "#### supervised_macro_precision ####"
Rscript supervised_macro_precision.r data/taxonomic/ plots/supervised/supervised_summary_all.pdf

echo "#### supervised_absolute_count_relative ####"
Rscript supervised_absolute_count_relative.r data/taxonomic/ plots/supervised/supervised_bp_count_relative_all.pdf

echo "#### supervised_absolute_count_absoulte ####"
Rscript supervised_absolute_count_absoulte.r data/taxonomic/ plots/supervised/supervised_bp_count_absolute_all.pdf

echo "#### supervised_ari ####"
Rscript supervised_ari.r data/taxonomic/ plots/supervised/supervised_ari_including_notassigned_all.pdf
Rscript supervised_ari.r data/taxonomic/ plots/supervised/supervised_ari_excluding_notassigned_all.pdf 1

echo "#### supervised_ari_by_category novelty ####"
Rscript supervised_ari_by_category.r data/taxonomic_novelty/ plots/supervised/supervised_ari_including_notassigned_novelty.pdf
Rscript supervised_ari_by_category.r data/taxonomic_novelty/ plots/supervised/supervised_ari_excluding_notassigned_novelty.pdf 1

echo "#### supervised_ari_by_category uniqueness ####"
Rscript supervised_ari_by_category.r data/taxonomic_uniqueness/ plots/supervised/supervised_ari_including_notassigned_uniqueness.pdf
Rscript supervised_ari_by_category.r data/taxonomic_uniqueness/ plots/supervised/supervised_ari_excluding_notassigned_uniqueness.pdf 1



