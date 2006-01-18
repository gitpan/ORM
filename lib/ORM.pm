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

package ORM;

use 5.008001;
use strict;
use warnings;
use Carp;
use Scalar::Util 'weaken';

use ORM::Error;
use ORM::Cache;
use ORM::Broken;
use ORM::Date;
use ORM::Datetime;
use ORM::Ta;
use ORM::Const;
use ORM::Ident;
use ORM::Expr;
use ORM::Order;
use ORM::Metaprop;
use ORM::MetapropBuilder;
use ORM::ResultSet;
use ORM::StatResultSet;

our $VERSION  = 0.81;

my $initialized;
my $db;
my $ta;

my $history_class;
my $prefer_lazy_load;
my $emulate_foreign_keys;
my $default_cache_size;

my %hier = ();

##
## CONSTRUCTORS
##

## use: $obj = $class->new
## (
##     prop      => { prop => [string|OBJECT] ... },
##     error     => ORM::Error,
##     temporary => boolean,
##     suspended => boolean,
##     history   => boolean,
## )
##
## 'temporary' - if set to true, then created object will
##     not be stored in database.
##     You can store that kind of objects later using method
##     $object->make_permanent.
##
## 'suspended' - if set to true, then constructor's behavior
##     is similar to those with 'temporary'=1 but after creation
##     object appended to the internal list of suspended objects.
##
##     Later you can flush all suspended objects into database
##     at one time by calling $class->flush_suspended. This allows to
##     optimize write of objects into database by means of database
##     server, e.g. ORM::Db::DBI::MySQL storage engine will use
##     multiple-rows form of INSERT statement:
##
##     INSERT INTO table (a,b,c) VALUES (1,1,1),(2,2,2),(3,3,3)...
##
sub new
{
    my $class   = shift;
    my %arg     = @_;
    my $error   = ORM::Error->new;
    my $self    = {};
    my $history = defined $arg{history} ? $arg{history} : $class->history_is_enabled;

    if( $class->_is_intermediate )
    {
        $error->add_fatal( "Can't create instance of intermediate class" );
    }

    unless( $error->fatal )
    {
        my $prop;

        bless $self, $class;

        # Extract required DB properties from %arg
        for $prop ( $class->_not_mandatory_props )
        {
            $self->{_ORM_data}{$prop} = $self->_normalize_prop_to_db_value
            (
                name  => $prop,
                error => $error,
                value =>
                (
                    exists $arg{prop}{$prop}
                        ? $arg{prop}{$prop}
                        : $class->_prop_default_value( $prop )
                ),
            );
        }
    }

    unless( $error->fatal )
    {
        # Check validity of object data
        $self->_validate_prop( prop=>$self->{_ORM_data}, error=>$error );
    }

    if( ! $arg{temporary} && ! $error->fatal )
    {
        $self->{_ORM_data}{id} = $db->insert_object
        (
            id     => $arg{repair_id},
            object => $self,
            error  => $error,
        );
        if( ! $error->fatal && ! $self->{_ORM_data}{id} )
        {
            $error->add_fatal( "Failed to detect id of newly created object of class '$class'" );
        }

        # Make record in history
        if( !$error->fatal && $history )
        {
            $history_class->new( obj=>$self, created=>1, error=>$error );
            $self->delete( error=>$error, history=>0 ) if( $error->fatal );
        }
    }

    $self->_cache->add( $self ) unless( $error->fatal );
    $arg{error} && $arg{error}->add( error=>$error );
    return $error->fatal ? undef : $self;
}

## use: $count = $class->count
## (
##     filter   => ORM::Filter,
##     error    => ORM::Error,
## )
##
sub count
{
    my $class = shift;
    $db->count( class=>$class, @_ );
}

sub exists
{
    my $class = shift;
    my %arg  = @_;

    return $class->count
    (
        filter => ( $class->M->id == $arg{id} ),
        error  => $arg{error},
    );
}

## use: @obj = $class->find
## (
##     filter     => ORM::Filter,
##     order      => ORM::Order,
##     lazy_load  => boolean,
##     page       => integer,
##     pagesize   => integer,
##     error      => ORM::Error,
##     return_ref => boolean,
##     return_res => boolean,
## )
##
## If called in scalar context returns first object from result set.
##
## If called in array context returns array of found objects.
##
## If 'return_ref' is true then return value is reference to the array
## of found objects with no respect to context.
##
## If 'return_res' is true then return value is object of class ORM::ResultSet,
## found objects can be accesed one by one via $result->next. It is useful to
## retrieve large amount of objects. Pays no respect to context and 'return_ref'.
##
## If 'pagesize' and 'page' is specified then result set is divided to pages
## with 'pagesize' object per page and only page numbered 'page' will be returned.
## First page number is 1.
##
## If 'lazy_load' specified then only data from tables corresponding to base class
## $class will be loaded initially.
##
sub find
{
    my $class     = shift;
    my %arg       = @_;
    my $error     = ORM::Error->new;
    my $page      = defined $arg{page} && int( $arg{page} );
    my $pagesize  = defined $arg{pagesize} && int( $arg{pagesize} );
    my $lazy_load = defined $arg{lazy_load} ? $arg{lazy_load} : $class->prefer_lazy_load;
    my $order     = ( ref $arg{order} eq 'ARRAY' ) ? ORM::Order->new( @{$arg{order}} ) : $arg{order};
    my @obj;
    my $res;

    if( !wantarray && !$arg{return_ref} && !$arg{return_res} )
    {
        $page     = ($page-1)*$pagesize+1;
        $pagesize = 1;
    }

    if( $class->_is_sealed || $lazy_load || $arg{return_res} )
    {
        $res = ORM::ResultSet->new
        (
            class  => $class,
            result => $db->select_base
            (
                class    => $class,
                filter   => $arg{filter},
                order    => $order,
                page     => $page,
                pagesize => $pagesize,
                error    => $error,
            ),
        );
        unless( $arg{return_res} || $error->fatal )
        {
            my $obj;
            while( $obj = $res->next ) { push @obj, $obj; }
        }
    }
    else
    {
        $res = $db->select_full
        (
            class    => $class,
            filter   => $arg{filter},
            order    => $order,
            page     => $page,
            pagesize => $pagesize,
            error    => $error,
        );
        unless( $error->fatal )
        {
            my $data;
            my $obj;
            while( $data = $res->next_row )
            {
                if( ref $data eq 'HASH' )
                {
                    $obj = bless { _ORM_data=>$data }, $data->{class};
                    delete $obj->{_ORM_data}{class};
                    $class->_cache->add( $obj );
                }
                else
                {
                    $obj = $data;
                }
                push @obj, $obj;
            }
        }
    }

    $arg{error} && $arg{error}->add( error=>$error );
    
    return
        $arg{return_res}
            ? $res
            : ( $arg{return_ref} ? \@obj : ( wantarray ? ( @obj ) : $obj[0] ) );
}

