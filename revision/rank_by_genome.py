#!/usr/bin/python

import collections
import numpy as np

EXCLUDE_PLASMIDS = True
FILTER_TAIL = True
BINNER_NAME = {1: "MyCC",
               2: "MetaWatt-3.5",
               3: "MetaBAT",
               4: "CONCOCT",
               5: "MaxBin 2.0"}
BINNER = {"berserk_euclid_2": 1,
          "berserk_hypatia_2": 2,
          "elated_franklin_13": 3,
          "goofy_hypatia_10": 4,
          "naughty_carson_2": 5,
          "berserk_euclid_1": 1,
          "berserk_hypatia_1": 2,
          "elated_franklin_12": 3,
          "goofy_hypatia_11": 4,
          "naughty_carson_1": 5,
          "berserk_euclid_0": 1,
          "berserk_hypatia_0": 2,
          "elated_franklin_11": 3,
          "goofy_hypatia_12": 4,
          "naughty_carson_0": 5}


def read_rows(input_stream):
    for line in input_stream:
        if len(line.strip()) == 0 or line.startswith("#") or line.startswith("\"rank\""):
            continue
        line = line.rstrip('\n')
        row_data = line.split('\t')
        yield row_data


def load_unique_common(unique_common_file_path):
    genome_to_unique_common = {}
    with open(unique_common_file_path) as read_handler:
        for line in read_handler:
            genome_to_unique_common[line.split("\t")[0]] = line.split("\t")[1].strip('\n')
    return genome_to_unique_common


def load_data(file_path, genome_to_unique_common):
    binner_to_data = {}
    with open(file_path) as read_handler:
        for row_data in read_rows(read_handler):
            bin = row_data[1].strip("\"")
            if EXCLUDE_PLASMIDS and \
                            bin in genome_to_unique_common and \
                            genome_to_unique_common[bin] == "circular element":
                continue
            binner = row_data[6].strip("\"")
            if binner not in BINNER:
                continue
            if binner not in binner_to_data:
                binner_to_data[binner] = []

            predicted_size = int(row_data[4])

            if row_data[2] != "NA" and predicted_size > 0:
                precision = float(row_data[2])
            else:
                precision = np.nan
            binner_to_data[binner].append({'bin': bin, 'precision': precision, 'recall': row_data[3],
                                           'predicted_size': predicted_size, 'real_size': row_data[5]})
    read_handler.close()
    return binner_to_data


def filter_tail(binner_to_data):
    for binner in binner_to_data:
        # for each binner, sort bins by increasing predicted size
        binner_to_data[binner] = sorted(binner_to_data[binner], key=lambda x: x['predicted_size'])
        sum_of_predicted_sizes = sum([int(float(bin['predicted_size'])) for bin in binner_to_data[binner]])
        cumsum_of_predicted_sizes = 0
        for bin in binner_to_data[binner]:
            predicted_size = int(float(bin['predicted_size']))
            cumsum_of_predicted_sizes += predicted_size
            if float(cumsum_of_predicted_sizes) / float(sum_of_predicted_sizes) <= .01:
                bin['precision'] = np.nan
            else:
                break
    return binner_to_data


def rank(file_path, genome_to_unique_common):
    binner_to_avgprecision = {}
    binner_to_avgrecall = {}
    binner_to_count_r = {}
    binner_to_count_p = {}

    # load data per binner
    binner_to_data = load_data(file_path, genome_to_unique_common)

    if FILTER_TAIL:
        binner_to_data = filter_tail(binner_to_data)

    for binner in binner_to_data:
        # for each predicted bin (row of the table)
        for bin in binner_to_data[binner]:

            # compute, for binner, the average recall over all its bins if the mapped genome size > 0
            real_size = float(bin['real_size'])
            if real_size > 0:
                recall = float(bin['recall'])
                if binner not in binner_to_avgrecall:
                    binner_to_avgrecall[binner] = .0
                    binner_to_count_r[binner] = 0
                binner_to_count_r[binner] += 1
                current_avg = binner_to_avgrecall[binner]
                binner_to_avgrecall[binner] = (recall - current_avg) / binner_to_count_r[binner] + current_avg

            # compute, for binner, the average precision over its bins
            if not np.isnan(bin['precision']):
                precision = bin['precision']
                if binner not in binner_to_avgprecision:
                    binner_to_avgprecision[binner] = .0
                    binner_to_count_p[binner] = 0
                binner_to_count_p[binner] += 1
                current_avg = binner_to_avgprecision[binner]
                binner_to_avgprecision[binner] = (precision - current_avg) / binner_to_count_p[binner] + current_avg
    return binner_to_avgprecision, binner_to_avgrecall


