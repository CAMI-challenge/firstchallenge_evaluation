#!/usr/bin/env perl

use lib "/homes/sjanssen/perl5/lib/perl5/";

use strict;
use warnings;
use Data::Dumper;
use Storable 'dclone', 'nstore', 'retrieve';
use EvalUtils;
use Math::Random::OO::Normal;
use POSIX;

system("wget https://raw.githubusercontent.com/CAMI-challenge/docker_profiling_tools/master/YAMLsj.pm") if (not -f "YAMLsj.pm");
system("wget https://raw.githubusercontent.com/CAMI-challenge/docker_profiling_tools/master/Utils.pm") if (not -f "Utils.pm");
require YAMLsj;
require Utils;

srand(42);
our $TIMESTAMP = qx(date); chomp $TIMESTAMP;


my @config = @{YAMLsj::parseYAML("config.yaml")};
#transform information of YAML into easier accessable data structures
	our @ordered_ranks = ();
	foreach my $rank (@{$config[0]->{'orderings'}->{'#children'}->[0]->{'taxonomicRanks'}->{'#children'}}) {
		push @ordered_ranks, $rank->{'name'}->{'#value'};
	}
	our @ordered_metrics = ();
	foreach my $name (@{$config[0]->{'orderings'}->{'#children'}->[0]->{'metrics'}->{'#children'}}) {
		push @ordered_metrics, $name->{'name'}->{'#value'};
	}
	our @ordered_goldstandards = ();
	foreach my $name (@{$config[0]->{'orderings'}->{'#children'}->[0]->{'goldstandards'}->{'#children'}}) {
		push @ordered_goldstandards, $name->{'name'}->{'#value'};
	}
	our @ordered_competitions = ();
	foreach my $name (@{$config[0]->{'orderings'}->{'#children'}->[0]->{'competitions'}->{'#children'}}) {
		push @ordered_competitions, $name->{'name'}->{'#value'};
	}
	our @ordered_datasets = ();
	foreach my $name (@{$config[0]->{'orderings'}->{'#children'}->[0]->{'datasets'}->{'#children'}}) {
		push @ordered_datasets, $name->{'name'}->{'#value'};
	}
	our $dir_cache = absFilename($config[0]->{'directories'}->{'#children'}->[0]->{'cache'}->{'#value'});
	our $verbose = $config[0]->{'misc'}->{'#children'}->[0]->{'verbose'}->{'#value'};
	our $RANKINDEPENDENT = $config[0]->{'constants'}->{'#children'}->[0]->{'rankIndependent'}->{'#value'};

#store taxonomy information
	our %NCBItaxonomy = ();

#read and produce data in a cached fashion
	my %data_metrics = %{compile_metrics_data()};
	my %data_profileSubmissions = %{compile_profileSubmission_data()};
	my %data_goldstandards = %{compile_goldstandard_data(\%data_profileSubmissions)};
	my %data_pairwise = %{compile_pairwise_data(\%data_metrics)};
	
#do the actual plotting of the data
	my $yaml_output = "version: 0.1.1\nresults:\n";
	create_boxplots(\%data_profileSubmissions, \%data_goldstandards);
	create_pairwise(\%data_pairwise);
	open (YAML, "> ".$config[0]->{'directories'}->{'#children'}->[0]->{'output'}->{'#value'}."/biobox.yaml") || die "cannot write biobox.yaml output file: $?";
		print YAML $yaml_output;
	close (YAML);
	
sub create_pairwise {
	my ($refHash_pairwisedata) = @_;

	my @parallelCommands = ();
	foreach my $select_competition ("all", @ordered_competitions) {
		foreach my $select_dataset ("all", @ordered_datasets) {
			next if (($select_competition eq "all" && $select_dataset ne "all") || ($select_competition ne "all" && $select_dataset eq "all"));
			
			my $dir_plots = $dir_cache."/pairwise_plots/".$select_competition."/".$select_dataset;
			qx(mkdir -p $dir_plots) if (not -d $dir_plots);
			
			my $filename_data = $dir_plots."/pairwise_".$select_competition."_".$select_dataset.".r";
			my %subdata = ();
			my %toolnames = ();
			foreach my $competition (keys(%{$refHash_pairwisedata})) {
				next if (($competition ne $select_competition) && ($select_competition ne "all"));
				foreach my $dataset (keys(%{$refHash_pairwisedata->{$competition}})) {
					next if (($dataset ne $select_dataset) && ($select_dataset ne "all"));
					foreach my $sample (keys(%{$refHash_pairwisedata->{$competition}->{$dataset}})) {
						foreach my $method_name_A (keys(%{$refHash_pairwisedata->{$competition}->{$dataset}->{$sample}})) {
							foreach my $version_A (keys(%{$refHash_pairwisedata->{$competition}->{$dataset}->{$sample}->{$method_name_A}})) {
								$toolnames{map_toolname($method_name_A, $version_A)}++;
								foreach my $method_name_B (keys(%{$refHash_pairwisedata->{$competition}->{$dataset}->{$sample}->{$method_name_A}->{$version_A}})) {
									foreach my $version_B (keys(%{$refHash_pairwisedata->{$competition}->{$dataset}->{$sample}->{$method_name_A}->{$version_A}->{$method_name_B}})) {
										$toolnames{map_toolname($method_name_B, $version_B)}++;
										foreach my $sourceFile (keys(%{$refHash_pairwisedata->{$competition}->{$dataset}->{$sample}->{$method_name_A}->{$version_A}->{$method_name_B}->{$version_B}})) {
											push @{$subdata{map_toolname($method_name_A, $version_A)}->{map_toolname($method_name_B, $version_B)}}, $refHash_pairwisedata->{$competition}->{$dataset}->{$sample}->{$method_name_A}->{$version_A}->{$method_name_B}->{$version_B}->{$sourceFile};
										}
									}
								}
							}
						}
					}
				}
			}
			
			my %matrix = ();
			foreach my $toolnameA (keys(%toolnames)) {
				foreach my $toolnameB (keys(%toolnames)) {
					my $value = "NA";
					my $n = 0;
					if (exists $subdata{$toolnameA}->{$toolnameB}) {
						$value = computeAVG($subdata{$toolnameA}->{$toolnameB});
						$n = scalar(@{$subdata{$toolnameA}->{$toolnameB}});
					} elsif (exists $subdata{$toolnameB}->{$toolnameA}) {
						$value = computeAVG($subdata{$toolnameB}->{$toolnameA});
						$n = scalar(@{$subdata{$toolnameB}->{$toolnameA}});
					} elsif ($toolnameA eq $toolnameB) {
						$value = 0;
						$n = 0;
					}
					$matrix{values}->{$toolnameA}->{$toolnameB} = $value;
					$matrix{values}->{$toolnameB}->{$toolnameA} = $value;
					$matrix{n}->{$toolnameA}->{$toolnameB} = $n;
					$matrix{n}->{$toolnameB}->{$toolnameA} = $n;
				}
			}
			
			my @values = ();
			my @ns = ();
			my @names = ();
			foreach my $name (sort keys(%{$matrix{values}})) {
				last if ($name =~ m/goldstandard/i);
				push @names, $name;
			}
			push @names, "";
			foreach my $name (sort keys(%{$matrix{values}})) {
				next if ($name !~ m/goldstandard/i);
				push @names, $name;
			}
			
			#~ my @names = ('Adam_d','Brian_d','Hank_d','Edd_d','Frank_d','Kirk_d','Donald_d','Isaac_d','Gustav_s','Adam_s_1','Adam_s_2','Cesar_s_1','Cesar_s_2','Brian_s_4','Brian_s_2','Brian_s_3','Brian_s_5','Brian_s_1','Brian_s_6','Donald_s','Jack_s','','goldstandard_all','goldstandard_filtered');
			foreach my $toolnameA (@names) {
				foreach my $toolnameB (@names) {
					if (($toolnameA eq '') || ($toolnameB eq '')) {
						push @values, "0.00123"; #to add empty row and column in order to separate pairwise tool comparisons from comparisons between a tool and a gold standard profile
						push @ns, 0;
					} else {
						push @values, $matrix{values}->{$toolnameA}->{$toolnameB};
						push @ns, $matrix{n}->{$toolnameA}->{$toolnameB};
					}
				}
			}
				
			my $filename_pdf = $dir_plots."/pairwise_".$select_competition."_".$select_dataset.".pdf";
			my $title = $select_competition." competition, ".$select_dataset." dataset";
			$title = "across all ".@ordered_competitions." competitions and all ".@ordered_datasets." datasets" if ($select_competition eq 'all' && $select_dataset eq 'all');
			open (R, "> ".$filename_data) || die "cannot write pairwise comparisons data to file '$filename_data': $?\n";
				print R 'require(gplots)'."\n";
				print R 'pdf("/dev/null")'."\n";
				print R "require(\"gplots\");\n";
				print R "mdat <- matrix(c(".join(",", @values)."), nrow=".@names.", ncol=".@names.", dimnames = list(c(\"".join('","', @names)."\"),c(\"".join('","', @names)."\")));\n";
				print R "ndat <- matrix(c(".join(",", @ns)."), nrow=".@names.", ncol=".@names.", dimnames = list(c(\"".join('","', @names)."\"),c(\"".join('","', @names)."\")));\n";
				print R "labeldat <- matrix(sprintf(\"%.2f\n%i\", mdat, ndat), nrow=nrow(mdat), ncol=ncol(mdat));\n";
				my $heatmapcmd = "mdat, symm=T, Rowv=FALSE, Colv=FALSE, dendrogram=c(\"none\"), trace=(\"none\"), key=F";
				print R "h <- heatmap.2(".$heatmapcmd.");\n";
				print R "dev.off();\n";
				print R 'pdf("'.$filename_pdf.'", width=15, height=15)'."\n";
				print R "heatmap.2(".$heatmapcmd.", cellnote=labeldat, notecex=0.7, col=colorRampPalette(c(\"white\", \"black\")), na.color=\"darkred\", notecol=ifelse(h\$carpet>max(mdat, na.rm=T)/2 | h\$carpet==0.00123,\"white\",\"black\"), margins=c(10,10));\n";
				print R 'text(x=0.6, y=0.78, label="'.$title.'", cex=2.0);'."\n";
				print R "dev.off();\n";
			close (R);
			push @parallelCommands, {
				cmd => "cat \"".$filename_data."\" | R --vanilla && pdfcrop \"$filename_pdf\" \"$filename_pdf\"",
				check => $filename_pdf,
			};
		}
	}
	print STDERR "drawing ".@parallelCommands." pairwise distance plots: ..." if ($verbose);
	executeParallel(\@parallelCommands);
	my @files = ();
	foreach my $cmd (@parallelCommands) {
		push @files, $cmd->{check};
	}
	my $outfile = $config[0]->{'directories'}->{'#children'}->[0]->{'output'}->{'#value'}."/pairwise_distances.pdf";
	my $cmd = "pdfunite ".join(" ", @files)." ".$outfile;
	system($cmd);
	$yaml_output .= "  - name: pairwise_distances\n";
	$yaml_output .= "    description: a heatmap view of Unifrac distances between tool predicted profiles and the diverse gold standard profiles.\n";
	$yaml_output .= "    inline: false\n";
	$yaml_output .= "    value: ".$outfile."\n";
	$yaml_output .= "    type: pdf\n";
	print STDERR " done.\n" if ($verbose);
}
		

