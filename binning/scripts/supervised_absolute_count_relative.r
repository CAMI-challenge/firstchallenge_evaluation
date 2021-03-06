library(grid)
library(reshape2)
library(ggplot2)
library(gridExtra)
library(scales)
library(RColorBrewer)

source("parse_raw_result_data.R")


create_count_plots <- function(root_path=NA, output_file=NA) {
  if(is.na(root_path)) {root_path<- argv[1]}
  if(is.na(output_file)) {output_file<- argv[2]}

  df_tools <- get_dataframe_of_tools_at_locations(root_path)
  df_tools_subset <- subset(df_tools, datatype=="absolute")
  df_tools_low <- subset(df_tools_subset, dataset=="1st CAMI Challenge Dataset 1 CAMI_low")
  df_tools_medium <- subset(df_tools_subset, dataset=="1st CAMI Challenge Dataset 2 CAMI_medium")
  df_tools_high <- subset(df_tools_subset, dataset=="1st CAMI Challenge Dataset 3 CAMI_high")

  method_labels <- df_tools_subset$method
  names(method_labels) <- df_tools_subset$anonymous

  if (length(df_tools_low$file)>0)
  {
    data_low <- gatherdata(
      as.vector(df_tools_low$file), as.vector(df_tools_low$anonymous))
    #data_low$tools <- factor(as.vector(data_low$tools), levels=levels(data_low$tools), labels=method_labels[levels(data_low$tools)])

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



  labels_map <- list(
  "true" = "Correct",
  "false" = "Incorrect",
  "unknown" = "Unknown",
  "unassigned" = "Unassigned"
  )

  blues <- rev(brewer.pal(8,"Blues")[2:8])
  reds <- rev(brewer.pal(8,"Reds")[2:8])
  greens <- rev(brewer.pal(8,"Greens")[2:8])
  blue_red_grey <- c(blues, reds, greens, "grey80")

  # The palette with grey:
  cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
  # The palette with black:
  cbbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "grey30")
  my_Palette <- rev(cbbPalette)
  test_palete <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "grey30")
  my_shapes <- c(20, 18)
  my_linetype <- rev(c("dotted", "solid")) # "solid", "dashed", "dotted", "dotdash", "twodash", "1F", "F1"

  #pdf(output_file, paper="a4r", width=297, height=210)
  ggplots <- list()
  if (length(df_tools_low$file)>0)
  {
    ggplots[[length(ggplots)+1]]  <- draw_plot_x(data_low, "Low Complexity Dataset\n", blue_red_grey, method_labels)
    #ggsave(paste(output_file, "_low.pdf", sep=""), path= output_path)
  }
  if (length(df_tools_medium$file)>0)
  {
    ggplots[[length(ggplots)+1]]  <- draw_plot_x(data_medium, "Medium Complexity Dataset\n", blue_red_grey, method_labels)
    #ggsave(paste(output_file, "_medium.pdf", sep=""), path= output_path)
  }
  if (length(df_tools_high$file)>0)
  {
    ggplots[[length(ggplots)+1]]  <- draw_plot_x(data_high, "High Complexity Dataset\n", blue_red_grey, method_labels)
    #ggsave(paste(output_file, "_high.pdf", sep=""), path= output_path)
  }

  output <- marrangeGrob(ggplots, nrow=1, ncol=1, top=NULL)
  ggsave(output_file, output, width=297, height=210, units='mm')#, device="pdf"
  #dev.off()

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


dir.exists <- function(d) {
  de <- file.info(d)$isdir
  ifelse(is.na(de), FALSE, de)
}

