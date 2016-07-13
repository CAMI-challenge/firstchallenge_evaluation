library('yaml')

get_dataframe_of_tools_at <- function(directory)
{
	dir_path_list_results <- list.dirs(directory, full.names=T, recursive=F)

	# read description
	anonymous_names <- c()
	method_names <- c()
	pool_names <- c()
	dir_path_list <- c()

	index <- 1
	for (dir_path in dir_path_list_results)
	{
		#print(dir_path)
		fp_description <- file.path(dir_path, "description.properties")
		if (!file.exists(fp_description))
		{
			print(paste("WARNING: Missing file:", fp_description, sep=" "))
			next
		}

		text <- readLines(fp_description)
		text <- gsub(" = ", " - ", text)
		text <- gsub("metabat", "MetaBAT", text)
		description <- read.table(text=text, sep='=', row.names=1, stringsAsFactors=F, col.names=c("","value"))
		ian <- which( rownames(description) == "anonymous_name")
		imn <- which( rownames(description) == "method_name")
		ipn <- which( rownames(description) == "pool_name")
		anonymous_names[index] <- description$value[ian]
		method_names[index] <- description$value[imn]
		if (grepl("Gold Standard", anonymous_names[index]))
		{
			anonymous_names[index] <- "Gold Standard"
			method_names[index] <- "Gold Standard"
		}
		dir_path_list[index] <- dir_path
		pool_names[index] <- description$value[ipn]
		index <- index + 1
	}

	# read yaml
	list_tools <- list(
		)

	entry_count <- 1
	for (index in 1:length(dir_path_list))
	{
		dir_path <- dir_path_list[index]
		anonymous <- anonymous_names[index]
		method <- method_names[index]
		dataset <- pool_names[index]
		#print(dir_path)
		fp_yaml <- file.path(dir_path, "output", "biobox.yaml")
		yaml_data <- yaml.load_file(fp_yaml)
		category <- "all"
		for (result in yaml_data$results)
		{
			if (!is.null(result$category))
			{
				category <- as.character(result$category)
			}
			list_tools$anonymous[entry_count] <- anonymous
			list_tools$method[entry_count] <- method
			list_tools$dataset[entry_count] <- dataset
			list_tools$category[entry_count] <- category
			list_tools$file[entry_count] <- file.path(dir_path, "output", result$value)
			list_tools$datatype[entry_count] <- "unknown"

			if (grepl("summary_stats.tsv", result$value))
			{
				list_tools$datatype[entry_count] <- "summary"
			}
			if (grepl("summary_stats_99.tsv", result$value))
			{
				list_tools$datatype[entry_count] <- "summary99"
			}
			if (grepl("summary_stats_95.tsv", result$value))
			{
				list_tools$datatype[entry_count] <- "summary95"
			}
			if (grepl("absolute_counts.tsv", result$value))
			{
				list_tools$datatype[entry_count] <- "absolute"
			}
			if (grepl("absolute_counts_per_rank.tsv", result$value))
			{
				list_tools$datatype[entry_count] <- "absolute_per_rank"
			}
			if (grepl("perbin_stats.tsv", result$value))
			{
				list_tools$datatype[entry_count] <- "perbin"
			}
			if (grepl("unsupervised_precision_stats.tsv", result$value))
			{
				list_tools$datatype[entry_count] <- "unsupervised_excluded"
			}
			if (grepl("unsupervised_recall_stats.tsv", result$value))
			{
				list_tools$datatype[entry_count] <- "unsupervised_included"
			}
			if (grepl("cmat_heatmap", result$value))
			{
				list_tools$datatype[entry_count] <- "heatmap"
			}
			entry_count <- entry_count+1
		}
		# add bygenome data if available
		file_path_by_genome <- file.path(dir_path, "output", "by_genome.tsv")		
		if (file.exists(file_path_by_genome))
		{
			list_tools$anonymous[entry_count] <- anonymous
			list_tools$method[entry_count] <- method
			list_tools$dataset[entry_count] <- dataset
			list_tools$category[entry_count] <- category
			list_tools$file[entry_count] <- file_path_by_genome
			list_tools$datatype[entry_count] <- "bygenome"
			entry_count <- entry_count+1
		}
	}

	data_frame_tools <- data.frame(
		anonymous = as.vector(list_tools$anonymous),
		method = as.vector(list_tools$method),
		dataset = as.vector(list_tools$dataset),
		category = as.vector(list_tools$category),
		file = as.vector(list_tools$file),
		datatype = as.vector(list_tools$datatype)
		)

	return(data_frame_tools)
}

#argv <- commandArgs(TRUE)
#dir_path_root <- argv[1]
#root_directory_list <- "."

get_dataframe_of_tools_at_locations <- function(root_directory_list)
{
	root_directories <- strsplit(root_directory_list, ",")
	dataframe_tools <- NULL
	for (directory in root_directories)
	{
		if (is.null(dataframe_tools))
		{
			dataframe_tools <- get_dataframe_of_tools_at(directory)
		}
		else
		{
			dataframe_tools <- rbind(dataframe_tools, get_dataframe_of_tools_at(directory))
		}
	}
	return(dataframe_tools)
}

#argv <- commandArgs(TRUE)
#root_folder <- argv[1]
#df <- get_dataframe_of_tools_at_locations(root_folder)
#print(summary(df))
#df_s <- subset(df, datatype=="unknown")
#print(summary(df_s))

