#!/usr/bin/python

import collections


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


def load_data(file_path, unique_common_file_path):
    genome_to_unique_common = load_unique_common(unique_common_file_path)
    binner_to_data = {}
    with open(file_path) as read_handler:
        for row_data in read_rows(read_handler):
            bin = row_data[1].strip("\"")
            if bin in genome_to_unique_common and genome_to_unique_common[bin] == "circular element":
                continue
            binner = row_data[6].strip("\"")
            if binner == "goofy_hypatia_0" or binner == "elated_franklin_10":
                continue
            if binner not in binner_to_data:
                binner_to_data[binner] = []
            binner_to_data[binner].append({'bin': bin, 'precision': row_data[2], 'recall': row_data[3],
                                           'predicted_size': row_data[4], 'real_size': row_data[5]})
    read_handler.close()
    return binner_to_data


def load_anonymous_names_mapping(name_mapping_file_path):
    anonymous_name_to_name = {}
    with open(name_mapping_file_path) as read_handler:
        for line in read_handler:
            anonymous_name_to_name[line.split(",")[0]] = line.split(",")[1].strip('\n')
    # anonymous_name_to_name["elated_franklin_10"] = "MetaBAT"
    anonymous_name_to_name["elated_franklin_11"] = "MetaBAT"
    anonymous_name_to_name["goofy_hypatia_12"] = "CONCOCT"
    return anonymous_name_to_name


def binner_name(binner):
    if binner in anonymous_name_to_name:
        return anonymous_name_to_name[binner]
    else:
        return binner


def rank(file_path, unique_common_file_path):
    binner_to_avgprecision = {}
    binner_to_avgrecall = {}
    binner_to_count_r = {}
    binner_to_count_p = {}

    # load data per binner, except circular elements
    binner_to_data = load_data(file_path, unique_common_file_path)

    genome_to_unique_common = load_unique_common(unique_common_file_path)

    for binner in binner_to_data:
        # for each binner, sort bins by decreasing predicted size
        binner_to_data[binner] = sorted(binner_to_data[binner], key=lambda x: x['predicted_size'], reverse=True)

        sum_of_predicted_sizes = sum([int(float(bin['predicted_size'])) for bin in binner_to_data[binner]])
        cumsum_of_predicted_sizes = 0

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

            # compute, for binner, the average precision over its bins until their cumulated predicted sizes reach 99% of the sum of all predicted sizes (i.e. ignore the smallest 1%)

            # if bin['bin'] in genome_to_unique_common and genome_to_unique_common[bin['bin']] == "circular element":
            #     continue

            predicted_size = int(float(bin['predicted_size']))
            cumsum_of_predicted_sizes += predicted_size
            if predicted_size > 0 and float(cumsum_of_predicted_sizes) / float(sum_of_predicted_sizes) <= .99:
                precision = float(bin['precision'])
                if binner not in binner_to_avgprecision:
                    binner_to_avgprecision[binner] = .0
                    binner_to_count_p[binner] = 0
                binner_to_count_p[binner] += 1
                current_avg = binner_to_avgprecision[binner]
                binner_to_avgprecision[binner] = (precision - current_avg) / binner_to_count_p[binner] + current_avg

    print "Precision"
    # sort binners by average precision
    binner_to_avgprecision = collections.OrderedDict(sorted(binner_to_avgprecision.items(), key=lambda t: t[1], reverse=True))
    for binner in binner_to_avgprecision:
        print binner_name(binner) + " -> " + str(binner_to_avgprecision[binner])
    print

    print "Recall"
    # sort binners by average recall
    binner_to_avgrecall = collections.OrderedDict(sorted(binner_to_avgrecall.items(), key=lambda t: t[1], reverse=True))
    for binner in binner_to_avgrecall:
        print binner_name(binner) + " -> " + str(binner_to_avgrecall[binner])
    print

    print "Precision + Recall"
    binner_to_precisionrecall = {}
    for binner in binner_to_avgprecision:
        binner_to_precisionrecall[binner] = binner_to_avgprecision[binner] + binner_to_avgrecall[binner]
    # sort binners by averaged sum of precision and recall
    binner_to_precisionrecall = collections.OrderedDict(sorted(binner_to_precisionrecall.items(), key=lambda t: t[1], reverse=True))
    for binner in binner_to_precisionrecall:
        print binner_name(binner) + " -> " + str(binner_to_precisionrecall[binner])


anonymous_name_to_name = load_anonymous_names_mapping(name_mapping_file_path="../binning/binnings.csv")
rank(file_path="../binning/tables/high_unsupervised_by_genome_all.tsv",
     unique_common_file_path="../metadata/ANI/unique_common.tsv")
