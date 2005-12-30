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

package ORM::Db::DBIResultSetFull;

use base 'ORM::DbResultSet';

$VERSION = 0.8;

sub new
{
    my $class = shift;
    my %arg   = @_;
    my $self  = { iterator=>0, rows=>[] };

    return bless $self, $class;
}

sub next_row
{
    my $self = shift;
    my $row;

    if( $self->{iterator} < @{$self->{rows}} )
    {
        $row = $self->{rows}[ $self->{iterator} ];
        $self->{rows}[ $self->{iterator} ] = undef;
        $self->{iterator}++;
    }

    return $row;
}

sub rows
{
    my $self = shift;

    scalar @{$self->{rows}};
}

sub result_tables { undef; }

##
## OBJECT METHODS
##

sub add_row
{
    my $self = shift;
    my $row  = shift;

    push @{$self->{rows}}, $row;
}
