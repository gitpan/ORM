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

package ORM::Base;

use Carp;

my %require;
my %loaded;
my $active = 0;
my $debug  = 0;

sub import
{
    my $class   = shift;
    my $base    = shift;
    my %arg     = @_;
    my $derived = caller 0;
    my $i_am_active;

    unless( $active )
    {
        print STDERR "***** Start loading *****\n" if( $debug );
        $active      = 1;
        $i_am_active = 1;
    }

    my $eval = "package $derived; use base $base; ";

    if( $arg{i_am_history} )
    {
        $eval .= 'do \'ORM/History.pm\';';
        $arg{history_is_enabled} = 0;
    }

    eval $eval;
    
    croak "Failed to load package $base\n$@" if( $@ );
    $loaded{$base}    = 1;
    $loaded{$derived} = 1;
    print STDERR "  Loading class $derived\n" if( $debug );

    my @require = $base->_derive( derived_class=>$derived, %arg );
    push @require, $derived->_history_class unless( $loaded{$derived->_history_class} );
    for my $module ( @require )
    {
        if( $loaded{$module} )
        {
            print STDERR "    $derived requested $module (already loaded)\n" if( $debug );
        }
        elsif( $require{$module} )
        {
            print STDERR "    $derived requested $module (already in queue)\n" if( $debug );
        }
        else
        {
            print STDERR "    $derived requested $module (queued)\n" if( $debug );
            $require{$module} = 1;
        }
    }

    if( $i_am_active )
    {
        while( %require )
        {
            my $load;

            for my $module ( keys %require )
            {
                $loaded{$module} = 1;
                $load           .= "require $module; ";
            }

            %require = ();
            print STDERR "Loading queued: $load\n" if( $debug );
            eval $load;
            croak "Failed to load packages: $load\n$@" if( $@ );
        }
        %loaded = ();
        $active = 0;
        print STDERR "***** Finish loading *****\n\n" if( $debug );
    }
}

1;
