library(grid)
library(reshape2)
library(ggplot2)
library(gridExtra)
library(scales)

source("parse_raw_result_data.R")

create_plots<- function(root_path=NA, output_file_path=NA) {
  if(is.na(root_path)) {root_path<- argv[1]}
  if(is.na(output_file_path)) {output_file_path<- argv[2]}
  
  df_tools <- get_dataframe_of_tools_at_locations(root_path)
  df_tools_average_prec <- subset(df_tools, datatype=="summary")
  df_tools_low <- subset(df_tools_average_prec, dataset=="1st CAMI Challenge Dataset 1 CAMI_low")
  df_tools_medium <- subset(df_tools_average_prec, dataset=="1st CAMI Challenge Dataset 2 CAMI_medium")
  df_tools_high <- subset(df_tools_average_prec, dataset=="1st CAMI Challenge Dataset 3 CAMI_high")
  
  if (length(df_tools_low$file)>0)
  {
    data_low <- gatherdata(
      as.vector(df_tools_low$file), as.vector(df_tools_low$anonymous))
  }
  if (length(df_tools_medium$file)>0)
  {
    data_medium <- gatherdata(
      as.vector(df_tools_medium$file), as.vector(df_tools_medium$anonymous))
  }
  if (length(df_tools_high$file)>0)
  {
    data_high <- gatherdata(
      as.vector(df_tools_high$file), as.vector(df_tools_high$anonymous))
  }
  
  dodge <- position_dodge(width = 0.3)
  dodge_big <- position_dodge(width = 0.6)
  dodge_small <- position_dodge(width = 0.2) #, height=0)
  
  
  #############
  ##
  ##  PLOTS
  ##
  #############
  
  
  if (length(df_tools_low$file)>0)
  {
    gg_plot_low <- draw_plot(data_low, "Low Complexity Dataset\n")
  }
  if (length(df_tools_medium$file)>0)
  {
    gg_plot_medium <- draw_plot(data_medium, "Medium Complexity Dataset\n")
  }
  if (length(df_tools_high$file)>0)
  {
    gg_plot_high <- draw_plot(data_high, "High Complexity Dataset\n")
  }
  #output <- arrangeGrob(gg_plot_low, gg_plot_medium, gg_plot_high, ncol=1)
  output <- marrangeGrob(list(gg_plot_low, gg_plot_medium, gg_plot_high), nrow=1, ncol=1, top=NULL)
  ggsave(output_file_path, output, device="pdf", width=297, height=210, units='mm')
  #dev.off()
}


add_percent <- function(x, ...)
{
  sprintf("%.0f%%", x)
}

lable_handle <- function(x, ...)
{
  display <- c()
  for(value in x)
  {
    if (is.na(value))
    {
      display <- append(display, "")
      next
    }
    if ((0 <= value) && (value <= 1))
    {
      display <- append(display, sprintf("%.2f", value))
    }
    else
    {
      display <- append(display, "")
    }
  }
  display
}



dir.exists <- function(d) {
  de <- file.info(d)$isdir
  ifelse(is.na(de), FALSE, de)
}

gatherdata <- function(file_paths, tools_names)
{
  separator <- '\t'
  levels <- c("superkingdom", "phylum", "class", "order", "family", "genus", "species")
  # ?instance,entropy,"rand index","adjusted rand index"
  column_tool <- c()
  column_precision <- c()
  column_precision_std <- c()
  column_recall <- c()
  column_recall_std <- c()
  column_accuracy <- c()
  column_misclassification_rate <- c()
  #print(file_paths)
  for (index in 1:length(file_paths))
  {
    # print(file_paths[index])
    column_tool <- append(column_tool, rep(tools_names[index], length(levels)))
    raw_data <- read.table(file_paths[index], sep = separator, header=T, row.names=1)
    column_precision <- append(column_precision, raw_data$precision)
    column_precision_std <- append(column_precision_std, raw_data$precision.stdev.)
    column_recall <- append(column_recall, raw_data$recall)
    column_recall_std <- append(column_recall_std, raw_data$recall.stdev.)
    column_accuracy <- append(column_accuracy, raw_data$accuracy)
    column_misclassification_rate <- append(column_misclassification_rate, raw_data$misclassification.rate)
  }
  data_frame <- data.frame(
    precision= column_precision,
    recall= column_recall,
    accuracy=column_accuracy,
    misclassification_rate=column_misclassification_rate)
  # data_frame_r <- data.frame(recall=column_recall)
  data_frame_sd <- data.frame(
    precision_sd= column_precision_std,
    recall_sd= column_recall_std)
  # data_frame_rsd <- data.frame(recall_std=column_recall_std)
  
  data_frame$level = factor(rep(levels, length(file_paths)), levels=levels)
  # data_frame_r$level = factor(rep(levels, length(file_paths)), levels=levels)
  data_frame_sd$level = factor(rep(levels, length(file_paths)), levels=levels)
  # data_frame_rsd$level = factor(rep(levels, length(file_paths)), levels=levels)
  
  melted <- melt(data_frame, "level")
  # melted_r <- melt(data_frame_r, "level")
  melted_sd <- melt(data_frame_sd, "level")
  # melted_rsd <- melt(data_frame_rsd, "level")
  # colnames(melted) <- c("level", "variable", "precision")
  #melted$recall = melted_r$value
  melted$sd = melted_sd$value
  #melted$recall_sd = melted_rsd$value
  melted$tools <- factor(column_tool)
  melted$variable <- factor(melted$variable)
  colnames(melted) <- c("level", "metric", "percent", "sd", "tools")
  return(melted)
}

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