## use: $obj = $class->find_id
## (
##     id        => integer,
##     lazy_load => boolean,
##     error     => ORM::Error,
## );
##
## In this context 'lazy_load' means that object will
## not be loaded at all. Loading of object data
## will be delayed until its properties will be demanded.
##
## find_id() with 'lazy_load' mostly useful when utilized
## by ORM->stat().
##
## Если параметр lazy_load == undef, по умолчанию происходит
## полная загрузка объекта, независимо от значения свойства
## prefer_lazy_load().
##
## При использовании find_id() с параметром 'lazy_load' важно помнить
## об отсутствии возможности определить фактический класс объекта
## во время конструирования, поэтому объект создается как представитель
## класса $class, для которого был вызван find_id().
## В последствии при явном или неявном вызове finish_loading()
## класс объекта меняется на фактический, до этого момента Вы можете
## работать с объектом только как с представителем класса $class.
##
## finish_loading() вызывается неявно в методе update() и при вызове
## свойства, находящегося в незагруженной таблице.
##
sub find_id
{
    my $class = shift;
    my %arg   = @_;
    my $self;

    $self = $class->_cache->get( $arg{id} );

    unless( $self )
    {
        $self = { _ORM_data=>{ id=>$arg{id} } };
        for my $table ( $class->_db_tables )
        {
            if( scalar $class->_db_table_fields( $table ) )
            {
                $self->{_ORM_missing_tables}{$table} = 1;
            }
        }
        bless $self, $class;

        unless( $arg{lazy_load} )
        {
            my $error = ORM::Error->new;
            $self->finish_loading( error=>$error );
            $self = undef if( ref $self eq 'ORM::Broken' || $error->fatal );
            $arg{error} && $arg{error}->add( error=>$error );
        }

        $self && $class->_cache->add( $self );
    }

    return $self;
}

## use: $obj = $class->find_or_new
## (
##     prop      => { prop_name => [string|OBJECT] ... },
##     lazy_load => boolean,
##     history   => boolean,
##     error     => ORM::Error,
## )
##
sub find_or_new
{
    my $class     = shift;
    my %arg       = @_;
    my $error     = ORM::Error->new;
    my $filter    = ORM::Expr->_and;
    my @obj;

    for my $prop ( keys %{$arg{prop}} )
    {
        if( $class->_has_prop( $prop ) )
        {
            $filter->add_expr( $class->M->_prop( $prop ) == $arg{prop}{$prop} );
        }
        else
        {
            $error->add_fatal( "Non-existing prop '$prop' specified" );
            last;
        }
    }

    unless( $error->fatal )
    {
        @obj = $class->find
        (
            filter    => $filter,
            error     => $error,
            pagesize  => 2,
            lazy_load => $arg{lazy_load},
        );
    }
    unless( $error->fatal )
    {
        if( @obj > 1 )
        {
            $error->add_fatal( "More than 1 object were found" );
        }
    }
    unless( $error->fatal )
    {
        if( ! @obj )
        {
            $obj[0] = $class->new( prop=>$arg{prop}, history=>$arg{history}, error=>$error );
        }
    }

    $arg{error} && $arg{error}->add( error=>$error );
    return $error->fatal ? undef : $obj[0];
}

##
## OBJECT METHODS
##

## use: $ta = $class->new_transaction( error=>ORM::Error );
##
## Begins transaction.
## Transaction will commit when object $ta will be destroyed.
##
sub new_transaction
{
    my $self = shift;
    my %arg  = @_;
    my $my_ta;

    if( $ta )
    {
        $my_ta = ORM::Ta->new;
    }
    else
    {
        $my_ta = ORM::Ta->new( db=>$db, error=>$arg{error} );
        $ta    = $my_ta;
        weaken $ta;
    }

    return $my_ta;
}

