# This script was used to build cumulativ plots for the high complexity dataset
# Please provide the path to each assembler and the png output file path in the first block

#########################################
#### BLOCK 1 - Path to the assemblies
#########################################


outputFileName = ''

# jolly_mcclintock_0 = Velour k63 c2.0
jolly_mcclintock_0_path <- ""

# jovial_tesla_0 = A* k63
jovial_tesla_0_path <- ""

# hungry_colden = Gold Standard
hungry_colden_path <- ""

# backstabbing_carson_0 = Velour k63 c2.0
backstabbing_carson_0_path <- ""

# jolly_mcclintock_0 = Velour k31 c2.0
clever_hypatia_1_path <- ""

# fervent_mayer_0 = Minia k21-k91
fervent_mayer_0_path <- ""

# suspicious_pare_2 = Ray k71
suspicious_pare_2_path <- ""

# suspicious_pare_4 = Ray k91
suspicious_pare_4_path <- ""

# sick_colden_0 = Velour k31 c4.01
sick_colden_0_path <- ""

# suspicious_mcclintock_0 = Velour k63 c2.0
suspicious_mcclintock_0_path <- ""

# stupefied_mclean_0 = Megahit ep k21-k91
stupefied_mclean_0_path <- ""

# insane_brattain_0 = Megahit ep mtl200 k21-k91
insane_brattain_0_path <- ""

# goofy_tesla_0 = Meraga k33-k63
goofy_tesla_0_path <- ""

#########################################
#### BLOCK 2 - Read in contig length of each assembler
#########################################

summary.jovial_tesla_0 <- read.csv(jovial_tesla_0_path,
                         head=T, row.names=1, sep="\t", check.names=T)
summary.jovial_tesla_0[is.na(summary.jovial_tesla_0)] <- 0
sizes.jovial_tesla_0 <- summary.jovial_tesla_0[,'contig_length', drop=FALSE]


summary.jolly_mcclintock_0 <- read.csv(jolly_mcclintock_0_path,
                           head=T, row.names=1, sep="\t", check.names=T)
summary.jolly_mcclintock_0[is.na(summary.jolly_mcclintock_0)] <- 0
sizes.jolly_mcclintock_0 <- summary.jolly_mcclintock_0[,'contig_length', drop=FALSE]


summary.hungry_colden <- read.csv(hungry_colden_path,
                           head=T, row.names=1, sep="\t", check.names=T)
summary.hungry_colden[is.na(summary.hungry_colden)] <- 0
sizes.hungry_colden <- summary.hungry_colden[,'contig_length', drop=FALSE]


summary.backstabbing_carson_0 <- read.csv(backstabbing_carson_0_path,
                           head=T, row.names=1, sep="\t", check.names=T)
summary.backstabbing_carson_0[is.na(summary.backstabbing_carson_0)] <- 0
sizes.backstabbing_carson_0 <- summary.backstabbing_carson_0[,'contig_length', drop=FALSE]


summary.clever_hypatia_1<- read.csv(clever_hypatia_1_path,
                           head=T, row.names=1, sep="\t", check.names=T)
summary.clever_hypatia_1[is.na(summary.clever_hypatia_1)] <- 0
sizes.clever_hypatia_1<- summary.clever_hypatia_1[,'contig_length', drop=FALSE]


summary.fervent_mayer_0<- read.csv(fervent_mayer_0_path,
                           head=T, row.names=1, sep="\t", check.names=T)
summary.fervent_mayer_0[is.na(summary.fervent_mayer_0)] <- 0
sizes.fervent_mayer_0<- summary.fervent_mayer_0[,'contig_length', drop=FALSE]


summary.suspicious_pare_2 <- read.csv(suspicious_pare_2_path,
                           head=T, row.names=1, sep="\t", check.names=T)
summary.suspicious_pare_2[is.na(summary.suspicious_pare_2)] <- 0
sizes.suspicious_pare_2<- summary.suspicious_pare_2[,'contig_length', drop=FALSE]



summary.suspicious_pare_4 <- read.csv(suspicious_pare_4_path,
                           head=T, row.names=1, sep="\t", check.names=T)
summary.suspicious_pare_4[is.na(summary.suspicious_pare_4)] <- 0
sizes.suspicious_pare_4<- summary.suspicious_pare_4[,'contig_length', drop=FALSE]


summary.sick_colden_0 <- read.csv(sick_colden_0_path,
                           head=T, row.names=1, sep="\t", check.names=T)
summary.sick_colden_0[is.na(summary.sick_colden_0)] <- 0
sizes.sick_colden_0<- summary.sick_colden_0[,'contig_length', drop=FALSE]