sub compile_pairwise_data {
	my ($refHash_data_metrics) = @_;
	my %data = ();
	%data = %{Storable::retrieve($dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'data_pairwiseComparisons'}->{'#value'})} if (-e $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'data_pairwiseComparisons'}->{'#value'});
	
	my %cache_parsedFiles = ();
	%cache_parsedFiles = %{parse_cacheLog($dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'log_parsedPairwise'}->{'#value'})} if (-e $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'log_parsedPairwise'}->{'#value'});

	#collect existing Unifrac values from "metrics.txt" files
	foreach my $goldstandard (keys(%{$refHash_data_metrics->{metrics}})) {
		foreach my $competition (keys(%{$refHash_data_metrics->{metrics}->{$goldstandard}})) {
			foreach my $dataset (keys(%{$refHash_data_metrics->{metrics}->{$goldstandard}->{$competition}->{'Unifrac'}->{$RANKINDEPENDENT}})) {
				foreach my $sample (keys(%{$refHash_data_metrics->{metrics}->{$goldstandard}->{$competition}->{'Unifrac'}->{$RANKINDEPENDENT}->{$dataset}})) {
					foreach my $refHash_metric (@{$refHash_data_metrics->{metrics}->{$goldstandard}->{$competition}->{'Unifrac'}->{$RANKINDEPENDENT}->{$dataset}->{$sample}}) {
						$data{$competition}->{$dataset}->{$sample}->{'goldstandard'}->{$goldstandard}->{$refHash_metric->{'method_name'}}->{$refHash_metric->{'version'}}->{'fromMetric:'.$refHash_metric->{'anonymous_name'}} = $refHash_metric->{'value'};
					}
				}
			}
		}
	}

	#prepare pairwise tool comparisons
		my %profileFiles = ();
		foreach my $profileSubmission (split(m/\n/, qx(find $config[0]->{'directories'}->{'#children'}->[0]->{'profileSubmissions'}->{'#value'} -type f -name "*"))) {
			my $id = pop [split(m|/|, $profileSubmission)];
			$profileFiles{$id} = $profileSubmission;
		}
		my %profiles = ();
		foreach my $goldstandard (keys(%{$refHash_data_metrics->{metrics}})) {
			foreach my $competition (keys(%{$refHash_data_metrics->{metrics}->{$goldstandard}})) {
				foreach my $dataset (keys(%{$refHash_data_metrics->{metrics}->{$goldstandard}->{$competition}->{'Unifrac'}->{$RANKINDEPENDENT}})) {
					foreach my $sample (keys(%{$refHash_data_metrics->{metrics}->{$goldstandard}->{$competition}->{'Unifrac'}->{$RANKINDEPENDENT}->{$dataset}})) {
						foreach my $refHash_profile (@{$refHash_data_metrics->{metrics}->{$goldstandard}->{$competition}->{'Unifrac'}->{$RANKINDEPENDENT}->{$dataset}->{$sample}}) {
							push @{$profiles{$competition}->{$dataset}->{$sample}->{$refHash_profile->{'method_name'}}->{$refHash_profile->{'version'}}}, $profileFiles{$refHash_profile->{'anonymous_name'}};
						}
					}
				}
			}
			last; #first gold standard is sufficient, other would be repetitive
		}
		
		my $dir_pairwise = $dir_cache.'/pairwise_comparisons/';
		system("mkdir -p $dir_pairwise") if (not -d $dir_pairwise);
		my @parallelCommands = ();
		foreach my $competition (keys(%profiles)) {
			foreach my $dataset (keys(%{$profiles{$competition}})) {
				foreach my $sample (keys(%{$profiles{$competition}->{$dataset}})) {
					my @methods = ();
					foreach my $method_name (keys(%{$profiles{$competition}->{$dataset}->{$sample}})) {
						foreach my $version (keys(%{$profiles{$competition}->{$dataset}->{$sample}->{$method_name}})) {
							push @methods, {'method_name' => $method_name, 'version' => $version};
						}
					}
					
					my $dir_pairwise_sample = $dir_pairwise."/".$competition."/".$dataset."/".$sample."/";
					system("mkdir -p $dir_pairwise_sample") if (not -d $dir_pairwise_sample);
					for (my $i = 0; $i < @methods; $i++) {
						my @profilesA = @{$profiles{$competition}->{$dataset}->{$sample}->{$methods[$i]->{'method_name'}}->{$methods[$i]->{'version'}}};
						for (my $j = $i; $j < @methods; $j++) {
							my @profilesB = @{$profiles{$competition}->{$dataset}->{$sample}->{$methods[$j]->{'method_name'}}->{$methods[$j]->{'version'}}};
							
							#~ print STDERR "  ".$methods[$i]->{'method_name'}."\t".$methods[$i]->{'version'}."\t".$methods[$j]->{'method_name'}."\t".$methods[$j]->{'version'}."\n" if ($verbose);
							my %compared = ();
							for (my $k = 0; $k < @profilesA; $k++) {
								for (my $l = 0; $l < @profilesB; $l++) {
									my ($fileA, $fileB) = sort ($profilesA[$k], $profilesB[$l]);
									if ($fileA ne $fileB) { #no need to compare two identical profiles
										my ($idA, $idB) = (pop [split(m|/|, $fileA)], pop [split(m|/|, $fileB)]);
										if (not exists $compared{$fileA}->{$fileB}) {
											#~ print STDERR "    ".$idA."\t".$idB."\n" if ($verbose);
											
											my $resultFile = $dir_pairwise_sample.$idA.":".$idB.".unifrac";
											if ((not exists $cache_parsedFiles{$idA.$idB}) || (((stat($fileA))[9]+(stat($fileB))[9]) != $cache_parsedFiles{$idA.$idB})) {
												push @parallelCommands, {
													cmd => "python EMDUnifrac.py -g ".$profilesA[$k]." -r ".$profilesB[$l]." > ".$resultFile,
													check => $resultFile,
												};
												$cache_parsedFiles{$idA.$idB} = (stat($fileA))[9]+(stat($fileB))[9];
											}
											$compared{$fileA}->{$fileB}++;
										}
									}
								}
							}
						}
					}
					
					#add pairwise goldstandard comparisons
						for (my $i = 0; $i < @ordered_goldstandards; $i++) {
							my $gsfile_A = $config[0]->{'directories'}->{'#children'}->[0]->{'goldstandards'}->{'#value'}."/".$ordered_goldstandards[$i]."/".$competition.":".$dataset.":".$sample.".profile";
							for (my $j = $i+1; $j < @ordered_goldstandards; $j++) {
								my $gsfile_B = $config[0]->{'directories'}->{'#children'}->[0]->{'goldstandards'}->{'#value'}."/".$ordered_goldstandards[$j]."/".$competition.":".$dataset.":".$sample.".profile";
								($gsfile_A, $gsfile_B) = sort ($gsfile_A,$gsfile_B);
								my ($idA, $idB) = (substr($gsfile_A, length($config[0]->{'directories'}->{'#children'}->[0]->{'goldstandards'}->{'#value'})), substr($gsfile_B, length($config[0]->{'directories'}->{'#children'}->[0]->{'goldstandards'}->{'#value'})));
								$idA =~ s/^\/|\.profile$//g;
								$idB =~ s/^\/|\.profile$//g;
								$idA =~ s/\/|:/_/g;
								$idB =~ s/\/|:/_/g;
								my $resultFile = $dir_pairwise_sample.$idA.":".$idB.".unifrac";
								if ((not exists $cache_parsedFiles{$idA.$idB}) || (((stat($gsfile_A))[9]+(stat($gsfile_B))[9]) != $cache_parsedFiles{$idA.$idB})) {
									push @parallelCommands, {
										cmd => "python EMDUnifrac.py -g ".$gsfile_A." -r ".$gsfile_B." > ".$resultFile,
										check => $resultFile,
									};
									$cache_parsedFiles{$idA.$idB} = (stat($gsfile_A))[9]+(stat($gsfile_B))[9];
								}
							}
						}
				}
			}
		}
		
	if (@parallelCommands > 0) {
		print STDERR "performing ".@parallelCommands." pairwise Unifrac profile comparisons: ..." if ($verbose);
		executeParallel(\@parallelCommands);
		write_cacheLog(\%cache_parsedFiles, $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'log_parsedPairwise'}->{'#value'});
		print STDERR " done.\n" if ($verbose);
	}
	print STDERR "collecting pairwise Unifrac values: ..." if ($verbose);
	foreach my $competition (keys(%profiles)) {
		foreach my $dataset (keys(%{$profiles{$competition}})) {
			foreach my $sample (keys(%{$profiles{$competition}->{$dataset}})) {
				my $dir_pairwise_sample = $dir_pairwise."/".$competition."/".$dataset."/".$sample."/";
				my @methods = ();
				foreach my $method_name (keys(%{$profiles{$competition}->{$dataset}->{$sample}})) {
					foreach my $version (keys(%{$profiles{$competition}->{$dataset}->{$sample}->{$method_name}})) {
						push @methods, {'method_name' => $method_name, 'version' => $version};
					}
				}
				for (my $i = 0; $i < @methods; $i++) {
					my @profilesA = @{$profiles{$competition}->{$dataset}->{$sample}->{$methods[$i]->{'method_name'}}->{$methods[$i]->{'version'}}};
					for (my $j = $i; $j < @methods; $j++) {
						my @profilesB = @{$profiles{$competition}->{$dataset}->{$sample}->{$methods[$j]->{'method_name'}}->{$methods[$j]->{'version'}}};
						for (my $k = 0; $k < @profilesA; $k++) {
							for (my $l = 0; $l < @profilesB; $l++) {
								my ($fileA, $fileB) = sort ($profilesA[$k], $profilesB[$l]);
								if ($fileA ne $fileB) {
									my ($idA, $idB) = (pop [split(m|/|, $fileA)], pop [split(m|/|, $fileB)]);
									my $resultFile = $dir_pairwise_sample.$idA.":".$idB.".unifrac";
									if (not exists $data{$competition}->{$dataset}->{$sample}->{$methods[$i]->{'method_name'}}->{$methods[$i]->{'version'}}->{$methods[$j]->{'method_name'}}->{$methods[$j]->{'version'}}->{$resultFile}) {
										my $unifracValue = qx(cat $resultFile); chomp $unifracValue;
										$data{$competition}->{$dataset}->{$sample}->{$methods[$i]->{'method_name'}}->{$methods[$i]->{'version'}}->{$methods[$j]->{'method_name'}}->{$methods[$j]->{'version'}}->{$resultFile} = $unifracValue;
									}
								}
							}
						}
					}
				}
				
				#add pairwise goldstandard comparisons
					for (my $i = 0; $i < @ordered_goldstandards; $i++) {
						my $gsfile_A = $config[0]->{'directories'}->{'#children'}->[0]->{'goldstandards'}->{'#value'}."/".$ordered_goldstandards[$i]."/".$competition.":".$dataset.":".$sample.".profile";
						for (my $j = $i+1; $j < @ordered_goldstandards; $j++) {
							my $gsfile_B = $config[0]->{'directories'}->{'#children'}->[0]->{'goldstandards'}->{'#value'}."/".$ordered_goldstandards[$j]."/".$competition.":".$dataset.":".$sample.".profile";
							($gsfile_A, $gsfile_B) = sort ($gsfile_A,$gsfile_B);
							my ($idA, $idB) = (substr($gsfile_A, length($config[0]->{'directories'}->{'#children'}->[0]->{'goldstandards'}->{'#value'})), substr($gsfile_B, length($config[0]->{'directories'}->{'#children'}->[0]->{'goldstandards'}->{'#value'})));
							$idA =~ s/^\/|\.profile$//g;
							$idB =~ s/^\/|\.profile$//g;
							$idA =~ s/\/|:/_/g;
							$idB =~ s/\/|:/_/g;
							my $resultFile = $dir_pairwise_sample.$idA.":".$idB.".unifrac";
							my $gsA = ((split(m/\_/, $idA))[0]);
							my $gsB = ((split(m/\_/, $idB))[0]);
							if (not exists $data{$competition}->{$dataset}->{$sample}->{'goldstandard'}->{$gsA}->{'goldstandard'}->{$gsB}->{$resultFile}) {
								my $unifracValue = qx(cat $resultFile); chomp $unifracValue;
								$data{$competition}->{$dataset}->{$sample}->{'goldstandard'}->{$gsA}->{'goldstandard'}->{$gsB}->{$resultFile} = $unifracValue;
							}
						}
					}
			}
		}
	}
	print STDERR " done.\n" if ($verbose);
	Storable::nstore(\%data, $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'data_pairwiseComparisons'}->{'#value'});
	
	return \%data;
}

