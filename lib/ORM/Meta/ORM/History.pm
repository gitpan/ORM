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

package ORM::Meta::ORM::History;

use base 'ORM::Metaprop';

$VERSION=0.81;

##
## CONSTRUCTORS
##

sub master       { shift->slaved_by == undef; }
sub delete_slave { shift->slaved_by->prop_name eq 'id'; }