## use: $self->update
## (
##     prop     => HASH,
##     old_prop => HASH,
##     history  => boolean,
##     error    => ORM::Error,
## )
##
sub update
{
    my $self     = shift;
    my $class    = ref $self;
    my %arg      = @_;
    my $error    = ORM::Error->new;
    my $history  = defined $arg{history} ? $arg{history} : $class->history_is_enabled;
    my %changed_prop;
    my %expr_prop;
    my %old_prop;

    $self->finish_loading( error=>$error );

    # Check if current properties match to those in 'old_prop' argument
    unless( $error->fatal )
    {
        %old_prop = %{$self->{_ORM_data}};
        if( $arg{old_prop} )
        {
            for my $prop ( keys %{$arg{old_prop}} )
            {
                my $old_normalized = $self->_normalize_prop_to_db_value
                (
                    name  => $prop,
                    value => $arg{old_prop}{$prop},
                    error => $error,
                );
                last if( $error->fatal );
                if( $self->_values_are_not_equal( $self->{_ORM_data}{$prop}, $old_normalized ) )
                {
                    $error->add_fatal
                    (
                        'Current properties of object #'.$self->id
                        . ' of class "'.$class.'" do not match '
                        . 'properties assumed by user',
                    );
                    last;
                }
            }
        }
    }

    # Detect data changes
    unless( $error->fatal )
    {
        for my $prop ( $class->_not_mandatory_props )
        {
            if( exists $arg{prop}{$prop} )
            {
                if( UNIVERSAL::isa( $arg{prop}{$prop}, 'ORM::Expr' ) )
                {
                    $expr_prop{$prop} = $arg{prop}{$prop};
                }
                else
                {
                    my $new_normalized = $self->_normalize_prop_to_db_value
                    (
                        name  => $prop,
                        value => $arg{prop}{$prop},
                        error => $error,
                    );
                    last if( $error->fatal );
                    if( $self->_values_are_not_equal( $self->{_ORM_data}{$prop}, $new_normalized ) )
                    {
                        $changed_prop{$prop} = 1;
                        $self->{_ORM_data}{$prop} = $new_normalized;
                        delete $self->{_ORM_cache}{$prop};
                    }
                }
            }
        }
    }
    # User validations
    unless( $error->fatal )
    {
        $self->_validate_prop( prop=>\%changed_prop, error=>$error );
    }
    # Detect data changes again to consider changes in _validate_prop
    unless( $error->fatal )
    {
        %changed_prop = ();
        for my $prop ( $class->_not_mandatory_props )
        {
            if( $self->_values_are_not_equal( $old_prop{$prop}, $self->{_ORM_data}{$prop} ) )
            {
                $changed_prop{$prop} = $self->{_ORM_data}{$prop};
                delete $expr_prop{$prop} if( exists $expr_prop{$prop} );
            }
            elsif( exists $expr_prop{$prop} )
            {
                $changed_prop{$prop} = $expr_prop{$prop};
            }
        }
    }

    if( $self->id && !$error->fatal && scalar( %changed_prop ) )
    {
        for my $prop ( keys %expr_prop )
        {
            $self->{_ORM_missing_tables}{ $class->_prop2table($prop) }{$prop} = 1;
        }

        # Update object
        unless( $error->fatal )
        {
            $db->update_object
            (
                object     => $self,
                values     => \%changed_prop,
                old_values => \%old_prop,
                error      => $error,
            );
        }

        # Save changes to history
        if( $history && !$error->fatal )
        {
            $self->finish_loading( error=>$error );
        }
        if( $history && !$error->fatal )
        {
            my %history;
            for my $prop_name ( keys %changed_prop )
            {
                $history{$prop_name} =
                [
                    $old_prop{$prop_name},
                    $self->{_ORM_data}{$prop_name}
                ];
            }
            $history_class->new
            (
                error   => $error,
                obj     => $self,
                changed => \%history,
            );
        }
    }

    if( $error->fatal )
    {
        # Roll back update action if error occured
        $self->{_ORM_data} = \%old_prop;
    }

    $arg{error} && $arg{error}->add( error=>$error );
    return undef;
}

## use: $self->delete( error=>ORM::Error, history=>boolean )
##
sub delete
{
    my $self    = shift;
    my $class   = ref $self;
    my %arg     = @_;
    my $error   = ORM::Error->new;
    my $history = defined $arg{history} ? $arg{history} : $class->history_is_enabled;

    if( $self->id )
    {
        unless( $error->fatal )
        {
            # Make record in history
            if( $history )
            {
                $history_class->new( obj=>$self, deleted=>1, error=>$error );
            }
        }
        unless( $error->fatal )
        {
            $db->delete_object
            (
                object => $self,
                error  => $error,
                emulate_foreign_keys => $emulate_foreign_keys,
            );
        }
        unless( $error->fatal )
        {
            $self->_rebless_to_broken( deleted=>1 );
        }
    }

    $arg{error} && $arg{error}->add( error=>$error );
    return undef;
}

## use: $object->refresh( error=>ORM::Error );
##
sub refresh
{
    my $self  = shift;
    my $class = ref $self;
    my %arg   = @_;

    $self->{_ORM_data} = { id=>$self->id };
    delete $self->{_ORM_cache};
    for my $table ( $class->_db_tables )
    {
        if( scalar $class->_db_table_fields( $table ) )
        {
            $self->{_ORM_missing_tables}{$table} = 1;
        }
    }

    $self->finish_loading( error=>$arg{error} );
}

## use: $object->finish_loading
## or
## use: $object->finish_loading( error=>ORM::Error );
##
## First form will rebless object to 'ORM::Broken' in case of error.
##
sub finish_loading
{
    my $self       = shift;
    my $class      = ref $self;
    my %arg        = @_;
    my $new_class;
    my $prop       = $arg{prop};
    my $prop_table = $prop && $class->_prop2table( $prop );

    if
    (
        exists $self->{_ORM_missing_tables}
        &&
        (
            ! defined $prop
            ||
            (
                defined $prop_table
                && $self->{_ORM_missing_tables}{$prop_table}
                &&
                (
                    !( ref $self->{_ORM_missing_tables}{$prop_table} eq 'HASH' )
                    || $self->{_ORM_missing_tables}{$prop_table}{$prop}
                )
            )
        )
    )
    {
        my $error = ORM::Error->new;
        my $data  = $db->select_tables
        (
            id     => $self->id,
            tables => $self->{_ORM_missing_tables},
            error  => $error,
        );

        $data = $data && $data->next_row;

        if( $error->fatal )
        {
            if( $arg{error} )
            {
                $arg{error}->add( error=>$error );
            }
            else
            {
                $self->_rebless_to_broken( error=>$error );
            }
        }
        elsif( !$data )
        {
            $self->_rebless_to_broken( deleted=>1 );
        }
        else
        {
            delete $self->{_ORM_missing_tables};

            # Fetch loaded properties
            if( exists $data->{class} )
            {
                $new_class = $data->{class};
                delete $data->{class};
            }
            for my $prop ( keys %$data )
            {
                $self->{_ORM_data}{$prop} = $data->{$prop};
            }
        }
    }

    # If actual class of object is different than blessed class,
    # then rebless object and upload residual tables if needed
    if( $new_class && $new_class ne $class )
    {
        $class->_load_ORM_class( $new_class );
        bless $self, $new_class;

        my $base_class_tables = $class->_db_tables_count;
        my $class_tables      = $new_class->_db_tables_count;

        for( my $i=$base_class_tables; $i<$class_tables; $i++ )
        {
            $self->{_ORM_missing_tables}{$new_class->_db_table($i)} = 1;
        }

        $self->finish_loading( error=>$arg{error} ) unless( defined $prop );
    }
}

##
## PROPERTIES
##

sub id           { $_[0]->{_ORM_data}{id}; }
sub class        { ref $_[0] || $_[0]; }
sub is_temporary { ! $_[0]->{_ORM_data}{id}; }

sub __ORM_db_value { $_[0]->{_ORM_data}{id}; }
sub __ORM_new_db_value
{
    my $class = shift;
    my %arg   = @_;
    my $self;

    if( defined $arg{value} )
    {
        $self = $class->find_id( id=>$arg{value}, error=>$arg{error}, lazy_load=>$arg{lazy_load} );
    }

    return $self;
}

