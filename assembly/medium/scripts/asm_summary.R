# This script was used to build cumulativ plots for the low complexity dataset
# Please provide the path to each assembler and the png output file path in the first block

#########################################
#### BLOCK 1 - Path to the assemblies
#########################################

outputFileName = ''

gold_Standard_0_path <- ""

# fervent_mayer_1 = Minia k21-k91
fervent_mayer_1_path <- ""

# fervent_blackwell_0 = Minia3 k21-k91
fervent_blackwell_0_path <- ""

# goofy_wilson_0 = Minia3 k21-k121
goofy_wilson_0_path <- ""

# jolly_euclid_0 = Ray k51
jolly_euclid_0_path <- ""

# backstabbing_carson_1 = Ray Blacklight k64
backstabbing_carson_1_path <- ""

# agitated_hodgkin_0 = Ray k71
agitated_hodgkin_0_path <- ""

# jolly_torvalds_0 = Ray k91
jolly_torvalds_0_path <- ""

# jolly_mcclintock_1 = Velour k63 c2.0 
jolly_mcclintock_1_path <- ""

# insane_curie_0 = Velour k63 c4.0
insane_curie_0_path <- ""

# goofy_tesla_1 = Meraga k33-k63
goofy_tesla_1_path <- ""

# adoring_almeida_4 = A* k63
adoring_almeida_4_path <- ""

#########################################
#### BLOCK 2 - Read in contig length of each assembler
#########################################

