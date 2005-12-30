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

package ORM::DbResultSet;

$VERSION = 0.8;

sub next_row
{
    die "You forget to override 'next_row' in '$_[0]'";
}

sub rows
{
    die "You forget to override 'rows' in '$_[0]'";
}

## use: $tables = $class->result_tables;
##
## Return reference to array with names of tables
## taking place in result set.
##
sub result_tables
{
    die "You forget to override 'result_tables' in '$_[0]'";
}
