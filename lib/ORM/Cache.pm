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

package ORM::Cache;

$VERSION = 0.8;

use Scalar::Util 'weaken';

my $cache_hit = 0;
my $cache_all = 0;

sub new
{
    my $class = shift;
    my %arg   = @_;
    my $self  =
    {
        hash  => {},
        array => [],
        ptr   => 0,
        size  => int( $arg{size}||0 ),
    };

    bless $self, $class;
    $self->{array}[$self->size-1] = undef if( $self->size );

    return $self;
}

##
## PROPERTIES
##

sub size { $_[0]->{size}; }
sub total_efficiency { $cache_hit / $cache_all; }

sub get
{
    my $self = shift;
    my $id   = shift;
    my $hit  = shift;
    my $obj = $self->{hash}{$id};

    $hit = 1 unless( defined $hit );

    $cache_hit+=$hit if( $obj );
    $cache_all++;

    return $obj;
}

##
## METHODS
##

sub add
{
    my $self = shift;
    my $obj  = shift;
    my $id   = $obj && $obj->id;

    if( $id && !$self->{hash}{$id} )
    {
        if( $self->{size} )
        {
            $self->{array}[$self->{ptr}] = $obj;
            $self->{ptr} = ( $self->{ptr} + 1 ) % $self->{size};
        }
        $self->{hash}{$id} = $obj;
        weaken $self->{hash}{$id};
    }
}

sub delete
{
    my $self = shift;
    my $obj  = shift;

    $obj && $obj->id && delete $self->{hash}{$obj->id};
}

sub clear_stat
{
    $cache_hit = 0;
    $cache_all = 0;
}

sub change_size
{
    my $self     = shift;
    my $new_size = int shift;

    $new_size = 0 if( $new_size < 0 );

    if( $new_size > $self->size )
    {
        $self->{size} = $new_size;
        $self->{array}[$new_size-1] = undef;
    }
    elsif( $new_size < $self->size )
    {
        $self->{size} = $new_size;
        $self->{ptr}  = 0 if( $self->{ptr} >= $new_size );
        splice @{$self->{array}}, $new_size;
    }
}

1;
