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

package ORM::Stat;

use ORM::Error;

$VERSION = 0.8;

sub new
{
    my $class = shift;
    my %arg   = @_;
    my $self;

    $self =
    {
        class         => $arg{class},
        data          => $arg{data},
        filter        => $arg{filter},
        group_by      => $arg{group_by},
        default_order => $arg{default_order},
    };

    bless $self, $class;
}

sub find
{
    my $class = shift;
    my %arg   = @_;
    my $error = ORM::Error->new;

    my $obj = $class->stat_class->stat
    (
        data        => $class->data,
        filter      => $class->filter,
        group_by    => $class->group_by,

        post_filter => $arg{filter},
        order       => ($arg{order}||$class->default_order),
        page        => $arg{page},
        pagesize    => $arg{pagesize},
        error       => $error,
        debug       => $arg{debug},
    );

    unless( $error->fatal )
    {
        for( my $i=$#$obj; $i>=0; $i-- )
        {
            bless $obj->[$i], $class;
        }
    }

    $arg{error} && $arg{error}->add( error=>$error );
    return $error->fatal ? undef : (wantarray ? @$obj : $obj);
}

sub count
{
    my $class = shift;
    my %arg   = @_;
    my $error = ORM::Error->new;
    my $count;

    my $count = $class->stat_class->stat
    (
        data        => $class->data,
        filter      => $class->filter,
        group_by    => $class->group_by,
        post_filter => $arg{filter},
        count       => 1,
        error       => $error,
        debug       => $arg{debug},
    );

    $arg{error} && $arg{error}->add( error=>$error );
    return $count;
}

sub _all_props
{
    my $class = shift;
    keys %{$class->data};
}

sub _property
{
    my $self = shift;
    my $prop = shift;

    $self->{$prop};
}

sub _property_id
{
    my $self = shift;
    my $prop = shift;

    ref $self->{$prop} ? $self->{$prop}->__ORM_db_value : $self->{$prop};
}

sub AUTOLOAD
{
    if( $AUTOLOAD =~ /^(.+)::(.+)$/ )
    {
        my $prop = $2;
        my $self = shift;

        $self->_property( $prop );
    }
}

1;
