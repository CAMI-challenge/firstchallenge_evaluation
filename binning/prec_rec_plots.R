
options(warn=-1)

# cleanup

rm(list=ls())

# load libraries

library("ggplot2")
library("scales")
library("grid")

# options

filter_tail <- F
best_only <- T
all_ranks_combined <- T
 
bin_types <- c("supervised", "unsupervised")
levels <- c("by_bin", "by_genome")
ANIs <- c("all", "common strain", "unique strain")

for (bin_type in bin_types) {
    if (bin_type=="unsupervised") levels <- c("by_genome")
    for (level in levels)
        for (ANI in ANIs) {
               
        # directories
        
        repo.dir <- dirname(sys.frame(1)$ofile)
        
        metadata.dir <- paste(repo.dir, "/../metadata/", sep="")
        if (bin_type=="supervised") results.dir <- paste(repo.dir, "/data/taxonomic/", sep="")
        if (bin_type=="unsupervised") results.dir <- paste(repo.dir, "/data/unsupervised/", sep="")
        figures.dir <- paste(repo.dir, "/plots/", sep="")
        
        # files
        
        ref_data_low.file <- paste(results.dir, "low_all_", level, ".tsv", sep="")
        ref_data_medium.file <- paste(results.dir, "medium_all_", level, ".tsv", sep="")
        ref_data_high.file <- paste(results.dir, "high_all_", level, ".tsv", sep="")

        ANI_data.file <- paste(metadata.dir, "ANI/unique_common.tsv", sep="")
        
        # load data
        
        ref_data_low <- read.table(ref_data_low.file, header=T, sep="\t")
        ref_data_medium <- read.table(ref_data_medium.file, header=T, sep="\t")
        ref_data_high <- read.table(ref_data_high.file, header=T, sep="\t")
        
        ref_data_low$group <- gsub("_[0-9]", "_low", ref_data_low$binner)
        ref_data_low$complexity <- "low"
        ref_data_medium$group <- gsub("_[0-9]", "_medium", ref_data_medium$binner)
        ref_data_medium$complexity <- "medium"
        ref_data_high$group <- gsub("_[0-9]", "_high", ref_data_high$binner)
        ref_data_high$complexity <- "high"
        
        ref_data_combined <- rbind(ref_data_low, ref_data_medium, ref_data_high)
        
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
                s <- rev(ref_data_combined[idx, ]$predicted_size)
                cs <- cumsum(s)
                q[i, 2] <- s[min(which(cs>q[i, 2]))]
            }
            
            idx <- apply(ref_data_combined, 1, function(x) as.numeric(x["predicted_size"]) > q[q[, 1]==x["binner_rank"], 2])
            ref_data_combined <- ref_data_combined[idx, ]
        
        }
        
        if (level=="by_genome") {

            ref_data_combined$ANI <- ANI_data$group[match(ref_data_combined$bin, ANI_data$bin)]    
            
            if (ANI!="all")
                ref_data_combined <- ref_data_combined[ref_data_combined$ANI==ANI, ]
            else
                ref_data_combined <- ref_data_combined[ref_data_combined$ANI!="circular element", ]

        }
        
        ### plotting
        
        points_size=1.25
        points_alpha=1
        points_shape=22
        bars_size=1
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
        
            df <- df[!grepl("Gold Standard", df$binner), ]
            
            means <- aggregate(df, by=list(df$binner), FUN=mean, na.rm=T)
            er <- aggregate(df, by=list(df$binner), FUN=sem, na.rm=T)
            real_sizes <- aggregate(df$real_size, by=list(df$binner), FUN=sum, na.rm=T)
            predicted_sizes <- aggregate(df$predicted_size, by=list(df$binner), FUN=sum, na.rm=T)
            
            df <- data.frame(binner=means[, 1],
                             tool=gsub("_[0-9]*$", "", means[, 1]),
                             precision=means$precision, recall=means$recall,
                             precision_er=er$precision, recall_er=er$recall,
                             real_size=real_sizes[, 2],
                             predicted_size=predicted_sizes[, 2])
            
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
            
            p <- ggplot(df, aes(x=precision, y=recall, color=tool)) +
                 geom_errorbarh(aes(xmin=precision-precision_er,
                                    xmax=precision+precision_er),
                                size=bars_size, alpha=bars_alpha, height=0) +
                 geom_errorbar(aes(ymin=recall-recall_er,
                                   ymax=recall+recall_er),
                               size=bars_alpha, alpha=bars_size, width=0) +
                 scale_x_continuous(labels=percent, limits=c(0.0, 1)) +
                 scale_y_continuous(labels=percent, limits=c(0, 1)) +
                 geom_point(aes(size=predicted_size), alpha=points_alpha, shape=points_shape, color="grey") +
                 geom_point(aes(size=real_size), alpha=points_alpha, shape=points_shape, color="black") +
                 ggtitle(title) +
                 main_theme +
                 theme(legend.position="right",
                       title=element_text(size=8))
            
            file <- paste(figures.dir, bin_type, "/prec_recall_combined_", rank,
                          "_", level, "_ANI_", ANI, ".pdf", sep="")
            file <- gsub(" ", "_", file)
            ggsave(file, p, width=7, height=5)
            print(file)
            
        }
    }
}

