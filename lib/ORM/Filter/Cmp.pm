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

package ORM::Filter::Cmp;

$VERSION=0.8;

use base 'ORM::Filter';

##
## CONSTRUCTORS
##

sub new
{
    my $class = shift;
    my $self  = { op => $_[0] };

    if( UNIVERSAL::isa( $_[1], 'ORM::Expr' ) )
    {
        $self->{arg1} = $_[1];
    }
    else
    {
        $self->{arg1} = ( ref $_[1] ? $_[1]->__ORM_db_value : $_[1] );
    }

    if( UNIVERSAL::isa( $_[2], 'ORM::Expr' ) )
    {
        $self->{arg2} = $_[2];
    }
    else
    {
        $self->{arg2} = ( ref $_[2] ? $_[2]->__ORM_db_value : $_[2] );
    }

    return bless $self, $class;
}

sub _sql_str
{
    my $self = shift;
    my %arg  = @_;

    return
        '(' . $self->scalar2sql( $self->{arg1}, $arg{tjoin} )
        . " $self->{op} "
        . $self->scalar2sql( $self->{arg2}, $arg{tjoin} ) . ')';
}

sub _tjoin
{
    my $self  = shift;
    my $tjoin = ORM::Tjoin->new;

    $tjoin->merge( $self->{arg1}->_tjoin ) if( ref $self->{arg1} );
    $tjoin->merge( $self->{arg2}->_tjoin ) if( ref $self->{arg2} );

    return $tjoin;
}
