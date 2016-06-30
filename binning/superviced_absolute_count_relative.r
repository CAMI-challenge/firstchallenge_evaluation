library(grid)
library(reshape2)
library(ggplot2)
#require(gridExtra)
library(scales)
library(RColorBrewer)




create_count_plots <- function(root_path=NA, output_file=NA, output_path=NA) {
  if(is.na(root_path)) {root_path<- argv[1]}
  if(is.na(output_file)) {output_file<- argv[2]}
  if(is.na(output_path)) {output_path<- argv[3]}
  file_paths <- list(
    "low"=paste(
      root_path, "low/", 
		  list.files(path=paste(root_path, "low/", sep="")), sep=""),
	  "medium"=paste(
		  root_path, "medium/",
		  
		  list.files(path=paste(root_path, "medium/", sep="")), sep=""),
	"high"=paste(
		root_path, "high/",
		list.files(path=paste(root_path, "high/", sep="")), sep="")
	)



#######################################


  dir_low <- paste(root_path, "low/", sep="")
  dir_medium <- paste(root_path, "medium/", sep="")
  dir_high <- paste(root_path, "high/", sep="")
  if (dir.exists(dir_low))
  {
	  result <- gatherdata(
		  file_paths$low, get_names(file_paths$low))
	    data_low <- result$melted
  }
  if (dir.exists(dir_medium))
  {
	    result <- gatherdata(
		  file_paths$medium, get_names(file_paths$medium))
	    data_medium <- result$melted
  }
  if (dir.exists(dir_high))
  {
	  result <- gatherdata(
		  file_paths$high, get_names(file_paths$high))
	    data_high <- result$melted
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
  "unassigned" = "Unassigned"
  )

  blues <- rev(brewer.pal(8,"Blues")[2:8])
  reds <- rev(brewer.pal(8,"Reds")[2:8])
  blue_red_grey <- c(blues, reds, "grey90")

  # The palette with grey:
  cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
  # The palette with black:
  cbbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "grey30")
  my_Palette <- rev(cbbPalette)
  test_palete <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "grey30")
  my_shapes <- c(20, 18)
  my_linetype <- rev(c("dotted", "solid")) # "solid", "dashed", "dotted", "dotdash", "twodash", "1F", "F1"

  #pdf(output_file, paper="a4r", width=297, height=210)
  if (dir.exists(dir_low))
  {
	  draw_plot_x(data_low, "Low Complexity Dataset\n", blue_red_grey)
    ggsave(paste(output_file, "_low.pdf", sep=""), path= output_path, device="pdf")
  }
  if (dir.exists(dir_medium))
  {
	  draw_plot_x(data_medium, "Medium Complexity Dataset\n", blue_red_grey)
    ggsave(paste(output_file, "_medium.pdf", sep=""), path= output_path, device="pdf")
  }
  if (dir.exists(dir_high))
  {
	  draw_plot_x(data_high, "High Complexity Dataset\n", blue_red_grey)
    ggsave(paste(output_file, "_high.pdf", sep=""), path= output_path, device="pdf")
  }

  #dev.off()

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


dir.exists <- function(d) {
  de <- file.info(d)$isdir
  ifelse(is.na(de), FALSE, de)
}

gatherdata <- function(file_paths, tools_names)
{
  separator <- '\t'
  levels <- c("root", "superkingdom", "phylum", "class", "order", "family", "genus", "species")
  column_tool <- c()
  column_levels <- c()
  column_true <- c()
  column_false <- c()
  total <- c()
  for (index in 1:length(file_paths))
  {
    print(file_paths[index])
    raw_data <- read.table(file_paths[index], sep = separator, header=T, row.names=1)
    #print(dim(raw_data)[1])
    #print(length(levels))
    column_levels <- append(column_levels, levels[1:dim(raw_data)[1]])
    column_tool <- append(column_tool, rep(tools_names[index], dim(raw_data)[1]))
    column_true <- append(column_true, raw_data$true)
    column_false <- append(column_false, raw_data$false)
    print(sum(raw_data$unknown))
    total <- append(total, rep(sum(raw_data$true) + sum(raw_data$false), dim(raw_data)[1]))
    #total[index] <- total[index]
    #column_false <- append(column_false, -1 *raw_data$false)
  }
  #print(total)
  #exit
  data_frame <- data.frame(
    true=column_true,
    false=column_false)
  data_frame$level = factor(column_levels)
  # print data_frame
  # print tools_names
  data_frame$tools <- factor(column_tool)
  data_frame$total <- total
  melted <- melt(data_frame, c("tools", "level", "total"))
  #melted <- melt(data_frame, c("level"))
  # melted$tools <- ''
  #melted$tools <- factor(column_tool)
  #levels(melted$variable)
  melted$variable <- factor(melted$variable, levels=c('true','false','unassigned'), labels=c("Correct","Incorrect","Unassigned"))
  melted$variable[melted$level == "root"] <- "Unassigned"
  #levels(melted$variable)
  return(list(melted = melted, total = total))
}

draw_plot_x <- function(data, title, c_palette)
{
  levels_tmp <- c("superkingdom", "phylum", "class", "order", "family", "genus", "species")
  levels <- c(levels_tmp, levels_tmp, "unassigned")
  x_labels <- c("Correct","Incorrect", "Unassigned")
  colour_theme <- c("deepskyblue3", "red", "grey30")

  data$value <- data$value/data$total*100	#				2	1			3

  ggplot(data, aes(x = tools, y = value, fill = interaction(level, variable), order = as.numeric(interaction(level, variable)))) +
    geom_bar(stat = 'identity', position = 'stack') +
    #facet_wrap(~ level, scales = "fix") +
    scale_y_continuous(labels = add_percent) +
    #scale_fill_manual(name=NULL,values=colour_theme, labels=x_labels) + #, labels=x_labels
    scale_fill_manual(name=NULL,values=c_palette, labels=levels, guide=guide_legend(reverse=T)
                      #scale_fill_manual(name=NULL,values=c_palette, guide=guide_legend(reverse=T)
    ) + #, labels=x_labels guide=guide_legend(reverse=T)
    labs(title=title, fill=NULL, x=NULL, y="% Sequence") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) # , vjust = 0.5
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

create_count_plots(argv[1], argv[2], argv[3])