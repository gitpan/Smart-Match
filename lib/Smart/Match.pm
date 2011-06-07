package Smart::Match;
BEGIN {
  $Smart::Match::VERSION = '0.002';
}

use 5.010001;
use strict;
use warnings FATAL => 'all';

use Carp qw/croak/;
use List::MoreUtils qw//;
use Scalar::Util qw(blessed looks_like_number);

use Smart::Match::Overload;

use Sub::Exporter -setup => {
	exports => [qw/
		match delegate
		always never
		any all none one
		true false
		number integer even odd
		more_than less_than at_least at_most positive negative range
		numwise stringwise
		string string_length
		object instance_of ref_type
		array array_length tuple head sequence
		hash hash_keys
	/],
	groups => {
		junctive => [qw/any all none one/],
		definite => [qw/always never/],
		boolean  => [qw/true false/],
		numeric  => [qw/number integer even odd more_than less_than at_least at_most/],
		compare  => [qw/numwise stringwise/],
		meta     => [qw/match delegate/],
		string   => [qw/string string_length/],
		refs     => [qw/object instance_of ref_type/],
		arrays   => [qw/array array_length tuple head sequence/],
		hashes   => [qw/hash hash_keys/],
	},
};

## no critic (Subroutines::ProhibitSubroutinePrototypes,ValuesAndExpressions::ProhibitConstantPragma)
sub match (&) {
	my $sub = shift;

	return Smart::Match::Overload->new($sub);
}

sub delegate (&@) {
	my ($sub, $match) = @_;
	return match { return $_ ~~ $match for $sub->() };
}

sub any {
	my @possibilities = @_;
	return match {
		for my $candidate (@possibilities) {
			return 1 if $_ ~~ $candidate;
		}
		return;
	};
}

sub all {
	my @possibilities = @_;
	return match {
		for my $candidate (@possibilities) {
			return if not $_ ~~ $candidate;
		}
		return 1;
	};
}

sub none {
	my @possibilities = @_;
	return match {
		for my $candidate (@possibilities) {
			return if $_ ~~ $candidate;
		}
		return 1;
	};
}

sub one {
	my @possibilities = @_;
	return match {
		my $count = 0;
		for my $candidate (@possibilities) {
			$count++ if $_ ~~ $candidate;
			return if $count > 1;
		}
		return $count == 1;
	};
}

use constant always => match { 1 };
use constant never  => match { };

use constant true  => match { $_ };
use constant false => match { not $_ };

use constant number  => match { looks_like_number($_) };
use constant integer => match { looks_like_number($_) and int == $_ };

use constant even => match { scalar integer and $_ % 2 == 0 };
use constant odd  => match { scalar integer and $_ % 2 == 1 };

sub more_than {
	my $cutoff = shift;
	return match { looks_like_number($_) and $_ > $cutoff };
}

sub at_least {
	my $cutoff = shift;
	return match { looks_like_number($_) and $_ >= $cutoff };
}

sub less_than {
	my $cutoff = shift;
	return match { looks_like_number($_) and $_ < $cutoff };
}

sub at_most {
	my $cutoff = shift;
	return match { looks_like_number($_) and $_ <= $cutoff };
}

sub range {
	my ($bottom, $top) = @_;
	return all(at_least($bottom), at_most($top));
}

use constant positive => more_than(0);
use constant negative => less_than(0);

sub numwise {
	my $other = shift;
	return match { scalar number and $_ == $other };
}

use constant string => match { ref() ? blessed($_) && overload::OverloadedStringify($_) : defined };

sub string_length {
	my $match = shift;
	return match { scalar string and length $_ ~~ $match };
}

sub stringwise {
	my $other = shift;
	return match { scalar string and $_ eq $other };
}

use constant object => match { blessed($_) };

sub instance_of {
	my $class = shift;
	return match { blessed($_) and $_->isa($class) };
}

sub ref_type {
	my $type = shift;
	return match { ref eq $type };
}

use constant array => ref_type('ARRAY');

sub array_length {
	my $match = shift;
	return match { scalar array and @{$_} + 0 ~~ $match };
}