summary.suspicious_mcclintock_0<- read.csv(suspicious_mcclintock_0_path,
                           head=T, row.names=1, sep="\t", check.names=T)
summary.suspicious_mcclintock_0[is.na(summary.suspicious_mcclintock_0)] <- 0
sizes.suspicious_mcclintock_0<- summary.suspicious_mcclintock_0[,'contig_length', drop=FALSE]


summary.stupefied_mclean_0<- read.csv(stupefied_mclean_0_path,
                           head=T, row.names=1, sep="\t", check.names=T)
summary.stupefied_mclean_0[is.na(summary.stupefied_mclean_0)] <- 0
sizes.stupefied_mclean_0<- summary.stupefied_mclean_0[,'contig_length', drop=FALSE]


summary.insane_brattain_0<- read.csv(insane_brattain_0_path,
                           head=T, row.names=1, sep="\t", check.names=T)
summary.insane_brattain_0[is.na(summary.insane_brattain_0)] <- 0
sizes.insane_brattain_0<- summary.insane_brattain_0[,'contig_length', drop=FALSE]


summary.goofy_tesla_0<- read.csv(goofy_tesla_0_path,
                           head=T, row.names=1, sep="\t", check.names=T)
summary.goofy_tesla_0[is.na(summary.goofy_tesla_0)] <- 0
sizes.goofy_tesla_0<- summary.goofy_tesla_0[,'contig_length', drop=FALSE]

#########################################
#### BLOCK 3 - Compute cumulative sums
#########################################

