library(grid)
library(reshape2)
library(ggplot2)
library(gridExtra)
library(scales)

source("parse_raw_result_data.R")
#"\t"

dir.exists <- function(d) {
    de <- file.info(d)$isdir
    ifelse(is.na(de), FALSE, de)
}

separator <- '\t'

gatherdata <- function(file_paths, tools_names)
{
	#print(tools_names)
	#print(file_paths)
	levels <- c("binning")
	#instance,entropy,"rand index","adjusted rand index"
	column_tool <- c()
	column_entropy <- c()
	column_ri <- c()
	column_ari <- c()
	for (index in 1:length(file_paths))
	{
		#print(file_paths[index])
		column_tool <- append(column_tool, rep(tools_names[index], length(levels)))
		raw_data <- read.table(file_paths[index], sep = separator, header=T, row.names=1)
		column_entropy <- append(column_entropy, tail(raw_data$entropy, n=1))
		column_ri <- append(column_ri, tail(raw_data$rand.index, n=1))
		column_ari <- append(column_ari, tail(raw_data$adjusted.rand.index, n=1))
	}
	data_frame <- data.frame(
		entropy = column_entropy,
		ri = column_ri,
		ari = column_ari)
	#data_frame$level = factor(rep(levels, length(file_paths)), levels=levels)
	data_frame$tools <- factor(column_tool)
	melted <- melt(data_frame, "tools")
	melted$variable <- factor(melted$variable)
	colnames(melted) <- c("tool", "metric", "value")
	levels(melted$metric) <- c("Entropy", "Rand index", "Adjusted rand index")
	return(melted)
}


get_names <- function(file_paths)
{
	names <- c()
	for (index in 1:length(file_paths))
	{
		names[index] <- tail(unlist(strsplit(file_paths[index], "[/.]")), n=2)[1]
	}
	names
}



dodge <- position_dodge(width = 0.3)
dodge_big <- position_dodge(width = 0.6)

#############
##
##  PLOTS
##
#############

add_percent <- function(x, ...)
{
	sprintf("%.0f%%", x)
}

title_main <- "Entropy, rand index, adjusted rand index"

# The palette with grey:
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
# The palette with black:
cbbPalette <- c("#000000", "#F0E442", "#E69F00", "#56B4E9", "#009E73", "#0072B2", "#D55E00", "#CC79A7")
my_colours <- rev(cbbPalette)
my_shapes <- c(20, 18)
my_linetype <- rev(c("dotted", "solid")) # "solid", "dashed", "dotted", "dotdash", "twodash", "1F", "F1"


draw_plot <- function(plotdata, title, method_labeller)
{
	#title_main <- "Assigned data" #title
	title_main <- title
	
	
	# The palette with grey:
	cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
	# The palette with black:
	cbbPalette <- c("#000000", "#F0E442", "#E69F00", "#56B4E9", "#009E73", "#0072B2", "#D55E00", "#CC79A7")
	my_colours <- rev(cbbPalette)
	my_shapes <- c(20, 18)
	my_linetype <- rev(c("dotted", "solid")) # "solid", "dashed", "dotted", "dotdash", "twodash", "1F", "F1"
	
	points_size=1.75 
	points_alpha=1
	#points_shape=22
	bars_size=0.75 #1
	bars_alpha=0.75
	point_sizes <- c(1:3)*1.5
	point_sizes <- c(2,3,5)
	#print(head(plotdata))
	#mergedata$percent_seq
	#mergedata$percent_bp
	gg_plot <- ggplot(
			plotdata,
			#aes(x=unsupervised_excluded, y=unsupervised_included, fill=tool, color=tool, shape=dataset, size=dataset), #, fill=dataset, color=tool
			#aes(x=percent_bp, y=percent_seq, fill=tool, color=tool, shape=dataset, size=dataset), #, fill=dataset, color=tool
			#aes(x=unsupervised_excluded, y=percent_seq, fill=tool, color=tool, shape=dataset, size=dataset), #, fill=dataset, color=tool
			aes(x=unsupervised_excluded, y=percent_bp, fill=tool, color=tool, shape=dataset, size=dataset), #, fill=dataset, color=tool
			) +
		geom_hline(yintercept=seq(0, 1, by=0.1), colour="grey80") +
		geom_vline(xintercept=seq(0, 1, by=0.1), colour="grey80") +
		scale_x_continuous(labels=percent, limits=c(0.0, 1), breaks=seq(0,1, 0.2), expand = c( 0.01 , 0.01 )) + #labels=percent, 
		scale_y_continuous(labels=percent, limits=c(0, 1), breaks=seq(0,1, 0.2), expand = c( 0.01 , 0.01 )) + #labels=percent, 
		scale_color_discrete(labels = method_labeller) +
		scale_fill_discrete(labels = method_labeller) +
		scale_shape_manual(values=c(21,24,23)) +
		scale_size_manual(values=point_sizes) +
		geom_point(
			#aes(color=tool, fill=tool), #, size=3, 
			stroke = 0.5, alpha=points_alpha, color="black") + #size=points_size, , shape=points_shape, color="black"
		# labs(title=title_main, fill="Tool", colour="Tool", shape="Dataset", size="Dataset", x="Percent of assigned base pairs", y="Percent of assigned Sequences") + #, linetype="Tool"
		#labs(title=title_main, fill="Tool", colour="Tool", shape="Dataset", size="Dataset", x="Adjusted Rand Index", y="Percent of assigned Sequences") + #, linetype="Tool"
		labs(title=title_main, fill="Tool", colour="Tool", shape="Dataset", size="Dataset", x="Adjusted Rand Index", y="Percent of assigned base pairs") + #, linetype="Tool"
		#labs(title=title_main, fill="Tool", colour="Tool", shape="Dataset", size="Dataset", x="Purity", y="Percent of assigned Sequences") + #, linetype="Tool"
		guides(fill = guide_legend(override.aes = list(shape = 21, size=3))) +
		theme(axis.text.x = element_text(angle = 45, hjust = 1), strip.background = element_rect(fill = "light blue")) # , vjust	0.5
	return(gg_plot)
}
#######################################

