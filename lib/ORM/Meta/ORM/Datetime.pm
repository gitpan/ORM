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

package ORM::Meta::ORM::Datetime;

$VERSION=0.8;

use base 'ORM::Metaprop';

package ORM::Datetime;

sub __ORM_db_value { shift->mysql_datetime; }
sub __ORM_new_db_value
{
    my $class = shift;
    my %arg   = @_;

    if( $arg{value} =~ /^\d+$/ )
    {
        $class->new_epoch( $arg{value} );
    }
    elsif( $arg{value} =~ /^0000\-00\-00( 00:00:00)?$/ )
    {
        undef;
    }
    else
    {
        $class->new_mysql( $arg{value} );
    }
}
