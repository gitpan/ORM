#
# DESCRIPTION
#   PerlORM - Object relational mapper (ORM) for Perl. PerlORM is Perl
#   library that implements object-relational mapping. Its features are
#   much similar to those of Java's Hibernate library, but interface is
#   much different and easier to use.
#
# AUTHOR
#   Alexey V. Akimov <akimov_alexey@sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2005-2006 Alexey V. Akimov
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU Lesser General Public
#   License as published by the Free Software Foundation; either
#   version 2.1 of the License, or (at your option) any later version.
#   
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   Lesser General Public License for more details.
#   
#   You should have received a copy of the GNU Lesser General Public
#   License along with this library; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

package ORM::Ta;

$VERSION = 0.8;

my $die;
my $die_handler_enabled;
my $old_die_handler;

sub new
{
    my $class = shift;
    my %arg   = @_;
    my $self  = {};

    if( $arg{db} )
    {
        $self->{db}    = $arg{db};
        $self->{error} = $arg{error} || ORM::Error->new;

        unless( $die_handler_enabled )
        {
            $die_handler_enabled = 1;
            $old_die_handler     = $::SIG{__DIE__};
            $::SIG{__DIE__}      = \&die_handler;
        }

        unless( $self->{error}->fatal )
        {
            my $error = ORM::Error->new;
            $self->{db}->begin_transaction( error=>$error );
            if( $error->fatal )
            {
                $self->{error}->add( error=>$error );
                $self->{not_started} = 1;
            }
        }
    }

    return bless $self, $class;
}

sub DESTROY
{
    my $self = shift;

    if( $self->{not_started} || !$self->{db} )
    {
        # nothing to do
    }
    elsif( $die )
    {
        $die = undef;
        $self->{error}->add_fatal( "Transaction rolled back because of 'die' exception" );
        $self->{db}->rollback_transaction( error=>$self->{error} );
    }
    elsif( $self->{error}->fatal )
    {
        $self->{db}->rollback_transaction( error=>$self->{error} );
    }
    else
    {
        $self->{db}->commit_transaction( error=>$self->{error} );
    }
}

sub die_handler
{
    unless( $^S )
    {
        $die = 1;
        $old_die_handler && &{$old_die_handler}( @_ );
    }
}

1;
