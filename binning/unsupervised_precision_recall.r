library(grid)
library(reshape2)
library(ggplot2)
library(gridExtra)
library(scales)

source("parse_raw_result_data.R")

merge_names <- function(vec_of_string)
{
  pattern = c("CONCOCT.*", "taxator-tk.*")
  replace = c("CONCOCT", "taxator-tk")
  for (index in 1:length(pattern)){
    vec_of_string <- gsub(pattern[index], replace[index], vec_of_string)}
  return(vec_of_string)
}

create_plots<- function(root_path=NA, output_file_path=NA, data_type=NA) {
  if(is.na(root_path)) {root_path<- argv[1]}
  if(is.na(output_file_path)) {output_file_path<- argv[2]}
  if(is.na(data_type)) {data_type<- "by_genome_weighted"}
  
  df_tools <- get_dataframe_of_tools_at_locations(root_path)
  df_tools_subset <- subset(df_tools, datatype==data_type)
  df_tools_low <- subset(df_tools_subset, dataset=="1st CAMI Challenge Dataset 1 CAMI_low")
  df_tools_medium <- subset(df_tools_subset, dataset=="1st CAMI Challenge Dataset 2 CAMI_medium")
  df_tools_high <- subset(df_tools_subset, dataset=="1st CAMI Challenge Dataset 3 CAMI_high")
  
  method_labels <- df_tools$method
  method_labels <- merge_names(method_labels)
  # names(method_labels) <- df_tools$anonymous
  names(method_labels) <- gsub("_[0-9]*$", "", df_tools$anonymous)
  labeller <- function(variables)
  {
    rvalue <- strtrim(method_labels[variables], 17)
    return(rvalue)
  }
  method_labeller <- as_labeller(labeller)

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
  
    if (length(df_tools_high$file)>0)
    {
        plotdata <- rbind(data_low, data_medium, data_high)
    }
    else if (length(df_tools_medium$file)>0)
    {
        plotdata <- rbind(data_low, data_medium)
    }
    else if (length(df_tools_low$file)>0)
    {
        plotdata <- data_low
    }
    else
        plotdata <- NULL

    plotdata$dataset <- factor(
        plotdata$dataset,
        levels=c('low','medium','high'),
        labels=c('low','medium','high')
        )
    plotdata$Tool <- factor(gsub("_[0-9]*$", "", plotdata$Tool))

    dodge <- position_dodge(width = 0.3)
    dodge_big <- position_dodge(width = 0.6)
    dodge_small <- position_dodge(width = 0.2) #, height=0)


    #############
    ##
    ##  PLOTS
    ##
    #############


    output <- draw_plot(plotdata, "Precition/Recall\n", method_labeller)
    ggsave(output_file_path, output, width=297, height=210, units='mm')#, device="pdf"
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
  column_tool <- c()
  column_precision <- c()
  column_recall <- c()
  #print(file_paths)
  for (index in 1:length(file_paths))
  {
    # print(file_paths[index])
    column_tool <- append(column_tool, tools_names[index])
    raw_data <- read.table(file_paths[index], sep = separator, header=T)
    # print(raw_data$precision)
    column_precision <- append(column_precision, raw_data$Precision)
    column_recall <- append(column_recall, raw_data$Recall)
  }
  data_frame <- data.frame(
    tool=column_tool,
    precision= column_precision,
    recall= column_recall)
  colnames(data_frame) <- c("Tool", "Precision", "Recall")
  return(data_frame)
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

draw_plot <- function(plotdata, title, method_labeller)
{
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
  gg_plot <- ggplot(
      plotdata,
      aes(x=Precision, y=Recall, fill=Tool, color=Tool, shape=dataset, size=dataset), #, fill=dataset, color=tool
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
      stroke = 0.5, alpha=points_alpha, color="black") + #size=points_size, , shape=points_shape, color="black"
    labs(title=title_main, fill="Tool", colour="Tool", shape="Dataset", size="Dataset", x="Precision", y="Recall") + #, linetype="Tool"
    guides(fill = guide_legend(override.aes = list(shape = 21, size=3))) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), strip.background = element_rect(fill = "light blue")) # , vjust  0.5
  return(gg_plot)

}

#######################################

argv <- commandArgs(TRUE)


#root_path <-  "YOURPATH/firstchallenge_evaluation/binning/data/superviced/ALL/truncated_macro_precision/" 
#output_file <- "PerformanceMeasures" #
#output_path <- "YOURPATH/firstchallenge_evaluation/binning/plots/superviced/"
data_type <- "by_genome_weighted"
create_plots(argv[1], argv[2], data_type)

