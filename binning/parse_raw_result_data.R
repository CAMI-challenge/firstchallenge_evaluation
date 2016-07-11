library('yaml')

get_dataframe_of_tools_at <- function(directory)
{
	dir_path_list_results <- list.dirs(directory, full.names=T, recursive=F)

	# read description
	anonymous_names <- rep("", length(dir_path_list_results))
	method_names <- rep("", length(dir_path_list_results))
	pool_names <- rep("", length(dir_path_list_results))

	index <- 1
	for (dir_path in dir_path_list_results)
	{
		#print(dir_path)
		fp_description <- file.path(dir_path, "description.properties")

		text <- readLines(fp_description)
		text <- gsub(" = ", " - ", text)
		text <- gsub("metabat", "MetaBAT", text)
		description <- read.table(text=text, sep='=', row.names=1, stringsAsFactors=F, col.names=c("","value"))
		ian <- which( rownames(description) == "anonymous_name")
		imn <- which( rownames(description) == "method_name")
		ipn <- which( rownames(description) == "pool_name")
		anonymous_names[index] <- description$value[ian]
		if (grepl("Gold Standard", anonymous_names[index]))
		{
			anonymous_names[index] <- "Gold Standard"
		}
		method_names[index] <- description$value[imn]
		pool_names[index] <- description$value[ipn]
		index <- index + 1
	}

	# read yaml

	## count categories
	fp_yaml <- file.path(dir_path_list_results[1], "output", "biobox.yaml")
	yaml_data <- yaml.load_file(fp_yaml)
	category_names <- list()
	#yaml_data$results[[1]]$category <- "test1"
	#yaml_data$results[[2]]$category <- "test2"

	for (result in yaml_data$results)
	{
		if (!is.null(result$category) && grepl("unsupervised_recall_stats", result$value))
		{
			category_names[length(category_names)+1] <- result$category
		}
	}
	category_names <- unlist(category_names)
	if (length(category_names) == 0)
	{
		category_names <- c("all")
	}
	#category_count <- length(category_names)

	datatypes <- list()
	datatypes$summary <- list()
	datatypes$absolute <- list()
	datatypes$perbin <- list()
	datatypes$bygenome <- list()
	datatypes$unsupervised <- list()
	file_paths <- list()
	file_paths$perbin <- list() #  rep("", length(dir_path_list_results))
	file_paths$bygenome <- list() #  rep("", length(dir_path_list_results))
	file_paths$summary <- list() #  rep("", length(dir_path_list_results))
	file_paths$absolute <- list() #  rep("", length(dir_path_list_results))
	file_paths$absolute_per_rank <- list() #  rep("", length(dir_path_list_results))
	file_paths$unsupervised_excluded <- list() #  rep("", length(dir_path_list_results))
	file_paths$unsupervised_included <- list() #  rep("", length(dir_path_list_results))

	index <- 1
	for (dir_path in dir_path_list_results)
	{
		#print(dir_path)
		fp_yaml <- file.path(dir_path, "output", "biobox.yaml")
		yaml_data <- yaml.load_file(fp_yaml)
		for (result in yaml_data$results)
		{
			if (grepl("summary_stats.tsv", result$value))
			{
				datatypes$summary[length(datatypes$summary)+1] <- "summary"
				file_paths$summary[length(file_paths$summary)+1] <- file.path(dir_path, "output", result$value)
			}
			if (grepl("absolute_counts.tsv", result$value))
			{
				datatypes$absolute[length(datatypes$absolute)+1] <- "absolute"
				file_paths$absolute[length(file_paths$absolute)+1] <- file.path(dir_path, "output", result$value)
			}
			if (grepl("absolute_counts_per_rank.tsv", result$value))
			{
				datatypes$absolute_per_rank[length(datatypes$absolute_per_rank)+1] <- "absolute_per_rank"
				file_paths$absolute_per_rank[length(file_paths$absolute_per_rank)+1] <- file.path(dir_path, "output", result$value)
			}
			if (grepl("perbin_stats.tsv", result$value))
			{
				datatypes$perbin[length(datatypes$perbin)+1] <- "perbin"
				file_paths$perbin[length(file_paths$perbin)+1] <- file.path(dir_path, "output", result$value)
				# quick fiix for added data not contained in yaml file
				datatypes$bygenome[length(datatypes$bygenome)+1] <- "bygenome"
				file_paths$bygenome[length(file_paths$bygenome)+1] <- file.path(dir_path, "output", "by_genome.tsv")
			}
			if (grepl("unsupervised_precision_stats.tsv", result$value))
			{
				datatypes$unsupervised_excluded[length(datatypes$unsupervised_excluded)+1] <- "unsupervised_excluded"
				file_paths$unsupervised_excluded[length(file_paths$unsupervised_excluded)+1] <- file.path(dir_path, "output", result$value)
			}
			if (grepl("unsupervised_recall_stats.tsv", result$value))
			{
				datatypes$unsupervised_included[length(datatypes$unsupervised_included)+1] <- "unsupervised_included"
				file_paths$unsupervised_included[length(file_paths$unsupervised_included)+1] <- file.path(dir_path, "output", result$value)
			}
		}
		index <- index + 1
	}

	tdatatypes <- as.vector(t(
		matrix(
			c(
				unlist(datatypes$summary), 
				unlist(datatypes$absolute), 
				unlist(datatypes$absolute_per_rank), 
				unlist(datatypes$perbin), 
				unlist(datatypes$bygenome), 
				unlist(datatypes$unsupervised_excluded), 
				unlist(datatypes$unsupervised_included)
			), 
			nrow=length(category_names))
		))
	tfiles <- as.vector(t(
		matrix(
			c(
				unlist(file_paths$summary), 
				unlist(file_paths$absolute), 
				unlist(file_paths$absolute_per_rank), 
				unlist(file_paths$perbin), 
				unlist(file_paths$bygenome), 
				unlist(file_paths$unsupervised_excluded), 
				unlist(file_paths$unsupervised_included)
			), 
			nrow=length(category_names))
		))

	if (length(union(
			length(file_paths$summary), 
			c(length(file_paths$perbin), 
			length(file_paths$absolute), 
			length(file_paths$absolute_per_rank))
			))!=1)
	{
		stop("ERROR: BAD FILE COUNT! (unsupervised)")
	}
	if (length(union(
			length(file_paths$unsupervised_excluded), 
			length(file_paths$unsupervised_included)
			))!=1)
	{
		stop("ERROR: BAD FILE COUNT! (unsupervised)")
	}
	#tdatatypes <- unlist(datatypes)
	if (length(file_paths$perbin)>0)
	{
		categories <- as.vector(t(matrix(rep(category_names,length(anonymous_names)*7), nrow=length(category_names))))
	}
	else
	{
		categories <- as.vector(t(matrix(rep(category_names,length(anonymous_names)*2), nrow=length(category_names))))
	}
	#print(categories)
	#print(tfiles)
	#print(tdatatypes)
	
	data_frame_tools <- data.frame(
		anonymous = anonymous_names,
		method = method_names,
		dataset = pool_names,
		categories = categories,
		files = tfiles,
		datatype = tdatatypes)
	#levels(data_frame_tools$method)
	#print(data_frame_tools$categories)
	#print(data_frame_tools$files)
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


