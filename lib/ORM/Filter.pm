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

package ORM::Filter;

$VERSION=0.8;

use ORM;
use base 'ORM::Expr';

##
## SUBROUTINES
##

sub scalar2sql
{
    my $class  = shift;
    my $scalar = shift;
    my $tjoin  = shift;
    my $ident  = shift;

    return
        ref $scalar
            ? $scalar->_sql_str( tjoin=>$tjoin, ident=>$ident )
            : ( defined $scalar ? $tjoin->class->ORM::qc( $scalar ) : 'NULL' );
}