sub create_boxplots {
	my ($refHash_profileSubmission, $refHash_goldstandards) = @_;
	
	my @parallelCommands = ();
	my @goldstandards = @{mergeListsUnique(\@ordered_goldstandards, [keys(%{$data_metrics{metrics}})])};
	my $numberDatasets = scalar(keys(%{$data_metrics{meta}->{everSeen}->{datasets}}));
	$numberDatasets++; #for across all dataset plots
	my $debugEnd = 'false';
	my %allSpecies = ();
	foreach my $goldstandard (@goldstandards) {
		#~ print STDERR "#goldstandard '$goldstandard'\n" if ($verbose);
		my @competitions = @{mergeListsUnique(\@ordered_competitions, [keys(%{$data_metrics{metrics}->{$goldstandard}})])};
		foreach my $competition (@competitions) {
			#~ print STDERR "  #competition: '$competition'\n" if ($verbose);
			my @metrics = @{mergeListsUnique(\@ordered_metrics, [keys(%{$data_metrics{metrics}->{$goldstandard}->{$competition}})])};
			foreach my $metric (@metrics) {
				#~ next if ($metric ne 'L1norm');

				#~ print STDERR "    #metric: '$metric'\n" if ($verbose);
				
				my $tmpdir = absFilename($dir_cache."/boxplots/".$goldstandard."/".$competition."/".$metric)."/";
				my $filename_rcommands = $tmpdir."/cmds.r";
				my $filename_data = $tmpdir."/metrics.data";
				my $filename_pdf = $tmpdir."/boxplots.pdf";
				my $recompute = 'true';
				if (not -d $tmpdir) {
					qx(mkdir -p "$tmpdir");
				} else {
					if (-f $filename_rcommands && -f $filename_data) {
						$recompute = 'false';
					}
				}
				if ($recompute eq 'true') {
					open (R, "> $filename_rcommands") || die "cannot write R commands to '$filename_rcommands': $?";
					my @ranks = @{mergeListsUnique(\@ordered_ranks, [keys(%{$data_metrics{metrics}->{$goldstandard}->{$competition}->{$metric}})])};
					unshift @ranks, "all" if (@ranks > 1);
					
					print R 'require(gplots)'."\n";
					print R 'require(grid)'."\n";
					print R 'pdf("'.$filename_pdf.'", width='.($config[0]->{'misc'}->{'#children'}->[0]->{'RpdfScale'}->{'#value'}*$numberDatasets).', height='.($config[0]->{'misc'}->{'#children'}->[0]->{'RpdfScale'}->{'#value'} * @ranks).')'."\n";
					print R 'data <- read.csv("'.$filename_data.'", sep="\t", header=T);'."\n";
					print R 'par(mfrow=c('.scalar(@ranks).','.$numberDatasets.'), ';
					print R 'oma=c(5,0,4,0)'; #bottom, left, top, right
					print R ');'."\n"; 
					print R 'par(bg = '.$config[0]->{'misc'}->{'#children'}->[0]->{'backgroundcolor_toy_competition'}->{'#value'}.');' if ($competition eq 'Toy');
					
					open (DATA, "> $filename_data") || die "cannot write data to '$filename_data': $?";
					print DATA join("\t", (
						'rank',
						'dataset',
						'sample',
						'method_name',
						'version',
						'anonymous_name',
						'id',
						'toolname',
						'value',
					))."\n";
					my %minmaxValues = ();
					my %numberTrueClasses = ();
					my %datasets_per_sample = ();
					my %random = ();
					foreach my $rank (@ranks) {
						next if (not exists $data_metrics{metrics}->{$goldstandard}->{$competition}->{$metric}->{$rank});
						#~ print STDERR "      #rank: '$rank'\n" if ($verbose);
						my @datasets = @{mergeListsUnique(\@ordered_datasets, [keys(%{$data_metrics{metrics}->{$goldstandard}->{$competition}->{$metric}->{$rank}})])};
						foreach my $dataset (@datasets) {
							#~ print STDERR "        #dataset: '$dataset'\n" if ($verbose);
							foreach my $sample (keys %{$data_metrics{metrics}->{$goldstandard}->{$competition}->{$metric}->{$rank}->{$dataset}}) {
								#~ print STDERR "          #sample: '$sample'\n" if ($verbose);
								$datasets_per_sample{$dataset}->{$sample}++;
								foreach my $refList_data (@{$data_metrics{metrics}->{$goldstandard}->{$competition}->{$metric}->{$rank}->{$dataset}->{$sample}}) {
									print DATA join("\t", (
										$rank,
										$dataset,
										$sample,
										$refList_data->{'method_name'},
										$refList_data->{'version'},
										$refList_data->{'anonymous_name'},
										$refList_data->{'id'},
										map_toolname($refList_data->{'method_name'},$refList_data->{'version'}),
										$refList_data->{'value'},
									))."\n";
									$minmaxValues{$rank}->{'min'} = $refList_data->{'value'} if ((not exists $minmaxValues{$rank}->{'min'}) || ($refList_data->{'value'} < $minmaxValues{$rank}->{'min'}));
									$minmaxValues{$rank}->{'max'} = $refList_data->{'value'} if ((not exists $minmaxValues{$rank}->{'max'}) || ($refList_data->{'value'} > $minmaxValues{$rank}->{'max'}));
									$minmaxValues{'all'}->{'min'} = $refList_data->{'value'} if ((not exists $minmaxValues{'all'}->{'min'}) || ($refList_data->{'value'} < $minmaxValues{'all'}->{'min'}));
									$minmaxValues{'all'}->{'max'} = $refList_data->{'value'} if ((not exists $minmaxValues{'all'}->{'max'}) || ($refList_data->{'value'} > $minmaxValues{'all'}->{'max'}));
								}
								if ($metric eq 'True Positives') {
									push @{$numberTrueClasses{$rank}->{$dataset}}, 	$data_goldstandards{numberTrueClasses}->{$goldstandard}->{$competition}->{$dataset}->{$sample}->{$rank};
									push @{$numberTrueClasses{$rank}->{'all'}}, 		$data_goldstandards{numberTrueClasses}->{$goldstandard}->{$competition}->{$dataset}->{$sample}->{$rank};
									push @{$numberTrueClasses{'all'}->{$dataset}}, 	$data_goldstandards{numberTrueClasses}->{$goldstandard}->{$competition}->{$dataset}->{$sample}->{$rank};
									push @{$numberTrueClasses{'all'}->{'all'}}, 		$data_goldstandards{numberTrueClasses}->{$goldstandard}->{$competition}->{$dataset}->{$sample}->{$rank};
								}
								if (($metric eq 'Unifrac') || ($metric eq 'L1norm')) {
									if ($rank ne 'all') {
										foreach my $type (keys(%{$refHash_goldstandards->{shuffling}->{$goldstandard}->{$competition}->{$dataset}->{$sample}})) {
											push @{$random{$rank}->{$dataset}->{$type}}, 	$refHash_goldstandards->{shuffling}->{$goldstandard}->{$competition}->{$dataset}->{$sample}->{$type}->{$metric}->{$rank};
											push @{$random{$rank}->{'all'}->{$type}}, 		$refHash_goldstandards->{shuffling}->{$goldstandard}->{$competition}->{$dataset}->{$sample}->{$type}->{$metric}->{$rank};
											push @{$random{'all'}->{$dataset}->{$type}}, $refHash_goldstandards->{shuffling}->{$goldstandard}->{$competition}->{$dataset}->{$sample}->{$type}->{$metric}->{$rank};
											push @{$random{'all'}->{'all'}->{$type}}, 	$refHash_goldstandards->{shuffling}->{$goldstandard}->{$competition}->{$dataset}->{$sample}->{$type}->{$metric}->{$rank};
										}
									}
								}
							}
						}
					}
					foreach my $rank (keys(%numberTrueClasses)) {
						foreach my $dataset (keys(%{$numberTrueClasses{$rank}})) {
							my @help = sort {$a <=> $b} @{$numberTrueClasses{$rank}->{$dataset}};
							delete $numberTrueClasses{$rank}->{$dataset};
							$numberTrueClasses{$rank}->{$dataset}->{min} = $help[0];
							$numberTrueClasses{$rank}->{$dataset}->{max} = $help[$#help];
						}
					}			
					foreach my $rank (keys(%random)) {
						foreach my $dataset (keys(%{$random{$rank}})) {
							foreach my $type (keys(%{$random{$rank}->{$dataset}})) {
								$random{$rank}->{$dataset}->{$type} = computeMedian($random{$rank}->{$dataset}->{$type});
								$minmaxValues{$rank}->{'min'} = $random{$rank}->{$dataset}->{$type} if ((not exists $minmaxValues{$rank}->{'min'}) || ($random{$rank}->{$dataset}->{$type} < $minmaxValues{$rank}->{'min'}));
								$minmaxValues{$rank}->{'max'} = $random{$rank}->{$dataset}->{$type} if ((not exists $minmaxValues{$rank}->{'max'}) || ($random{$rank}->{$dataset}->{$type} > $minmaxValues{$rank}->{'max'}));
								$minmaxValues{'all'}->{'min'} = $random{$rank}->{$dataset}->{$type} if ((not exists $minmaxValues{'all'}->{'min'}) || ($random{$rank}->{$dataset}->{$type} < $minmaxValues{'all'}->{'min'}));
								$minmaxValues{'all'}->{'max'} = $random{$rank}->{$dataset}->{$type} if ((not exists $minmaxValues{'all'}->{'max'}) || ($random{$rank}->{$dataset}->{$type} > $minmaxValues{'all'}->{'max'}));
							}
						}
					}
				
					#create dummy entries to have always the same number of columns in each plot
					foreach my $toolname (keys(%{$data_metrics{meta}->{everSeen}->{toolnames}})) {
						print DATA join("\t", (
							'NA',
							'NA',
							'NA',
							'NA',
							'NA',
							'NA',
							'NA',
							$toolname,
							'NA',
						))."\n";
					}
					close DATA;
					
					foreach my $rank (@ranks) {
						my @datasets = @{mergeListsUnique(\@ordered_datasets, [keys(%{$data_metrics{meta}->{everSeen}->{datasets}})])};
						unshift @datasets, 'all';
						foreach my $dataset (@datasets) {
							my $title = ', main="';
							
							my $restriction_dataset = "T";
							if ($dataset eq 'all') {
								$title .= 'across all '.scalar(keys(%datasets_per_sample)).' datasets';
							} else {
								$restriction_dataset = 'data$dataset=="'.$dataset.'"';
								my $nrSamples = 0;
								foreach my $sampleName (keys(%{$datasets_per_sample{$dataset}})) {
									$nrSamples++ if ($dataset eq 'low' || $sampleName ne 'pool');
								}
								$title .= $dataset.' ('.$nrSamples.' sample'.($nrSamples > 1 ? 's' : '').')';
							}
							$title .= '"';
							$title = "" if ($rank ne $ranks[0]); #don't repeat boxplot title, if already printed in first row
							
							my $restriction_rank = "T";
							my $labelYaxis = "";
							if ($rank eq 'all') {
								$labelYaxis = "ylab=\"across all ".(scalar(@ranks)-1)." ranks\", ";
							} else {
								$labelYaxis = "ylab=\"$rank\", ";
								if ($rank eq $RANKINDEPENDENT) {
									$restriction_rank = "T";
								} else {
									$restriction_rank = 'data$rank=="'.$rank.'"';
								}
							}
							print R 'sub <- subset(data, '.$restriction_dataset.' & '.$restriction_rank.');'."\n";
							my $barplotCommand = 'sub$value ~ sub$toolname, axes=F, ylim=c('.$minmaxValues{$rank}->{'min'}.', '.$minmaxValues{$rank}->{'max'}.')';
							print R 'b <- boxplot('.$barplotCommand.', add=F '.$title.', '.$labelYaxis.' frame=T, las=2);'."\n";
							print R '   for (i in 1:length(b$n)) {';
							print R '     if (b$n[i] <= 0) {';
							print R '       rect(i-0.5,-10000,i+1-0.5,border=NA, '.$minmaxValues{$rank}->{'max'}.'*2+10,col='.$config[0]->{'misc'}->{'#children'}->[0]->{'color_missingvalues_box'}->{'#value'}.');';
							print R '     }';
							print R '   };'."\n";
							print R 'colors = ifelse(b$n > 0, "black", '.$config[0]->{'misc'}->{'#children'}->[0]->{'color_missingvalues_text'}->{'#value'}.')'."\n";
							if ($metric eq 'True Positives') {
								if ($numberTrueClasses{$rank}->{$dataset}->{min} == $numberTrueClasses{$rank}->{$dataset}->{max}) {
									print R '   abline(h='.$numberTrueClasses{$rank}->{$dataset}->{min}.', col='.$config[0]->{'misc'}->{'#children'}->[0]->{'color_trueClasses_line'}->{'#value'}.');'."\n";
								} else {
									print R '   rect(0,'.$numberTrueClasses{$rank}->{$dataset}->{min}.',length(levels(data$toolname))+1,'.$numberTrueClasses{$rank}->{$dataset}->{max}.', border=NA, col='.$config[0]->{'misc'}->{'#children'}->[0]->{'color_trueClasses_box'}->{'#value'}.');'."\n";
								}
							} elsif ($metric eq 'Unifrac' || $metric eq 'L1norm') {
								foreach my $type (keys(%{$random{$rank}->{$dataset}})) {
									print R 'abline(h='.$random{$rank}->{$dataset}->{$type}.', col='.$config[0]->{'misc'}->{'#children'}->[0]->{'color_randomline_'.$type}->{'#value'}.');'."\n";
								}
							}
							print R 'mtext(side = 3, text="n=", cex=0.4, at=0, line = 0.3);'."\n";
							print R 'mtext(side = 1, text = levels(data$toolname), at = c(1:length(levels(data$toolname))), col=colors, line = 0.8, las=2, cex=0.6);'."\n";
							print R 'mtext(side = 3, text = b$n, at = c(1:length(levels(data$toolname))), col=colors, line = 0.4, las=2, cex=0.4);'."\n";
							print R 'axis(1, labels = FALSE, at = c(1:length(levels(data$toolname))));'."\n";
							print R 'axis(2);'."\n";
							print R 'axis(3, labels = FALSE, cex.axis=0.6, tck=-0.02, at = c(1:length(levels(data$toolname))));'."\n";
							print R 'mtext(side = 1, text = levels(data$toolname), at = c(1:length(levels(data$toolname))), line = 0.8, las=2, cex=0.6, col=colors);'."\n";
							print R "\n";
						}
					}
					print R 'grid.lines(x = '.((1/$numberDatasets)).', y = c(0,0.97), gp = gpar(col = "gray", lwd=5));'."\n";
					print R 'grid.lines(y = '.((1/@ranks)*(@ranks-1)-0.028).', x = c(0,1), gp = gpar(col = "gray", lwd=5));'."\n";
					print R 'mtext("'.$competition.' competition, metric: '.$metric.'", side=3, line=1, outer=TRUE, cex=2, font=2);'."\n";
					if ($metric eq 'True Positives') {
						print R 'par(fig=c(0,1,0,1),oma=c(0,0,0,0),mar=c(0,0,0,0),new=TRUE); plot(0,0,type="n",bty="n",xaxt="n",yaxt="n"); ';
						print R 'legend("bottom", c("number of taxonomic classes in gold standard profile(s)"),xpd=TRUE,horiz=FALSE,inset=c(0,0),bty="n",lty=c(1),col='.$config[0]->{'misc'}->{'#children'}->[0]->{'color_trueClasses_line'}->{'#value'}.',cex=1);'."\n";
					} elsif ($metric eq 'Unifrac' || $metric eq 'L1norm') {
						%allSpecies = %{collectAllTaxonomySpecies_Bacteria()} if (scalar(keys(%allSpecies)) <= 0);
						print R 'par(fig=c(0,1,0,1),oma=c(0,0,0,0),mar=c(0,0,0,0),new=TRUE); plot(0,0,type="n",bty="n",xaxt="n",yaxt="n");'."\n";
						print R 'legend("bottom", c(';
						print R '"significance level '.($config[0]->{'misc'}->{'#children'}->[0]->{'shuffling_significance'}->{'#value'}*100).'%, '.$config[0]->{'misc'}->{'#children'}->[0]->{'numberShufflingIterations'}->{'#value'}.' iterations for the following background models:",';
						print R '"true number of species, drawn from all '.scalar(keys(%allSpecies)).' bacterial species in NCBI, abundances from log-normal(mu='.$config[0]->{'misc'}->{'#children'}->[0]->{'mean_lognormal_abundancedistribution'}->{'#value'}.',sigma='.$config[0]->{'misc'}->{'#children'}->[0]->{'standarddeviation_lognormal_abundancedistribution'}->{'#value'}.')",';
						print R '"true number of species, drawn from all ever prediced species ('.keys(%{$refHash_profileSubmission->{predictedSpecies}}).'), abundances from log-normal(mu='.$config[0]->{'misc'}->{'#children'}->[0]->{'mean_lognormal_abundancedistribution'}->{'#value'}.',sigma='.$config[0]->{'misc'}->{'#children'}->[0]->{'standarddeviation_lognormal_abundancedistribution'}->{'#value'}.')",';
						print R '"true strains, true but shuffled abundances"';
						print R '),xpd=TRUE,horiz=FALSE,inset=c(0,0),bty="n",lty=c(1,1,1),col=c("white", '.$config[0]->{'misc'}->{'#children'}->[0]->{'color_randomline_alice'}->{'#value'}.','.$config[0]->{'misc'}->{'#children'}->[0]->{'color_randomline_iris'}->{'#value'}.','.$config[0]->{'misc'}->{'#children'}->[0]->{'color_randomline_johannes'}->{'#value'}.'),cex=1);'."\n";
					}

					print R 'dev.off()'."\n";
					close R;
				}
				push @parallelCommands, {
					cmd => "cat \"".absFilename($filename_rcommands)."\" | R --vanilla",
					check => $filename_pdf,
				};
#~ $debugEnd = 'true';
				last if ($debugEnd eq 'true');
			}
			last if ($debugEnd eq 'true');
		}
		last if ($debugEnd eq 'true');
	}
	executeParallel(\@parallelCommands);
	foreach my $goldstandard (@goldstandards) {
		my @competitions = @{mergeListsUnique(\@ordered_competitions, [keys(%{$data_metrics{metrics}->{$goldstandard}})])};
		foreach my $competition (@competitions) {
			my @metrics = @{mergeListsUnique(\@ordered_metrics, [keys(%{$data_metrics{metrics}->{$goldstandard}->{$competition}})])};
			my @files = ();
			foreach my $metric (@metrics) {
				push @files, "\"".$dir_cache."/boxplots/".$goldstandard."/".$competition."/".$metric."/boxplots.pdf\"";
			}
			my $outfile = $config[0]->{'directories'}->{'#children'}->[0]->{'output'}->{'#value'}."/boxplots_".$goldstandard."_".$competition.".pdf";
			my $cmd = "pdfunite ".join(" ", @files)." ".$outfile;
			system($cmd);
			$yaml_output .= "  - name: boxplots\n";
			$yaml_output .= "    description: aggregated boxplot presentation of diverse metrics to assess performance of all profiling tool of the CAMI challenge.\n";
			$yaml_output .= "    inline: false\n";
			$yaml_output .= "    value: ".$outfile."\n";
			$yaml_output .= "    type: pdf\n";
		}
	}
}

sub executeParallel {
	my ($refList_cmds) = @_;
	
	our $availcpus = qx(nproc); chomp $availcpus;
	#~ $availcpus--;
	my $cmdFile = $dir_cache."/commands.parallel";
	my $run = 'false';
	open (CMD, "> ".$cmdFile) || die "cannot write command to file '$cmdFile': $?";
		foreach my $element (@{$refList_cmds}) {
			if (not -f $element->{check}) {
				print CMD $element->{cmd}."\n";
				$run = 'true';
			}
		}
	close (CMD);
	
	if ($run eq 'true') {
		system($config[0]->{'misc'}->{'#children'}->[0]->{'parallels_command'}->{'#value'}." -a $cmdFile -j $availcpus")
	}
}

sub compile_goldstandard_data {
	my @shuffleTypes = ('iris','johannes','alice');
	
	my ($refHash_profileSubmission) = @_;
	
	my %allSpecies = ();

	my %cache_parsedFiles = ();
	%cache_parsedFiles = %{parse_cacheLog($dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'log_parsedGoldstandards'}->{'#value'})} if (-e $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'log_parsedGoldstandards'}->{'#value'});
	if ((not -f "EMDUnifrac.py") || (not -f "ProfilingMetrics.py")) {
		print STDERR "downloading tool to quickly compute Unifrac metrics by David Koslicki\n" if ($verbose);
		system("wget https://raw.githubusercontent.com/CAMI-challenge/bbx-profiling-evaluation-dk/master/EMDUnifrac.py");
		system("wget https://raw.githubusercontent.com/CAMI-challenge/bbx-profiling-evaluation-dk/master/ProfilingMetrics.py");
	}
	
	print STDERR "parsing and shuffling goldstandard profiles: " if ($verbose);
	my %data = ();
	%data = %{Storable::retrieve($dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'data_goldstandards'}->{'#value'})} if (-e $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'data_goldstandards'}->{'#value'});
	my @parallelCommands = ();
	foreach my $goldstandardFilename (split(m/\n/, qx(find $config[0]->{'directories'}->{'#children'}->[0]->{'goldstandards'}->{'#value'} -name "*.profile"))) {
		my $id = substr($goldstandardFilename, length($config[0]->{'directories'}->{'#children'}->[0]->{'goldstandards'}->{'#value'}));
		$id =~ s|^/||;
		$id =~ s/\.profile$//;
		$id =~ s/\/|:/_/g;
	
		if ((not exists $cache_parsedFiles{$id}) || ((stat($goldstandardFilename))[9] != $cache_parsedFiles{$id})) {
			%allSpecies = %{collectAllTaxonomySpecies_Bacteria()} if (scalar(keys(%allSpecies)) <= 0);
			print STDERR "*" if ($verbose);
			my ($truth_type, $competition, $dataset, $sample) = split(m/\_/, $id);
			my %profile = %{EvalUtils::readProfile($goldstandardFilename)};
			
			#count number of taxonomic classes
			foreach my $taxid (keys (%{$profile{tree}})) {
				$data{numberTrueClasses}->{$truth_type}->{$competition}->{$dataset}->{$sample}->{$profile{tree}->{$taxid}->{RANK}}++;
			}
			
			#shuffle for p-value computation
			my $dir_shuffling = $dir_cache.'/profile_shuffling/'.$id.'/';
			system("mkdir -p $dir_shuffling") if (not -d $dir_shuffling);
			for (my $i = 0; $i < $config[0]->{'misc'}->{'#children'}->[0]->{'numberShufflingIterations'}->{'#value'}; $i++) {
				foreach my $type (@shuffleTypes) {
					my $shuffled_profile_filename = $dir_shuffling.$type.'_'.$i;
					if (not -f $shuffled_profile_filename.'.profile') {
						open (PROF, "> ".$shuffled_profile_filename.'.profile') || die "cannot write shuffled profile to '$shuffled_profile_filename.profile': $?";
							if ($type eq 'johannes') {
								print PROF shuffle_GoldStandardStrains(\%profile);
							} elsif ($type eq 'iris') {
								print PROF shuffle_selectStrainsFromPool(\%profile, $refHash_profileSubmission->{predictedSpecies});
							} elsif ($type eq 'alice') {
								print PROF shuffle_selectStrainsFromPool(\%profile, \%allSpecies);
							}
						close (PROF);
						push @parallelCommands, {
							cmd => "python ProfilingMetrics.py -o ".$shuffled_profile_filename.'.result'." -g ".$goldstandardFilename." -r ".$shuffled_profile_filename.'.profile'." -n y -e 0 -c y",
							check => $shuffled_profile_filename.'.result',
						};
					}
				}
			}
		} else {
			print STDERR "." if ($verbose);
		}
	}
	print STDERR " done.\n" if ($verbose);
		
	if (@parallelCommands > 0) {
		print STDERR "Compute distance between goldstandard and shuffled profiles (".@parallelCommands."): " if ($verbose);
		executeParallel(\@parallelCommands);
		foreach my $goldstandardFilename (split(m/\n/, qx(find $config[0]->{'directories'}->{'#children'}->[0]->{'goldstandards'}->{'#value'} -name "*.profile"))) {
			my $id = substr($goldstandardFilename, length($config[0]->{'directories'}->{'#children'}->[0]->{'goldstandards'}->{'#value'}));
			$id =~ s|^/||;
			$id =~ s/\.profile$//;
			$id =~ s/\/|:/_/g;
			my ($truth_type, $competition, $dataset, $sample) = split(m/\_/, $id);
			my $dir_shuffling = $dir_cache.'/profile_shuffling/'.$id.'/';

			foreach my $type (@shuffleTypes) {
				my @randomResults = ();
				for (my $i = 0; $i < $config[0]->{'misc'}->{'#children'}->[0]->{'numberShufflingIterations'}->{'#value'}; $i++) {
					push @randomResults, parse_metrics($dir_shuffling.$type.'_'.$i.'.result');
				}
				@randomResults = sort {$a->{Unifrac}->{$RANKINDEPENDENT} <=> $a->{Unifrac}->{$RANKINDEPENDENT}} @randomResults;
				my $index = ceil((@randomResults-1)*$config[0]->{'misc'}->{'#children'}->[0]->{'shuffling_significance'}->{'#value'});
				$data{shuffling}->{$truth_type}->{$competition}->{$dataset}->{$sample}->{$type} = $randomResults[$index];
			}			
			$cache_parsedFiles{$id} = (stat($goldstandardFilename))[9];
		}
		print STDERR " complete.\n" if ($verbose);
	}

	write_cacheLog(\%cache_parsedFiles, $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'log_parsedGoldstandards'}->{'#value'});
	Storable::nstore(\%data, $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'data_goldstandards'}->{'#value'});
	
	return \%data;
}

