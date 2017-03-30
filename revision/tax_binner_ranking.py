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
PATH="../binning/tables/%s_supervised_summary_stats_99.tsv" #replace %s with low medium high

def read_table(fname):
	tool_res = {"superkingdom":{},"phylum":{},"class":{},"order":{},"family":{},"genus":{},"species":{}}
	with open(fname,'r') as res:
		for line in res:
			if line.startswith("rank"): #header
				continue
			rank, prec, rec, acc, mis, tool = line.strip().split('\t')
			tool_res[rank].update({tool:[prec,rec,acc,mis]})
	return tool_res

# add all samples/data sets and average, sort tools by ranks
def merge_tools(*tables):
	merged = {}
	for table in tables:
		for rank in table:
			for tool in table[rank]:
				if tool not in BINNER:
					if "Gold_Standard" in tool:
						tname = "Gold Standard"
					else:
						continue
				else:
					tname = BINNER_NAME[BINNER[tool]]
				if tname in merged:
					if rank in merged[tname]:
						merged[tname][rank][0].append(float(table[rank][tool][0])) #prec
						merged[tname][rank][1].append(float(table[rank][tool][1])) #rec
						merged[tname][rank][2].append(float(table[rank][tool][2])) #acc
						merged[tname][rank][3].append(float(table[rank][tool][3])) #mis
					else:
						merged[tname][rank] = [[float(x)] for x in table[rank][tool]]
				else:
					merged[tname] = {rank:[[float(x)] for x in table[rank][tool]]}
	by_rank = {"superkingdom":{},"phylum":{},"class":{},"order":{},"family":{},"genus":{},"species":{}}
	for tool in merged:
		for rank in merged[tool]:
			averages = []
			for metric in merged[tool][rank]:
				averages.append(sum(metric)/len(metric)) # average of current metric
			by_rank[rank].update({tool:averages})
	return by_rank

def create_ranking(by_rank):
	with open("tax_binners_ranking.tsv",'wb') as res:
		for rank in by_rank:
			res.write("%s:\n" % rank)
			sorted_prec = []
			sorted_rec = []
			sorted_prrc = []
			sorted_acc = []
			sorted_mis = []
			for tool in by_rank[rank]:
				prec, rec, acc, mis = by_rank[rank][tool]
				sorted_prec.append((tool,prec))
				sorted_rec.append((tool,rec))
				sorted_prrc.append((tool,prec+rec))
				sorted_acc.append((tool,acc))
				sorted_mis.append((tool,mis))
			sorted_prec = sorted(sorted_prec,key=lambda x:x[1],reverse=True)
			sorted_rec = sorted(sorted_rec,key=lambda x:x[1],reverse=True)
			sorted_prrc = sorted(sorted_prrc,key=lambda x:x[1], reverse=True)
			sorted_acc = sorted(sorted_acc,key=lambda x:x[1],reverse=True) #prec/rec/acc maximised
			sorted_mis = sorted(sorted_mis,key=lambda x:x[1]) #lower misclassification is good
			res.write("Precision:\n")
			for tool in sorted_prec:
				res.write("%s\t%s\n" % (tool[0],tool[1]))
			res.write("\nRecall:\n")
			for tool in sorted_rec:
				res.write("%s\t%s\n" % (tool[0],tool[1]))
			res.write("\nPrecision + Recall:\n")
			for tool in sorted_prrc:
				res.write("%s\t%s\n" % (tool[0],tool[1]))
			res.write("\nAccuracy:\n")
			for tool in sorted_acc:
				res.write("%s\t%s\n" % (tool[0],tool[1]))
			res.write("\nMisclassification rate:\n")
			for tool in sorted_mis:
				res.write("%s\t%s\n" % (tool[0],tool[1]))
			res.write("\n\n")

combined = [read_table(PATH % dataset) for dataset in ["low","medium","high"]]
merged = merge_tools(combined[0],combined[1],combined[2])
create_ranking(merged)
