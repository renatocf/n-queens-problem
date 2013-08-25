#!/usr/bin/perl
use v5.14;

# Receives as input the number of queens
my $n_queens = shift @ARGV
or die "USAGE: gen_tab.pl n_queens";

# Discards first line, checking if it is a minisat ans
chomp(my $title = <>);
say $title;
$title =~ /SAT/i or die "Not a minisat answer!";

# Prints the top of the table
print ".---" x $n_queens, ".\n";

# The middle
$/ = " ";
my ($i, $j) = (1,1); 
while((my $var = <>) != 0)
{
    print "| ";
    ($var < 0) ? (print "  ") : (print "Q "); # Queen or empty?
    ($i == $n_queens) ? ($i = 1) : ($i++);    # Line completed?
    
    if($i == 1)
    {
        print "|\n";
        ($j++ != $n_queens) ? # Last variable?
            (print "|---" x $n_queens, "|\n") : ();
    }
}

# And finally the bottom
print "'---" x $n_queens, "'\n";