gatherdata <- function(file_paths, tools_names)
{
  separator <- '\t'
  levels <- c("root", "superkingdom", "phylum", "class", "order", "family", "genus", "species")
  level_order <- c("superkingdom", "phylum", "class", "order", "family", "genus", "species", "root")
  column_tool <- c()
  column_levels <- c()
  column_true <- c()
  column_false <- c()
  column_unknown <- c()
  total <- c()
  for (index in 1:length(file_paths))
  {
    raw_data <- read.table(file_paths[index], sep = separator, header=T, row.names=1)
    column_levels <- append(column_levels, levels[1:dim(raw_data)[1]])
    column_tool <- append(column_tool, rep(tools_names[index], dim(raw_data)[1]))
    column_true <- append(column_true, raw_data$true)
    column_false <- append(column_false, raw_data$false)
    column_unknown <- append(column_unknown, raw_data$unknown)
    # print(sum(raw_data$unknown))
    total <- append(total, rep(sum(raw_data$true) + sum(raw_data$false) + sum(raw_data$unknown), dim(raw_data)[1]))
  }
  #print(total)
  #exit
  data_frame <- data.frame(
    true=column_true,
    false=column_false,
    unknown=column_unknown)
  data_frame$level = factor(column_levels, levels=level_order)
  data_frame$tools <- factor(column_tool)
  data_frame$total <- total
  melted <- melt(data_frame, c("tools", "level", "total"))
  melted$variable <- factor(melted$variable, levels=c('true','false','unknown', 'unassigned'), labels=c("Correct","Incorrect","Unknown", "Unassigned"))
  melted$variable[melted$level == "root"] <- "Unassigned"
  #melted$variable <- factor(as.vector(melted$variable), levels=c('true','false','unknown', 'unassigned'), labels=c("Correct","Incorrect","Unknown", "Unassigned"))
  #melted$level <- reorder.factor(melted$level, new.order=level_order)
  #return(melted)
  return(melted[with(melted, order(variable)), ])
}

draw_plot_x <- function(data, title, c_palette, method_labels)
{
  method_labeller <- function(variables)
  {
    rvalue <- strtrim(method_labels[variables], 17)
    return(rvalue)
  }
  levels_tmp1 <- c("superkingdom", "phylum", "class", "order", "family", "genus", "species")
  #levels_tmp2 <- c("superkingdom", "phylum", "class", "order", "family", "genus", "species")
  #levels_tmp3 <- c("superkingdom", "phylum", "class", "order", "family", "genus", "species")
  legend_levels <- c(rep(levels_tmp1, 3), "unassigned")
  colour_theme <- c("deepskyblue3", "red", "grey30", "grey70")
  #print(levels(data$variable))
  #print(levels(data$level))
  data$value <- data$value/data$total*100	#				2	1			3

  tmp <- ggplot(data, aes(x = tools, y = value, fill = interaction(level, variable), order = as.numeric(interaction(variable,level)))) +
    geom_bar(stat = 'identity', position = 'stack') +
    #facet_wrap(~ level, scales = "fix") +
    scale_x_discrete(labels = method_labeller) +
    scale_y_continuous(labels = add_percent) +
    scale_fill_manual(name=NULL,values=c_palette, labels=legend_levels, guide=guide_legend(reverse=T, nrow=15)) + #, labels=x_labels guide=guide_legend(reverse=T)
    labs(title=title, fill=NULL, x=NULL, y="% Basepairs") +
    geom_text(aes(label = "Green: Unknown", x = Inf, y = 1), hjust = -0.8, vjust = -4, family = "Times") +
    geom_text(aes(label = "Red: Incorrect", x = Inf, y = 1), hjust = -1, vjust = -2, family = "Times") +
    geom_text(aes(label = "Blue: Correct", x = Inf, y = 1), hjust = -1.1, vjust = 0, family = "Times") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) # , vjust = 0.5
  gt <- ggplot_gtable(ggplot_build(tmp))
  gt$layout$clip[gt$layout$name == "panel"] <- "off"
  return(gt)
}


draw_plot <- function(data, title, total)
{
  total <- total
  data$value <- data$value/total*100
  ggplot(data, aes(x = tools, y =value, fill = level)) +
    geom_bar(stat = 'identity', position = 'stack', colour="black") +
    facet_grid(~ variable) + #, labeller=my_labeller
    scale_y_continuous(labels = add_percent, breaks=seq(0,100,10)) +
    scale_fill_manual(values=my_Palette, breaks=rev(data$level)) +
    labs(fill="Level", x=NULL, y="Percent of Sequences") +
    ggtitle(title) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) # , vjust = 0.5
}


my_labeller <- function(variable, value)
{
  return(labels_map[value])
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


add_percent <- function(x, ...)
{
  sprintf("%.0f%%", x)
}

#######################################
# MAIN
#######################

argv <- commandArgs(TRUE)

#root_path <-  "YOURPATH/firstchallenge_evaluation/binning/data/superviced/ALL/truncated_macro_precision/" 
#output_file <- "CountPlots" 
#output_path <- "YOURPATH/firstchallenge_evaluation/binning/plots/superviced/"

create_count_plots(argv[1], argv[2])

