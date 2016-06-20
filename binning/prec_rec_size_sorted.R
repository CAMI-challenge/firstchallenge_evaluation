
options(warn=-1)

# cleanup

rm(list=ls())

# load libraries

library("ggplot2")
library("scales")
library("grid")
library("splines")
library("MASS")

# directories

repo.dir <- "/biodata/dep_psl/grp_psl/garridoo/cami/firstchallenge_evaluation/"
results.dir <- paste(repo.dir, "/binning/data/superviced/ALL/by_bin/", sep="")
figures.dir <- paste(repo.dir, "/binning/plots/superviced/", sep="")

# files

ref_data_low.file <- paste(results.dir, "/low/all.txt", sep="")
ref_data_medium.file <- paste(results.dir, "/medium/all.txt", sep="")
ref_data_high.file <- paste(results.dir, "/high/all.txt", sep="")

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

# removing small bins (<= 1% pred. size) for each tool_parameter_set / rank combination

ref_data_combined <- within(ref_data_combined,
                            binner_rank <- paste(ref_data_combined$binner,
                                                 ref_data_combined$rank,
                                                 ref_data_combined$group,
                                                 sep='_'))

# threshold <- 0.01
# q <- aggregate(ref_data_combined$predicted_size, by=list(ref_data_combined$binner_rank), sum)
# q[, 2] <- q[, 2]*threshold
# for (i in 1:nrow(q)) {
#     idx <- ref_data_combined$binner_rank==q[i, 1]
#     s <- rev(ref_data_combined[idx, ]$predicted_size)
#     cs <- cumsum(s)
#     q[i, 2] <- s[min(which(cs>q[i, 2]))]
# }
# 
# idx <- apply(ref_data_combined, 1, function(x) as.numeric(x[6]) > q[q[, 1]==x[10], 2])
# ref_data_combined <- ref_data_combined[idx, ]

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

complexity <- "high"

for (complexity in unique(ref_data_combined$complexity)) {

    ref_data <- ref_data_combined[ref_data_combined$complexity==complexity, ]
    
    idx <- grepl("Gold_Standard", ref_data$binner)
    bin_sizes <- data.frame(bin=ref_data$bin[idx],
                            real_size=ref_data$real_size[idx])
    bin_sizes <- bin_sizes[bin_sizes$real_size > 0, ]
    bin_sizes <- unique(bin_sizes)
    idx <- sort(bin_sizes$real_size, index.return=T)$ix
    bin_sizes <- bin_sizes[idx, ]
    bin_sizes$idx <- 1:nrow(bin_sizes)
    
    
    idx <- ref_data$bin %in% bin_sizes$bin
    ref_data <- ref_data[idx, ]
    
    ref_data$bin <- factor(ref_data$bin, levels=bin_sizes$bin)
    ref_data$idx <- as.numeric(bin_sizes$idx[match(ref_data$bin, bin_sizes$bin)])
    
    df <- ref_data
    
    df$tool <- gsub('_[highlowmedium]+', "", df$group)
    
    dfbest <- NULL
    for (g in unique(df$group)) {
    
        dfg <- df[df$group==g, ]
        dfg <- aggregate(dfg$recall, by=list(dfg$binner), FUN=mean, na.rm=T)
        idx <- sort(dfg$x, decreasing=T, index.return=T)$ix
            dfg <- as.character(dfg[idx[1], 1])
            dfbest <- rbind(dfbest, dfg)
    
    }
    
    df <- df[df$binner %in% dfbest, ]
    
    p2 <- ggplot(df, aes(x=idx, y=precision, color=tool)) +
          geom_point(alpha=points_alpha, shape=19, size=0.1) +
          stat_smooth(method="lm", formula=y ~ ns(x, 7), se=F, size=0.5) +
          scale_y_continuous(labels=percent, limits=c(0, 1)) +
          labs(x="bin") +
          main_theme +
          theme(legend.position="none",
                 axis.text.x=element_blank(),
                 axis.ticks.x=element_blank())
    
    p3 <- ggplot(df, aes(x=idx, y=recall, color=tool)) +
          geom_point(alpha=points_alpha, shape=19, size=0.1) +
          stat_smooth(method="lm", formula=y ~ ns(x, 7), se=F, size=0.6) +
          scale_y_continuous(labels=percent, limits=c(0, 1)) +
          labs(x="bin") +
          main_theme +
          theme(legend.position="bottom",
                 axis.text.x=element_blank(),
                 axis.ticks.x=element_blank())
    
    dg<- df[df$tool=="Gold_Standard", ]
    p1 <- ggplot(dg, aes(x=bin, y=real_size)) +
          geom_bar(stat="identity", alpha=points_alpha, size=0.1) +
          labs(x="bin", y="bin size") +
          ggtitle(complexity) +
          main_theme +
          theme(legend.position="none",
                 axis.text.x=element_blank(),
                 axis.ticks.x=element_blank())
    
    p1 <- ggplot_gtable(ggplot_build(p1))
    p2 <- ggplot_gtable(ggplot_build(p2))
    p3 <- ggplot_gtable(ggplot_build(p3))
    
    maxWidth = unit.pmax(p1$widths[2:3],
                         p2$widths[2:3],
                         p3$widths[2:3])
    
    p1$widths[2:3] <- maxWidth
    p2$widths[2:3] <- maxWidth
    p3$widths[2:3] <- maxWidth
    
    pg1 <- grid.arrange(p1, p2, heights = c(3, 4))
    pgf <- grid.arrange(pg1, p3, heights = c(6, 4))
    
    ggsave(paste(figures.dir, "prec_rec_size_sorted_", complexity, ".pdf", sep=""), pgf, width=10, height=8, useDingbats=F)

}

