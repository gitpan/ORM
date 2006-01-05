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

package ORM::Broken;

use Carp;

$VERSION = 0.8;

sub AUTOLOAD
{
    my $self   = shift;
    my $method = $AUTOLOAD;

    if( ref $self )
    {
        if( $self->{deleted} )
        {
            croak
                "Object of class '$self->{class}' with id #$self->{id}"
                . " has been deleted and should not be used.";
        }
        else
        {
            croak
                "Object of class '$self->{class}' with id #$self->{id}"
                . " is broken after lazy load and should not be used."
                . ( $self->{error}
                    ? ("Error occured during lazy load:\n".$self->{error}->text)
                    : "Object not found during lazy load."
                );
        }
    }
    else
    {
        croak "Warning! Use of broken object!";
    }
}

sub DESTROY
{
}

1;
