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

package ORM::Filter::Func;

$VERSION=0.8;

use base 'ORM::Filter';

##
## CONSTRUCTORS
##

sub concat { (shift @_)->new( 'CONCAT', @_ ); }

sub new
{
    my $class = shift;
    my $self  = { func => shift };

    for my $arg ( @_ )
    {
        if( ref $arg )
        {
            if( UNIVERSAL::isa( $arg, 'ORM::Expr' ) )
            {
                push @{$self->{arg}}, $arg;
            }
            else
            {
                push @{$self->{arg}}, $arg->__ORM_db_value;
            }
        }
        else
        {
            push @{$self->{arg}}, $arg;
        }
    }

    return bless $self, $class;
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
        $sql .= $self->scalar2sql( $arg, $arg{tjoin} ).',';
    };
    chop $sql;

    return "$self->{func}( $sql )";
}

sub _tjoin
{
    my $self  = shift;
    my $tjoin = ORM::Tjoin->new;

    for my $arg ( @{$self->{arg}} )
    {
        $tjoin->merge( $arg->_tjoin ) if( ref $arg );
    }

    return $tjoin;
}

