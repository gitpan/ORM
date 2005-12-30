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

package ORM::Db::DBI::SQLite;

$VERSION = 0.8;

use base 'ORM::Db::DBI';

##
## CONSTRUCTORS
##

sub new
{
    my $class = shift;
    my %arg   = @_;

    $arg{driver} = 'SQLite';
    $class->SUPER::new( %arg );
}

##
## CLASS METHODS
##

sub qc
{
    my $self = shift;
    my $str  = shift;

    if( defined $str )
    {
        $str =~ s/\'/\'\'/g;
        $str = "'$str'";
    }
    else
    {
        $str = 'NULL';
    }

    return $str;
}

sub qi
{
    my $self = shift;
    my $str  = shift;

    $str =~ s/\[/\\\[/g;
    $str =~ s/\]/\\\]/g;
    $str = "[$str]";

    return $str;
}

sub qt { $_[0]->qi( $_[1] ); }
sub qf { $_[0]->qi( $_[1] ); }

##
## OBJECT METHODS
##


sub begin_transaction
{
    my $self  = shift;
    my %arg   = @_;

    $self->{ta} = 1;
    $self->do( query=>"BEGIN TRANSACTION", error=>$arg{error} );
}

sub commit_transaction
{
    my $self  = shift;
    my %arg   = @_;

    delete $self->{ta};
    $self->do( query=>"COMMIT TRANSACTION", error=>$arg{error} );
}

sub rollback_transaction
{
    my $self  = shift;
    my %arg   = @_;

    delete $self->{ta};
    unless( $self->{lost_connection} )
    {
        $self->do( query=>"ROLLBACK TRANSACTION", error=>$arg{error} );
    }
}

## use: $id = $db->insertid()
##
sub insertid
{
    my $self = shift;
    $self->_db_handler ? $self->_db_handler->func( 'last_insert_rowid' ) : undef;
}

sub table_struct
{
    my $self   = shift;
    my %arg    = @_;
    my $error  = ORM::Error->new;
    my %field;
    my %defaults;
    my $res;

    ## Fetch table structure
    $res = $self->select
    (
        query => "SELECT sql FROM sqlite_master WHERE type='table' and name=".$self->qc($arg{table}),
        error => $error,
    );
    unless( $error->fatal )
    {
        my $data;

        $data = $res->next_row;
        $data = $data ? $data->{sql} : '';
        $data =~ /^CREATE TABLE [^\(]+\((.+)\)/ism;
        $data = $1 || '';
        $data =~ s/[\r\n]/ /g;

        my @rows = split /,/, $data if( $data );

        for $row ( @rows )
        {
            if( $row =~ /^\s*([^\s]+)\s+([^\s]+)(.*?\s+default (NULL|\'[^\']*\'))?/i )
            {
                my $name = $1;
                my $type = $2;
                my $def  = $4;

                $name = $1 if( $name =~ /^\[(.+)\]$/ );

                if( ! defined $def )
                {
                }
                elsif( $def eq 'NULL' )
                {
                    $def = undef;
                }
                else
                {
                    $def = substr $def, 1, (length $def) - 2;
                }

                $defaults{ $name } = $def;
                $field{ $name }    = $arg{class}->_db_type_to_class( $name, $type );
            }
            else
            {
                $error->add_fatal( "Can't detect columns for table '$arg{table}'" );
                last;
            }
        }
    }

    ## Fetch class references
    if( scalar( %field ) )
    {
        $res = $self->select
        (
            error => $error,
            query => 'SELECT * FROM _ORM_refs WHERE class='.$self->qc( $arg{class} ),
        );
        unless( $error->fatal )
        {
            while( $data = $res->next_row )
            {
                if( exists $field{$data->{prop}} )
                {
                    $field{$data->{prop}} = $data->{ref_class};
                }
            }
        }
    }

    $arg{error} && $arg{error}->add( error=>$error );
    return \%field, \%defaults;
}

sub _ta_select { ''; }

sub _lost_connection
{
    my $self = shift;
    my $err  = shift;

    defined $err && ( $err == 2006 || $err == 2013 );
}

##
## SQL FUNCTIONS
##

sub _func_concat        { shift; ORM::Filter::Cmp->new( '||', @_ ); }
