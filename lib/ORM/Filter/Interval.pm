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

package ORM::Filter::Interval;

$VERSION=0.8;

use base 'ORM::Filter';

##
## CONSTRUCTORS
##

sub new
{
    my $class = shift;
    my $self  = { interval => (shift @_), arg => (shift @_) };

    if( ref $self->{arg} )
    {
        unless( UNIVERSAL::isa( $self->{arg}, 'ORM::Expr' ) )
        {
            $self->{arg} = $self->{arg}->__ORM_db_value;
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

    return 'INTERVAL '.$self->scalar2sql( $self->{arg}, $arg{tjoin} ).' '.$self->{interval};
}

sub _tjoin
{
    my $self  = shift;
    return $self->{arg}->_tjoin if( ref $self->{arg} );
}
