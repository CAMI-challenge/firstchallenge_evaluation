#! /bin/bash

#device="_%01d.png"
device=".pdf"

set -o errexit
set -o nounset

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}"
BINNING_DIR="${SCRIPT_DIR}/../"

echo "#### Concatinate by genome tables ####"
Rscript "${SCRIPT_DIR}/table_concatinate.r" "${BINNING_DIR}"

echo "#### Make average prec rec plots ####"
Rscript "${SCRIPT_DIR}/average_prec_rec_plots.r"

rm "${SCRIPT_DIR}/Rplots.pdf"

echo "#### unsupervised_precision_recall ####"
Rscript "${SCRIPT_DIR}/unsupervised_precision_recall.r" "${BINNING_DIR}/data/unsupervised/" "${BINNING_DIR}/plots/unsupervised/unsupervised_precision_recall${device}"

echo "#### unsupervised_ari ####"
Rscript "${SCRIPT_DIR}/unsupervised_ari.r" "${BINNING_DIR}/data/unsupervised/" "${BINNING_DIR}/plots/unsupervised/unsupervised_ari_including_notassigned_all${device}"
Rscript "${SCRIPT_DIR}/unsupervised_ari.r" "${BINNING_DIR}/data/unsupervised/" "${BINNING_DIR}/plots/unsupervised/unsupervised_ari_excluding_notassigned_all${device}" 1

echo "#### unsupervised_ari_by_category novelty ####"
Rscript "${SCRIPT_DIR}/unsupervised_ari_by_category.r" "${BINNING_DIR}/data/unsupervised_novelty/" "${BINNING_DIR}/plots/unsupervised/unsupervised_ari_including_notassigned_novelty${device}" 
Rscript "${SCRIPT_DIR}/unsupervised_ari_by_category.r" "${BINNING_DIR}/data/unsupervised_novelty/" "${BINNING_DIR}/plots/unsupervised/unsupervised_ari_excluding_notassigned_novelty${device}" 1

echo "#### unsupervised_ari_by_category uniqueness ####"
Rscript "${SCRIPT_DIR}/unsupervised_ari_by_category.r" "${BINNING_DIR}/data/unsupervised_uniqueness/" "${BINNING_DIR}/plots/unsupervised/unsupervised_ari_including_notassigned_uniqueness${device}" 
Rscript "${SCRIPT_DIR}/unsupervised_ari_by_category.r" "${BINNING_DIR}/data/unsupervised_uniqueness/" "${BINNING_DIR}/plots/unsupervised/unsupervised_ari_excluding_notassigned_uniqueness${device}" 1



echo "#### supervised_macro_precision ####"
Rscript "${SCRIPT_DIR}/supervised_macro_precision.r" "${BINNING_DIR}/data/taxonomic/" "${BINNING_DIR}/plots/supervised/supervised_summary_all${device}"
Rscript "${SCRIPT_DIR}/supervised_macro_precision.r" "${BINNING_DIR}/data/taxonomic/" "${BINNING_DIR}/plots/supervised/supervised_summary_all_99${device}" 1

echo "#### supervised_absolute_count_relative ####"
Rscript "${SCRIPT_DIR}/supervised_absolute_count_relative.r" "${BINNING_DIR}/data/taxonomic/" "${BINNING_DIR}/plots/supervised/supervised_bp_count_relative_all${device}"

echo "#### supervised_absolute_count_absoulte ####"
Rscript "${SCRIPT_DIR}/supervised_absolute_count_absoulte.r" "${BINNING_DIR}/data/taxonomic/" "${BINNING_DIR}/plots/supervised/supervised_bp_count_absolute_all${device}"

echo "#### supervised_ari ####"
Rscript "${SCRIPT_DIR}/supervised_ari.r" "${BINNING_DIR}/data/taxonomic/" "${BINNING_DIR}/plots/supervised/supervised_ari_including_notassigned_all${device}"
Rscript "${SCRIPT_DIR}/supervised_ari.r" "${BINNING_DIR}/data/taxonomic/" "${BINNING_DIR}/plots/supervised/supervised_ari_excluding_notassigned_all${device}" 1

echo "#### supervised_ari_by_category novelty ####"
Rscript "${SCRIPT_DIR}/supervised_ari_by_category.r" "${BINNING_DIR}/data/taxonomic_novelty/" "${BINNING_DIR}/plots/supervised/supervised_ari_including_notassigned_novelty${device}"
Rscript "${SCRIPT_DIR}/supervised_ari_by_category.r" "${BINNING_DIR}/data/taxonomic_novelty/" "${BINNING_DIR}/plots/supervised/supervised_ari_excluding_notassigned_novelty${device}" 1

echo "#### supervised_ari_by_category uniqueness ####"
Rscript "${SCRIPT_DIR}/supervised_ari_by_category.r" "${BINNING_DIR}/data/taxonomic_uniqueness/" "${BINNING_DIR}/plots/supervised/supervised_ari_including_notassigned_uniqueness${device}"
Rscript "${SCRIPT_DIR}/supervised_ari_by_category.r" "${BINNING_DIR}/data/taxonomic_uniqueness/" "${BINNING_DIR}/plots/supervised/supervised_ari_excluding_notassigned_uniqueness${device}" 1

