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

package ORM::Ident;

use base 'ORM::Expr';

$VERSION = 0.8;

sub new
{
    my $class = shift;
    my $self  = { name=>shift };

    return bless $self, $class;
}

sub _sql_str
{
    my $self = shift;
    my %arg  = @_;

    $arg{tjoin}->class->ORM::qi( $self->{name} );
}

sub name  { shift->{name}; }
sub _tjoin { ORM::Tjoin->new; }

1;
