
options(warn=-1)

# cleanup

rm(list=ls())

# load libraries

library("ggplot2")
library("scales")
library("grid")

# options

merge_names <- function(vec_of_string)
{
    pattern = c("CONCOCT.*", "taxator-tk.*")
    replace = c("CONCOCT", "taxator-tk")
    for (index in 1:length(pattern)){
        vec_of_string <- gsub(pattern[index], replace[index], vec_of_string)}
    return(vec_of_string)
}

filter_tail <- T
best_only <- T
all_ranks_combined <- T
device <- "png"

bin_types <- c("unsupervised", "supervised")
levels <- c("by_genome", "by_bin")
ANIs <- c("all", "common strain", "unique strain")
categories <- c(
    #"unidentified circular element","unidentified plasmid", "circular element",
    "all", "unique strain", "common strain","new_family","new_genus","new_order","new_species","new_strain","virus"
    )

repo.dir <- dirname(sys.frame(1)$ofile)
source(file.path(repo.dir, "parse_raw_result_data.R"))

for (bin_type in bin_types) {
    
    # handling of method labels

    if (bin_type=="supervised") rawdata.dir <- file.path(repo.dir, "/data/taxonomic/")
    if (bin_type=="unsupervised") rawdata.dir <- file.path(repo.dir, "/data/unsupervised/")
    df_tools <- get_dataframe_of_tools_at_locations(rawdata.dir)
    method_labels <- df_tools$method
    method_labels <- merge_names(method_labels)
    names(method_labels) <- gsub("_[0-9]*$", "", df_tools$anonymous)
    labeller <- function(variables)
    {
        rvalue <- strtrim(method_labels[variables], 17)
        return(rvalue)
    }
    method_labeller <- as_labeller(labeller)
    dataset_labels <- df_tools$dataset

    names(dataset_labels) <- df_tools$anonymous
    labeller <- function(variables)
    {
        rvalue <- dataset_labels[variables]#strtrim(, 17)
        return(rvalue)
    }
    dataset_labeller <- as_labeller(labeller)
    
    # reading tables
    
    if (bin_type=="supervised") levels <- c("by_genome", "by_bin")
    if (bin_type=="unsupervised") levels <- c("by_genome")
    for (level in levels)
      for (category in categories)
        for (ANI in ANIs) {

        # directories
        metadata.dir <- file.path(repo.dir, "..", "metadata")
        ANI_data.file <- file.path(metadata.dir, "ANI", "unique_common.tsv")
        results.dir <- file.path(repo.dir, "tables")
        figures.dir <- file.path(repo.dir, "plots")
        
        # files
        suffix <- paste("_", bin_type, "_", level, "_", category, ".tsv", sep="")
        ref_data_low.file <- file.path(results.dir, paste("low", suffix, sep=""))
        ref_data_medium.file <- file.path(results.dir, paste("medium", suffix, sep=""))
        ref_data_high.file <- file.path(results.dir, paste("high", suffix, sep=""))
        
        # load data
        ref_data_low <- NULL
        ref_data_medium <- NULL
        ref_data_high <- NULL
        if (file.exists(ref_data_low.file)) {
            ref_data_low <- read.table(ref_data_low.file, header=T, sep="\t")
            ref_data_low$group <- gsub("_[0-9]*", "_low", ref_data_low$binner)
            ref_data_low$complexity <- "low"
        }# else print(paste("Missing:", ref_data_low.file, sep=" "))

        if (file.exists(ref_data_medium.file)) {
            ref_data_medium <- read.table(ref_data_medium.file, header=T, sep="\t")
            ref_data_medium$group <- gsub("_[0-9]*", "_medium", ref_data_medium$binner)
            ref_data_medium$complexity <- "medium"
        }

        if (file.exists(ref_data_high.file)) {
            ref_data_high <- read.table(ref_data_high.file, header=T, sep="\t")
            ref_data_high$group <- gsub("_[0-9]*", "_high", ref_data_high$binner)
            ref_data_high$complexity <- "high"
        }

        if (file.exists(ref_data_high.file))  # all data exists
            ref_data_combined <- rbind(ref_data_low, ref_data_medium, ref_data_high)
        else if (file.exists(ref_data_medium.file))  # high is missing
        {
            #print(paste("Missing:", ref_data_high.file, sep=" "))
            ref_data_combined <- rbind(ref_data_low, ref_data_medium)
        }
        else if (file.exists(ref_data_low.file))  # high, medium is missing
        {
            #print(paste("Missing:", ref_data_medium.file, sep=" "))
            ref_data_combined <- ref_data_low
        }
        else  # only low and medium exists
        {
            #print(paste("Missing:", ref_data_low.file, sep=" "))
            next
        }
        
        ANI_data <- read.table(ANI_data.file, header=F, sep="\t")
        colnames(ANI_data) <- c("bin", "group")
        ANI_data$bin <- gsub(".gt1kb", "", ANI_data$bin)
        
        # remove small bins (<= 1% pred. size) for each tool_parameter_set / rank combination
        
        if (filter_tail) {
            
            ref_data_combined <- within(ref_data_combined,
                                        binner_rank <- paste(ref_data_combined$binner,
                                                             ref_data_combined$rank,
                                                             ref_data_combined$group,
                                                             sep='_'))
            
            threshold <- 0.01
            q <- aggregate(ref_data_combined$predicted_size, by=list(ref_data_combined$binner_rank), sum)
            q[, 2] <- q[, 2]*threshold
            for (i in 1:nrow(q)) {
                idx <- ref_data_combined$binner_rank==q[i, 1]
                s <- sort(ref_data_combined[idx, ]$predicted_size)
                #print(s)
                cs <- cumsum(s)
                q[i, 2] <- s[min(which(cs>q[i, 2]))]
            }
            
            idx <- apply(ref_data_combined, 1, function(x) as.numeric(x["predicted_size"]) > q[q[, 1]==x["binner_rank"], 2])
            ref_data_combined$precision[!idx] <- NA
        
        }
        
        if (level=="by_genome") {

            ref_data_combined$ANI <- ANI_data$group[match(ref_data_combined$bin, ANI_data$bin)]    
            
            if (ANI!="all")
                ref_data_combined <- ref_data_combined[ref_data_combined$ANI==ANI, ]
            else
                ref_data_combined <- ref_data_combined[ref_data_combined$ANI!="circular element", ]

        } else if (ANI!="all") next
        
        ### plotting
        
        points_size=1.25 
        points_alpha=1
        points_shape=22
        bars_size=0.75 #1
        bars_alpha=0.75
        
        # ggplot2 theme
        
        main_theme <- theme(panel.background=element_blank(),
                            panel.grid=element_blank(),
                            axis.line.x=element_line(color="black"),
                            axis.line.y=element_line(color="black"),
                            axis.line=element_line(color="black"),
                            axis.ticks=element_line(color="black"),
                            axis.text=element_text(colour="black", size=10),
                            legend.position="top",
                            legend.background=element_blank(),
                            legend.key=element_blank(),
                            text=element_text(family="sans"))
        
        # function to get the SEM for the error bars
        
        sem <- function(x, na.rm=T) {
        
            return(sd(x, na.rm=na.rm)/sqrt(length(x)-sum(is.na(x))))
            
        }
        
        if (all_ranks_combined) ref_data_combined$rank <- "all_ranks"
        
        for (rank in unique(ref_data_combined$rank)) {
        
            # plot precision / recall scatter plot combined per rank
            
            title <- paste("precision / recall", "\n(rank=", rank, "; bin_type=", bin_type,
                           "; filter_tail=", filter_tail, "; ANI=", ANI, ")", sep="")
            
            df <- ref_data_combined[ref_data_combined$rank==rank, ]
        
            #df <- df[!grepl("Gold Standard", df$binner), ]
            
            means <- aggregate(df, by=list(df$binner), FUN=mean, na.rm=T)
            er <- aggregate(df, by=list(df$binner), FUN=sem, na.rm=T)
            real_sizes <- aggregate(df$real_size, by=list(df$binner), FUN=sum, na.rm=T)
            predicted_sizes <- aggregate(df$predicted_size, by=list(df$binner), FUN=sum, na.rm=T)
            
            df <- data.frame(binner=means[, 1],
                             tool=gsub("_[0-9]*$", "", means[, 1]),
                             #dataset=dataset_labeller(means[, 1]),
                             precision=means$precision, recall=means$recall,
                             precision_er=er$precision, recall_er=er$recall,
                             real_size=real_sizes[, 2],
                             predicted_size=predicted_sizes[, 2])
            #print(union(df$binner, c()))
            df$dataset <- factor(dataset_labeller(df$binner), 
                levels=c("1st CAMI Challenge Dataset 1 CAMI_low","1st CAMI Challenge Dataset 2 CAMI_medium","1st CAMI Challenge Dataset 3 CAMI_high"),
                labels=c('low','medium','high')
                )
            
            df$real_size <- df$real_size/1E10
            df$predicted_size <- df$predicted_size/1E10
            
            complexity <- unique(data.frame(binner=ref_data_combined$binner,
                                            group=ref_data_combined$group))
            df$group <- complexity$group[match(df$binner, complexity$binner)]
            
            # use only best parameter set for each tool
            
            if (best_only) {
        
                dfbest <- NULL
                
                    for (g in unique(df$group)) {
                    
                        dfg <- df[df$group==g, ]
                        idx <- sort(dfg$precision + dfg$recall, decreasing=T, index.return=T)$ix
                        dfg <- dfg[idx[1], ]
                        dfbest <- rbind(dfbest, dfg)
                    
                    }
        
            } else {
        
                dfbest <- df
        
            }
            
            df <- dfbest

       #print(df) 
            #dodge_small <- position_dodge(.2) , position=dodge_small
            p <- ggplot(df, aes(x=precision, y=recall, color=tool, fill=tool, shape=dataset)) +
                 geom_hline(yintercept=seq(0, 2, by=0.1), colour="grey90") +
                 geom_vline(xintercept=seq(0, 2, by=0.1), colour="grey90") +
                 geom_errorbarh(aes(xmin=precision-precision_er,
                                    xmax=precision+precision_er),
                                size=bars_size, alpha=bars_alpha, height=0) +
                 geom_errorbar(aes(ymin=recall-recall_er,
                                   ymax=recall+recall_er),
                               size=bars_size, alpha=bars_alpha, width=0) +
                 scale_x_continuous(labels=percent, limits=c(0.0, 1), breaks=seq(0,1, 0.2), expand = c( 0.01 , 0.01 )) +
                 scale_y_continuous(labels=percent, limits=c(0, 1), breaks=seq(0,1, 0.2), expand = c( 0.01 , 0.01 )) +
                 scale_color_discrete(labels = method_labeller) +
                 scale_fill_discrete(labels = method_labeller, guide=FALSE) +
                 #scale_shape_discrete(labels = dataset_labeller) +
                 scale_shape(solid = FALSE) +
                 geom_point(size=points_size, alpha=points_alpha, color="black") + #, shape=points_shape
                 #geom_point(aes(size=predicted_size), alpha=points_alpha, shape=points_shape, color="grey") +
                 #geom_point(aes(size=real_size), alpha=points_alpha, shape=points_shape, color="black") +
                 #geom_text(aes(label=round(precision*100)), size=3, hjust=1, vjust=-0.3, show.legend=F) +
                 #geom_text(aes(label=round(recall*100)), size=3, hjust=-1, vjust=-0.3, show.legend=F) +
                 #ggtitle(title) +
                 labs(title=title, color="Tool", shape="Dataset (complexity)") + #, x=NULL, y=NULL
                 main_theme +
                 theme(legend.position="right",
                       title=element_text(size=8))
            
            filename <- paste("prec_recall_combined_", rank, "_", level, "_", category, "_ANI_", ANI, ".", device, sep="")
            filename <- gsub(" ", "_", filename)
            filepath <- file.path(figures.dir, bin_type, filename)
            ggsave(filepath, p, width=7, height=5)
            print(filepath)
        }
    }
}

