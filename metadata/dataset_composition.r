library(grid)
library(reshape2)
library(ggplot2)
library(gridExtra)
library(scales)
#library(cowplot)

separator = '\t'

raw_data <- read.table("dataset_composition.tsv", sep = separator, header=T) # , row.names=1
levels_labels <- as.vector(raw_data$type)
df <- as.data.frame.matrix(raw_data)

raw_data_novelty <- read.table("dataset_composition_novelty.tsv", sep = separator, header=T) # , row.names=1
df_novelty <- as.data.frame.matrix(raw_data_novelty)
df_novelty_mini <- data.frame(
	X = "Novelty",
	type = df_novelty$novelty,
	Low = df_novelty$Low,
	Medium = df_novelty$Medium,
	High = df_novelty$High
)
levels_labels <- unique(c(levels_labels, as.vector(df_novelty_mini$type)))

df <- rbind(df, df_novelty_mini)

melted <- melt(df, c("X", "type"))

df$Low <- df$Low/(sum(df$Low)/3.0)
df$Medium <- df$Medium/(sum(df$Medium)/3.0)
df$High <- df$High/(sum(df$High)/3.0)

melted.r <- melt(df, c("X", "type"))
melted$percent <- melted.r$value

melted$type <- factor(melted$type, levels=levels_labels, labels=levels_labels)
melted$X <- factor(melted$X, levels=c("Novelty", "ANI", "Genomes"))

label_positions <- c(
		cumsum(melted$percent[Reduce("&", list(melted$variable=="Low", melted$X == "Genomes"))])-melted$percent[Reduce("&", list(melted$variable=="Low", melted$X == "Genomes"))]/2.0,
		cumsum(melted$percent[Reduce("&", list(melted$variable=="Low", melted$X == "ANI"))])-melted$percent[Reduce("&", list(melted$variable=="Low", melted$X == "ANI"))]/2.0,
		cumsum(melted$percent[Reduce("&", list(melted$variable=="Low", melted$X == "Novelty"))])-melted$percent[Reduce("&", list(melted$variable=="Low", melted$X == "Novelty"))]/2.0,
		cumsum(melted$percent[Reduce("&", list(melted$variable=="Medium", melted$X == "Genomes"))])-melted$percent[Reduce("&", list(melted$variable=="Medium", melted$X == "Genomes"))]/2.0,
		cumsum(melted$percent[Reduce("&", list(melted$variable=="Medium", melted$X == "ANI"))])-melted$percent[Reduce("&", list(melted$variable=="Medium", melted$X == "ANI"))]/2.0,
		cumsum(melted$percent[Reduce("&", list(melted$variable=="Medium", melted$X == "Novelty"))])-melted$percent[Reduce("&", list(melted$variable=="Medium", melted$X == "Novelty"))]/2.0,
		cumsum(melted$percent[Reduce("&", list(melted$variable=="High", melted$X == "Genomes"))])-melted$percent[Reduce("&", list(melted$variable=="High", melted$X == "Genomes"))]/2.0,
		cumsum(melted$percent[Reduce("&", list(melted$variable=="High", melted$X == "ANI"))])-melted$percent[Reduce("&", list(melted$variable=="High", melted$X == "ANI"))]/2.0,
		cumsum(melted$percent[Reduce("&", list(melted$variable=="High", melted$X == "Novelty"))])-melted$percent[Reduce("&", list(melted$variable=="High", melted$X == "Novelty"))]/2.0
	)
label_positions[melted$percent==0] <- -2

gplot <- ggplot(melted, aes(x = X, y = percent, fill = type, label=type)) + #, order = as.numeric(type)
	geom_bar(stat = 'identity', position = 'stack') +
	#scale_x_discrete(labels=NULL) +
	scale_y_continuous(labels=percent, limits=c(0.0, 1), expand = c( 0.01 , 0.01 )) +
	facet_grid(variable ~ ., switch = "y") +
	coord_flip() +
	guides(fill=FALSE) +
	geom_text(
			nudge_x=-0.2,
			size = 3,
			aes(
				label=value,
				y=label_positions)) +
	geom_label(
			nudge_x=0.2,
			size = 3,
			aes(y=label_positions))+
	labs(title="Dataset Composition", fill=NULL, x=NULL, y="% Genomes") +
	theme(
		strip.text.y = element_text(face = "bold")
		) # axis.ticks.y = element_blank()
# ggdraw(switch_axis_position(gplot, axis = 'x'))
output_file_path <- "dataset_composition.pdf"
ggsave(output_file_path, gplot, width=297, height=210, units='mm')#, device="pdf"