sub compile_profileSubmission_data {
	my %cache_parsedFiles = ();
	%cache_parsedFiles = %{parse_cacheLog($dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'log_parsedProfileSubmissions'}->{'#value'})} if (-e $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'log_parsedProfileSubmissions'}->{'#value'});
	
	print STDERR "parsing profile submission information: " if ($verbose);
	my %data = ();
	%data = %{Storable::retrieve($dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'data_profileSubmissions'}->{'#value'})} if (-e $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'data_profileSubmissions'}->{'#value'});
	foreach my $profileSubmission (split(m/\n/, qx(find $config[0]->{'directories'}->{'#children'}->[0]->{'profileSubmissions'}->{'#value'} -type f -name "*"))) {
		my $id = pop [split(m|/|, $profileSubmission)];
		
		if ((not exists $cache_parsedFiles{$id}) || ((stat($profileSubmission))[9] != $cache_parsedFiles{$id})) {
			print STDERR "*" if ($verbose);
			my %profile = %{EvalUtils::readProfile($profileSubmission)};
			foreach my $taxid (keys (%{$profile{'tree'}})) {
				if (lc($profile{'tree'}->{$taxid}->{'RANK'}) eq "species") {
					if (not exists $data{predictedSpecies}->{$taxid}) {
						my %taxon = %{getTaxSpecies($taxid)};
						$data{predictedSpecies}->{$taxid} = \%taxon; # if ($taxon{TAXPATH} =~ m/^2\|/);
					}
				}
			}
			$cache_parsedFiles{$id} = (stat($profileSubmission))[9];
		} else {
			print STDERR "." if ($verbose);
		}
	}
	write_cacheLog(\%cache_parsedFiles, $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'log_parsedProfileSubmissions'}->{'#value'});
	Storable::nstore(\%data, $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'data_profileSubmissions'}->{'#value'});
	print STDERR " done.\n" if ($verbose);
	print STDERR "Found ".scalar(keys(%{$data{predictedSpecies}}))." different species.\n" if ($verbose);

	return \%data;
}

