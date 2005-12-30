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

package ORM::Filter::Group;

$VERSION=0.8;

use Carp;
use base 'ORM::Filter';

##
## CONSTRUCTORS
##

sub new
{
    my $class = shift;
    my $op    = shift;
    my @arg   = @_;
    my $self  = bless { op=>$op, arg=>[] }, $class;

    $self->add_expr( @arg );
    return $self;
}

##
## PROPERTIES
##

sub _sql_str
{
    my $self = shift;
    my %arg  = @_;
    my $sql;

    for my $arg ( @{$self->{arg}} )
    {
        my $add  = $arg->_sql_str( tjoin=>$arg{tjoin} );
        $sql .= " $self->{op} " if( $sql && $add );
        $sql .= $add;
    }

    return $sql && "($sql)";
}

sub _tjoin
{
    my $self  = shift;
    my $tjoin = ORM::Tjoin->new;

    for my $arg ( @{$self->{arg}} )
    {
        $tjoin->merge( $arg->_tjoin );
    }

    return $tjoin;
}

##
## METHODS
##

sub add_expr
{
    my $self = shift;
    my @arg  = @_;

    for( my $i=0; $i<@arg; $i++ )
    {
        if( ! defined $arg[$i] )
        {
            splice @arg, $i, 1;
            $i--;
        }
        elsif( ! ref $arg[$i] || !$arg[$i]->can( '_tjoin' ) )
        {
            croak "Bad arg #".($i+1).": '$arg[$i]'";
        }
    }
    push @{$self->{arg}}, @arg;

    return undef;
}
