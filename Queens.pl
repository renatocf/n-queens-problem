#!/usr/bin/perl 
package main;
use v5.14; 

#######################################################################
##                    PACKAGE/GLOBAL VARIABLES                       ##
#######################################################################

# Pragmas
use strict; 
use warnings;

# Number of queens
our $n_queens = shift @ARGV 
or die "USAGE: perl Queens.pl n_queens\n";

# Number of variables and clausules
our $n_vars = $n_queens*$n_queens;
our $n_clausules = n_lines($n_queens);

#######################################################################
##                             HEADER                                ##
#######################################################################

# Comments section
print << "COMMENTS";
c Nome      Renato Cordeiro Ferreira
c MAC0239   Metodos Formais de Programacao
c Professor Marcelo Finger
c Problema  n Rainhas
COMMENTS

# Header/Preamble section
print << "HEADER";
p cnf $n_vars $n_clausules
HEADER

#######################################################################
##                            CLAUSULES                              ##
#######################################################################

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

# Third clausules (part 1): diagonals of the 1st line
# ¬Q_1,j ∨ ¬Q_1+k,j+k ∀ k ∈ ℕ : max{j+k,1+k} ≤ {right_limit, 0, n²}
# ¬Q_1,j ∨ ¬Q_1+k,j-k ∀ k ∈ ℕ : max{j-k,1-k} ≥ {left_limit, 0, n²}
my $left_limit = 1;
my $right_limit = $n_queens;

for my $j (1..$n_queens)
{ 
    my ($dmd, $dsd, @dmd, @dsd, $ans); 
    my $position = $j;
    
    # Descending main diagonal (dmd): ↘  (+,+)
    $dmd = diagonals(q|↘ |, $position);
    push @dmd, $ans while($ans = $dmd->());
    two_by_two(@dmd);
    
    # Descending second diagonal (dsd): ↙  (+,-)
    $dsd = diagonals(q|↙ |, $position);
    push @dsd, $ans while($ans = $dsd->());
    two_by_two(@dsd);
}

# Third clausules (part 2): diagonals of the last line
# ¬Q_n,j ∨ ¬Q_n-k,j+k ∀ k ∈ ℕ : max{j+k,1+k} ≤ {right_limit, 0, n²}
# ¬Q_n,j ∨ ¬Q_n-k,j-k ∀ k ∈ ℕ : max{j-k,1-k} ≥ {left_limit, 0, n²}
$left_limit = ($n_queens-1)*$n_queens+1;
$right_limit = $n_queens*$n_queens;

for my $j (2..$n_queens-1)
{ 
    my ($amd, $asd, @amd, @asd, $ans);
    my $position = ($n_queens-1)*$n_queens + $j;
    
    # Ascending main diagonal (amd): ↖  (-,-)
    $amd = diagonals(q|↖ |, $position);
    push @amd, $ans while($ans = $amd->());
    two_by_two(@amd);
    
    # Ascending second diagonal (asd): ↗  (-,+)
    $asd = diagonals(q|↗ |, $position);
    push @asd, $ans while($ans = $asd->());
    two_by_two(@asd);
}

#######################################################################
##                          SUBROUTINES                              ##
#######################################################################

# Subroutine:  n_lines
# Arguments:   number of queens
# Description: Given the number of queens, deterministically 
#              calculates how may clausules will be used to
#              create an entry in the cnf format.
sub n_lines {
    my $n_queens = shift;    # Number of queens
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

# Subroutine:  diagonals
# Arguments:   direction (↘ ,↙ ,↖ ,↗ ), position
# Description: Given the direction and position, creates a subroutine 
#              that lists all the positions in the diagonal for that
#              direction.
sub diagonals 
{ 
    ## VARIABLES ######################################################
    my $dir = shift;                   # Simbolic direcion
    my $position = shift;              # Our position in the board
    my ($di, $dj) = (-1, -1);          # Counters to advance lines
    my ($sig_up, $sig_right) = (0, 0); # Defining the direction
    
    given($dir) {
        when(q|↘ |) { $sig_up = 0; $sig_right = 0 } # (+,+)
        when(q|↙ |) { $sig_up = 0; $sig_right = 1 } # (+,-)
        when(q|↖ |) { $sig_up = 1; $sig_right = 1 } # (-,-)
        when(q|↗ |) { $sig_up = 1; $sig_right = 0 } # (-,+)
        default     { die "Signal unknown!\n" };
    }
    
    ## GENERATE SUBROUTINE ############################################
    return sub {
        # Counters to advance in the lines
        $di++; $dj++; 
        my ($line, $pos) = ($di*$n_queens, 0);
        
        $pos = $position               # From the position, go:
             + (-1)**$sig_up * $line   # $line above (↑ ) or below (↓ )
             + (-1)**$sig_right * $dj; # $dj   right (→ ) or left  (← )
        
        # But only while we are in the boundaries of the line
        return $pos unless( 
            $pos < 0 or $pos > $n_vars
            or $pos < $left_limit + (-1)**$sig_up * $line 
            or $pos > $right_limit + (-1)**$sig_up * $line 
        );
        return 0;
    }
}

# Subroutine:  two_by_two
# Arguments:   list of numbers
# Description: Given a a list, prints the elements $a and $b 
#              in the format "-$a -$b 0".
sub two_by_two 
{
    while(my $first = shift @_) {
        for my $second (@_) {
            print "-$first -$second 0\n";
        }
    }
}

__END__

#######################################################################
##                          DOCUMENTATION                            ##
#######################################################################

PROBLEM OF N QUEENS: 
--------------------

Given N queens and a NxN chess board, is it possible to put all the
queens in such a way they do not attack each other?

Example: 4x4 chess table with 4 queens
Result:  SATISFABLE

                      01     02     03     04
                   .------.------.------.------.
                   |      | ++++ |      |      |
                01 |  13  |  Q1  | 3142 |  12  |
                   |      | ++++ |      |      |
                   |------|------|------|------|
                   |      |      |      | ++++ |
                02 | 1234 | 321  | 124  |  Q2  |
                   |      |      |      | ++++ |
                   |------|------|------|------|
                   | ++++ |      |      |      |
                03 |  Q3  |  314 |  342 | 1324 |
                   | ++++ |      |      |      |
                   |------|------|------|------|
                   |      |      | ++++ |      |
                04 |  43  | 3412 |  Q4  |  42  |
                   |      |      | ++++ |      |
                   '------'------'------'------'