sub base_class
{
    my $class = ref $_[0] ? ref shift : shift;
    $hier{$class}{BASE_CLASS}
}

sub primary_class
{
    my $class = ref $_[0] ? ref shift : shift;
    $hier{$class}{PRIMARY_CLASS}
}

sub initial_class
{
    my $class = ref $_[0] ? ref shift : shift;
    $hier{$class}{INITIAL_CLASS}
}

sub M
{
    my $self  = shift;
    my $class = ref $self || $self;
    my $prop  = shift;

    if( $prop )
    {
        ORM::Metaprop->_new( prop_class=>$class, prop=>$prop );
    }
    else
    {
        ORM::Metaprop->_new_flat( class=>$class );
    }
}

## use: $value = -$object->P( error=>$error )->prop1->prop2->prop3;
##
sub P
{
    my $self  = shift;
    my %arg   = @_;

    ORM::MetapropBuilder->new
    (
        prop_class => (ref $self),
        need_value => $self,
        error      => $arg{error},
    );
}

sub metaprop_class
{
    my $self  = shift;
    my $class = ( ref $self ) || $self;

    return $hier{$class}{METAPROP_CLASS};
}

sub ql { $db->ql( $_[1] ); }
sub qc { $db->qc( $_[1] ); }
sub qi { $db->qi( $_[1] ); }
sub qt { $db->qt( $_[1] ); }
sub qf { $db->qf( $_[1] ); }
sub _db { $db; }
sub _history_class { $history_class; }

## use: $state = $class->history_is_enabled;
## use: $state = $class->history_is_enabled( $new_state );
##
## If $new_state is specified then value of flag
## 'history_is_enabled' will be replaced to $new_state.
## $new_state can be undef, in that case global default value
## will be used instead.
##
sub history_is_enabled
{
    my $class = shift;

    if( @_ )
    {
        if( defined $_[0] )
        {
            if( $hier{$class} )
            {
                $hier{$class}{HISTORY_IS_ENABLED} = $_[0];
            }
            else
            {
                croak "Can't change global history settings";
            }
        }
        else
        {
            delete $hier{$class}{HISTORY_IS_ENABLED} if( $hier{$class} );
        }
    }

    exists $hier{$class}{HISTORY_IS_ENABLED}
        ? $hier{$class}{HISTORY_IS_ENABLED}
        : $history_class;
}

## use: $state = $class->prefer_lazy_load;
## use: $state = $class->prefer_lazy_load( $new_state );
##
## If $new_state is specified then value of flag
## 'prefer_lazy_load' will be replaced to $new_state.
## $new_state can be undef, in that case global default value
## will be used instead.
##
sub prefer_lazy_load
{
    my $class = shift;

    if( @_ )
    {
        if( defined $_[0] )
        {
            $hier{$class}{PREFER_LAZY_LOAD} = $_[0];
        }
        else
        {
            delete $hier{$class}{PREFER_LAZY_LOAD};
        }
    }

    exists $hier{$class}{PREFER_LAZY_LOAD}
        ? $hier{$class}{PREFER_LAZY_LOAD}
        : $prefer_lazy_load;
}

sub _plain_prop
{
    my $class = shift;
    my $prop  = shift;

    exists( $hier{$class}{PROP}{$prop} )
        && ( ! $hier{$class}{PROP}{$prop} );
}
sub _prop_is_ref
{
    my $class  = shift;
    my $prop   = shift;
    my $pclass = $class->_prop_class( $prop );

    $pclass && $hier{$pclass} && $pclass;
}

sub _is_sealed                { $hier{ref $_[0]||$_[0]}{SEALED}; }
sub _prop_class               { $hier{$_[0]}{PROP}{$_[1]}; }
sub _prop_default_value       { $hier{$_[0]}{PROP_DEFAULT_VALUE}{$_[1]}; }
sub _has_prop                 { exists $hier{$_[0]}{PROP}{$_[1]}; }
sub _prop2table               { $hier{$_[0]}{PROP2TABLE_MAP}{$_[1]}; }
sub _prop2field               { $hier{$_[0]}{PROP2FIELD_MAP}{$_[1]}; }
sub _is_intermediate          { $hier{$_[0]}{INTERMEDIATE}; }
sub _is_initial               { !$hier{$_[0]}; }
sub _db_table                 { $hier{$_[0]}{TABLE}[$_[1]]; }
sub _db_tables_str            { $hier{$_[0]}{TABLES_STR}; }
sub _db_tables_count          { scalar( @{$hier{$_[0]}{TABLE}} ); }
sub _db_tables                { @{$hier{$_[0]}{TABLE}}; }
sub _db_tables_ref            { $hier{$_[0]}{TABLE}; }
sub _db_table_fields          { keys %{$hier{$_[0]}{TABLE_STRUCT}{$_[1]}}; }
sub _db_tables_inner_join     { $hier{$_[0]}{TABLES_INNER_JOIN}; }
sub _not_mandatory_props      { keys %{$hier{$_[0]}{PROP2FIELD_MAP}}; }
sub _all_props                { ( 'id', 'class', keys %{$hier{$_[0]}{PROP2FIELD_MAP}} ); }
sub _cache                    { $hier{( ref $_[0] || $_[0] )->primary_class}{CACHE}; }

sub _rev_refs
{
    my $class = shift;
    my @refs  = values %{$hier{$class}{REV_REFS}};

    if( $hier{$class}{BASE_CLASS} )
    {
        push @refs, $hier{$class}{BASE_CLASS}->_rev_refs;
    }

    return @refs;
}

sub _has_rev_ref
{
    my $class     = shift;
    my $rev_class = shift;
    my $rev_prop  = shift;

    $hier{$class}{REV_REFS}{ $rev_class.' '.$rev_prop }
    || (
        $rev_class->base_class
        && $class->_has_rev_ref( $rev_class->base_class, $rev_prop )
    )
    || (
        $class->base_class
        && $class->base_class->_has_rev_ref( $rev_class, $rev_prop )
    );
}

