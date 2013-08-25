#!/usr/bin/perl
package main;
use v5.14;

say "How many queens do yoy want to run the pipeline?";
chomp(my $n = <STDIN>); my $num = $n;

if($n <= 0)    { die "Must be a positive number of queens!"; }
elsif($n < 10) { $n = "0".$n; }

open(my $CNF, ">", "${n}_queens.cnf");
print $CNF qx/perl Queens.pl ${num}/;
close $CNF;

open(my $SAT, ">", "${n}_queens.minisat");
print $SAT qx|minisat ${n}_queens.cnf ${n}_queens.ans 2>/dev/null|;
close $SAT;

print qx/perl gen_tab.pl ${num} < ${n}_queens.ans/;
