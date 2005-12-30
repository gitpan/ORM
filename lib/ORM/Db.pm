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

package ORM::Db;

$VERSION=0.8;

use ORM;
use ORM::DbLog;

## use: $db = $class->new( ... );
##
## Constructor of database connection.
## Parameters is up to derived class.
##
sub new
{
    die "You forget to override 'new' in '$_[0]'";
}

## use: $db->disconnect;
##
## Close connection to storage engine if makes sense.
## $db should automatically reconnect to storage engine
## upon any request that uses the connection.
##
## Used to implement backup servers.
##
sub disconnect
{
    die "You forget to override 'disconnect' in '$_[0]'";
}

## use: $number = $class->count
## (
##     filter => ORM::Expr,
##     error  => ORM::Error,
## );
##
## Count objects of class 'class' filtered by 'filter'
##
sub count
{
    die "You forget to override 'count' in '$_[0]'";
}

## use: $result_set = $class->select_base
## (
##     filter   => ORM::Expr,
##     order    => ORM::Order,
##     page     => interger,
##     pagesize => interger,
##     error    => ORM::Error,
## );
##
## Select rows from tables corresponding to base class 'class'
## matched by 'filter'.
##
sub select_base
{
    die "You forget to override 'select_base' in '$_[0]'";
}

## use: $result_set = $class->select_full
## (
##     filter   => ORM::Expr,
##     order    => ORM::Order,
##     page     => interger,
##     pagesize => interger,
##     error    => ORM::Error,
## );
##
## Select rows from tables corresponding to base class 'class'
## or its descendants matched by 'filter'.
##
## ����� select_full ������ �������������� ���������
## ������� �������� � ����, ������� $result_set �����
## ��������� �� ������ ����� ����� ��� ���������������
## �������� �� � ������� �������, ���� ��� ������� � ����.
##
## �� ������ ���������� ��� sealed �������.
##
sub select_full
{
    die "You forget to override 'select_full' in '$_[0]'";
}

## use: $result_set = $class->select_tables
## (
##     id       => (integer || string),
##     tables   => HASH,
##     error    => ORM::Error,
## );
##
## Select joined rows from tables 'tables' with id='id'.
## 'id' can be string of format 'id1,id2,id3,...'.
##
sub select_tables
{
    die "You forget to override 'select_tables' in '$_[0]'";
}

## use: $result_set = $class->select_stat
## (
##     filter      => ORM::Expr,
##
##     data        => { alias=>ORM::Expr, ... },
##     group_by    => [ ORM::Ident|ORM::Metaprop, ... ],
##     post_filter => ORM::Expr,
##
##     order       => ORM::Order,
##     page        => integer,
##     pagesize    => integer,
##     error       => ORM::Error->new,
## );
##
sub select_stat
{
    die "You forget to override 'select_stat' in '$_[0]'";
}

## use: $insert_id = $class->insert_object
## (
##     id     => number,
##     object => ORM,
##     error  => ORM::Error,
## );
##
## Insert values of object properties into corresponding tables.
##
sub insert_object
{
    die "You forget to override 'insert_object' in '$_[0]'";
}

## use: $update_id = $class->update_object
## (
##     object => ORM,
##     values => hash,
##     error  => ORM::Error,
## );
##
## Update values of object properties in corresponding tables.
##
sub update_object
{
    die "You forget to override 'update_object' in '$_[0]'";
}

## use: $delete_id = $class->delete_object
## (
##     object => ORM,
##     error  => ORM::Error,
##     emulate_foreign_keys => boolean,
## );
##
## Delete rows with values of object properties from corresponding tables.
##
sub delete_object
{
    die "You forget to override 'delete_object' in '$_[0]'";
}

## use: $db->optimize_tables( class=>string, error=>ORM::Error );
##
## Simply call SQL's 'OPTIMIZE TABLE'
##
sub optimize_tables
{
    die "You forget to override 'optimize_tables' in '$_[0]'";
}

## use: ( $fields, $defaults ) = $class->table_struct
## (
##     class => string,
##     table => string,
##     error => ORM::Error,
## );
##
## $fields   - reference to hash of table field names and types
## $defaults - reference to hash of fields default values
##
sub table_struct
{
    die "You forget to override 'table_struct' in '$_[0]'";
}

## use: @classes = $class->referencing_classes
## (
##     class => string,
##     error => ORM::Error,
## );
##
## @classes contains references to hashes with
## keys 'class' and 'prop' meaning that property
## 'prop' of class 'class' references to class 'class'
## specified as parameter to the method.
##
sub referencing_classes
{
    die "You forget to override 'referencing_classes' in '$_[0]'";
}

## use: $quoted_str = $db->qc( $str )
##
## Used to quote constant values.
##
## If value being quoted is undef, then 'qc'
## should return SQL NULL value.
##
sub qc
{
    my $class = shift;
    die "You forget to override 'qc' method in '$class'";
}

## use: $quoted_str = $db->qt( $str )
##
## Used to table names.
##
sub qt
{
    my $class = shift;
    die "You forget to override 'qt' method in '$class'";
}

## use: $quoted_str = $db->qf( $str )
##
## Used to quote field names.
##
sub qf
{
    my $class = shift;
    die "You forget to override 'qf' method in '$class'";
}

## use: $quoted_str = $db->qi( $str )
##
## Used to quote identifier names.
##
sub qi
{
    my $class = shift;
    die "You forget to override 'qi' method in '$class'";
}

## use: $quoted_str = $db->ql( $str )
##
## Used to quote strings that should take place in LIKE-string.
##
sub ql
{
    my $class = shift;
    die "You forget to override 'ql' method in '$class'";
}

##
## TRANSACTIONS
##

## use: $class->begin_transaction( error=>ORM::Error );
##
## �� ������ �������������� ����, ������������ ������� ORM::Ta
##
sub begin_transaction
{
    die "You forget to override 'begin_transaction' method in '$_[0]'";
}

## use: $class->commit_transaction( error=>ORM::Error );
##
## �� ������ �������������� ����, ������������ ������� ORM::Ta
##
sub commit_transaction
{
    die "You forget to override 'commit_transaction' method in '$_[0]'";
}

## use: $class->rollback_transaction( error=>ORM::Error );
##
## �� ������ �������������� ����, ������������ ������� ORM::Ta
##
sub rollback_transaction
{
    die "You forget to override 'rollback_transaction' method in '$_[0]'";
}
