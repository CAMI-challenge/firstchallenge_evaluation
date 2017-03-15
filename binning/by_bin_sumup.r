source("parse_raw_result_data.R")

get_data_table <- function(data)
{
	sumup <- NULL
	for(index in 1:length(data$file))
	{
		file_path <- as.character(data$file[index])
		tmp <- read.csv(file_path,sep = "\t")
		tmp$binner <- rep(as.character(as.character(data$anonymous[index])), dim(tmp)[1])
		if (is.null(sumup))
		{
			sumup <- tmp
		}
		else
		{
			sumup <- rbind(sumup, tmp)
		}
	}
	colnames(sumup) <- c("rank", "bin", "precision", "recall", "predicted_size", "real_size", "binner")
	return(sumup)
}

# levels <- c("by_bin", "by_genome")
levels <- c("by_genome")
bin_types <- c(
	"supervised",
	"supervised",
	"supervised",
	"unsupervised",
	"unsupervised",
	"unsupervised"
	)
bin_types <- c(
	"supervised",
	"unsupervised"
	)
bin_location <- c(
	paste(
		file.path("data", "taxonomic"),
		file.path("data", "taxonomic_novelty"),
		file.path("data", "taxonomic_uniqueness"),
		sep=','
		),
	paste(
		file.path("data", "unsupervised"),
		file.path("data", "unsupervised_novelty"),
		file.path("data", "unsupervised_uniqueness"),
		sep=','
		)
	)

datasets <- c(
	"1st CAMI Challenge Dataset 1 CAMI_low",
	"1st CAMI Challenge Dataset 2 CAMI_medium",
	"1st CAMI Challenge Dataset 3 CAMI_high"
	)
names(datasets) <- c("low", "medium", "high")
#argv <- commandArgs(TRUE)
#output_dir <- argv[1]
root_dir <- "."
output_dir <- file.path(root_dir, "tables")


for (dir_index in 1:length(bin_location))
{
	data_dir <- file.path(root_dir, bin_location[dir_index])
	print(data_dir)
	df_tools <- get_dataframe_of_tools_at_locations(data_dir)
	# print(levels(df_tools$category))
	for (data_type in levels)
	{
		df_tools_by_type <- subset(df_tools, datatype==data_type)
		for (data_category in as.vector(levels(df_tools$category)))
		{
			df_tools_by_type_by_category <- subset(df_tools_by_type, category==data_category)
			for (dataset_name in names(datasets))
			{
				data_subset <- subset(df_tools_by_type_by_category, dataset==datasets[dataset_name])
				if (length(data_subset$file) < 1) next
				sumup <- get_data_table(data_subset)
				file_name <- paste(dataset_name, "_", bin_types[dir_index], "_", data_type, "_", data_category, ".tsv", sep="")
				file_path <- file.path(output_dir, file_name)
				write.table(sumup, file=file_path, row.names=FALSE, sep = "\t")
			}
		}
	}
}

