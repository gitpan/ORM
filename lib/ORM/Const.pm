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

package ORM::Const;

use base 'ORM::Expr';

$VERSION = 0.8;

sub new
{
    my $class = shift;
    my $self  = { value=>shift };

    return bless $self, $class;
}

sub new_int
{
    my $class = shift;
    my $self  = { value=>(int shift), int=>1 };

    return bless $self, $class;
}

sub _sql_str
{
    my $self = shift;
    my %arg  = @_;

    $self->{int} ? $self->{value} : $arg{tjoin}->class->ORM::qc( $self->{value} );
}

sub value { $_[0]->{value}; }
sub _tjoin { ORM::Tjoin->new; }

1;