sub compile_metrics_data {
	my %cache_parsedFiles = ();
	%cache_parsedFiles = %{parse_cacheLog($dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'log_parsedSubmissions'}->{'#value'})} if (-e $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'log_parsedSubmissions'}->{'#value'});
	
	print STDERR "parsing metrics.txt information from single submission runs: " if ($verbose);
	my %data = ();
	%data = %{Storable::retrieve($dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'data_metrics'}->{'#value'})} if (-e $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'data_metrics'}->{'#value'});
	foreach my $propsFilename (split(m/\n/, qx(find $config[0]->{'directories'}->{'#children'}->[0]->{'singleSubmissionResults'}->{'#value'} -name "description.properties"))) {
		my $id = substr($propsFilename, length($config[0]->{'directories'}->{'#children'}->[0]->{'singleSubmissionResults'}->{'#value'}));
		$id =~ s|^/||;
		$id =~ s/\/description\.properties//;
		my $metricsFilename = $propsFilename; $metricsFilename =~ s|description\.properties|/output/metrics.txt|;
		if ((not exists $cache_parsedFiles{$id}) || ((stat($metricsFilename))[9]+(stat($propsFilename))[9] != $cache_parsedFiles{$id})) {
			print STDERR "*" if ($verbose);
			my %properties = %{parse_properties($propsFilename)};			
			my %metrics = %{parse_metrics($metricsFilename)};

			foreach my $metricname (keys %metrics) {
				foreach my $rank (@ordered_ranks, $RANKINDEPENDENT) {
					if (defined $metrics{$metricname}->{$rank}) {
						my $elem = {
							'id' => $id,
							'method_name' => $properties{'method_name'},
							'version' => $properties{'version'},
							'anonymous_name' => $properties{'anonymous_name'},
							'value' => $metrics{$metricname}->{$rank},						
						};
						next if (($metricname eq 'Precision') && ($metrics{$metricname}->{$rank} == -1)); # skip precision values of "-1". They indicate a missing value. Precision must always be non negative!
						push @{$data{metrics}->{$properties{'_truth_type'}}->{map_competition($properties{'competition_name'})}->{$metricname}->{$rank}->{map_poolname($properties{'pool_name'})}->{map_samplename($properties{'sample_name'})}}, $elem;
						$data{meta}->{everSeen}->{toolnames}->{map_toolname($properties{'method_name'}, $properties{'version'})}++;
						$data{meta}->{everSeen}->{datasets}->{map_poolname($properties{'pool_name'})}++;
						$data{meta}->{everSeen}->{competitions}->{map_competition($properties{'competition_name'})}++;
					}
				}
			}
			$cache_parsedFiles{$id} = (stat($metricsFilename))[9]+(stat($propsFilename))[9];
		} else {
			print STDERR "." if ($verbose);
		}
	}
	write_cacheLog(\%cache_parsedFiles, $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'log_parsedSubmissions'}->{'#value'});
	Storable::nstore(\%data, $dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'data_metrics'}->{'#value'});
	print STDERR " done.\n" if ($verbose);
	
	return \%data;
}