def print_precision_and_recall(binner_number_to_avgprecision, binner_number_to_avgrecall):
    print "Precision"
    # sort binners by average precision
    binner_number_to_avgprecision = collections.OrderedDict(sorted(binner_number_to_avgprecision.items(), key=lambda t: t[1], reverse=True))
    for binner_number in binner_number_to_avgprecision:
        print "%s \t %1.3f" % (BINNER_NAME[binner_number], binner_number_to_avgprecision[binner_number])
    print

    print "Recall"
    # sort binners by average recall
    binner_number_to_avgrecall = collections.OrderedDict(sorted(binner_number_to_avgrecall.items(), key=lambda t: t[1], reverse=True))
    for binner_number in binner_number_to_avgrecall:
        print "%s \t %1.3f" % (BINNER_NAME[binner_number], binner_number_to_avgrecall[binner_number])
    print

    print "Precision + Recall"
    binner_number_to_precisionrecall = {}
    for binner_number in binner_number_to_avgprecision:
        binner_number_to_precisionrecall[binner_number] = binner_number_to_avgprecision[binner_number] + binner_number_to_avgrecall[binner_number]
    # sort binners by averaged sum of precision and recall
    binner_number_to_precisionrecall = collections.OrderedDict(sorted(binner_number_to_precisionrecall.items(), key=lambda t: t[1], reverse=True))
    for binner_number in binner_number_to_precisionrecall:
        print "%s \t %1.3f" % (BINNER_NAME[binner_number], binner_number_to_precisionrecall[binner_number])


def main(unique_common_file_path, *files_path):
    binner_number_to_list_avgprecision = {}
    binner_number_to_list_avgrecall = {}
    genome_to_unique_common = load_unique_common(unique_common_file_path)

    for file in files_path:
        binner_to_avgprecision, binner_to_avgrecall = rank(file, genome_to_unique_common)
        for binner in binner_to_avgprecision:
            binner_number = BINNER[binner]
            if binner_number not in binner_number_to_list_avgprecision:
                binner_number_to_list_avgprecision[binner_number] = []
            binner_number_to_list_avgprecision[binner_number].append(binner_to_avgprecision[binner])
        for binner in binner_to_avgrecall:
            binner_number = BINNER[binner]
            if binner_number not in binner_number_to_list_avgrecall:
                binner_number_to_list_avgrecall[binner_number] = []
            binner_number_to_list_avgrecall[binner_number].append(binner_to_avgrecall[binner])

    binner_number_to_avgprecision = {}
    binner_number_to_avgrecall = {}
    for binner_number in binner_number_to_list_avgprecision:
        binner_number_to_avgprecision[binner_number] = sum(binner_number_to_list_avgprecision[binner_number]) / len(binner_number_to_list_avgprecision[binner_number])
    for binner_number in binner_number_to_list_avgrecall:
        binner_number_to_avgrecall[binner_number] = sum(binner_number_to_list_avgrecall[binner_number]) / len(binner_number_to_list_avgrecall[binner_number])
    print_precision_and_recall(binner_number_to_avgprecision, binner_number_to_avgrecall)


main("../metadata/ANI/unique_common.tsv",
     "../binning/tables/low_unsupervised_by_genome_all.tsv",
     "../binning/tables/medium_unsupervised_by_genome_all.tsv",
     "../binning/tables/high_unsupervised_by_genome_all.tsv")
