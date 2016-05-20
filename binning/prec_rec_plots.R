
options(warn=-1)

# cleanup

rm(list=ls())

# load libraries

library("ggplot2")
library("scales")
library("grid")

# directories

repo.dir <- "C:/local_data/virtualbox_shared/Docs/CAMI/GitCAMI/firstchallenge_evaluation/"
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
ref_data_medium$group <- gsub("_[0-9]", "_medium", ref_data_medium$binner)
ref_data_high$group <- gsub("_[0-9]", "_high", ref_data_high$binner)

ref_data_combined <- rbind(ref_data_low, ref_data_medium, ref_data_high)
# ref_data_combined <- ref_data_high

# removing small bins (<= 1% pred. size) for each tool_parameter_set / rank combination

ref_data_combined <- within(ref_data_combined,
                            binner_rank <- paste(ref_data_combined$binner,
                                                 ref_data_combined$rank,
                                                 ref_data_combined$group,
                                                 sep='_'))

threshold <- 0.10
q <- aggregate(ref_data_combined$predicted_size, by=list(ref_data_combined$binner_rank), sum)
q[, 2] <- q[, 2]*threshold
for (i in 1:nrow(q)) {
    idx <- ref_data_combined$binner_rank==q[i, 1]
    s <- rev(ref_data_combined[idx, ]$predicted_size)
    cs <- cumsum(s)
    q[i, 2] <- s[min(which(cs>q[i, 2]))] 

} 

idx <- apply(ref_data_combined, 1, function(x) as.numeric(x[5]) > q[q[, 1]==x[8], 2])
ref_data_combined <- ref_data_combined[idx, ]


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

# plot precision / recall scatter plot combined

title <- "precision / recall"

df <- ref_data_combined
means <- aggregate(df, by=list(df$binner), FUN=mean, na.rm=T)
er <- aggregate(df, by=list(df$binner), FUN=sem, na.rm=T)
df <- data.frame(binner=means[, 1],
                 group=gsub("_[0-9]*$", "", means[, 1]),
                 precision=means$precision, recall=means$recall,
                 precision_er=er$precision, recall_er=er$recall)


p <- ggplot(df, aes(x=precision, y=recall, color=group)) +
     geom_errorbarh(aes(xmin=precision-precision_er,
                        xmax=precision+precision_er),
                    size=bars_size, alpha=bars_alpha, height=0) +
     geom_errorbar(aes(ymin=recall-recall_er,
                       ymax=recall+recall_er),
                   size=bars_alpha, alpha=bars_size, width=0) +
     scale_x_continuous(labels=percent, limits=c(0.0, 1)) +
     scale_y_continuous(labels=percent, limits=c(0, 1)) +
     geom_point(size=points_size, alpha=points_alpha, shape=points_shape, color="black") +
     ggtitle(title) +
     main_theme +
     theme(legend.position="right")

ggsave(paste(figures.dir, "prec_recall_combined.pdf", sep=""), p, width=7, height=5)

# plot precision / recall scatter plot combined per rank

title <- "precision / recall per rank"

df <- ref_data_combined
df <- df[df$rank!="superkingdom", ]
#df <- df[df$rank!="genus", ]
#df <- df[df$rank!="species", ]
 df$binner=gsub("_[0-9]*$", "", df$binner) # plot for single versus multiple binners
df$group_rank <- apply(df, 1, function(x) paste(x[1], x[2]))
 
means <- aggregate(df, by=list(df$group_rank), FUN=mean, na.rm=T)
er <- aggregate(df, by=list(df$group_rank), FUN=sem, na.rm=T)
df <- data.frame(binner=gsub(" .*", "", means[, 1]),
                 group=gsub("_[0-9] .*$", "", means[, 1]),
                 rank=gsub(".* ", "", means[, 1]),
                 precision=means$precision, recall=means$recall,
                 precision_er=er$precision, recall_er=er$recall)

df$rank <- factor(df$rank, levels=c("phylum", "class", "order", "family", "genus", "species"))

p <- ggplot(df, aes(x=precision, y=recall, color=binner, shape=rank)) +
     geom_errorbarh(aes(xmin=precision-precision_er,
                        xmax=precision+precision_er),
                    size=bars_size, alpha=bars_alpha, height=0) +
     geom_errorbar(aes(ymin=recall-recall_er,
                       ymax=recall+recall_er),
                   size=bars_alpha, alpha=bars_size, width=0) +
     scale_x_continuous(labels=percent, limits=c(0, 1)) +
     scale_y_continuous(labels=percent, limits=c(0, 1)) +
     geom_point(size=points_size, alpha=points_alpha, color="black") +
     ggtitle(title) +
     main_theme +
     theme(legend.position="right")

ggsave(paste(figures.dir, "prec_recall_combined_by_rank.pdf", sep=""), p, width=7, height=5)

