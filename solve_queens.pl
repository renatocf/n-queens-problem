#!/usr/bin/perl
package main;
use v5.14;

# Pragmas
use strict;
use warnings;
use Fcntl qw(LOCK_EX);

# Options
use Getopt::Long;
my $help = undef;
GetOptions("help" => \$help);

# Help message
if($help) { system(q/perl -wT Queens.pl --help/); exit }

# Usage/variables
scalar @ARGV == 1 and my $n = shift @ARGV 
or die "Usage: solve_queels.pl n_queens\n";

$n =~ /^(\d+)$/
or die "The number of queens must be made only of integers";

my $num = $n = $1;
unless($n > 0) { die "Must be a positive number of queens!"; }
elsif($n < 10) { $n = "0".$n; }

# Call Queen.pl with 'n' and stores the output in n_queens.cnf
open(my $CNF, ">", "${n}_queens.cnf")
    or die "Cannot open ${n}_queens.cnf";

flock $CNF, LOCK_EX 
    or die "Could not lock ${n}_queens.cnf";

print $CNF qx/perl -wT Queens.pl ${num}/;
close $CNF;

# Call minisat with 'n' and stores the output in n_queens.minisat
open(my $SAT, ">", "${n}_queens.minisat"); 
    or die "Cannot open ${n}_queens.minisat";

flock $CNF, LOCK_EX 
    or die "Could not lock ${n}_queens.minisat";

print $SAT qx|minisat ${n}_queens.cnf ${n}_queens.ans 2>/dev/null|;
close $SAT;

# Call gen_tab.pl with n_queens.ans and shows the result in STDOUT
print qx/perl -wT gen_tab.pl ${num} < ${n}_queens.ans/;