## use: $class->stat
## (
##     data        => { alias=>ORM::Expr, ... },
##     preload     => { alias=>boolean, ... },
##     filter      => ORM::Expr,
##     group_by    => [ ORM::Ident|ORM::Metaprop, ... ],
##     post_filter => ORM::Expr,
##     order       => ORM::Order,
##     lazy_load   => boolean,
##     page        => integer,
##     pagesize    => integer,
##     count       => boolean,
##     error       => ORM::Error,
##     return_res  => boolean,
## )
##
## Если 'count' установлен, то результатом выполнения
## метода будет количество строк в статистике а не
## сама статистика. page и pagesize не имеют смысла
## при установленном count.
##
sub stat
{
    my $class    = shift;
    my %arg      = @_;
    my $error    = ORM::Error->new;
    my $page     = defined $arg{page}     && int( $arg{page} );
    my $pagesize = defined $arg{pagesize} && int( $arg{pagesize} );
    my $order    = ( ref $arg{order} eq 'ARRAY' ) ? ORM::Order->new( @{$arg{order}} ) : $arg{order};
    my %preload  = $arg{preload} ? %{$arg{preload}} : ();
    my %data;
    my %conv;
    my $res;

    if( ! %{$arg{data}} )
    {
        $error->add_fatal( "'data' argument is missing" );
    }

    unless( $error->fatal )
    {
        # Prepare type converstions
        if( $arg{count} )
        {
            %data = %{$arg{data}};
        }
        elsif( %preload )
        {
            for my $name ( keys %{$arg{data}} )
            {
                if( ! UNIVERSAL::isa( $arg{data}{$name}, 'ORM::Metaprop' ) )
                {
                    $conv{$name} = undef;
                    $data{$name} = $arg{data}{$name};
                    delete $preload{$name};
                }
                elsif( $arg{data}{$name}->_prop_ref_class && $preload{$name} )
                {
                    $conv{$name} = $arg{data}{$name}->_prop_class;
                    for my $prop ( $arg{data}{$name}->_prop_ref_class->_all_props )
                    {
                        if( $prop eq 'id' )
                        {
                            $data{$name} = $arg{data}{$name}->_prop( $prop );
                        }
                        else
                        {
                            $data{"_${name} ${prop}"} = $arg{data}{$name}->_prop( $prop );
                        }
                    }
                }
                else
                {
                    $conv{$name} = $arg{data}{$name}->_prop_class;
                    $data{$name} = $arg{data}{$name};
                    delete $preload{$name};
                }
            }
        }
        else
        {
            %data = %{$arg{data}};
            for my $name ( keys %data )
            {
                if
                (
                    UNIVERSAL::isa( $data{$name}, 'ORM::Metaprop' )
                    && $data{$name}->_prop_class
                )
                {
                    $conv{$name} = $data{$name}->_prop_class;
                }
                else
                {
                    $conv{$name} = undef;
                }
            }
        }

        # Fetch result set
        $res = $db->select_stat
        (
            class       => $class,
            data        => \%data,
            filter      => $arg{filter},
            post_filter => $arg{post_filter},
            group_by    => $arg{group_by},
            order       => $order,
            page        => $page,
            pagesize    => $pagesize,
            error       => $error,
        );
    }

    if( $res && !$error->fatal )
    {
        if( $arg{count} )
        {
            $res = $res->rows;
        }
        else
        {
            $res = ORM::StatResultSet->new
            (
                class     => $class,
                result    => $res,
                preload   => \%preload,
                conv      => \%conv,
                lazy_load => $arg{lazy_load},
            );
            if( !$arg{return_res} )
            {
                my @stat;
                my $stat;

                while( $stat = $res->next( error=>$error ) )
                {
                    if( $error->fatal )
                    {
                        @stat = ();
                        last;
                    }
                    push @stat, $stat;
                }

                $res = \@stat;
            }
        }
    }

    $arg{error} && $arg{error}->add( error=>$error );
    return $res;
}

## use: $prop = $obj->_property
## (
##     name     => string,
##     error    => ORM::Error,
## );
##
## 'name'   - is name of the property corresponding to field name in DB table
##
## $prop    - is either plain property,
##            either object referenced by id in DB,
##            or object referenced by value in DB
##
sub _property
{
    my $self   = shift;
    my %arg    = ( @_ == 1 ) ? () : @_;
    my $prop   = ( @_ == 1 ) ? $_[0] : $arg{name};
    my $class  = ref $self;
    my $error  = ORM::Error->new;
    my $res;
    my $pclass;


    if( exists $arg{new_value} )
    {
        $self->update( prop=>{ $prop=>$arg{new_value} }, error=>$error );
    }
    else
    {
        if( exists $self->{_ORM_missing_tables} )
        {
            $self->finish_loading( prop=>$prop, error=>$error );
        }

        unless( $error->fatal )
        { 
            if( $prop eq 'class' && $class->_is_sealed )
            {
                $res = $class;
            }
            elsif( $class->_plain_prop( $prop ) )
            {
                $res = $self->{_ORM_data}{$prop};
            }
            elsif( $pclass = $class->_prop_class( $prop ) )
            {
                if( defined $self->{_ORM_data}{$prop} )
                {
                    unless( exists $self->{_ORM_cache}{$prop} )
                    {
                         $self->{_ORM_cache}{$prop} = $pclass->__ORM_new_db_value
                         (  
                            value => $self->{_ORM_data}{$prop},
                            error => $error,
                         );
                    }
                    $res = $self->{_ORM_cache}{$prop};
                }
            }
        }
    }

    $arg{error} && $arg{error}->add( error=>$error );
    return $res;
}

## use: $prop = $obj->_property_id
## (
##     name     => string,
##     error    => ORM::Error,
## );
##
## 'name'   - is name of the property corresponding to field name in DB table
##
## $prop    - is either plain property,
##            either object referenced by id in DB,
##            or object referenced by value in DB
##
sub _property_id
{
    my $self   = shift;
    my %arg;
    my $prop;

    if( @_ == 1 )
    {
        $prop = $_[0];
    }
    else
    {
        %arg = @_;
        $prop = $arg{name};
    }

    if( exists $self->{_ORM_missing_tables} )
    {
        $self->finish_loading( prop=>$prop, error=>$arg{error} )
    }

    return $self->{_ORM_data}{$prop};
}

sub _rev_prop
{
    my $self      = shift;
    my $rev_class = shift;
    my $rev_prop  = shift;
    my %arg       = @_;

    if( (ref $self)->_has_rev_ref( $rev_class, $rev_prop ) )
    {
        $arg{filter} = $arg{filter} & ( $rev_class->M->_prop( $rev_prop ) == $self );
        $rev_class->find( %arg );
    }
}

