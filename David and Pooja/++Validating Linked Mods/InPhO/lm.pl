#!/usr/bin/perl
# first attempt at rating matched links from entities to wikipedia
# Reads from STDIN -- i.e.: perl lev.pl < TSV_FILE
# TSV FILE should have at least 3 tab-separated columns
#   native identifier     wikipedia match     string used to match

# Writes to STDOUT tab separated lines with first an integer indicating
# confidence, 0-9, and rest as before.

use utf8;
use Text::Levenshtein qw(distance);
use URI::Encode qw(uri_encode uri_decode);;

while (<>) {
    chomp;
    my $match = 0;
    
    (my $id, my $wp_orig, my $name_orig, my @rest) = split(/\t/);

    # split out and regularize the components of the wikipedia identifier
    my $wp = $wp_orig;
    $wp = uri_decode($wp);
    $wp =~ s/_*\([^)]+\)//g;
    $wp = lc($wp);
    my @wpf = split(/\//,$wp);
    my @wpfe = split(/_/,$wpf[$#wpf]);
    

    
    # split out and regularize the components of the name/label
    my $name = $name_orig;
    $name = uri_decode($name);
    $name =~ s/\s*\([^)]+\)//g;
    $name = lc($name);
    my @namee = split(/\s/,$name);
    
    
    if ($namee[$#namee] eq $wpfe[$#wpfe]) { # last parts match exactly
	if ($namee[0] eq $wpfe[0]) { # first parts match exactly
	    $match = 9; # high confidence

	} elsif (distance($namee[0],$wpfe[0]) < 2) {
	    $match = 8; # reasonable conf
	    
	} elsif (length($namee[0])<3 or length($wpfe[0])<3) { # initials?
	    my @nchars = split(//,$namee[0]);
	    my @wchars = split(//,$wpfe[0]);
	    if ($nchars[0] eq $wchars[0]) {
		$match = '8';
	    }
	} else { # try to match into name
	    foreach my $w (@wpfe) {
		foreach my $n (@namee) {
		    if ($n eq $w) {
			$match = 7;
			
		    } elsif ( distance($n,$w) < 2) {
			$match = 6;
		    }
		}
	    }
	}
    } elsif ($namee[0] eq $wpfe[$#wpfe]
	     and $namee[$#namee] eq $wpfe[0]) { # crossover
	$match = 7;

    } elsif (distance($namee[$#namee],$wpfe[$#wpfe]) + distance($namee[0],$wpfe[0]) < 3) { # or nearly match
	$match = 8;
    } 
    
    print join("\t",$match,$id,$wp_orig,$name_orig);
    print "\n";
}
