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