sub _rev_prop_count
{
    my $self      = shift;
    my $rev_class = shift;
    my $rev_prop  = shift;
    my %arg       = @_;

    if( (ref $self)->_has_rev_ref( $rev_class, $rev_prop ) )
    {
        $arg{filter} = $arg{filter} & ( $rev_class->M->_prop( $rev_prop ) == $self );
        $rev_class->count( %arg );
    }
}

## use: $prop = $obj->prop( error=>ORM::Error, new_value=>SCALAR );
##
## 'prop' - is name of the property corresponding to field name in DB table
##
## If 'new_value' is specified, then $obj will be updated with this value
## and new value will be returned.
##
sub AUTOLOAD
{
    if( $ORM::AUTOLOAD =~ /^(.+)::(.+)$/ )
    {
        my $prop = $2;
        my $self = shift;
        my %arg  = @_;

        die "Called undefined static method '$ORM::AUTOLOAD' of class '$self'" unless( ref $self );

        $self->_property( name=>$prop, %arg );
    }
}

##
## CLASS METHODS
##

sub optimize_storage
{
    my $class = shift;
    $db->optimize_tables( class=>$class );
}

##
## PROTECTED METHODS
##

sub _find_constructor
{
    my $class = shift;
    my $prop  = shift;
    my $result_tables = shift;
    my $self;

    if( $prop->{id} )
    {
        if( $prop->{class} )
        {
            ORM->_load_ORM_class( $prop->{class} );
            $self = bless { _ORM_data => $prop }, $prop->{class};

            if( $result_tables )
            {
                my $class_tables_count  = $prop->{class}->_db_tables_count;
                my $loaded_tables_count = scalar( @$result_tables );
                for( my $i=$loaded_tables_count; $i<$class_tables_count; $i++ )
                {
                    $self->{_ORM_missing_tables}{$prop->{class}->_db_table($i)} = 1;
                }
            }

            delete $self->{_ORM_data}{class};
        }
        else
        {
            $self = bless { _ORM_data => $prop }, $class;
        }
    }

    return $self;
}

sub _rebless_to_broken
{
    my $self = shift;
    my %arg  = @_;
    
    $self->_cache->delete( $self );

    $self->{class}   = ref $self;
    $self->{id}      = $self->id;

    if( $arg{deleted} )
    {
        $self->{deleted} = 1;
    }
    elsif( $arg{error} && $arg{error}->fatal )
    {
        $self->{error} = $arg{error};
    }

    delete $self->{_ORM_data};
    delete $self->{_ORM_cache};
    delete $self->{_ORM_missing_tables};

    bless $self, 'ORM::Broken';
}

## use: $self->_normalize_prop_to_db_value( name=>STRING, value=>SCALAR, error=>ORM::Error )
##
## Приводит указанное пользователем (программистом) значение свойства
## к виду пригодному для хранения в базе данных.
##
## Все параметры обязательны.
##
sub _normalize_prop_to_db_value
{
    my $self       = shift;
    my $class      = ref $self;
    my %arg        = @_;
    my $error      = ORM::Error->new;
    my $prop_name  = $arg{name};
    my $prop_value = $arg{value};
    my $prop_ref   = ref $prop_value;

    if( ! $class->_has_prop( $prop_name ) )
    {
        $error->add_fatal( "Superfluous property '$prop_name'" );
    }
    elsif( $class->_plain_prop( $prop_name ) )
    {
        if( $prop_ref )
        {
            $error->add_fatal
            (
                "Property '$prop_name' should be scalar, not reference"
            );
        }
    }
    elsif( $class->_prop_is_ref( $prop_name ) )
    {
        if( ! defined $prop_value )
        {
            # leave NULL value
        }
        elsif( ! $prop_ref )
        {
            my $obj = $class->_prop_class( $prop_name )->exists
            (
                id     => $prop_value,
                error  => $error,
            );
            unless( $obj )
            {
                $error->add_fatal
                (
                    "Property '$prop_name' of type '"
                    . $class->_prop_class( $prop_name )
                    . "' with id='$prop_value' was not found"
                );
            }
        }
        elsif( UNIVERSAL::isa( $prop_ref, $class->_prop_class( $prop_name ) ) )
        {
            $prop_value = $prop_value->id;
        }
        else
        {
            $error->add_fatal
            (
                "Property '$prop_name' should be of type "
                . "'" . $class->_prop_class( $prop_name ) . "' not '"
                . (ref $prop_value) . "'"
            );
        }
    }
    else # if( $class->_prop_class( $prop_name ) && ! $class->_prop_is_ref( $prop_name ) )
    {
        if( ! defined $prop_value )
        {
            # leave undef value
        }
        elsif( ! $prop_ref )
        {
            my $obj = $class->_prop_class( $prop_name )->__ORM_new_db_value
            (
                value => $prop_value,
                error => $error,
            );
            $prop_value = $obj ? $obj->__ORM_db_value : undef;
        }
        elsif( UNIVERSAL::isa( $prop_ref, $class->_prop_class( $prop_name ) ) )
        {
            $prop_value = $prop_value->__ORM_db_value;
        }
        else
        {
            $error->add_fatal
            (
                "Property '$prop_name' should be of type "
                . "'" . $class->_prop_class( $prop_name ) . "' not '"
                . (ref $prop_value) . "'"
            );
        }
    }

    $arg{error}->add( error=>$error );
    return $arg{error}->fatal ? undef : $prop_value;
}

## use: $self->_validate_prop( prop=>HASH, error=>ORM::Error )
##
## Проверяет допустимость значений свойств объекта,
## и корректирует их автоматически если это возможно.
##
## Свойство 'error' - обязательно.
## свойство 'prop' должно содержать ссылку на хеш, ключами которого
## являются имена свойств объекта, подлежащих проверке.
##
## Этот метод автоматически вызывается методами new и update,
## и не должен явно вызываться из других мест.
## При переопределении метода _validate_prop в наследуемых
## классах обязательно вызывайте из него метод базового
## класса $self->SUPER::_validate_prop(...).
##
sub _validate_prop {}

