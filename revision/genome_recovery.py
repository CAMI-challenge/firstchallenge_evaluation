#!/usr/bin/python

from operator import add

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

HIGH = "../binning/tables/high_unsupervised_by_genome_all.tsv"
MEDIUM = "../binning/tables/medium_unsupervised_by_genome_all.tsv"
LOW = "../binning/tables/low_unsupervised_by_genome_all.tsv"


def strp(string):
	return string.strip("\"")

def read_table(result_file):
	tools = {}
	with open(result_file,'r') as res:
		for line in res:
			rank, taxon, prec, rec, predsize, realsize, tool = map(strp,line.split('\t'))
			tool = tool.rstrip("\"\n")
			if (rank == "rank"): #header
				continue
			if tool not in tools:
				tools[tool] = [[],[],[],[]] # prec rec predsize realsize
			try:
				tools[tool][0].append(float(prec))
				tools[tool][1].append(float(rec))
			except:
				continue # if precision is NA, the genome cannot end up anywhere in the table
			tools[tool][2].append(int(predsize))
			tools[tool][3].append(int(realsize))
	return tools 

def filter_tail(tools):
	for tool in tools:
		tools[tool][2] = sorted(tools[tool][2],reverse=True) #sort descending
		s = float(sum(tools[tool][2]))
		cs = 0
		i = 0
		for size in tools[tool][2]:
			cs += size
			i += 1
			if cs/s > .99:
				for j in xrange(len(tools[tool])):
					tools[tool][j] = tools[tool][j][0:i]
				break
	return tools

def calc_table(tools):
	genome_recovery = {}
	for tool in tools:
		if tool not in genome_recovery:
			genome_recovery[tool] = [0,0,0,0,0,0] #>0.9/<0.05 | >0.9/<0.1 | >0.7/<0.05 | >0.7/<0.1 | >0.5/<0.05 | >0.5/<0.1
		for i in xrange(len(tools[tool][0])):
			prec = tools[tool][0][i]
			rec = tools[tool][1][i]
			if (float(rec) > 0.9):
				if (float(prec) > 0.95):
					genome_recovery[tool][0] += 1
				if (float(prec) > 0.9):
					genome_recovery[tool][1] += 1
			if (float(rec) > 0.7):
				if (float(prec) > 0.95):
					genome_recovery[tool][2] += 1
				if (float(prec) > 0.9):
					genome_recovery[tool][3] += 1
			if (float(rec) > 0.5):
				if (float(prec) > 0.95):
					genome_recovery[tool][4] += 1
				if (float(prec) > 0.9):
					genome_recovery[tool][5] += 1
	return genome_recovery

# map low/med/high to one table
def map_tools(*tools):
	merged = {}
	for res in tools:
		for tool in res:
			if "Gold Standard" in tool:
				mapped = "Gold Standard"
			elif tool not in BINNER:
				continue
			else:
				mapped = str(BINNER[tool])
			if mapped in merged:
				map(add,merged[mapped],res[tool])
			else:
				merged[mapped] = res[tool]
	corr_names = {BINNER_NAME[int(x)]:merged[x] for x in merged if "Gold Standard" not in x} #map to real tool names
	corr_names.update({"Gold Standard":merged["Gold Standard"]})
	return corr_names

def print_table(tools):
	with open("binner_completeness.tsv",'wb') as toWrite:
		for tool in tools:
			line = "%s\t>50%% complete\t>70%% complete\t>90%% complete\n" % tool
			toWrite.write(line)
			line = "<10%% contamination\t%s\t%s\t%s\n" % (tools[tool][5],tools[tool][3],tools[tool][1])
			toWrite.write(line)
			line = "<5%% contamination\t%s\t%s\t%s\n" % (tools[tool][4],tools[tool][2],tools[tool][0])
			toWrite.write(line)


tools_high = read_table(HIGH)
tools_medium = read_table(MEDIUM)
tools_low = read_table(LOW)

tools_high = filter_tail(tools_high)
tools_medium = filter_tail(tools_medium)
tools_low = filter_tail(tools_low)

res_high = calc_table(tools_high)
res_medium = calc_table(tools_medium)
res_low = calc_table(tools_low)

merged = map_tools(res_high, res_medium, res_low)
print_table(merged)
