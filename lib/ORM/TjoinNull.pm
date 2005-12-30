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

package ORM::TjoinNull;

$VERSION = 0.8;

sub new
{
    my $class = shift;
    my $self  = {};

    return bless $self, $class;
}

sub copy { $_[0]; }

sub merge
{
    my $self  = shift;
    my $tjoin = shift;
    my $copy  = $tjoin->copy;

    %{$self} = %{$copy};
    bless $self, ref $copy;
}
