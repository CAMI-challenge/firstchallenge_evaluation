#!/usr/bin/env python

"""
Script for the generation of a ranking of all the taxa appearing in the CAMI data sets.
Given the result tables of all the tools and the gold standard binning, calculate a table
of all the taxa and their average precision/recall/(prec+rec) generated by all participants
"""

# hard-coded paths to needed tables
HIGH = "../binning/tables/high_supervised_by_bin_all.tsv"
MEDIUM = "../binning/tables/medium_supervised_by_bin_all.tsv"
LOW = "../binning/tables/low_supervised_by_bin_all.tsv"
GSA_HIGH = "../binning/data/taxonomic/adoring_lalande_=_Gold_Standard_0/output/perbin_stats.tsv"
GSA_MEDIUM = "../binning/data/taxonomic/adoring_lalande_=_Gold_Standard_1/output/perbin_stats.tsv" 
GSA_LOW = "../binning/data/taxonomic/determined_meitner_=_Gold_Standard_0/output/perbin_stats.tsv"

# read the gold standard file (in binning/data/taxonomic/<name>/output/perbin_stats.tsv
def read_gold_standard(gsa_path):
	taxa = {}
	with open(gsa_path,'r') as gsa:
		for line in gsa:
			if line.startswith('instance'):
				continue #header
			line_data = line.split('\t')
			rank = line_data[0]
			taxon = line_data[1]
			if 'unassigned' in taxon:
				continue # do not consider unassigned sequences (contains plasmids etc?)
			if rank in taxa:
				taxa[rank].append(taxon) # add taxon class to current taxonomy rank
			else:
				taxa.update({rank:[taxon]})
	return taxa

# the names in the table have a " around them, whyever
def strp(string):
	return string.strip("\"")

# iterates over the results table (in binning/tables/<dataset>_supervised_by_bin_all.tsv) and gets all prec/rec values
def get_prec_rec_per_taxon(gsa_taxa, result_file):
	taxon_prec = {}
	taxon_rec = {}
	tools = set()
	with open(result_file,'r') as res:
		for line in res:
			if line.startswith("\"rank"): #header
				continue
			rank, taxon, prec, rec, predsize, realsize, toolname = map(strp,line.split('\t')) #remove "
			toolname = toolname.rstrip("\"\n")
			if "Gold Standard" in toolname:
				continue
			else:
				tools.update({toolname})
			taxa = gsa_taxa[rank] # retrieve all gsa taxa of current rank
			if taxon in taxa:
				if (taxon,rank) in taxon_prec:
					taxon_prec[(taxon,rank)].append(prec)
					taxon_rec[(taxon,rank)].append(rec)
				else:
					taxon_prec.update({(taxon,rank):[prec]})
					taxon_rec.update({(taxon,rank):[rec]})
	for rank in gsa_taxa:
		for taxon in gsa_taxa[rank]:
			if (taxon,rank) not in taxon_prec:
				taxon_prec.update({(taxon,rank):["NA"]})
				taxon_rec.update({(taxon,rank):[0.]})
	return taxon_prec, taxon_rec, tools

#in case precision is NA
def is_not_na(num):
	try:
		float(num)
		return True
	except:
		return False

def get_taxon_ranking(taxon_prec, taxon_rec):
	taxon_vals = {}
	for (taxon,rank) in taxon_prec:
		prec_non_na = [float(x) for x in taxon_prec[(taxon,rank)] if is_not_na(x)]
		if len(prec_non_na) > 0:
			avg_prec = sum(prec_non_na)/len(prec_non_na)
		else:
			avg_prec = "NA"
		avg_rec = sum(map(float,taxon_rec[(taxon,rank)]))/len(taxon_rec[(taxon,rank)]) #no NA in recall
		if avg_prec != "NA":
			prec_rec = avg_prec + avg_rec
		else:
			prec_rec = avg_rec
		taxon_vals.update({(taxon,rank):[avg_prec,avg_rec,prec_rec,len(prec_non_na)]})
	return taxon_vals

# merge resutls of the data sets, building the average if some taxa appear in multiple data sets
def merge_data_sets(*dicts):
	merged = {}
	for d in dicts: #all dicts
		for elem in d: #all elems
			prec, rec, prec_rec, num = d[elem]
			if elem in merged:
				if prec != "NA":
					merged[elem][0].append(prec)
				merged[elem][3] += num
				merged[elem][1].append(rec)
				merged[elem][2].append(prec_rec)
			else:
				merged[elem] = [[prec],[rec],[prec_rec],num,]
	for elem in merged:
		if "NA" not in merged[elem][0]:
			merged[elem][0] = sum(merged[elem][0])/len(merged[elem][0])
		else:
			merged[elem][0] = "NA"
		merged[elem][1] = sum(merged[elem][1])/len(merged[elem][1])
		merged[elem][2] = sum(merged[elem][2])/len(merged[elem][2])
	return merged

# taken the previous methods, calculate everything for every dataset and merge all the results and gold standards
def calculate_taxon_metrics():
	gsa_low = read_gold_standard(GSA_LOW)
	gsa_medium = read_gold_standard(GSA_MEDIUM)
	gsa_high = read_gold_standard(GSA_HIGH)
	combined_gsa = [gsa_low,gsa_medium,gsa_high]
	low_taxa = get_prec_rec_per_taxon(gsa_low,LOW)
	medium_taxa = get_prec_rec_per_taxon(gsa_medium,MEDIUM)
	high_taxa = get_prec_rec_per_taxon(gsa_high,HIGH)
	tools_low = low_taxa[2]
	tools_medium = medium_taxa[2]
	tools_high = high_taxa[2]
	with open('tools_by_sample.txt','wb') as t:
		t.write(str(list(tools_low)))
		t.write("\n")
		t.write(str(list(tools_medium)))
		t.write("\n")
		t.write(str(list(tools_high)))
	tools = [tools_low,tools_medium,tools_high]
	low_avg = get_taxon_ranking(low_taxa[0],low_taxa[1])
	medium_avg = get_taxon_ranking(medium_taxa[0],medium_taxa[1])
	high_avg = get_taxon_ranking(high_taxa[0],high_taxa[1])
	total_res = merge_data_sets(low_avg,medium_avg,high_avg)
	return total_res, combined_gsa, tools

#take the results and order taxa by rank and write to out
def write_result_table(combined_gsa, res_per_taxon, tools, out):
	complete_gsa = combined_gsa[0].copy()
	complete_gsa.update(combined_gsa[1])
	complete_gsa.update(combined_gsa[2])
	with open(out,'wb') as toWrite:
		toWrite.write("rank\ttaxon\tprecision\trecall\tsum_prec_rec\t#predictions\n")
		line = ""
		ranks = ['superkingdom','phylum','class','order','family','genus','species']
		for rank in ranks:
			for taxon in complete_gsa[rank]:
				prec = res_per_taxon[(taxon,rank)][0]
				rec = res_per_taxon[(taxon,rank)][1]
				prec_rec = res_per_taxon[(taxon,rank)][2]
				num_pred = res_per_taxon[(taxon,rank)][3]
				poss_pred = 0
				for i in [0,1,2]:
					if taxon in combined_gsa[i][rank]:
						poss_pred += len(tools[i]) # how many predictions were possible
				line = rank + '\t' + taxon + '\t' + str(prec) + '\t' + str(rec) + '\t' + str(prec_rec) + '\t' + str(num_pred) + "/" + str(poss_pred) + '\n'
				toWrite.write(line)

res, gsa, tools = calculate_taxon_metrics()
write_result_table(gsa, res, tools, "per_taxon.tsv")
