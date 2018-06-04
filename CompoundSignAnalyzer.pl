#!/usr/bin/perl
print "--- Compound Sign Analyzer ---\n";
use utf8;
use Unicode::Collate;
use utf8::all;

my $collator = Unicode::Collate->new(table => undef); #returns an object

#load sillabary as hash (sign value => SIGN NAME)
open(S, "<syllabary_WEM_diri.tab") || die "Error opening the sillabary!\n\n";
@syll_WEM = <S>;

#open OUTPUT file
open(OUT, ">_OUTPUT_composite_signs_map.gexf") || die "Error creating the output file!\n\n";

foreach $line (@syll_WEM) {
    chop $line;
    @columns = split (/\t/,$line);
    $sign_names = $columns[1];
    $sign_names =~ s/&/÷/g;
    $sign_names =~ s/\(//g;
    $sign_names =~ s/\)//g;
    #$sign_names =~ s/@/~/g;
    #$sign_names =~ s/%/_CROSSED_/g;
    
    if (($sign_names =~ m/×/) && ($sign_names !~ m/\./)) { ## no GA2×AN.DUN3@g = agarin3
	@signs = split (/\./, $sign_names);
	foreach $sign (@signs) {
	    $nodes{$sign}++;  #track and count signs used in diri compounds, ex.: TE => 7; count = node weight
	}
	for ($n=0;$n<=$#signs;$n++) {
	    for ($m=$n+1;$m<=$#signs;$m++) {
		$edge_couple = "$signs[$n]--$signs[$m]";
		$edges{$edge_couple}++;
	    }
	}
    }
   
}

print OUT "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print OUT "<gexf xmlns=\"http://www.gexf.net/1.1draft\"\n";
print OUT "    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n";
print OUT "    xsi:schemaLocation=\"http://www.gexf.net/1.1draft http://www.gexf.net/1.1draft/gexf.xsd\"    version=\"1.1\">\n";
print OUT "    <graph mode=\"static\" defaultedgetype=\"undirected\">\n";


print OUT "<nodes>\n";

foreach $node (keys %nodes) {
    print OUT "\t\t<node id=\"$node\" label=\"$node\" />\n"; #<node id="0.0" label="Myriel"/>
}
print OUT "</nodes>\n";


print OUT "<edges>\n";
foreach $edge (keys %edges) {
    @start_end = split (/--/, $edge);
    print OUT "\t<edge id=\"$edge\" source=\"$start_end[0]\" target=\"$start_end[1]\" weight=\"$edges{$edge}.0\" />\n"; #label=\"$edges_labels{$edge}\"\n";
}

print OUT "</edges>\n";

print OUT "</graph>\n";
print OUT "</gexf>\n";
print "\nDone.\n";


close S;
