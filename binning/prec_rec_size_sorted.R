
options(warn=-1)

# cleanup

rm(list=ls())

# load libraries

library("ggplot2")
library("scales")
library("grid")
library("gridExtra")
library("splines")
library("MASS")

complexity_levels <- c("low", "medium", "high")
categories <- c(
    #"unidentified circular element","unidentified plasmid", "circular element",
    "all", "common strain","new_family","new_genus","new_order","new_species","new_strain", "unique strain" #,"virus"
    )

for (category in categories)
for (complexity_level in complexity_levels) {

    # options
    
    level <- "by_bin"
    bin_type <- "supervised"    
    filter_tail <- F
    best_only <- T
    all_ranks_combined <- T
    
    # directories
    
    repo.dir <- dirname(sys.frame(1)$ofile)
    
    metadata.dir <- file.path(repo.dir, "..", "metadata")
    results.dir <- file.path(repo.dir, "tables")
    figures.dir <- file.path(repo.dir, "plots")
    
    # files

    suffix <- paste("_", bin_type, "_", level, "_", category, ".tsv", sep="")
    ref_data_low.file <- file.path(results.dir, paste("low", suffix, sep=""))
    ref_data_medium.file <- file.path(results.dir, paste("medium", suffix, sep=""))
    ref_data_high.file <- file.path(results.dir, paste("high", suffix, sep=""))
    print(ref_data_low.file)

    # load data

    if (complexity_level=="high") {
        if (!file.exists(ref_data_high.file)) next
        ref_data_high <- read.table(ref_data_high.file, header=T, sep="\t")
        ref_data_high$group <- gsub("_[0-9]", "_high", ref_data_high$binner)
        ref_data_high$complexity <- "high"
        ref_data_combined <- ref_data_high
    }

    if (complexity_level=="medium") {
        if (!file.exists(ref_data_medium.file)) next
        ref_data_medium <- read.table(ref_data_medium.file, header=T, sep="\t")
        ref_data_medium$group <- gsub("_[0-9]", "_medium", ref_data_medium$binner)
        ref_data_medium$complexity <- "medium"
        ref_data_combined <- ref_data_medium
    }

    if (complexity_level=="low") {
        if (!file.exists(ref_data_low.file)) next
        ref_data_low <- read.table(ref_data_low.file, header=T, sep="\t")
        ref_data_low$group <- gsub("_[0-9]", "_low", ref_data_low$binner)
        ref_data_low$complexity <- "low"
        ref_data_combined <- ref_data_low
    }
   
    ref_data_combined <- ref_data_combined[ref_data_combined$bin!="unassigned", ]

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
    
    ### plotting
    
    points_size=1.25
    points_alpha=1
    points_shape=22
    bars_size=1
    bars_alpha=1
    
    # ggplot2 theme
    
    main_theme <- theme(panel.background=element_blank(),
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
         
        title <- paste("precision / recall", "(", rank, ")", sep="")
    
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
    
        best_tools <- unique(dfbest$binner)
    
        df <- ref_data_combined[ref_data_combined$rank==rank, ]
        
        df <- df[df$binner %in% best_tools, ]
   
                df$predicted_size <- as.numeric(df$predicted_size)                
 
        df$norm_pred_size <- NA
        df$norm_pred_size_cumsum <- NA
        df_norm <- df[NULL, ]
    
        for (binner in unique(df$binner)) {
        
            df_binner <- df[df$binner==binner, ]
            df_binner$norm_pred_size <- df_binner$predicted_size / sum(df_binner$predicted_size)
            idx <- sort(df_binner$norm_pred_size, index.return=T)$ix
            df_binner <- df_binner[idx, ]
            df_binner$norm_pred_size_cumsum <- cumsum(df_binner$norm_pred_size)
    
            df_norm <- rbind(df_norm, df_binner)
    
        }
    
        df <- df_norm
    
        title <- paste("precision (", rank, "; ", complexity_level, ")", sep="")
        
        p1 <- ggplot(df, aes(x=norm_pred_size_cumsum, y=precision, color=binner, fill=binner)) +
              geom_point(alpha=points_alpha, shape=19, size=0.5) +
              geom_hline(yintercept=-0.05) +
              scale_y_continuous(labels=percent) +
              facet_grid(binner ~ .) +
              labs(x="accumulated bin size") +
              ggtitle(title) +
              main_theme +
              theme(legend.position="none",
                    panel.grid.major=element_line(color="grey", size=0.1),
                    strip.background=element_rect(colour="black", fill="transparent")
                    )
         
        title <- paste("recall (", rank, "; ", complexity_level, ")", sep="")
        
        p2 <- ggplot(df, aes(x=norm_pred_size_cumsum, y=recall, color=binner, fill=binner)) +
              geom_point(alpha=points_alpha, shape=19, size=0.5) +
              geom_hline(yintercept=-0.05) +
              scale_y_continuous(labels=percent) +
              facet_grid(binner ~ .) +
              labs(x="accumulated bin size") +
              ggtitle(title) +
              main_theme +
              theme(legend.position="none",
                    panel.grid.major=element_line(color="grey", size=0.1),
                    strip.background=element_rect(colour="black", fill="transparent")
                    )
         
        pg1 <- grid.arrange(p1, p2, ncol=2)
        
        filename <- paste("prec_rec_sorted_", rank, "_", complexity_level, "_", category, ".pdf", sep="")
        filename <- gsub(" ", "_", filename)
        filepath <- file.path(figures.dir, bin_type, filename)
        ggsave(filepath, pg1, width=16, height=10)
        print(filepath)
    
    }

}
