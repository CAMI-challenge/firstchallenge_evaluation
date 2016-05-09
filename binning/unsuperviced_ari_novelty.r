library(grid)
library(reshape2)
library(ggplot2)
require(gridExtra)
library(scales)

#"\t"

dir.exists <- function(d) {
    de <- file.info(d)$isdir
    ifelse(is.na(de), FALSE, de)
}

gatherdata <- function(file_paths, tools_names)
{
	#print(tools_names)
	separator <- '\t'
	#print(file_paths)
	levels <- c("binning")
	# ﻿instance,entropy,"rand index","adjusted rand index"
	column_tool <- c()
	column_entropy <- c()
	column_ri <- c()
	column_ari <- c()
	for (index in 1:length(file_paths))
	{
		print(file_paths[index])
		column_tool <- append(column_tool, rep(tools_names[index], length(levels)))
		raw_data <- read.table(file_paths[index], sep = separator, header=T, row.names=1)
		column_entropy <- append(column_entropy, raw_data$entropy)
		column_ri <- append(column_ri, raw_data$rand.index)
		column_ari <- append(column_ari, raw_data$adjusted.rand.index)
	}
	data_frame <- data.frame(
		entropy = column_entropy,
		ri = column_ri,
		ari = column_ari)
	#data_frame$level = factor(rep(levels, length(file_paths)), levels=levels)
	data_frame$tools <- factor(column_tool)
	melted <- melt(data_frame, "tools")
	melted$variable <- factor(melted$variable)
	colnames(melted) <- c("tools", "metric", "value")
	levels(melted$metric) <- c("Entropy", "Rand index", "Adjusted rand index")
	return(melted)
}


#names <- 'berserk_feynman,lonely_shockley,lonely_wright,prickly_morse'
#paths <- 'low/berserk_feynman.csv,low/lonely_shockley.csv,low/lonely_wright.csv,low/prickly_morse.csv'
#tools_names <- unlist(strsplit(names, ','))
#file_paths <- unlist(strsplit(paths, ','))
#output_file <- "out.pdf"
#tools_names <- unlist(strsplit(argv[1], ','))
#file_paths <- unlist(strsplit(argv[2], ','))

get_names <- function(file_paths)
{
	names <- c()
	for (index in 1:length(file_paths))
	{
		#print(strsplit(file_paths[index], c('.', '/'))[-2])
		names[index] <- tail(unlist(strsplit(file_paths[index], "[/.]")), n=2)[1]
		#names[index] <- strsplit(file_paths[index], '.')[1]
	}
	names
}



#######################################

