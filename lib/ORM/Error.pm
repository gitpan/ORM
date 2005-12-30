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

package ORM::Error;

$VERSION=0.8;

##
## CONSTRUCTORS
##

sub new
{
    my $class = shift;
    my $self  = {};

    return bless $self, $class;
}

##
## OBJECT METHODS
##

sub add
{
    my $self = shift;
    my %arg  = @_;

    if( ref $arg{error} )
    {
        for my $err ( @{$arg{error}->{list}} )
        {
            my $type = $arg{conv}{$err->{type}} || $err->{type};
            $self->{fatal} = ( $type eq 'fatal' );
            push @{$self->{list}},
            {
                class   => $err->{class},
                sub     => $err->{sub},
                type    => $type,
                comment => $err->{comment},
            };
        }
    }
    else
    {
        my( $package, $filename, $line, $sub ) = caller 1;

        if( $package )
        {
            $sub =~ s/^${package}:://;
        }
        else
        {
            $package = caller;
        }

        $self->{fatal} = ( $arg{type} eq 'fatal' );

        push @{$self->{list}},
        {
            class   => $package,
            sub     => ( $sub || 'main' ),
            type    => $arg{type},
            comment => $arg{comment},
        };
    }
}

sub add_fatal
{
    my $self = shift;

    my( $package, $filename, $line, $sub ) = caller 1;

    if( $package )
    {
        $sub =~ s/^${package}:://;
    }
    else
    {
        $package = caller;
    }

    $self->{fatal} = 1;

    push @{$self->{list}},
    {
        class   => $package,
        sub     => ( $sub || 'main' ),
        type    => 'fatal',
        comment => $_[0],
    };
}

sub add_warn
{
    my $self = shift;

    my( $package, $filename, $line, $sub ) = caller 1;
    $sub =~ s/^${package}:://;
    $package = caller unless( $package );

    push @{$self->{list}},
    {
        class   => $package,
        sub     => ( $sub || 'main' ),
        type    => 'warning',
        comment => $_[0],
    };
}

sub upto
{
    my $self = shift;
    my $up   = shift;

    $up && $up->add( error=>$self );
}

##
## OBJECT PROPERTIES
##

sub text
{
    my $self = shift;
    my $text = '';

    for( @{$self->{list}} )
    {
        $text .= sprintf "%s: %s->%s(): %s\n",
            $_->{type}, $_->{class}, $_->{sub}, $_->{comment};
    }

    return $text;
}

sub any   { defined $_[0]->{list} && scalar @{$_[0]->{list}}; }
sub fatal { $_[0]->{fatal}; }
