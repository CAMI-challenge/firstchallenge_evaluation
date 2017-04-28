source("prec_rec_plots.R")
argv <- commandArgs(TRUE)
root_dir = argv[1]
device = argv[2]
prec_rec_plot(root_dir, T, T, T, device)
#source("prec_rec_size_sorted.R")

