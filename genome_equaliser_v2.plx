#!/usr/bin/perl
# Written: Nick Kent Nov 2011
# Last updated: Nick Kent, 21st Oct 2014
# Updated: Nick Kent, 14th June 2019 - use cwd
# USAGE:- perl genome_equaliser_v2.plx
#
#
# This script takes one or more whole genome .sgr files output from the Yeast/Dicty_KDE.plx +
# chromo_equalizer.plx process (placed in the genome_B directory), and attempts to normalize 
# their overall peak height profiles to a comparator whole genome.sgr file profile (placed
# in the genome_A directory). 
#
# When you run the script, the A file will be used to calculate a "read frequency per
# bin" value. A similar value is calculated for each B directory file and the A/B ratio
# is used to define scaling factors which are applied to each B file. The normalized .sgr
# files are output into the out directory.
#
# This version outputs frequency per bin values at the command line
#
# WARNING: this is still a development script 
#
#
#
################################################################################
use strict;
use Cwd;
use warnings;
use Math::Round;
################################################################################
# SET THE 3 VARIABLES BELOW AS REQUIRED
# $A_indir_path   - The directory containing a comparator .sgr file
# $B_indir_path   - The directory containing the remaining  .sgr files
# $outdir_path  - The directory to store the normalized .sgr output files
################################################################################

my $A_indir_path =cwd."/genome_A";
my $B_indir_path =cwd."/genome_B";
my $outdir_path =cwd."/genome_out";

################################################################################
################################################################################
# MAIN PROGRAM - you should not need to edit below this line
################################################################################
################################################################################
#print "start:\t", `date`."\n";

####################
####################
# THE INPUT FILE(S)
####################
####################

# define some variables
my (@A_files, $A_infile, $outfile, @A_line);
my (@B_files, $B_infile, @B_line);
my $scale_factor;

# Open the A file

# store input file names in an array
opendir(DIR, $A_indir_path) || die "Unable to access file at: $A_indir_path $!\n";
@A_files = readdir(DIR);

# process each A input file within the indir_path in turn
foreach $A_infile (@A_files){
    
    # ignore hidden files and only get the one ending .sgr
    if (($A_infile !~ /^\.+/) && ($A_infile =~ /.*\.sgr/)){
        

        
        # get chromosome number from infile name
        $A_infile =~ /\w{3}(\d+).*/;

		        
        # print out some useful info
        print ("\nThe base file for comaprison is '".$A_infile."'\n");

        
        open(IN, "$A_indir_path/$A_infile")
            || die "Unable to open $A_infile: $!";
        
        # define new array to store required values from infile
        # define some variables
        my @A_chr;
        my @A_bin;
	my @A_freq;
	my ($A_sum, $A_values, $A_average);
        
        # loop through infile to get values
        while(<IN>){
            
	chomp;
            # split line by delimiter and store elements in an array
            @A_line = split('\t',$_);
            
            # store the columns we want in a new array
            # sum the "read frequency" values

	    push(@A_chr, $A_line[0]);
            push(@A_bin, $A_line[1]);
            push(@A_freq, $A_line[2]);
            $A_sum += $A_line[2];
	   
        }
        
        # close in file handle
        close(IN);
        
        # determine average read frequency per bin
        $A_values = @A_bin;
        $A_average = $A_sum/$A_values;
        


# find and process the B input files

# store input file names in an array
opendir(DIR, $B_indir_path) || die "Unable to access file at: $B_indir_path $!\n";
@B_files = readdir(DIR);

# process each A input file within the indir_path in turn
foreach $B_infile (@B_files){
    
    # ignore hidden files and only get the one ending .sgr
    if (($B_infile !~ /^\.+/) && ($B_infile =~ /.*\.sgr/)){
        

        
        # get chromosome number from infile name
        $B_infile =~ /\w{3}(\d+).*/;


		        
        # print out some useful info
        print ("\nProcessing '".$B_infile."'\n");
        
        open(IN, "$B_indir_path/$B_infile")
            || die "Unable to open $B_infile: $!";
        
        # define new array to store required values from infile
        # define some variables
        my @B_chr;
        my @B_bin;
	my @B_freq;
	my ($B_sum, $B_values, $B_average);
        
        # loop through infile to get values
        while(<IN>){
            
	chomp;
            # split line by delimiter and store elements in an array
            @B_line = split('\t',$_);
            
            # store the columns we want in a new array
            # sum the "read frequency" values

	    push(@B_chr, $B_line[0]);
            push(@B_bin, $B_line[1]);
            push(@B_freq, $B_line[2]);
            $B_sum += $B_line[2];
	   
        }
        
        # close in file handle
        close(IN);
        
        # determine average read frequency per bin
        $B_values = @B_bin;
        $B_average = $B_sum/$B_values;
        
        #calculate scale factor for this file
        $scale_factor = $A_average/$B_average;
        
        print "\nAverage frequency value per bin in the A genome was: $A_average";
        print "\nAverage frequency value per bin in the B genome was: $B_average";
        print "\nScaling factor for $B_infile is: $scale_factor\n";
        

#########################################################################################
##########################################################################################
#The output of normalized files
##########################################################################################
##########################################################################################
        # define outfile name from infile name
        $outfile = substr($B_infile,0,-4)."_gnorm"."_$scale_factor";
        $outfile .= '.sgr';
        
        # try and open the .sgr output file
        open(OUT,"> $outdir_path/$outfile")
             || die "Unable to open $outfile: $!";
        
print "\nJust creating $outfile\n";

# a counter variables
my $count = 0; # Counter for each line ID

until ($count == $B_values){ #until 1

print(OUT 
		$B_chr[$count]."\t".
		$B_bin[$count]."\t".
		round($B_freq[$count]*$scale_factor)."\n");
		
		$count++;

} #until 1 closer


 # close .sgr out file handle
        close(OUT);

        
        
    }
}
}
}
#print "\nend:\t", `date`."\n";
