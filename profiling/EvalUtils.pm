#/usr/bin/env perl

use strict;
use warnings;

package EvalUtils;

use Data::Dumper;
use Storable 'dclone', 'nstore', 'retrieve';

sub readProfile {
	my ($filename) = @_;
	
	my %header = ();
	my %profile = ();
	my @headerOrder = ();
	my @bodyHeader = ();
	open (IN , $filename) || die "cannot read profile '$filename': $!";
		while (my $line = <IN>) {
			if ($line =~ m/^@/) {
				if ($line =~ m/^@@(.+?)$/) {
					@bodyHeader = split(m/\t|\n/, $1);
				} else {
					my ($key, $value) = ($line =~ m/^@(.+?):(.*?)$/);
					push @headerOrder, $key;
					$header{$key} = $value;
				}
			} elsif ($line =~ m/^\s*$/) {
			} elsif ($line =~ m/^#/) {
			} elsif ($line =~ m/^\d+\.?\d*\s+/) {
				my @fields = split(m/\t|\n/, $line);
				my %taxon = ();
				for (my $i = 0; $i < @fields; $i++) {
					$taxon{$bodyHeader[$i]} = $fields[$i];
				}
				$profile{$fields[0]} = \%taxon;
			} else {
				die "unexpected line: '$line'\n";
			}
		}
	close (IN);
	
	return {header => \%header, tree => \%profile, header_order => \@headerOrder, body_order => \@bodyHeader};
}

sub printProfile {
	my ($profile) = @_;
	
	my $out = "# Taxonomic Profiling Output\n";
	foreach my $key (@{$profile->{header_order}}) {
		$out .= '@'.$key.":".$profile->{header}->{$key}."\n";
	}
	$out .= '@@'.join("\t", @{$profile->{body_order}})."\n";
	
	my @ranks = split(m#\s*\|\s*#, $profile->{header}->{Ranks});
	foreach my $rank (@ranks, 'no rank') {
		foreach my $taxid (sort {$profile->{tree}->{$b}->{PERCENTAGE} <=> $profile->{tree}->{$a}->{PERCENTAGE}} keys(%{$profile->{tree}})) {
			if (lc($profile->{tree}->{$taxid}->{RANK}) eq $rank) {
				foreach my $field (@{$profile->{body_order}}) {
					if (exists $profile->{tree}->{$taxid}->{$field}) {
						$out .= $profile->{tree}->{$taxid}->{$field};
					}
					$out .= "\t" if ($field ne $profile->{body_order}->[@{$profile->{body_order}}-1]);
				}
				$out .=  "\n";
			}
		}
	}
	
	return $out;
}

sub reconstructProfile {
	my ($profile) = @_;
	
	#renormalilze to 100 % if all existing taxa are of one level
		my $allOfOneLevel = undef;
		foreach my $taxid (keys(%{$profile->{tree}})) {
			if (not defined $allOfOneLevel) {
				$allOfOneLevel = $profile->{tree}->{$taxid}->{RANK};
			} else {
				$allOfOneLevel = 'false' if ($allOfOneLevel ne $profile->{tree}->{$taxid}->{RANK});
				last;
			}
		}
		if ($allOfOneLevel ne 'false') {
			my $sum = 0;
			foreach my $taxid (keys(%{$profile->{tree}})) {
				$sum += $profile->{tree}->{$taxid}->{PERCENTAGE};
			}
			foreach my $taxid (keys(%{$profile->{tree}})) {
				$profile->{tree}->{$taxid}->{PERCENTAGE} /= $sum / 100;
			}
		}
	
	my %newTaxids = ();
	my @ranks = split(m#\s*\|\s*#, $profile->{header}->{Ranks});
	foreach my $taxid (keys(%{$profile->{tree}})) {
		my @taxpath = split(m/\|/, $profile->{tree}->{$taxid}->{TAXPATH});
		my @taxpathname = split(m/\|/, $profile->{tree}->{$taxid}->{TAXPATHSN});
		for (my $i = 0; $i+1 < @taxpath; $i++) {
			if (not exists $newTaxids{$taxpath[$i]}) {
				$newTaxids{$taxpath[$i]} = {
					TAXID => $taxpath[$i],
					RANK => $ranks[$i],
					TAXPATH => join("|", @taxpath[0 .. $i]),
					TAXPATHSN => join("|", @taxpathname[0 .. $i]),
					PERCENTAGE => $profile->{tree}->{$taxid}->{PERCENTAGE}
				}
			} else {
				$newTaxids{$taxpath[$i]}->{PERCENTAGE} += $profile->{tree}->{$taxid}->{PERCENTAGE};
			}
		}
	}
	
	foreach my $taxid (keys(%newTaxids)) {
		$profile->{tree}->{$taxid} = dclone \%{$newTaxids{$taxid}};
	}
}


1;