sub map_toolname {
	my ($method_name, $version) = @_;
	
	if (($method_name eq 'Common Kmers') && ($version eq '')) {
		return 'Adam_s_1';
	} elsif (($method_name eq 'Common Kmers') && ($version eq 'Sensitive Unnormalized')) {
		return 'Adam_s_2';
	} elsif (($method_name eq 'commonkmers') && ($version eq 'sjanssen')) {
		return 'Adam_d';
	} elsif (($method_name eq 'FOCUS') && ($version eq 'cfk8bd')) {
		return 'Brian_s_1';
	} elsif (($method_name eq 'FOCUS') && ($version eq 'cfk7bd')) {
		return 'Brian_s_2';
	} elsif (($method_name eq 'FOCUS') && ($version eq 'cfk7d')) {
		return 'Brian_s_3';
	} elsif (($method_name eq 'FOCUS') && ($version eq 'cfk7b')) {
		return 'Brian_s_4';
	} elsif (($method_name eq 'FOCUS') && ($version eq 'cfk8b')) {
		return 'Brian_s_5';
	} elsif (($method_name eq 'FOCUS') && ($version eq 'cfk8d')) {
		return 'Brian_s_6';
	} elsif (($method_name eq 'FOCUS') && ($version eq 'sjanssen')) {
		return 'Brian_d';
	} elsif (($method_name eq 'DUDes') && ($version eq 'old')) {
		return 'Cesar_s_2';
	} elsif (($method_name eq 'DUDes') && ($version eq '')) {
		return 'Cesar_s_1';
	} elsif (($method_name eq 'Taxy-Pro') && ($version eq 'sjanssen')) {
		return 'Donald_d';
	} elsif (($method_name eq 'Taxy-Pro') && ($version eq '')) {
		return 'Donald_s';
	} elsif (($method_name eq 'MetaPhyler') && ($version eq 'V1.25')) {
		return 'Edd_d';
	} elsif (($method_name eq 'mOTU') && ($version eq '1.1.1')) {
		return 'Frank_d';
	} elsif (($method_name eq 'CLARK') && ($version eq 'v1.1.3')) {
		return 'Gustav_s';
	} elsif (($method_name eq 'MetaPhlAn2.0') && ($version eq 'db_v20')) {
		return 'Hank_d';
	} elsif (($method_name eq 'TIPP') && ($version eq '1.1')) {
		return 'Isaac_d';
	} elsif (($method_name eq 'mpipe') && ($version eq '')) {
		return 'Jack_s';
	} elsif (($method_name eq 'Quickr') && ($version eq 'sjanssen')) {
		return 'Kirk_d';
	} else {
		my $output = $method_name;
		$output .= "_".$version if ($version ne '');
		$output =~ s/\s/_/g;
		return $output;
	}
}

