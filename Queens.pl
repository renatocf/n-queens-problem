#!/usr/bin/perl 
package main;
use v5.14;

# Problem of N queens: given N queens 
# and a NxN chess board, is it possible 
# to put all the queens in such a way 
# they do not attack each other?
# 
# Example: 4x4 chess table with 4 queens
# Result:  SATISFABLE
#
#       01     02     03     04
#    .------.------.------.------.
#    |      | ++++ |      |      |
# 01 |  13  |  Q1  | 3142 |  12  |
#    |      | ++++ |      |      |
#    |------|------|------|------|
#    |      |      |      | ++++ |
# 02 | 1234 | 321  | 124  |  Q2  |
#    |      |      |      | ++++ |
#    |------|------|------|------|
#    | ++++ |      |      |      |
# 03 |  Q3  |  314 |  342 | 1324 |
#    | ++++ |      |      |      |
#    |------|------|------|------|
#    |      |      | ++++ |      |
# 04 |  43  | 3412 |  Q4  |  42  |
#    |      |      | ++++ |      |
#    '------'------'------'------'

# Pragmas
use strict;
use warnings;

# Package/Global vars
our $n_queens = shift @ARGV 
or die "USAGE: perl Queens.pl n_queens\n";
our $n_vars = $n_queens*$n_queens;
our $n_lines = n_lines($n_queens);

# select OUT;
print << "COMMENTS";
c Nome      Renato Cordeiro Ferreira
c MAC0239   Metodos Formais de Programacao
c Professor Marcelo Finger
c Problema  n Rainhas
COMMENTS

print << "HEADER";
p cnf $n_vars $n_lines
HEADER

# First clausules: just 1 queen per line
# ∧ (i=1,n) [ ∨ (j=1,n) Q_i,j ]
for my $i (0..$n_queens-1) 
{
    for my $j (1..$n_queens) { 
        print($i*$n_queens+$j, " "); 
    }
    print "0 \n";
}

# Second clausules: just 1 queen per column
# ¬Q_i,j ∨ ¬Q_i,k, ∀ i,j ∈ [1,n]
for(my $i = 1; $i <= $n_queens; $i++) # (1..$n_queens)
{
    for(my $j =1; $j <= $n_queens; $j++) { # (1..$n_queens)
        my $first = ($j-1)*$n_queens + $i;
        for(my $k = $j+1; $k <= $n_queens; $k++) { #($j+1..$n_queens)
            my $second = ($k-1) * $n_queens + $i;
            print "-$first -$second 0\n" if($first != $second);
        }
    }
}

my $left_limit = 1;
my $right_limit = $n_queens;

for my $j (1..$n_queens)
{ 
    say STDERR "i==>1 j==>$j";
    
    my ($dmd, $dsd);
    my $position = $j;
    say STDERR "pos: ", $position;
    say STDERR $left_limit;
    say STDERR $right_limit;
    
    # Descending main diagonal: ↘  (+,+)
    {
        my ($di, $dj) = (-1, -1);
        $dmd = sub { 
            # Counters to advance in the lines
            $di++; $dj++; 
            
            # Advance $line lines below (↓ )
            my $line = $di*$n_queens;
            
            # Advance $dj columns right (→ )
            my $pos = $position + $line + $dj; 
            
            # Must be in the boundaries of the line
            unless( ($pos < $left_limit + $line  or $pos < 0)
                or  ($pos > $right_limit + $line or $pos > $n_vars))
            {
                return $pos;
            }
            return 0;
        };
    }
    
    # Descending second diagonal: ↙  (+,-)
    {
        my ($di, $dj) = (-1, -1);
        $dsd = sub { 
            # Counters to advance in the lines
            $di++; $dj++;
            # Advance $line lines above (↓ )
            my $line = $di*$n_queens;
            # Advance $dj columns lift (← )
            my $pos = $position + $line - $dj;
            # Must be in the boundaries of the line
            unless( ($pos < $left_limit + $line  or $pos < 0)
                or  ($pos > $right_limit + $line or $pos > $n_vars))
            {
                return $pos;
            }
            return 0;
        };
    }
    
    my (@dmd, @dsd, $ans, $first); 
    push @dmd, $ans while($ans = $dmd->());
    say STDERR "DMD: ", "@dmd";
    
    while($first = shift @dmd) {
        for my $second (@dmd) {
            print "-$first -$second 0\n"
        }
    }
    
    push @dsd, $ans while($ans = $dsd->());
    say STDERR "DSD: ", "@dsd";
    
    while($first = shift @dsd) {
        for my $second (@dsd) {
            print "-$first -$second 0\n"
        }
    }
}
    
$left_limit = ($n_queens-1)*$n_queens+1;
$right_limit = $n_queens*$n_queens;

for my $j (2..$n_queens-1)
{ 
    say STDERR "i==>$n_queens j==>$j";
    
    my ($amd, $asd);
    my $position = ($n_queens-1)*$n_queens + $j;
    say STDERR "pos: ", $position;
    say STDERR $left_limit;
    say STDERR $right_limit;
    
    # Ascending main diagonal: ↖  (-,-)
    {
        my ($di, $dj) = (-1, -1);
        $amd = sub { 
            # Counters to advance in the lines
            $di++; $dj++;
            # Advance $line lines below (↑ )
            my $line = $di*$n_queens;
            # Advance $dj columns lift (← )
            my $pos = $position - $line - $dj;
            # Must be in the boundaries of the line
            unless( ($pos < $left_limit - $line  or $pos < 0)
                or  ($pos > $right_limit - $line or $pos > $n_vars))
            {
                return $pos;
            }
            return 0;
        };
    }
    
    # Ascending second diagonal: ↗  (-,+)
    {
        my ($di, $dj) = (-1, -1);
        $asd = sub { 
            # Counters to advance in the lines
            $di++; $dj++;
            # Advance $line lines below (↑ )
            my $line = $di*$n_queens;
            # Advance $dj columns right (→ )
            my $pos = $position - $line + $dj;
            # Must be in the boundaries of the line
            unless( ($pos < $left_limit - $line  or $pos < 0)
                or  ($pos > $right_limit - $line or $pos > $n_vars))
            {
                return $pos;
            }
            return 0;
        };
    }
    
    my (@amd, @asd, $ans, $first);
    push @amd, $ans while($ans = $amd->());
    say STDERR "AMD: ", "@amd";
    
    while($first = shift @amd) {
        for my $second (@amd) {
            print "-$first -$second 0\n"
        }
    }
    
    push @asd, $ans while($ans = $asd->());
    say STDERR "ASD: ", "@asd";
    
    while($first = shift @asd) {
        for my $second (@asd) {
            print "-$first -$second 0\n"
        }
    }
}

# Subroutine:  n_lines
# Arguments:   number of queens
# Description: Given the number of queens, deterministically 
#              calculates how may clausules will be used to
#              create an entry in the cnf format
sub n_lines {
    my $n_queens = shift;
    my $n_lines = $n_queens; # 1 Queens per line
        
    # Just 1 queen per column
    $n_lines += $n_queens * ($n_queens*($n_queens-1)/2);
    
    # Sub diagonals (but the matrix'ones)
    for(my $i = 2; $i < $n_queens; $i++) {
        $n_lines += 4*$i*($i-1)/2;
    }
    
    # Main and secondary table diagonals
    $n_lines += 2 * ($n_queens*($n_queens-1)/2);
    
    return $n_lines;
}
