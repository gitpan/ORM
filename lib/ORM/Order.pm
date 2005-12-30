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

package ORM::Order;

$VERSION=0.8;

use ORM::Metaprop;

## use: $order = $class->new
## (
##     (
##         ORM::Metaprop
##         | [ORM::Metaprop, ('ASC'|'DESC')] 
##     ),
##     ... 
## )
##
## OR
##
## $order = $class->new( STRING )
##
sub new
{
    my $class = shift;
    my @order;

    if( ref $_[0] )
    {
        @order = @_;
        # Validating $arg{order}
        for( my $i=0; $i<@order; $i++ )
        {
            if( ref $order[$i] eq 'ARRAY' )
            {
                $order[$i][1] = ( $order[$i][1] =~ /^DESC$/i ) ? 'DESC' : 'ASC';
            }
            else
            {
                $order[$i] = [ $order[$i], 'ASC' ];
            }
        }
    }
    else
    {
        my %arg = @_;
        my $obj_class = $arg{class};
        my $order_str = $arg{sort_str};

        for my $field ( split /[\,]+/, $order_str )
        {
            my( $prop, $dir ) = split /\s/, $field;
            push @order,
            [
                $obj_class->M->_prop( $prop ),
                ( ( $dir =~ /^DESC$/i ) ? 'DESC' : 'ASC' ),
            ];
        }
    }
    return scalar(@order) ? ( bless { order=>\@order }, $class ) : undef;
}

sub _tjoin
{
    my $self  = shift;

    if( !$self->{tjoin} )
    {
        $self->{tjoin} = ORM::Tjoin->new;
        for my $prop ( @{$self->{order}} )
        {
            $self->{tjoin}->merge( $prop->[0]->_tjoin );
        }
    }

    return $self->{tjoin};
}

sub sql_order_by
{
    my $self  = shift;
    my %arg   = @_;
    my $sql;

    for my $prop ( @{$self->{order}} )
    {
        $sql .= $prop->[0]->_sql_str( tjoin=>$arg{tjoin} ) .' '. $prop->[1] .',';
    }
    chop $sql;

    return $sql;
}

sub cond
{
    my $self  = shift;
    my $index = shift;

    return $self->{order}[$index];
}

sub conds_amount
{
    my $self = shift;
    return scalar @{$self->{order}};
}
