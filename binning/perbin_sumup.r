source("parse_raw_result_data.R")

argv <- commandArgs(TRUE)
root_folder <- argv[1]
output_folder <- root_folder

datatype <- "perbin"
if (length(argv)>1)
{
	datatype <- argv[2]
}

df_tools <- get_dataframe_of_tools_at_locations(root_folder)
df_tools_perbin <- subset(df_tools, datatype=="perbin")

low <- subset(df_tools_perbin, dataset=="1st CAMI Challenge Dataset 1 CAMI_low")
medium <- subset(df_tools_perbin, dataset=="1st CAMI Challenge Dataset 2 CAMI_medium")
high <- subset(df_tools_perbin, dataset=="1st CAMI Challenge Dataset 3 CAMI_high")


#binner	rank	bin	precision	recall	predicted_size	real_size
# "instance"	"class"	"precision"	"recall"	"predicted.class.size"	"real.class.size"	"binner"

get_dataframe_of_tools_at <- function(data)
{
	sumup <- NULL
	for(index in 1:length(data$files))
	{
		tmp <- read.csv(as.character(data$files[index]),sep = "\t")
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

category <- "all"
sumup <- get_dataframe_of_tools_at(low)
file_name <- paste("low_", category, "_", datatype, ".tsv", sep="")
file_path <- file.path(output_folder, file_name)
write.table(sumup, file=file_path,row.names=FALSE, sep = "\t")

sumup <- get_dataframe_of_tools_at(medium)
file_name <- paste("medium_", category, "_", datatype, ".tsv", sep="")
file_path <- file.path(output_folder, file_name)
write.table(sumup, file=file_path,row.names=FALSE, sep = "\t")

sumup <- get_dataframe_of_tools_at(high)
file_name <- paste("high_", category, "_", datatype, ".tsv", sep="")
file_path <- file.path(output_folder, file_name)
write.table(sumup, file=file_path,row.names=FALSE, sep = "\t")