summary.Gold_Standard_0<- read.csv(gold_Standard_0_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.Gold_Standard_0[is.na(summary.Gold_Standard_0)] <- 0
sizes.Gold_Standard_0<- summary.Gold_Standard_0[,'contig_length', drop=FALSE]


summary.fervent_mayer_1<- read.csv(fervent_mayer_1_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.fervent_mayer_1[is.na(summary.fervent_mayer_1)] <- 0
sizes.fervent_mayer_1<- summary.fervent_mayer_1[,'contig_length', drop=FALSE]

summary.fervent_blackwell_0<- read.csv(fervent_blackwell_0_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.fervent_blackwell_0[is.na(summary.fervent_blackwell_0)] <- 0
sizes.fervent_blackwell_0<- summary.fervent_blackwell_0[,'contig_length', drop=FALSE]

summary.goofy_wilson_0<- read.csv(goofy_wilson_0_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.goofy_wilson_0[is.na(summary.goofy_wilson_0)] <- 0
sizes.goofy_wilson_0<- summary.goofy_wilson_0[,'contig_length', drop=FALSE]

summary.jolly_euclid_0<- read.csv(jolly_euclid_0_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.jolly_euclid_0[is.na(summary.jolly_euclid_0)] <- 0
sizes.jolly_euclid_0<- summary.jolly_euclid_0[,'contig_length', drop=FALSE]

summary.backstabbing_carson_1<- read.csv(backstabbing_carson_1_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.backstabbing_carson_1[is.na(summary.backstabbing_carson_1)] <- 0
sizes.backstabbing_carson_1<- summary.backstabbing_carson_1[,'contig_length', drop=FALSE]

summary.agitated_hodgkin_0<- read.csv(agitated_hodgkin_0_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.agitated_hodgkin_0[is.na(summary.agitated_hodgkin_0)] <- 0
sizes.agitated_hodgkin_0<- summary.agitated_hodgkin_0[,'contig_length', drop=FALSE]


summary.jolly_torvalds_0<- read.csv(jolly_torvalds_0_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.jolly_torvalds_0[is.na(summary.jolly_torvalds_0)] <- 0
sizes.jolly_torvalds_0<- summary.jolly_torvalds_0[,'contig_length', drop=FALSE]


summary.jolly_mcclintock_1<- read.csv(jolly_mcclintock_1_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.jolly_mcclintock_1[is.na(summary.jolly_mcclintock_1)] <- 0
sizes.jolly_mcclintock_1<- summary.jolly_mcclintock_1[,'contig_length', drop=FALSE]


summary.insane_curie_0<- read.csv(insane_curie_0_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.insane_curie_0[is.na(summary.insane_curie_0)] <- 0
sizes.insane_curie_0<- summary.insane_curie_0[,'contig_length', drop=FALSE]

summary.goofy_tesla_1<- read.csv(goofy_tesla_1_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.goofy_tesla_1[is.na(summary.goofy_tesla_1)] <- 0
sizes.goofy_tesla_1<- summary.goofy_tesla_1[,'contig_length', drop=FALSE]


summary.adoring_almeida_4<- read.csv(adoring_almeida_4_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.adoring_almeida_4[is.na(summary.adoring_almeida_4)] <- 0
sizes.adoring_almeida_4<- summary.adoring_almeida_4[,'contig_length', drop=FALSE]


#########################################
#### BLOCK 3 - Compute cumulative sums
#########################################

contigSizes.Gold_Standard_0 <- summary.Gold_Standard_0[order(summary.Gold_Standard_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.Gold_Standard_0 <- cumsum(as.numeric(contigSizes.Gold_Standard_0))
contigNum.Gold_Standard_0 <- c(rep(1, length(contigSizes.Gold_Standard_0)))
contigNum.Gold_Standard_0 <- cumsum(as.numeric(contigNum.Gold_Standard_0))

contigSizes.fervent_mayer_1 <- summary.fervent_mayer_1[order(summary.fervent_mayer_1[, "contig_length"], decreasing=T), "contig_length"]
contigSums.fervent_mayer_1 <- cumsum(as.numeric(contigSizes.fervent_mayer_1))
contigNum.fervent_mayer_1 <- c(rep(1, length(contigSizes.fervent_mayer_1)))
contigNum.fervent_mayer_1 <- cumsum(as.numeric(contigNum.fervent_mayer_1))

contigSizes.fervent_blackwell_0 <- summary.fervent_blackwell_0[order(summary.fervent_blackwell_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.fervent_blackwell_0 <- cumsum(as.numeric(contigSizes.fervent_blackwell_0))
contigNum.fervent_blackwell_0 <- c(rep(1, length(contigSizes.fervent_blackwell_0)))
contigNum.fervent_blackwell_0 <- cumsum(as.numeric(contigNum.fervent_blackwell_0))

contigSizes.goofy_wilson_0 <- summary.goofy_wilson_0[order(summary.goofy_wilson_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.goofy_wilson_0 <- cumsum(as.numeric(contigSizes.goofy_wilson_0))
contigNum.goofy_wilson_0 <- c(rep(1, length(contigSizes.goofy_wilson_0)))
contigNum.goofy_wilson_0 <- cumsum(as.numeric(contigNum.goofy_wilson_0))

contigSizes.jolly_euclid_0 <- summary.jolly_euclid_0[order(summary.jolly_euclid_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.jolly_euclid_0 <- cumsum(as.numeric(contigSizes.jolly_euclid_0))
contigNum.jolly_euclid_0 <- c(rep(1, length(contigSizes.jolly_euclid_0)))
contigNum.jolly_euclid_0 <- cumsum(as.numeric(contigNum.jolly_euclid_0))

contigSizes.backstabbing_carson_1 <- summary.backstabbing_carson_1[order(summary.backstabbing_carson_1[, "contig_length"], decreasing=T), "contig_length"]
contigSums.backstabbing_carson_1 <- cumsum(as.numeric(contigSizes.backstabbing_carson_1))
contigNum.backstabbing_carson_1 <- c(rep(1, length(contigSizes.backstabbing_carson_1)))
contigNum.backstabbing_carson_1 <- cumsum(as.numeric(contigNum.backstabbing_carson_1))

contigSizes.agitated_hodgkin_0 <- summary.agitated_hodgkin_0[order(summary.agitated_hodgkin_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.agitated_hodgkin_0 <- cumsum(as.numeric(contigSizes.agitated_hodgkin_0))
contigNum.agitated_hodgkin_0 <- c(rep(1, length(contigSizes.agitated_hodgkin_0)))
contigNum.agitated_hodgkin_0 <- cumsum(as.numeric(contigNum.agitated_hodgkin_0))

contigSizes.jolly_torvalds_0 <- summary.jolly_torvalds_0[order(summary.jolly_torvalds_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.jolly_torvalds_0 <- cumsum(as.numeric(contigSizes.jolly_torvalds_0))
contigNum.jolly_torvalds_0 <- c(rep(1, length(contigSizes.jolly_torvalds_0)))
contigNum.jolly_torvalds_0 <- cumsum(as.numeric(contigNum.jolly_torvalds_0))

contigSizes.jolly_mcclintock_1 <- summary.jolly_mcclintock_1[order(summary.jolly_mcclintock_1[, "contig_length"], decreasing=T), "contig_length"]
contigSums.jolly_mcclintock_1 <- cumsum(as.numeric(contigSizes.jolly_mcclintock_1))
contigNum.jolly_mcclintock_1 <- c(rep(1, length(contigSizes.jolly_mcclintock_1)))
contigNum.jolly_mcclintock_1 <- cumsum(as.numeric(contigNum.jolly_mcclintock_1))

contigSizes.insane_curie_0 <- summary.insane_curie_0[order(summary.insane_curie_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.insane_curie_0 <- cumsum(as.numeric(contigSizes.insane_curie_0))
contigNum.insane_curie_0 <- c(rep(1, length(contigSizes.insane_curie_0)))
contigNum.insane_curie_0 <- cumsum(as.numeric(contigNum.insane_curie_0))

contigSizes.goofy_tesla_1 <- summary.goofy_tesla_1[order(summary.goofy_tesla_1[, "contig_length"], decreasing=T), "contig_length"]
contigSums.goofy_tesla_1 <- cumsum(as.numeric(contigSizes.goofy_tesla_1))
contigNum.goofy_tesla_1 <- c(rep(1, length(contigSizes.goofy_tesla_1)))
contigNum.goofy_tesla_1 <- cumsum(as.numeric(contigNum.goofy_tesla_1))

contigSizes.adoring_almeida_4 <- summary.adoring_almeida_4[order(summary.adoring_almeida_4[, "contig_length"], decreasing=T), "contig_length"]
contigSums.adoring_almeida_4 <- cumsum(as.numeric(contigSizes.adoring_almeida_4))
contigNum.adoring_almeida_4 <- c(rep(1, length(contigSizes.adoring_almeida_4)))
contigNum.adoring_almeida_4 <- cumsum(as.numeric(contigNum.adoring_almeida_4))

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


contig_sizes_list <- list(list(contigSizes.Gold_Standard_0, contigSums.Gold_Standard_0, "#a6cee3", "Gold Standard"), 
			  list(contigSizes.fervent_mayer_1, contigSums.fervent_mayer_1, "#1f78b4", "Minia k21-k91"),
			  list(contigSizes.fervent_blackwell_0, contigSums.fervent_blackwell_0, "#33a02c", "Minia3 k21-k91"),
			  list(contigSizes.goofy_wilson_0, contigSums.goofy_wilson_0, "#fb9a99", "Minia3 k21-k121"),
			  list(contigSizes.jolly_euclid_0, contigSums.jolly_euclid_0, "#e31a1c", "Ray k51"),
			  list(contigSizes.backstabbing_carson_1, contigSums.backstabbing_carson_1, "#fdbf6f", "Ray Blacklight k64"),
			  list(contigSizes.agitated_hodgkin_0, contigSums.agitated_hodgkin_0, "#ff7f00", "Ray k71"),
			  list(contigSizes.jolly_torvalds_0, contigSums.jolly_torvalds_0, "#cab2d6", "Ray k91"),
			  list(contigSizes.jolly_mcclintock_1, contigSums.jolly_mcclintock_1, "#6a3d9a", "Velour k63 c2.0"),
			  list(contigSizes.insane_curie_0, contigSums.insane_curie_0, "#ffff99", "Velour k63 c4.0"),
			  list(contigSizes.goofy_tesla_1, contigSums.goofy_tesla_1, "#b15928", "Meraga k33-k63"),
			  list(contigSizes.adoring_almeida_4, contigSums.adoring_almeida_4, "#d9d9d9", "A* k63"))

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

contig_sum_list <- list(list(contigNum.Gold_Standard_0, contigSums.Gold_Standard_0, "#a6cee3", "Gold Standard"),
		       	list(contigNum.fervent_mayer_1, contigSums.fervent_mayer_1, "#1f78b4", "Minia k21-k91"),
		       	list(contigNum.fervent_blackwell_0, contigSums.fervent_blackwell_0, "#33a02c", "Minia3 k21-k91"),
		       	list(contigNum.goofy_wilson_0, contigSums.goofy_wilson_0, "#fb9a99", "Minia3 k21-k121"),
		       	list(contigNum.jolly_euclid_0, contigSums.jolly_euclid_0, "#e31a1c", "Ray k51"),
		       	list(contigNum.backstabbing_carson_1, contigSums.backstabbing_carson_1, "#fdbf6f", "Ray Blacklight k64"),
		       	list(contigNum.agitated_hodgkin_0, contigSums.agitated_hodgkin_0, "#ff7f00", "Ray k71"),
		       	list(contigNum.jolly_torvalds_0, contigSums.jolly_torvalds_0, "#cab2d6", "Ray k91"),
		       	list(contigNum.jolly_mcclintock_1, contigSums.jolly_mcclintock_1, "#6a3d9a", "Velour k63 c2.0"),
		       	list(contigNum.insane_curie_0, contigSums.insane_curie_0, "#ffff99", "Velour k63 c4.0"),
		       	list(contigNum.goofy_tesla_1, contigSums.goofy_tesla_1, "#b15928", "Meraga k33-k63"),
		       	list(contigNum.adoring_almeida_4, contigSums.adoring_almeida_4, "#d9d9d9", "A* k63")
			)


create_number_contigs_plots("Number of contigs", "Cumulative contig size" ,"Cumulative contig numbers",contig_sum_list)

dev.off()