contigSizes.backstabbing_carson_0 <- summary.backstabbing_carson_0[order(summary.backstabbing_carson_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.backstabbing_carson_0 <- cumsum(as.numeric(contigSizes.backstabbing_carson_0))
contigNum.backstabbing_carson_0 <- c(rep(1, length(contigSizes.backstabbing_carson_0)))
contigNum.backstabbing_carson_0 <- cumsum(as.numeric(contigNum.backstabbing_carson_0))

contigSizes.jolly_mcclintock_0 <- summary.jolly_mcclintock_0[order(summary.jolly_mcclintock_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.jolly_mcclintock_0 <- cumsum(as.numeric(contigSizes.jolly_mcclintock_0))
contigNum.jolly_mcclintock_0 <- c(rep(1, length(contigSizes.jolly_mcclintock_0)))
contigNum.jolly_mcclintock_0 <- cumsum(as.numeric(contigNum.jolly_mcclintock_0))

contigSizes.hungry_colden <- summary.hungry_colden[order(summary.hungry_colden[, "contig_length"], decreasing=T), "contig_length"]
contigSums.hungry_colden <- cumsum(as.numeric(contigSizes.hungry_colden))
contigNum.hungry_colden <- c(rep(1, length(contigSizes.hungry_colden)))
contigNum.hungry_colden <- cumsum(as.numeric(contigNum.hungry_colden))

contigSizes.jovial_tesla_0 <- summary.jovial_tesla_0[order(summary.jovial_tesla_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.jovial_tesla_0 <- cumsum(as.numeric(contigSizes.jovial_tesla_0))
contigNum.jovial_tesla_0 <- c(rep(1, length(contigSizes.jovial_tesla_0)))
contigNum.jovial_tesla_0 <- cumsum(as.numeric(contigNum.jovial_tesla_0))

contigSizes.clever_hypatia_1 <- summary.clever_hypatia_1[order(summary.clever_hypatia_1[, "contig_length"], decreasing=T), "contig_length"]
contigSums.clever_hypatia_1 <- cumsum(as.numeric(contigSizes.clever_hypatia_1))
contigNum.clever_hypatia_1 <- c(rep(1, length(contigSizes.clever_hypatia_1)))
contigNum.clever_hypatia_1 <- cumsum(as.numeric(contigNum.clever_hypatia_1))

contigSizes.fervent_mayer_0 <- summary.fervent_mayer_0[order(summary.fervent_mayer_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.fervent_mayer_0 <- cumsum(as.numeric(contigSizes.fervent_mayer_0))
contigNum.fervent_mayer_0 <- c(rep(1, length(contigSizes.fervent_mayer_0)))
contigNum.fervent_mayer_0 <- cumsum(as.numeric(contigNum.fervent_mayer_0))


contigSizes.suspicious_pare_2<- summary.suspicious_pare_2[order(summary.suspicious_pare_2[, "contig_length"], decreasing=T), "contig_length"]
contigSums.suspicious_pare_2<- cumsum(as.numeric(contigSizes.suspicious_pare_2))
contigNum.suspicious_pare_2<- c(rep(1, length(contigSizes.suspicious_pare_2)))
contigNum.suspicious_pare_2<- cumsum(as.numeric(contigNum.suspicious_pare_2))

contigSizes.suspicious_pare_4<- summary.suspicious_pare_4[order(summary.suspicious_pare_4[, "contig_length"], decreasing=T), "contig_length"]
contigSums.suspicious_pare_4<- cumsum(as.numeric(contigSizes.suspicious_pare_4))
contigNum.suspicious_pare_4<- c(rep(1, length(contigSizes.suspicious_pare_4)))
contigNum.suspicious_pare_4<- cumsum(as.numeric(contigNum.suspicious_pare_4))


contigSizes.sick_colden_0<- summary.sick_colden_0[order(summary.sick_colden_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.sick_colden_0<- cumsum(as.numeric(contigSizes.sick_colden_0))
contigNum.sick_colden_0<- c(rep(1, length(contigSizes.sick_colden_0)))
contigNum.sick_colden_0<- cumsum(as.numeric(contigNum.sick_colden_0))

contigSizes.suspicious_mcclintock_0<- summary.suspicious_mcclintock_0[order(summary.suspicious_mcclintock_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.suspicious_mcclintock_0<- cumsum(as.numeric(contigSizes.suspicious_mcclintock_0))
contigNum.suspicious_mcclintock_0<- c(rep(1, length(contigSizes.suspicious_mcclintock_0)))
contigNum.suspicious_mcclintock_0<- cumsum(as.numeric(contigNum.suspicious_mcclintock_0))

contigSizes.stupefied_mclean_0<- summary.stupefied_mclean_0[order(summary.stupefied_mclean_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.stupefied_mclean_0<- cumsum(as.numeric(contigSizes.stupefied_mclean_0))
contigNum.stupefied_mclean_0<- c(rep(1, length(contigSizes.stupefied_mclean_0)))
contigNum.stupefied_mclean_0<- cumsum(as.numeric(contigNum.stupefied_mclean_0))

contigSizes.insane_brattain_0<- summary.insane_brattain_0[order(summary.insane_brattain_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.insane_brattain_0<- cumsum(as.numeric(contigSizes.insane_brattain_0))
contigNum.insane_brattain_0<- c(rep(1, length(contigSizes.insane_brattain_0)))
contigNum.insane_brattain_0<- cumsum(as.numeric(contigNum.insane_brattain_0))

contigSizes.goofy_tesla_0<- summary.goofy_tesla_0[order(summary.goofy_tesla_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.goofy_tesla_0<- cumsum(as.numeric(contigSizes.goofy_tesla_0))
contigNum.goofy_tesla_0<- c(rep(1, length(contigSizes.goofy_tesla_0)))
contigNum.goofy_tesla_0<- cumsum(as.numeric(contigNum.goofy_tesla_0))


#########################################
#### BLOCK 4 - Build the plots
#########################################

png(outputFileName, res = 300, height= 4000, width = 2500)
par(xpd=F, mfrow=c(2,1), mar=c(4,4,4,4))

create_plots_contig_size <- function(x ,y , main, plots){
  extract <- function(arrays, pos){
    arrays[pos]
  }

  counter <<- 0
  for (assembler in plots){
    counter <<- counter + 1
    assemblerContigNumber <- assembler[1]
    assemblerContigSums <- assembler[2]
    color <- assembler[3]

    print(rev(range(unlist(sapply(plots, function(elem){ extract(elem,1)})))))

    plot(unlist(assemblerContigNumber), unlist(assemblerContigSums), type='l', log="x",
         xlim=rev(range(unlist(sapply(plots, function(elem){ extract(elem,1)})))),
         ylim=c(1,max(unlist(sapply(plots, function(elem){ extract(elem,2)})), na.rm=TRUE)),
         col=unlist(color),
         main=main,
         xlab=x,
         ylab=y)
    abline(h=max(unlist(assemblerContigSums))/2, col=unlist(color))
    if(counter != length(plots)){
      par(new=T, xpd=F)
    }
  }
  legend("topleft", border="black",
         legend=unlist(sapply(plots, function(elem){ extract(elem,4)})),
         col=unlist(sapply(plots, function(elem){ extract(elem,3)})),
         cex = 0.65,
         pch=c(19,19,19,19))
}


contig_sizes_list <- list(
			  list(contigSizes.hungry_colden, contigSums.hungry_colden, "#b2df8a", "Gold Standard"),
                          list(contigSizes.jovial_tesla_0, contigSums.jovial_tesla_0, "#a6cee3", "A* k63"),
			  list(contigSizes.jolly_mcclintock_0, contigSums.jolly_mcclintock_0, "#1f78b4", "Velour k63 c2.0"),
			  list(contigSizes.clever_hypatia_1, contigSums.clever_hypatia_1, "#33a02c", "Velour k31 c2.0"),
			  list(contigSizes.backstabbing_carson_0, contigSums.backstabbing_carson_0, "#fb9a99", "Ray Blacklight k64"),
			  list(contigSizes.fervent_mayer_0, contigSums.fervent_mayer_0, "#e31a1c", "Minia k21-k91"),
			  list(contigSizes.suspicious_pare_2, contigSums.suspicious_pare_2, "#fdbf6f", "Ray k71"),
			  list(contigSizes.suspicious_pare_4, contigSums.suspicious_pare_4, "#ff7f00", "Ray k91"),
			  list(contigSizes.sick_colden_0, contigSums.sick_colden_0, "#cab2d6", "Velour k31 c4.01"),
			  list(contigSizes.suspicious_mcclintock_0, contigSums.suspicious_mcclintock_0, "#6a3d9a", "Velour k63 c2.0"),
			  list(contigSizes.stupefied_mclean_0, contigSums.stupefied_mclean_0, "#ffff99", "Megahit ep k21-k91"),
			  list(contigSizes.insane_brattain_0, contigSums.insane_brattain_0, "#b15928", "Megahit ep mtl200 k21-k91"),
			  list(contigSizes.goofy_tesla_0, contigSums.goofy_tesla_0, "#d9d9d9", "Meraga k33-k63")
			  )
create_plots_contig_size("Contig size (log)", "Cumulative contig size" ,"Cumulative contig sizes", contig_sizes_list)

create_number_contigs_plots <- function(x ,y , main, plots){
  extract <- function(arrays, pos){
    arrays[pos]
  }

  counter <<- 0
  for (assembler in plots){
    counter <<- counter + 1
    assemblerContigNumber <- assembler[1]
    assemblerContigSums <- assembler[2]
    color <- assembler[3]
    plot(unlist(assemblerContigNumber), unlist(assemblerContigSums), type='l', #log="x",
         xlim=c(0,max(unlist(sapply(plots, function(elem){ extract(elem,1)})))),
         ylim=c(1,max(unlist(sapply(plots, function(elem){ extract(elem,2)})), na.rm=TRUE)),
         col=unlist(color),
         main=main,
         xlab=x,
         ylab=y)

    abline(h=max(unlist(assemblerContigSums))/2, col=unlist(color))
    if(counter != length(plots)){
      par(new=T, xpd=F)
    }
  }
  legend("topright", bg="transparent", border="black",
         legend=unlist(sapply(plots, function(elem){ extract(elem,4)})),
         col=unlist(sapply(plots, function(elem){ extract(elem,3)})),
         cex = 0.65,
         pch=c(19,19,19,19))
}

contig_sum_list <- list(
		       	list(contigNum.hungry_colden, contigSums.hungry_colden, "#b2df8a", "Gold Standard"),
                        list(contigNum.jovial_tesla_0, contigSums.jovial_tesla_0, "#a6cee3", "A* k63"),
		       	list(contigNum.jolly_mcclintock_0, contigSums.jolly_mcclintock_0, "#1f78b4", "Velour k63 c2.0"),
		       	list(contigNum.clever_hypatia_1, contigSums.clever_hypatia_1, "#33a02c", "Velour k31 c2.0"),
		       	list(contigNum.backstabbing_carson_0, contigSums.backstabbing_carson_0, "#fb9a99", "Ray Blacklight k64"),
		       	list(contigNum.fervent_mayer_0, contigSums.fervent_mayer_0, "#e31a1c", "Minia k21-k91"),
		       	list(contigNum.suspicious_pare_2, contigSums.suspicious_pare_2, "#fdbf6f", "Ray k71"),
		       	list(contigNum.suspicious_pare_4, contigSums.suspicious_pare_4, "#ff7f00", "Ray k91"),
		       	list(contigNum.sick_colden_0, contigSums.sick_colden_0, "#cab2d6", "Velour k31 c4.01"),
		       	list(contigNum.suspicious_mcclintock_0, contigSums.suspicious_mcclintock_0, "#6a3d9a", "Velour k63 c4.01"),
		       	list(contigNum.stupefied_mclean_0, contigSums.stupefied_mclean_0, "#ffff99", "Megahit ep k21-k91"),
		       	list(contigNum.insane_brattain_0, contigSums.insane_brattain_0, "#b15928", "Megahit ep mtl200 k21-k91"),
		       	list(contigNum.goofy_tesla_0, contigSums.goofy_tesla_0, "#d9d9d9", "Meraga k33-k63")
			)
create_number_contigs_plots("Number of contigs", "Cumulative contig size" ,"Cumulative contig numbers",contig_sum_list)

dev.off()