sub map_poolname {
	my ($input) = @_;

	if ($input =~ m/1st CAMI Challenge Dataset \d CAMI_(high|medium|low)/) {
		return lc($1);
	} elsif ($input =~ m/Toy Test Dataset (High|Medium|Low)_Complexity/) {
		return lc($1);
	}
	
	return $input;
}

sub map_samplename {
	my ($input) = @_;

	if ($input =~ m/HIGH_S00(\d)/ || $input =~ m/HC_Sample(\d)/) {
		return $1;
	} elsif ($input =~ m/MED_S00(\d)/ || $input =~ m/MC_Sample(\d)_/) {
		return $1;
	} elsif ($input =~ m/LOW_S00(\d)/ || $input =~ m/LC_Sample(\d)_/) {
		return $1;
	} else {
		return "pool";
	}
	
	return $input;
}

sub map_competition {
	my ($input) = @_;

	if ($input eq 'CAMI Challenge') {
		return 'CAMI';
	} elsif ($input eq 'Toy Run') {
		return 'Toy';
	}
	
	return $input;
}

sub parse_properties {
	my ($filename) = @_;
	
	my %content = ();
	open (IN, $filename) || die "parse_properties: cannot read file '$filename': $?";
		while (my $line = <IN>) {
			next if ($line =~ m/^\s*$/);
			chomp $line;
			my ($key, $value) = ($line =~ m/^(.+?)=(.*)$/);
			$content{$key} = $value;
		}
	close (IN);
	
	return \%content;
}