sub tuple {
	my @entries = @_;
	return match { scalar array and $_ ~~ @entries };
}

sub sequence {
	my $matcher = shift;
	return match { scalar array and not List::MoreUtils::any { not $_ ~~ $matcher } @{$_} };
}

sub head {
	my @entries = @_;
	return match { scalar array_length(at_least(scalar @entries)) and [ @{$_}[ 0..$#entries ] ] ~~ @entries };
}

use constant hash => ref_type('HASH');

sub hash_keys {
	my $matcher = shift;
	return match { scalar hash and [ sort keys %{$_} ] ~~ $matcher };
}

1;

# ABSTRACT: Smart matching utilities



=pod

=head1 NAME

Smart::Match - Smart matching utilities

=head1 VERSION

version 0.002

=head1 SYNOPSIS

 given ($foo) {
     say 'We've got a positive number' when positive;
     say 'We've got an array' when array;
     say 'We've got a non-empty string' when string_length(positive);
 }

=head1 DESCRIPTION

This module provides a number of helper functions for smartmatching. Some are simple functions that directly match the left hand side, such as

 $foo ~~ positive
 $bar ~~ array

Others are higher-order matchers that take one or more matchers as an argument, such as

 $foo ~~ string_length(positive)
 $bar ~~ any(array, hash)

Do note that ordinary values are matchers too, so

 $baz ~~ any(1,2,3)

will also do what you mean.

=head1 FUNCTIONS

=head2 always()

This always matches.

=head2 never()

This never matches.

=head2 any(@matchers)

This matches if the left hand side matches any of C<@matchers>.

=head2 all(@matchers)

This matches if the left hand side matches all of C<@matchers>.

=head2 none(@matchers)

This matches if the left hand side matches none of C<@matchers>.

=head2 one(@matchers)

This matches if the left hand side matches exactly one of C<@matchers>.

=head2 true()

This matches if the left hand side is true.

=head2 false()

This matches if the left hand side is false.

=head2 number()

This matches if the left hand side is a number.

=head2 integer()

This matches if the left hand side is an integer.

=head2 even()

This matches if the left hand side is even.

=head2 odd()

This matches if the left hand side is odd.

=head2 more_than($cutoff)

Matches if the left hand side is more than C<$cutoff>.

=head2 at_least($cutoff)

Matches if the left hand side is at least C<$cutoff>.

=head2 less_than($cutoff)

Matches if the left hand side is less than C<$cutoff>.

=head2 at_most($cutoff)

Matches if the left hand side is at most C<$cutoff>.

=head2 positive()

This is a synonym for C<more_than(0)>.

=head2 negative()

This is a synonym for C<less_than(0)>.

=head2 range($bottom, $top)

A synonym for C<all(at_least($bottom, at_most($top))>.

=head2 numwise($number)

Matches the left hand side numerically with $number if that makes sense, returns false otherwise.

=head2 string()

Matches any string, that is any defined value that's that's not a reference without string overloading.

=head2 stringwise($string)

Matches the left hand side lexographically with $string if that makes sense, returns false otherwise.

=head2 string_length($matcher)

Matches the string's length 

=head2 object()

Matches any object (that is, a blessed reference).

=head2 instance_of($class)

Matches any instance of class C<$class>.

=head2 ref_type($type)

Matches any unblessed reference of type $type.

=head2 array()

Matches any unblessed array.

=head2 array_length($matcher)

Matches any unblessed array whose length matches C<$matcher>.

=head2 tuple(@entries)

Matches a list whose elements match C<@entries> one by one.

=head2 head(@elements)

Matches a list whose head elements match C<@entries> one by one.

=head2 sequence($matches)

Matches a list whose elements all match C<$matcher>.

=head2 hash()

Matches any unblessed hash.

=head2 hash_keys($matcher)

Match a sorted list of hash keys against $matcher.

=head2 match { ... }

Create a new matching function. It will be run with the left-hand side in C<$_>.

=head2 delegate { ... } $matcher

Run the block, and then match the return value against C<$matcher>.

=head1 AUTHOR

Leon Timmermans <leont@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Leon Timmermans.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

