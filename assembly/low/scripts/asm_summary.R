# This script was used to build cumulativ plots for the low complexity dataset
# Please provide the path to each assembler and the png output file path in the first block

#########################################
#### BLOCK 1 - Path to the assemblies
#########################################

outputFileName = ''

gold_Standard_2_path <- ""

# fervent_blackwell_1 = Minia3 k21-k241
fervent_blackwell_1_path <- ""

# sad_galileo_0 = Velour k31 c20.01
sad_galileo_0_path <- ""

# clever_hypatia_0 = Velour k31 c2.0
clever_hypatia_0_path <- ""

# jolly_bartik_1 = Ray k41
jolly_bartik_1_path <- ""

# jolly_euclid_1 = Ray k51
jolly_euclid_1_path <- ""

# serene_shockley_0 = Ray Blacklight k64
serene_shockley_0_path <- ""

# jolly_torvalds_1 = Ray k91
jolly_torvalds_1_path <- ""

# goofy_tesla_2 = Meraga k33-k63
goofy_tesla_2_path <- ""

# adoring_almeida_6 = A* k63
adoring_almeida_6_path <- ""

#########################################
#### BLOCK 2 - Read in contig length of each assembler
#########################################

summary.Gold_Standard_2<- read.csv(gold_Standard_2_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.Gold_Standard_2[is.na(summary.Gold_Standard_2)] <- 0
sizes.Gold_Standard_2<- summary.Gold_Standard_2[,'contig_length', drop=FALSE]


summary.fervent_blackwell_1<- read.csv(fervent_blackwell_1_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.fervent_blackwell_1[is.na(summary.fervent_blackwell_1)] <- 0
sizes.fervent_blackwell_1<- summary.fervent_blackwell_1[,'contig_length', drop=FALSE]

summary.sad_galileo_0<- read.csv(sad_galileo_0_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.sad_galileo_0[is.na(summary.sad_galileo_0)] <- 0
sizes.sad_galileo_0<- summary.sad_galileo_0[,'contig_length', drop=FALSE]

summary.clever_hypatia_0<- read.csv(clever_hypatia_0_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.clever_hypatia_0[is.na(summary.clever_hypatia_0)] <- 0
sizes.clever_hypatia_0<- summary.clever_hypatia_0[,'contig_length', drop=FALSE]

summary.jolly_bartik_1<- read.csv(jolly_bartik_1_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.jolly_bartik_1[is.na(summary.jolly_bartik_1)] <- 0
sizes.jolly_bartik_1<- summary.jolly_bartik_1[,'contig_length', drop=FALSE]


summary.jolly_euclid_1<- read.csv(jolly_euclid_1_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.jolly_euclid_1[is.na(summary.jolly_euclid_1)] <- 0
sizes.jolly_euclid_1<- summary.jolly_euclid_1[,'contig_length', drop=FALSE]


summary.serene_shockley_0<- read.csv(serene_shockley_0_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.serene_shockley_0[is.na(summary.serene_shockley_0)] <- 0
sizes.serene_shockley_0<- summary.serene_shockley_0[,'contig_length', drop=FALSE]


summary.jolly_torvalds_1<- read.csv(jolly_torvalds_1_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.jolly_torvalds_1[is.na(summary.jolly_torvalds_1)] <- 0
sizes.jolly_torvalds_1<- summary.jolly_torvalds_1[,'contig_length', drop=FALSE]


summary.goofy_tesla_2<- read.csv(goofy_tesla_2_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.goofy_tesla_2[is.na(summary.goofy_tesla_2)] <- 0
sizes.goofy_tesla_2<- summary.goofy_tesla_2[,'contig_length', drop=FALSE]

summary.adoring_almeida_6<- read.csv(adoring_almeida_6_path, 
                           head=T, row.names=1, sep="\t", check.names=T)
summary.adoring_almeida_6[is.na(summary.adoring_almeida_6)] <- 0
sizes.adoring_almeida_6<- summary.adoring_almeida_6[,'contig_length', drop=FALSE]

#########################################
#### BLOCK 3 - Compute cumulative sums
#########################################

contigSizes.Gold_Standard_2 <- summary.Gold_Standard_2[order(summary.Gold_Standard_2[, "contig_length"], decreasing=T), "contig_length"]
contigSums.Gold_Standard_2 <- cumsum(as.numeric(contigSizes.Gold_Standard_2))
contigNum.Gold_Standard_2 <- c(rep(1, length(contigSizes.Gold_Standard_2)))
contigNum.Gold_Standard_2 <- cumsum(as.numeric(contigNum.Gold_Standard_2))

contigSizes.fervent_blackwell_1 <- summary.fervent_blackwell_1[order(summary.fervent_blackwell_1[, "contig_length"], decreasing=T), "contig_length"]
contigSums.fervent_blackwell_1 <- cumsum(as.numeric(contigSizes.fervent_blackwell_1))
contigNum.fervent_blackwell_1 <- c(rep(1, length(contigSizes.fervent_blackwell_1)))
contigNum.fervent_blackwell_1 <- cumsum(as.numeric(contigNum.fervent_blackwell_1))

contigSizes.sad_galileo_0 <- summary.sad_galileo_0[order(summary.sad_galileo_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.sad_galileo_0 <- cumsum(as.numeric(contigSizes.sad_galileo_0))
contigNum.sad_galileo_0 <- c(rep(1, length(contigSizes.sad_galileo_0)))
contigNum.sad_galileo_0 <- cumsum(as.numeric(contigNum.sad_galileo_0))

contigSizes.clever_hypatia_0 <- summary.clever_hypatia_0[order(summary.clever_hypatia_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.clever_hypatia_0 <- cumsum(as.numeric(contigSizes.clever_hypatia_0))
contigNum.clever_hypatia_0 <- c(rep(1, length(contigSizes.clever_hypatia_0)))
contigNum.clever_hypatia_0 <- cumsum(as.numeric(contigNum.clever_hypatia_0))

contigSizes.jolly_bartik_1 <- summary.jolly_bartik_1[order(summary.jolly_bartik_1[, "contig_length"], decreasing=T), "contig_length"]
contigSums.jolly_bartik_1 <- cumsum(as.numeric(contigSizes.jolly_bartik_1))
contigNum.jolly_bartik_1 <- c(rep(1, length(contigSizes.jolly_bartik_1)))
contigNum.jolly_bartik_1 <- cumsum(as.numeric(contigNum.jolly_bartik_1))

contigSizes.jolly_euclid_1 <- summary.jolly_euclid_1[order(summary.jolly_euclid_1[, "contig_length"], decreasing=T), "contig_length"]
contigSums.jolly_euclid_1 <- cumsum(as.numeric(contigSizes.jolly_euclid_1))
contigNum.jolly_euclid_1 <- c(rep(1, length(contigSizes.jolly_euclid_1)))
contigNum.jolly_euclid_1 <- cumsum(as.numeric(contigNum.jolly_euclid_1))

contigSizes.serene_shockley_0 <- summary.serene_shockley_0[order(summary.serene_shockley_0[, "contig_length"], decreasing=T), "contig_length"]
contigSums.serene_shockley_0 <- cumsum(as.numeric(contigSizes.serene_shockley_0))
contigNum.serene_shockley_0 <- c(rep(1, length(contigSizes.serene_shockley_0)))
contigNum.serene_shockley_0 <- cumsum(as.numeric(contigNum.serene_shockley_0))

contigSizes.jolly_torvalds_1 <- summary.jolly_torvalds_1[order(summary.jolly_torvalds_1[, "contig_length"], decreasing=T), "contig_length"]
contigSums.jolly_torvalds_1 <- cumsum(as.numeric(contigSizes.jolly_torvalds_1))
contigNum.jolly_torvalds_1 <- c(rep(1, length(contigSizes.jolly_torvalds_1)))
contigNum.jolly_torvalds_1 <- cumsum(as.numeric(contigNum.jolly_torvalds_1))

contigSizes.goofy_tesla_2  <- summary.goofy_tesla_2 [order(summary.goofy_tesla_2[, "contig_length"], decreasing=T), "contig_length"]
contigSums.goofy_tesla_2  <- cumsum(as.numeric(contigSizes.goofy_tesla_2 ))
contigNum.goofy_tesla_2  <- c(rep(1, length(contigSizes.goofy_tesla_2 )))
contigNum.goofy_tesla_2  <- cumsum(as.numeric(contigNum.goofy_tesla_2 ))

contigSizes.adoring_almeida_6 <- summary.adoring_almeida_6[order(summary.adoring_almeida_6[, "contig_length"], decreasing=T), "contig_length"]
contigSums.adoring_almeida_6 <- cumsum(as.numeric(contigSizes.adoring_almeida_6))
contigNum.adoring_almeida_6 <- c(rep(1, length(contigSizes.adoring_almeida_6)))
contigNum.adoring_almeida_6 <- cumsum(as.numeric(contigNum.adoring_almeida_6))


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


contig_sizes_list <- list(list(contigSizes.Gold_Standard_2, contigSums.Gold_Standard_2, "#a6cee3", "Gold Standard"), 
			  list(contigSizes.fervent_blackwell_1, contigSums.fervent_blackwell_1, "#1f78b4", "Minia3 k21-k241"),
			  list(contigSizes.sad_galileo_0, contigSums.sad_galileo_0, "#33a02c", "Velour k31 c20.01"),
			  list(contigSizes.clever_hypatia_0, contigSums.clever_hypatia_0, "#fb9a99", "Velour k31 c2.0"),
			  list(contigSizes.jolly_bartik_1, contigSums.jolly_bartik_1, "#e31a1c", "Ray k41"),
			  list(contigSizes.jolly_euclid_1, contigSums.jolly_euclid_1, "#fdbf6f", "Ray k51"),
			  list(contigSizes.serene_shockley_0, contigSums.serene_shockley_0, "#ff7f00", "Ray Blacklight k64"),
			  list(contigSizes.jolly_torvalds_1, contigSums.jolly_torvalds_1, "#cab2d6", "Ray k91"),
			  list(contigSizes.goofy_tesla_2, contigSums.goofy_tesla_2, "#6a3d9a", "Meraga k33-k63"),
			  list(contigSizes.adoring_almeida_6, contigSums.adoring_almeida_6, "#ffff99", "A* k63"))

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
  legend("topright", border="black",
         legend=unlist(sapply(plots, function(elem){ extract(elem,4)})),
         col=unlist(sapply(plots, function(elem){ extract(elem,3)})),
         cex = 0.65,
         pch=c(19,19,19,19))
}

contig_sum_list <- list(list(contigNum.Gold_Standard_2, contigSums.Gold_Standard_2, "#a6cee3", "Gold Standard"),
		       	list(contigNum.fervent_blackwell_1, contigSums.fervent_blackwell_1, "#1f78b4", "Minia3 k21-k241"),
		       	list(contigNum.sad_galileo_0, contigSums.sad_galileo_0, "#33a02c", "Velour k31 c20.01"),
		       	list(contigNum.clever_hypatia_0, contigSums.clever_hypatia_0, "#fb9a99", "Velour k31 c2.0"),
		       	list(contigNum.jolly_bartik_1, contigSums.jolly_bartik_1, "#e31a1c", "Ray k41"),
		       	list(contigNum.jolly_euclid_1, contigSums.jolly_euclid_1, "#fdbf6f", "Ray k51"),
		       	list(contigNum.serene_shockley_0, contigSums.serene_shockley_0, "#ff7f00", "Ray Blacklight k64"),
		       	list(contigNum.jolly_torvalds_1, contigSums.jolly_torvalds_1, "#cab2d6", "Ray k91"),
		       	list(contigNum.goofy_tesla_2, contigSums.goofy_tesla_2, "#6a3d9a", "Meraga k33-k63"),
		       	list(contigNum.adoring_almeida_6, contigSums.adoring_almeida_6, "#ffff99", "A* k63")
			)


create_number_contigs_plots("Number of contigs", "Cumulative contig size" ,"Cumulative contig numbers",contig_sum_list)

dev.off()
