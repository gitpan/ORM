#
# DESCRIPTION:
#   PerlORM - Object relational mapper (ORM) for Perl. PerlORM is Perl
#   library that implements object-relational mapping. Its features are
#   much similar to those of Java's Hibernate library, but interface is
#   much different and easier to use.
#
# AUTHOR:
#   Alexey V. Akimov <akimov_alexey@sourceforge.net>
#
# COPYRIGHT
#   Copyright (c) 2005 Alexey V. Akimov. All rights reserved.
#

package ORM::Db::DBIResultSet;

use base 'ORM::DbResultSet';

$VERSION = 0.8;

sub new
{
    my $class = shift;
    my %arg   = @_;
    my $self  = { result=>$arg{result}, tables=>$arg{tables} };

    return $arg{result} ? bless( $self, $class ) : undef;
}

sub next_row
{
    my $self = shift;

    $self->{result}->fetchrow_hashref;
}

sub rows
{
    my $self = shift;

    $self->{result}->rows;
}

sub result_tables
{
    my $self = shift;

    $self->{tables};
}