draw_plot <- function(data, title)
{
  
  # precision averaged over predicted bins, recall averaged over true bins, precision in this dir is truncated precision (1% of smallest predicted bins removed)
  title_main <- title
  
  
  # The palette with grey:
  cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
  # The palette with black:
  cbbPalette <- c("#000000", "#F0E442", "#E69F00", "#56B4E9", "#009E73", "#0072B2", "#D55E00", "#CC79A7")
  my_colours <- rev(cbbPalette)
  my_shapes <- c(20, 18)
  my_linetype <- rev(c("dotted", "solid")) # "solid", "dashed", "dotted", "dotdash", "twodash", "1F", "F1"
  
  
  
  gg_plot <- ggplot() +
    geom_ribbon(
      data=subset(data, metric=="precision" | metric=="recall"),
      aes(x = level, y = percent, ymax=percent+sd, ymin=percent-sd, linetype=metric, fill=metric, group=interaction(metric, tools)),
      alpha = 0.2) +
    
    geom_line(
      data=subset(data, metric=="precision" | metric=="recall"),
      aes(x = level, y = percent, colour=metric, linetype=metric, fill=metric, group=interaction(metric, tools)),
      size = .7,) +
    
    geom_line(
      data=subset(data , metric=="accuracy" | metric=="misclassification_rate"),
      aes(x = level, y = percent, colour=metric, linetype=metric, fill=metric, group=interaction(metric, tools)),
      size = .7,
    ) +
    scale_y_continuous(labels = add_percent, breaks=c(0,25,50,75,100)) +
    scale_fill_manual(
      values=my_colours,  
      breaks=c("accuracy", "misclassification_rate", "precision", "recall"), 
      labels=c("Accuracy", "Misclassification", "Av. Precision", "Av. Recall"))+ #c("Accuracy", "Misclassification", "Precision", "Recall")) +
    scale_colour_manual(
      values=my_colours,  
      breaks=c("accuracy", "misclassification_rate", "precision", "recall"), 
      labels=c("Accuracy", "Misclassification", "Av. Precision", "Av. Recall")) +#c("Accuracy", "Misclassification", "Precision", "Recall")) +
    scale_linetype_manual(
      values=c("solid", "dashed", "dotted", "dotdash"),
      breaks=c("accuracy", "misclassification_rate", "precision", "recall"), 
      labels=c("Accuracy", "Misclassification", "Av. Precision", "Av. Recall")) +
    labs(title=title_main, fill="Metric", linetype="Metric", colour="Metric", x=NULL, y=NULL) +
    #ggtitle(paste(title, title_main, sep='\n')) +
    #facet_grid(~ tools) +
    facet_wrap(~ tools, as.table = FALSE) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), strip.background = element_rect(fill = "light blue")) # , vjust  0.5
  return(gg_plot)
}

#######################################

argv <- commandArgs(TRUE)


#root_path <-  "YOURPATH/firstchallenge_evaluation/binning/data/superviced/ALL/truncated_macro_precision/" 
#output_file <- "PerformanceMeasures" #
#output_path <- "YOURPATH/firstchallenge_evaluation/binning/plots/superviced/"

create_plots(argv[1], argv[2])