sub parse_cacheLog {
	my ($filename) = @_;
	
	my %content = ();
	open (IN, $filename) || die "parse_cachelog: cannot read file '$filename': $?";
		while (my $line = <IN>) {
			next if ($line =~ m/^\s*$/ || $line =~ m/^#/);
			my ($file, $date) = split(m/\n|\t/, $line);
			$content{$file} = $date;
		}
	close (IN);
	
	return \%content;
}

sub parse_metrics {
	my ($filename) = @_;
	
	my %content = ();
	open (IN, $filename) || die "parse_metrics: cannot read file '$filename': $?";
		my @metricNames = ();
		while (my $line = <IN>) {
			next if ($line =~ m/^\s*$/);
			if (@metricNames == 0) {
				@metricNames = split(m/\t|\n/, $line);
				shift @metricNames; #omit "Taxonomic Rank"
				foreach my $name (@metricNames) {
					$name =~ s/:.*$//;
				}
				next;
			}
			my @fields = split(m/\t|\n/, $line);
			if ($fields[0] eq 'rank independent') {
				$content{$metricNames[0]}->{$RANKINDEPENDENT} = $fields[1];
			} else {
				for (my $i = 2; $i < @fields; $i++) {
					$content{$metricNames[$i-1]}->{$fields[0]} = $fields[$i];
				}
			}
		}
	close (IN);
	
	return \%content;
}

sub write_cacheLog {
	my ($refHash, $filename) = @_;
	
	open (OUT, "> ".$filename) || die "write_cachelog: cannot write file '$filename': $?";
		print OUT "# a list of items that have been read somewhen in the past. The second column informs of the point in time, when read the item. Delete lines, if you want to re-analyse those items. They might have changed in between.\n";
		foreach my $id (keys(%{$refHash})) {
			print OUT $id."\t".$refHash->{$id}."\n";
		}
	close (IN);
}

sub absFilename {
	my ($filename) = @_;
	
	my $afn = qx(readlink -m "$filename");
	chomp $afn;
	
	return $afn;
}
sub mergeListsUnique {
	my ($listA, $listB) = @_;

	my @result = ();
	foreach my $elemA (@{$listA}) {
		if ((not listContains(\@result, $elemA)) && (listContains($listB, $elemA))) {
			push @result, $elemA;
		}
	}
	foreach my $elemB (@{$listB}) {
		if (not listContains(\@result, $elemB)) {
			push @result, $elemB;
		}
	}
	
	return \@result;
}
sub listContains {
	my ($list, $elem) = @_;
	
	foreach my $l (@{$list}) {
		return 1 if ($l eq $elem);
	}
	
	return 0;
}

sub shuffle_GoldStandardStrains {
	#take all strains from a true profile, which have a superkingdom; this exclues e.g. plasmids. Randomly reassign existing abundances to these strains; renormalize the profile and reconstruct the upper part of the tree.
	my ($goldstandard) = @_;
	
	my %profile_goldstandard = %{$goldstandard};
	my %profile_shuffled = %{dclone \%profile_goldstandard};
	delete $profile_shuffled{tree};
	
	my @abundances = ();
	foreach my $taxid (keys(%{$profile_goldstandard{tree}})) {
		next if ($profile_goldstandard{tree}->{$taxid}->{RANK} ne 'strain');
		next if ($profile_goldstandard{tree}->{$taxid}->{TAXPATH} =~ m/^\|/); #omit strains of unknown origin, e.g. plasmids
		push @abundances, $profile_goldstandard{tree}->{$taxid}->{PERCENTAGE};
	}
	my $nrSpecies = scalar(@abundances);
	foreach my $taxid (keys(%{$profile_goldstandard{tree}})) {
		next if ($profile_goldstandard{tree}->{$taxid}->{RANK} ne 'strain');
		next if ($profile_goldstandard{tree}->{$taxid}->{TAXPATH} =~ m/^\|/); #omit strains of unknown origin, e.g. plasmids
		$profile_shuffled{tree}->{$taxid} = dclone $profile_goldstandard{tree}->{$taxid};
		$profile_shuffled{tree}->{$taxid}->{PERCENTAGE} = splice(@abundances, int(rand @abundances), 1)
	}

	EvalUtils::reconstructProfile(\%profile_shuffled);
	my $prof = EvalUtils::printProfile(\%profile_shuffled);
	
	return $prof;
}

sub loadTaxonomy {
	$NCBItaxonomy{nodes} = Utils::read_taxonomytree($config[0]->{'directories'}->{'#children'}->[0]->{'taxonomy'}->{'#value'}."/nodes.dmp") if (not exists $NCBItaxonomy{nodes});
	$NCBItaxonomy{names} = Utils::read_taxonomyNames($config[0]->{'directories'}->{'#children'}->[0]->{'taxonomy'}->{'#value'}."/names.dmp") if (not exists $NCBItaxonomy{names});
	$NCBItaxonomy{merged} = Utils::read_taxonomyMerged($config[0]->{'directories'}->{'#children'}->[0]->{'taxonomy'}->{'#value'}."/merged.dmp") if (not exists $NCBItaxonomy{merged});
}
sub getTaxSpecies {
	my ($taxid) = @_;
	
	loadTaxonomy();
	
	if (not exists $NCBItaxonomy{nodes}->{$taxid}) {
		if (not exists $NCBItaxonomy{merged}->{$taxid}) {
			print "error: cannot find a taxonomy ID '$taxid'.\n";
		} else {
			$taxid = $NCBItaxonomy{merged}->{$taxid};
		}
	}
	my @lineage = @{Utils::getLineage($taxid, $NCBItaxonomy{nodes})};
	Utils::addNamesToLineage(\@lineage, $NCBItaxonomy{names});
	my $taxpath = "";
	my $taxpathsn = "";
	foreach my $rank (@lineage) {
		if (Utils::isWantedRank($rank->{rank}, \@ordered_ranks)) {
			$taxpath .= $rank->{'taxid'}."|";
			$taxpathsn .= $rank->{'name'}."|";
		}
	}
	return {
		'RANK' => 'species',
		'TAXPATH' => substr($taxpath, 0, -1),
		'TAXPATHSN' => substr($taxpathsn, 0, -1),
		'TAXID' => $taxid,
	};
}

sub collectAllTaxonomySpecies_Bacteria {
	my $storefilename = absFilename($dir_cache.'/'.$config[0]->{'filenames'}->{'#children'}->[0]->{'data_allSpeciesOfTaxonomy'}->{'#value'});
	
	my %species = ();
	if (-e $storefilename) {
		%species = %{Storable::retrieve($storefilename)};
	} else {
		loadTaxonomy();
		#collect all species that are bacteria, i.e. superkingdom == 2 of a NCBI taxonomy
		print STDERR "collecting all bacterial species from taxonomy:\n";
		foreach my $taxid (keys(%{$NCBItaxonomy{nodes}})) {
			next if ($NCBItaxonomy{nodes}->{$taxid}->{rank} ne 'species');
			my %taxon = %{getTaxSpecies($taxid)};
			$species{$taxid} = \%taxon if ($taxon{TAXPATH} =~ m/^2\|/);
		}
		print STDERR " done. Found ".scalar(keys(%species))." different species.\n";
		Storable::nstore(\%species, $storefilename);
	}
	
	return \%species;
}

sub shuffle_selectStrainsFromPool {
	my ($inputProfile, $refHash_species) = @_;

	my $nrSpecies = 0;
	foreach my $taxid (keys(%{$inputProfile->{tree}})) {
		next if ($inputProfile->{tree}->{$taxid}->{RANK} ne 'strain');
		next if ($inputProfile->{tree}->{$taxid}->{TAXPATH} =~ m/^\|/); #omit strains of unknown origin, e.g. plasmids
		$nrSpecies++;
	}

	my ($mean, $standarddeviation) = ($config[0]->{'misc'}->{'#children'}->[0]->{'mean_lognormal_abundancedistribution'}->{'#value'}, $config[0]->{'misc'}->{'#children'}->[0]->{'standarddeviation_lognormal_abundancedistribution'}->{'#value'});
	my $normal = Math::Random::OO::Normal->new($mean,$standarddeviation);

	my %profile_shuffled = %{dclone $inputProfile};
	delete $profile_shuffled{tree};
	my @species = keys(%{$refHash_species});
	for (my $i = 0; $i < $nrSpecies; $i++) {
		my $taxid = splice(@species, int(rand @species), 1);
		$profile_shuffled{tree}->{$taxid} = dclone $refHash_species->{$taxid};
		$profile_shuffled{tree}->{$taxid}->{PERCENTAGE} = exp($mean+$standarddeviation*$normal->next());
	}
	EvalUtils::reconstructProfile(\%profile_shuffled);
	
	return EvalUtils::printProfile(\%profile_shuffled);
}

sub computeMedian {
	my ($refList) = @_;

	my @sorted = sort {$a <=> $b} (@{$refList});
	if (@sorted % 2 == 1) {
		return $sorted[$#sorted/2];
	} else {
		return ($sorted[@sorted/2]+$sorted[@sorted/2-1])/2;
	}
}
sub computeAVG {
	my ($refList) = @_;

	my $sum = 0;
	foreach my $elem (@{$refList}) {
		$sum += $elem;
	}
	if (@{$refList} != 0) {
		return ($sum / @{$refList});
	} else {
		return 0;
	}
}
