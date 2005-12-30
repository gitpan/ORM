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

package ORM::ResultSet;

use ORM;

$VERSION = 0.8;

##
## CONSTRUCTORS
##

## use: $result_set = ORM::ResultSet->new( class=>string, result=>ORM::DbResultSet );
##
sub new
{
    my $class = shift;
    my %arg   = @_;

    bless { class=>$arg{class}, result=>$arg{result} }, $class;
}

##
## PROPERTIES
##

sub next
{
    my $self = shift;
    my $obj;

    if( exists $self->{preview} )
    {
        $obj = $self->{preview};
        delete $self->{preview};
    }
    else
    {
        my $res = $self->{result} && $self->{result}->next_row;

        if( $res )
        {
            $obj = $self->{class}->_cache->get( $res->{id}, 0 );
            unless( $obj )
            {
                $obj = $self->{class}->_find_constructor( $res, $self->{result}->result_tables );
                $self->{class}->_cache->add( $obj );
            }
        }
    }

    return $obj;
}

sub preview
{
    my $self = shift;

    $self->{preview} = $self->next( @_ ) unless( exists $self->{preview} );
    return $self->{preview};
}

sub amount
{
    my $self = shift;

    $self->{result}->rows;
}