get_frames <- function(root_path)
{
	novelties <- rev(c("new_order", "new_family", "new_genus", "new_species", "new_strain"))
	data_low <- data.frame()
	data_medium <- data.frame()
	data_high <- data.frame()
	nov_low <- c()
	nov_medium <- c()
	nov_high <- c()
	for (folder_novelty in novelties)
	{
		file_paths <- list(
			"low"=paste(
				root_path, folder_novelty, "/ari/low/", 
				list.files(path=paste(root_path, folder_novelty, "/ari/low/", sep="")), sep=""),
			"medium"=paste(
				root_path, folder_novelty, "/ari/medium/",
				list.files(path=paste(root_path, folder_novelty, "/ari/medium/", sep="")), sep=""),
			"high"=paste(
				root_path, folder_novelty, "/ari/high/",
				list.files(path=paste(root_path, folder_novelty, "/ari/high/", sep="")), sep="")
			)
		#######################################
		dir_low <- paste(root_path, folder_novelty, "/ari/low/", sep="")
		dir_medium <- paste(root_path, folder_novelty, "/ari/medium/", sep="")
		dir_high <- paste(root_path, folder_novelty, "/ari/high/", sep="")
		if (dir.exists(dir_low))
		{
			data_frame <- gatherdata(
				file_paths$low, get_names(file_paths$low))
			nov_low <- append(nov_low, rep(folder_novelty, length(data_frame$tools)))
			if (length(data_low) == 0)
			{
				data_low <- data_frame
			}
			else
			{
				data_low <- rbind(data_low, data_frame)
			}
		}
		if (dir.exists(dir_medium))
		{
			data_frame <- gatherdata(
				file_paths$medium, get_names(file_paths$medium))
			nov_medium <- append(nov_medium, rep(folder_novelty, length(data_frame$tools)))
			if (length(data_medium) == 0)
			{
				data_medium <- data_frame
			}
			else
			{
				data_medium <- rbind(data_medium, data_frame)
			}
		}
		if (dir.exists(dir_high))
		{
			data_frame <- gatherdata(
				file_paths$high, get_names(file_paths$high))
			nov_high <- append(nov_high, rep(folder_novelty, length(data_frame$tools)))
			if (length(data_high) == 0)
			{
				data_high <- data_frame
			}
			else
			{
				data_high <- rbind(data_high, data_frame)
			}
		}
	}
	data_low$novelty <- factor(nov_low, levels=novelties)
	data_medium$novelty <- factor(nov_medium, levels=novelties)
	data_high$novelty <- factor(nov_high, levels=novelties)
	return(list(low=data_low, medium=data_medium, high=data_high))
}

argv <- commandArgs(TRUE)
root_path <- argv[1]
output_file <- argv[2]

dataframes <- get_frames(root_path)
#print(dataframes$low)

dodge <- position_dodge(width = 0.3)
dodge_big <- position_dodge(width = 0.6)
dodge_small <- position_dodge(width = 0.1, height=0)
#######################################


#############
##
##  PLOTS
##
#############

add_percent <- function(x, ...)
{
	sprintf("%.0f%%", x)
}

#title_main <- "(%s) Entropy, rand index, adjusted rand index"
title_main <- "Entropy, rand index, adjusted rand index"

# The palette with grey:
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
# The palette with black:
cbbPalette <- c("#000000", "#F0E442", "#E69F00", "#56B4E9", "#009E73", "#0072B2", "#D55E00", "#CC79A7")
my_colours <- rev(cbbPalette)
my_shapes <- c(20, 18)
my_linetype <- rev(c("dotted", "solid")) # "solid", "dashed", "dotted", "dotdash", "twodash", "1F", "F1"


#pdf("example_macro_prec_recall.pdf", paper="a4r", width=297, height=210)
draw_plot <- function(data, title)
{
	ggplot(subset(data, metric == "Adjusted rand index"), 
		aes(x = novelty, y = value, colour=tools, group=interaction(tools, metric))) + #fill=tools, 
		#geom_bar(stat="identity") +
		geom_line(size = .7) +
		#labs(title=title_main, colour="Tool name", x="Level", y=NULL) +
		labs(fill="Anonymous submission", x=NULL, y=NULL) +
		scale_y_continuous(breaks = c(0, 0.25, 0.5, 0.75, 1), limits=c(0, 1)) +
		facet_wrap( ~ metric, ncol=1, scales="fix") + #, as.table = FALSE, scales="free_y"
		geom_text(aes(label=value), size=4, hjust=0.4, vjust=-0.4, show_guide=F) +
		ggtitle(title) +
		theme(axis.text.x = element_text(angle = 45, hjust = 1), panel.margin = unit(1, "lines")) # , vjust = 0.5
}
pdf(output_file, paper="a4r", width=297, height=210)
#if (dir.exists(dir_low))
#{
draw_plot(dataframes$low, "Low Complexity Dataset\n")
#}
#if (dir.exists(dir_medium))
#{
draw_plot(dataframes$medium, "Medium Complexity Dataset\n")
#}
#if (dir.exists(dir_high))
#{
draw_plot(dataframes$high, "High Complexity Dataset\n")
#}
dev.off()

