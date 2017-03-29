#!/usr/bin/env python

import os
import StringIO
try:
	import configparser
except ImportError:
	import ConfigParser as configparser

"""
Creates a table from all summary_stats_99 files from the taxonomic binners' results
"""

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
PATH="../binning/data/taxonomic/"
OUT="../binning/tables/%s_supervised_summary_stats_99.tsv"
DATASETS={"1st CAMI Challenge Dataset 1 CAMI_low":"low",
		"1st CAMI Challenge Dataset 2 CAMI_medium":"medium",
		"1st CAMI Challenge Dataset 3 CAMI_high":"high"}

def create_table(path):
	by_sample = {} # sort for low/medium/high
	for folder in os.listdir(path):
		description = path + folder + "/description.properties"
		with open(description,'r') as desc:
			config = StringIO.StringIO()
			config.write('[dummy]\n') # dummy header (.properties -> .INI)
			config.write(desc.read())
			config.seek(0, os.SEEK_SET)
			cparse = configparser.SafeConfigParser()
			cparse.readfp(config)
			dataset = cparse.get('dummy','pool_name')
			by_sample[folder] = dataset
	toWrite = "rank\tprecision\trecall\taccuracy\tmisclassification rate\ttool\n"
	for ds in ["low","medium","high"]:
		fname = OUT % ds
		with open(fname,'wb') as res:
			res.write(toWrite)
	for folder in os.listdir(path):
		dataset = DATASETS[by_sample[folder]]
		summary_stats = path + folder + "/output/summary_stats_99.tsv"
		out = OUT % dataset
		with open(summary_stats,'r') as stat:
			toWrite = ""
			for line in stat:
				if line.startswith("rank"):
					continue
				splt = line.strip().split('\t')
				toWrite += "%s\t%s\t%s\t%s\t%s\t%s\n" % (splt[0],splt[1],splt[4],splt[7],splt[8],folder)
			with open(out,'a') as res:
				res.write(toWrite)

create_table(PATH)
