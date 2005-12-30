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

package ORM::Filter::Case;

$VERSION=0.8;

use base 'ORM::Filter';

##
## CONSTRUCTORS
##

sub new
{
    my $class = shift;
    my $self  = {};

    if( ref $_[0] ne 'ARRAY' )
    {
        $self->{value} = shift;
        unless( UNIVERSAL::isa( $self->{value}, 'ORM::Expr' ) )
        {
            $self->{value} = ORM::Const->new( $self->{value} );
        }
    }

    @{$self->{case}} = @_;

    if( ref $self->{case}[-1] ne 'ARRAY' )
    {
        $self->{else} = pop @{$self->{case}};
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

    $sql .= 'CASE';
    $sql .= ' '.$self->{value}->_sql_str( %arg ) if( $self->{value} );
    $sql .= "\n";

    for my $case ( @{$self->{case}} )
    {
        $sql .=
            $arg{ident}
            . '  WHEN '.$self->scalar2sql( $case->[0], $arg{tjoin}, $arg{ident}.'  ' )
            . ' THEN '.$self->scalar2sql( $case->[1], $arg{tjoin}, $arg{ident}.'  ' ) . "\n";
    }

    if( exists $self->{else} )
    {
        $sql .= $arg{ident}.'  ELSE '.$self->scalar2sql( $self->{else}, $arg{tjoin}, $arg{ident}.'  ' )."\n";
    }

    $sql .= $arg{ident}."  END";

    return $sql;
}

sub _tjoin
{
    my $self  = shift;
    my $tjoin = ORM::Tjoin->new;

    for my $arg ( $self->{value}, $self->{else} )
    {
        if( UNIVERSAL::isa( $arg, 'ORM::Expr' ) )
        {
            $tjoin->merge( $arg->_tjoin );
        }
    }

    for my $arg ( @{$self->{case}} )
    {
        if( UNIVERSAL::isa( $arg->[0], 'ORM::Expr' ) )
        {
            $tjoin->merge( $arg->[0]->_tjoin );
        }
        if( UNIVERSAL::isa( $arg->[1], 'ORM::Expr' ) )
        {
            $tjoin->merge( $arg->[1]->_tjoin );
        }
    }

    return $tjoin;
}

##
## METHODS
##

sub add_case
{
    my $self = shift;
    my $case = shift;

    push @{$self->{case}}, $case;
}