argv <- commandArgs(TRUE)
root_path <- argv[1]
output_file <- argv[2]

merge_names <- function(vec_of_string)
{
	pattern = c("CONCOCT.*", "taxator-tk.*")
	replace = c("CONCOCT", "taxator-tk")
	for (index in 1:length(pattern)){
		vec_of_string <- gsub(pattern[index], replace[index], vec_of_string)}
	return(vec_of_string)
}


df_tools <- get_dataframe_of_tools_at_locations(root_path)
#df_tools$anonymous <- factor(gsub("_[0-9]*$", "", df_tools$anonymous))

method_labels <- df_tools$method
method_labels <- gsub("[()]", "", method_labels)
method_labels <- merge_names(method_labels)
#names(method_labels) <- df_tools$anonymous
names(method_labels) <- gsub("_[0-9]*$", "", df_tools$anonymous)
labeller <- function(variables)
{
	rvalue <- strtrim(method_labels[variables], 17)
	return(rvalue)
}
method_labeller <- as_labeller(labeller)

get_dataframe <- function(df_tools_subset, value)
{
	df_tools_low <- subset(df_tools_subset, dataset=="1st CAMI Challenge Dataset 1 CAMI_low")
	df_tools_medium <- subset(df_tools_subset, dataset=="1st CAMI Challenge Dataset 2 CAMI_medium")
	df_tools_high <- subset(df_tools_subset, dataset=="1st CAMI Challenge Dataset 3 CAMI_high")

	#######################################

	if (length(df_tools_low$file)>0)
	{
		data_low <- gatherdata(
		  as.vector(df_tools_low$file), as.vector(df_tools_low$anonymous))
		data_low$dataset <- "low"
	}
	if (length(df_tools_medium$file)>0)
	{
		data_medium <- gatherdata(
		  as.vector(df_tools_medium$file), as.vector(df_tools_medium$anonymous))
		data_medium$dataset <- "medium"
	}
	if (length(df_tools_high$file)>0)
	{
		data_high <- gatherdata(
		  as.vector(df_tools_high$file), as.vector(df_tools_high$anonymous))
		data_high$dataset <- "high"
	}
	rdata <- rbind(data_low, data_medium, data_high)
	colnames(rdata) <- c("binner", "metric", value, "dataset")
	return(rdata)
}
#######################################

#######################################
file_path_stats <- file.path("..", "..", "metadata", "misc", "stats_unsupervised.tsv")
raw_data <- read.table(file_path_stats, sep = separator, header=T)
colnames(raw_data) <- c("binner", "qsn", "gsn", "qbp", "gbp")
#######################################


value <- "unsupervised_included"
df1 <- get_dataframe(subset(df_tools, datatype==value), value)
value <- "unsupervised_excluded"
df2 <- get_dataframe(subset(df_tools, datatype==value), value)
mergedata <- merge(df1, df2, by=c("binner", "metric", "dataset"))
mergedata$tool <- factor(gsub("_[0-9]*$", "", mergedata$binner))

#setdiff(mergedata$binner, raw_data$binner)

mergedata <- merge(mergedata, raw_data, by="binner")
mergedata$binner <- NULL
mergedata$percent_seq <- mergedata$qsn / as.double(mergedata$gsn)
mergedata$percent_bp <- mergedata$qbp / as.double(mergedata$gbp)
mergedata <- subset(mergedata, metric == "Adjusted rand index")

mergedata$dataset <- factor(
	mergedata$dataset,
	levels=c('low','medium','high'),
	labels=c('low','medium','high')
	)
#mergedata$inc_exc <- mergedata$unsupervised_included + mergedata$unsupervised_excluded
#maxs <-aggregate(inc_exc ~ tool + dataset, data=mergedata, FUN=max, na.rm=TRUE)
maxs <-aggregate(unsupervised_excluded ~ tool + dataset, data=mergedata, FUN=max, na.rm=TRUE)
mergemaxdata <- merge(maxs, mergedata)


gplot <- draw_plot(mergemaxdata, "Adjusted Rand Index\n", method_labeller)

#output <- marrangeGrob(ggplots, nrow=1, ncol=1, top=NULL)
ggsave(output_file, gplot, width=297, height=210, units='mm')#, device="pdf"
#######################################