## use: $self->_fix_prop( prop=>HASH, error=>ORM::Error )
##
## May be called from _validate_prop to change values of
## properties before commiting them to database.
##
sub _fix_prop
{
    my $self  = shift;
    my %arg   = @_;
    my $error = ORM::Error->new;

    for my $prop ( keys %{$arg{prop}} )
    {
        if( (ref $self)->_has_prop( $prop ) )
        {
            delete $self->{_ORM_cache}{$prop};
            $self->{_ORM_data}{$prop} = $self->_normalize_prop_to_db_value
            (
                name  => $prop,
                value => $arg{prop}{$prop},
                error => $error,
            );
        }
    }

    $arg{error} && $arg{error}->add( error=>$error );
    return undef;
}

## use: ORM->_init
## (
##     db                   => ORM::Db,
##     history_class        => string||undef,
##     prefer_lazy_load     => boolean,
##     emulate_foreign_keys => boolean,
## )
##
## _init вызывается в дочернем инициализирующем классе от
## которого в последствии наследуются все классы модели.
##
sub _init
{
    my $class = shift;
    my %arg   = @_;

    if( $initialized )
    {
        die "At present it is imposible to derive more that one control class from ORM";
    }
    else
    {
        die "'db' argument not specified"                   unless( exists $arg{db} );
        die "'db' argument is specified but undefined"      unless( $arg{db} );
        die "'db' argument specified is not descendant of 'ORM::Db'" unless( UNIVERSAL::isa( $arg{db}, 'ORM::Db' ) );
        die "'prefer_lazy_load' argument not specified"     unless( exists $arg{prefer_lazy_load} );
        die "'emulate_foreign_keys' argument not specified" unless( exists $arg{emulate_foreign_keys} );
        die "'default_cache_size' argument not specified" unless( exists $arg{default_cache_size} );

        $initialized = 1;

        $db                   = $arg{db};
        $history_class        = $arg{history_class};
        $prefer_lazy_load     = $arg{prefer_lazy_load};
        $emulate_foreign_keys = $arg{emulate_foreign_keys};
        $default_cache_size   = $arg{default_cache_size};
    }
}

## use: $base_class->_derive
## (
##     derived_class      => string,
##     intermediate       => boolean,
##     table              => string,
##
##     history_is_enabled => boolean,
##     prefer_lazy_load   => boolean,
## )
##
## Should be called in BEGIN{...} of every derived class
##
sub _derive
{
    my $class   = shift;
    my %arg     = @_;
    my $error   = ORM::Error->new;
    my $base    = $hier{$class};
    my $derived;
    my $struct;
    my $defaults;
    my $table;

    $derived = $hier{$arg{derived_class}} = {};

    # Copy SQL configuration from base class
    if( $base )
    {
        if( $class->_is_sealed )
        {
            $error->add_fatal
            (
                "You cannot create class derived from '$class'"
                . " because '$class' is sealed. If you want to derive"
                . " from '$class' you should add column 'class' to"
                . " table '".$class->_db_table(0)."' and fill it with"
                . " '$class' values."
            );
        }
        else
        {
            $derived->{BASE_CLASS}            = $class;
            $derived->{INITIAL_CLASS}         = $base->{INITIAL_CLASS};
            $derived->{PRIMARY_CLASS}         = $base->{PRIMARY_CLASS};
            $derived->{TABLES_STR}            = $base->{TABLES_STR};
            $derived->{TABLES_INNER_JOIN}     = $base->{TABLES_INNER_JOIN};
            %{$derived->{PROP2FIELD_MAP}}     = %{$base->{PROP2FIELD_MAP}};
            %{$derived->{PROP2TABLE_MAP}}     = %{$base->{PROP2TABLE_MAP}};
            %{$derived->{TABLE_STRUCT}}       = %{$base->{TABLE_STRUCT}};
            %{$derived->{PROP}}               = %{$base->{PROP}};
            %{$derived->{PROP_DEFAULT_VALUE}} = %{$base->{PROP_DEFAULT_VALUE}};
            @{$derived->{TABLE}}              = @{$base->{TABLE}};
        }
    }
    else
    {
        $derived->{INITIAL_CLASS} = $class;
        $derived->{PRIMARY_CLASS} = $arg{derived_class};
        $derived->{CACHE}         = ORM::Cache->new( size=>($arg{cache_size}||$default_cache_size) );
    }

    unless( $error->fatal )
    {
        $derived->{REV_REFS}     = {};
        $derived->{INTERMEDIATE} = $arg{intermediate};

        # History configuration
        if( exists $arg{history_is_enabled} )
        {
            $derived->{HISTORY_IS_ENABLED} = $arg{history_is_enabled};
        }
        elsif( exists $base->{HISTORY_IS_ENABLED} )
        {
            $derived->{HISTORY_IS_ENABLED} = $base->{HISTORY_IS_ENABLED};
        }

        # Lazy load configuration
        if( exists $arg{prefer_lazy_load} )
        {
            $derived->{PREFER_LAZY_LOAD} = $arg{prefer_lazy_load};
        }
            
        # Detect db table name
        $table = $arg{table} || $class->_guess_table_name( $arg{derived_class} );
    }

    if( $table )
    {
        ( $struct, $defaults ) = $db->table_struct
        (
            class => $arg{derived_class},
            table => $table,
            error => $error,
        );
        if( $history_class && $arg{derived_class} eq $history_class )
        {
            $struct->{slaved_by} = $history_class;
        }
        # Check whether table exists
        if( ! scalar( %$struct ) )
        {
            $error->add_fatal
            (
                "Table '$table' for class '$arg{derived_class}' not found."
            );
            $table = undef;
        }
    }
    if( $table )
    {
        # Check whether table format is correct
        unless( $error->fatal )
        {
            if( ! exists $struct->{id} )
            {
                $error->add_fatal( "Table '$table' should contain 'id' column" );
            }
        }
        unless( $error->fatal )
        {
            if
            (
                $class->_class_is_primary( $arg{derived_class} )
                && ! exists $struct->{class}
            )
            {
                $derived->{SEALED} = 1;
            }
        }
        # Initialize $derived->{TABLES_INNER_JOIN}
        unless( $error->fatal )
        {
            if( !$class->_class_is_primary( $arg{derived_class} ) )
            {
                $derived->{TABLES_INNER_JOIN} .= ' AND ' if( $derived->{TABLES_INNER_JOIN} );
                $derived->{TABLES_INNER_JOIN} .=
                    $db->qt( $table ).'.id = '.$db->qt( $derived->{TABLE}[0] ).'.id';
            }
        }
        # Initialize
        #   $derived->{PROP},
        #   $derived->{PROP_DEFAULT_VALUE},
        #   $derived->{PROP2FIELD_MAP},
        #   $derived->{PROP2TABLE_MAP}
        unless( $error->fatal )
        {
            my $prop;
            for $prop ( keys %$struct )
            {
                $derived->{PROP}{$prop}               = $struct->{$prop};
                $derived->{PROP_DEFAULT_VALUE}{$prop} = $defaults->{$prop};
            }

            $derived->{PROP2TABLE_MAP}{id} = $table unless( $derived->{PROP2TABLE_MAP}{id} );
            delete $struct->{id};

            for my $field ( keys %$struct )
            {
                unless( $derived->{PROP2FIELD_MAP}{$field} )
                {
                    $derived->{PROP2TABLE_MAP}{$field} = $table;
                    if( $field ne 'class' )
                    {
                        $derived->{PROP2FIELD_MAP}{$field} =
                            $db->qt( $table ) . '.' . $db->qf( $field );
                    }
                }
                else
                {
                    $error->add_fatal
                    (
                        "Duplicate columns "
                        . "'$derived->{PROP2FIELD_MAP}{$field}',"
                        . " '".$db->qt($table).'.'.$db->qf($field)."'"
                    );
                    last;
                }
            }
        }
        # Initialize
        #   $derived->{TABLE},
        #   $derived->{TABLE_STR},
        #   $derived->{TABLE_STRUCT},
        delete $struct->{class};
        unless( $error->fatal )
        {
            if( !$class->_class_is_primary( $arg{derived_class} ) )
            {
                $derived->{TABLES_STR} .= ',';
            }
            $derived->{TABLES_STR} .= $db->qt( $table );
            $derived->{TABLE_STRUCT}{$table} = $struct;
            push @{$derived->{TABLE}}, $table;
        }
    }

    unless( $error->fatal )
    {
        # Load self metaprop class
        $derived->{METAPROP_CLASS} = "ORM::Meta::$arg{derived_class}";
        if( ! eval "require $derived->{METAPROP_CLASS}" )
        {
            if( $derived->{BASE_CLASS} )
            {
                $derived->{METAPROP_CLASS} = $base->{METAPROP_CLASS};
            }
            else
            {
                $derived->{METAPROP_CLASS} = 'ORM::Metaprop';
            }
        }
    }

    my %require;

    unless( $error->fatal )
    {
        # Load referenced and referencing classes
        # and initialize reverse props
        for my $prop ( keys %{$derived->{TABLE_STRUCT}{$table}} )
        {
            my $pclass = $derived->{PROP}{$prop};
            if( $pclass && !$hier{$pclass} )
            {
                $require{$pclass} = 1;
            }
        }
        for my $pclass ( $db->referencing_classes( class=>$arg{derived_class}, error=>$error ) )
        {
            $require{$pclass->{class}} = 1 unless( $hier{$pclass->{class}} );
            $derived->{REV_REFS}{ $pclass->{class}.' '.$pclass->{prop} }
                = [ $pclass->{class}, $pclass->{prop} ];
        }
        ## Этот кусок кода нужен только для исполнения в среде mod_perl,
        ## В остальных случаях он не имеет эффекта.
        ##
        ## Если Вы написали новый ORM-класс имеющий ссылочные свовйства,
        ## то классы на которые ссылаются свойства не будут об этом знать,
        ## т.е. они не переопределят свои _rev_refs если не перезапустить
        ## httpd. Этот код позволяет избежать проблемы.
        ##
        for my $prop ( keys %{$derived->{TABLE_STRUCT}{$table}} )
        {
            my $pclass = $derived->{PROP}{$prop};
            my $key    = "$arg{derived_class} $prop";
            if( $pclass && $hier{$pclass} && !$hier{$pclass}{REV_REFS}{$key} )
            {
                $hier{$pclass}->{REV_REFS}{$key} = [ $arg{derived_class}, $prop ];
            }
        }

        # Load metaclasses of not ORM classes
        for my $prop ( keys %{$derived->{TABLE_STRUCT}{$table}} )
        {
            my $pclass = $derived->{PROP}{$prop};
            if( $pclass && !$hier{$pclass} )
            {
                ORM::Metaprop->_class2metaclass( $pclass );
            }
        }
    }

    # Print error message and exit if necessary
    die $error->text if( $error->any );

    return keys %require;
}

