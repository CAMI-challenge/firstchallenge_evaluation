#!/usr/bin/env python

BINNER_NAME = {1: "MyCC",
               2: "MetaWatt-3.5",
               3: "MetaBAT",
               4: "CONCOCT",
               5: "MaxBin 2.0",
               6: "MEGAN",
               7: "taxator-tk",
               8: "Kraken",
               9: "PhyloPythiaS+"}
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
          "naughty_carson_0": 5,
          "lonely_davinci_1": 6,
          "fervent_sammet_1": 7,
          "prickly_fermi_2": 8,
          "modest_babbage_3": 9,
          "lonely_davinci_0": 6,
          "fervent_sammet_2": 7,
          "prickly_fermi_10": 8,
          "modest_babbage_5": 9,
          "lonely_davinci_7": 6,
          "fervent_sammet_11": 7,
          "prickly_fermi_1": 8,
          "modest_babbage_1": 9}

ASSIGNED_STATS="../metadata/misc/stats_unsupervised.tsv"

def get_binner_name(anonymous_name):
	if anonymous_name not in BINNER:
		if "Gold_Standard" in anonymous_name:
			return "Gold Standard"
		else:
			return None
	else:
		return BINNER_NAME[BINNER[anonymous_name]]

def read_assigned_stats(fname):
	assigned = []
	with open(fname) as assigned_stats:
		for line in assigned_stats:
			tool, ass_seq, total_seq, ass_bp, total_bp = line.strip().split('\t')
			if (tool == "tool"): #header
				continue
			ass_bp = float(ass_bp)
			total_bp = float(total_bp)
			tname = get_binner_name(tool)
			if tname is None:
				continue
			assigned.append((tname,ass_bp/total_bp*100.))
	assigned = sorted(assigned, key=lambda x:x[1], reverse=True)
	return assigned

def average(assigned):
	averaged_dict = {}
	for tool, stat in assigned:
		if tool in averaged_dict:
			averaged_dict[tool].append(stat)
		else:
			averaged_dict[tool] = [stat]
	averaged = []
	for tool in averaged_dict:
		averaged.append((tool, sum(averaged_dict[tool])/len(averaged_dict[tool])))
	averaged = sorted(averaged, key=lambda x: x[1], reverse=True)
	return averaged

assigned = read_assigned_stats(ASSIGNED_STATS)
assigned = average(assigned)
for t in assigned:
	print t