##
## PRIVATE METHODS
##

sub _values_are_not_equal
{
    my $self = shift;
    my $val1 = shift;
    my $val2 = shift;

    ( ( defined $val1 ) xor ( defined $val2 ) )
    || ( defined $val1 && defined $val2 && ( $val1 ne $val2 ) );
}

##
## METHODS AND PROPERTIES TO USE VIA CLASS INITIALISATION
## (ORM->_derive)
##

sub _class_is_primary         { ! exists $hier{ $_[1] }{TABLE}; }

## use: $table_name = $class->_guess_table_name( $obj_class );
##
sub _guess_table_name
{
    my $class = shift;
    my $table = shift;

    $table =~ s/::/__/g;

    return $table;
}

## use: $prop_class = $class->_db_type_to_class( $db_field_name, $db_type_name );
##
sub _db_type_to_class
{
    my $class = shift;
    my $field = shift;
    my $type  = shift;
    my $prop_class;

    ## These classes will be used by default for columns
    ## of type 'date' and 'datetime' in database.
    ##
    ## '__ORM_new_db_value' method of classes should
    ## be able to return object constructed by value
    ## of 'time' function.
    ##
    ## This means:
    ##
    ## $class->__ORM_new_db_value( value=>1125850389 )->__ORM_db_value
    ## should return '2005-09-04 22:13:09'
    ##
    if( ( lc $type ) eq 'date' )
    {
        $prop_class = 'ORM::Date';
    }
    elsif( ( lc $type ) eq 'datetime' )
    {
        $prop_class = 'ORM::Datetime';
    }

    return $prop_class;
}

## use: $class->_load_ORM_class( $class );
##
sub _load_ORM_class
{
    my $class      = shift;
    my $load_class = shift;

    unless( $hier{$load_class} )
    {
        $load_class .= '.pm';
        $load_class  =~ s(::)(/)g;
        require $load_class;
    }
}

sub DESTROY
{
    $_[0]->_cache && $_[0]->_cache->delete( $_[0] );
}

1;
__END__
